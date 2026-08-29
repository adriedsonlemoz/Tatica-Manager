part of 'club_editor_screen.dart';

extension _ClubEditorImportActions on _ClubEditorScreenState {
  Future<void> _importPack() async {
    try {
      final file = await openFile(acceptedTypeGroups: const [_ClubEditorScreenState._fileTypes]);
      if (file == null) return;
      final length = await file.length();
      if (length > 8 * 1024 * 1024) {
        throw const FormatException('O arquivo é grande demais. Limite: 8 MiB.');
      }
      final decoded = ClubPackImporter.decodeBytes(
        await file.readAsBytes(),
        fileName: file.name,
      );
      final normalized = ClubIdentityEngine.normalizeAndValidatePack(
        decoded,
        expectedIds: _pack!.clubs.map((item) => item.clubId),
        fallbackPack: _pack,
      );
      if (!widget.editsDefaultPack) {
        final currentIds = _allPlayerIds(_pack!);
        final importedIds = _allPlayerIds(normalized);
        if (currentIds.length != importedIds.length || !currentIds.every(importedIds.contains)) {
          throw const FormatException(
            'Esta carreira só aceita bancos que preservem exatamente os IDs atuais dos jogadores.',
          );
        }
      }
      if (!mounted) return;
      final confirmed = await _confirmFullPackImport(normalized);
      if (confirmed != true || !mounted) return;
      _updateEditorState(() {
        _pack = normalized;
        _dirty = true;
        _error = null;
      });
      final playerCount = _allPlayerIds(normalized).length;
      final logoCount = normalized.clubs.where((club) => club.iconBase64?.isNotEmpty == true).length;
      await showEditorNotice(
        context,
        title: 'Pacote carregado',
        message: '“${normalized.name}” está pronto para revisão. Foram carregados ${normalized.clubs.length} clubes, $playerCount jogadores, ${normalized.managers?.length ?? 0} técnicos e $logoCount escudos. Toque em Salvar alterações quando terminar.',
      );
    } catch (error, stack) {
      await DiagnosticService.instance.record(
        'EDITOR_PACK_IMPORT_ERROR',
        error,
        stack,
        'Falha ao importar um pacote completo na Central de Edição.',
      );
      if (!mounted) return;
      _updateEditorState(() => _error = _ClubEditorScreenState._friendlyError(error));
    }
  }

  Future<bool?> _confirmFullPackImport(ClubIdentityPack pack) {
    final playerCount = _allPlayerIds(pack).length;
    final logoCount = pack.clubs.where((club) => club.iconBase64?.isNotEmpty == true).length;
    final managerCount = pack.managers?.length ?? 0;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
        contentPadding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        icon: const Icon(Icons.inventory_2_rounded, color: AppColors.green, size: 40),
        title: const Text('Importar pacote completo'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pack.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              if (pack.author?.isNotEmpty == true)
                Text('Por ${pack.author}', style:  TextStyle(color: AppColors.muted, fontSize: 12)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _PackSummaryRow(icon: Icons.shield_outlined, label: 'Clubes', value: '${pack.clubs.length}'),
                    _PackSummaryRow(icon: Icons.groups_2_outlined, label: 'Jogadores', value: '$playerCount'),
                    _PackSummaryRow(icon: Icons.sports_rounded, label: 'Técnicos', value: '$managerCount'),
                    _PackSummaryRow(icon: Icons.image_outlined, label: 'Escudos', value: '$logoCount'),
                  ],
                ),
              ),
              const SizedBox(height: 9),
               Text(
                'Os dados serão preparados para revisão. Nada é gravado até você tocar em Salvar alterações. IDs internos permanentes são preservados.',
                style: TextStyle(color: AppColors.muted, height: 1.35, fontSize: 12.5),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.download_done_rounded),
            label: const Text('Carregar pacote'),
          ),
        ],
      ),
    );
  }

  Future<void> _importLogoPack() async {
    try {
      final file = await openFile(acceptedTypeGroups: const [_ClubEditorScreenState._logoPackTypes]);
      if (file == null) return;
      final length = await file.length();
      if (length > 8 * 1024 * 1024) {
        throw const FormatException('O pack de escudos é grande demais. Limite: 8 MiB.');
      }
      final current = _pack!;
      final decoded = ClubLogoPackImporter.decodeBytes(await file.readAsBytes());
      final normalized = ClubLogoPackEngine.normalizeAndValidate(
        decoded,
        expectedIds: current.clubs.map((club) => club.clubId),
      );
      final proposed = ClubLogoPackEngine.applyToIdentityPack(current, normalized);
      if (!mounted) return;
      final confirmed = await _confirmLogoPackImport(pack: normalized, current: current, proposed: proposed);
      if (confirmed != true || !mounted) return;
      _updateEditorState(() {
        _pack = proposed;
        _dirty = true;
        _error = null;
      });
      await showEditorNotice(
        context,
        title: 'Escudos carregados',
        message: '${normalized.logos.length} escudo(s) foram preparados. Revise os clubes e toque em Salvar alterações para gravar o novo banco.',
      );
    } catch (error, stack) {
      await DiagnosticService.instance.record(
        'EDITOR_LOGO_IMPORT_ERROR',
        error,
        stack,
        'Falha ao importar um pacote de escudos na Central de Edição.',
      );
      if (!mounted) return;
      _updateEditorState(() => _error = _ClubEditorScreenState._friendlyError(error));
    }
  }

  Future<bool?> _confirmLogoPackImport({
    required ClubLogoPack pack,
    required ClubIdentityPack current,
    required ClubIdentityPack proposed,
  }) {
    final currentById = {for (final club in current.clubs) club.clubId: club};
    final proposedById = {for (final club in proposed.clubs) club.clubId: club};
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
        icon: const Icon(Icons.collections_rounded, color: AppColors.green, size: 40),
        title: const Text('Importar pack de escudos'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${pack.name} • ${pack.logos.length} escudo(s)', style: const TextStyle(fontWeight: FontWeight.w900)),
              if (pack.author?.isNotEmpty == true)
                Text('Por ${pack.author}', style:  TextStyle(color: AppColors.muted)),
              const SizedBox(height: 7),
               Text(
                'Somente os escudos vinculados aos IDs permanentes serão alterados.',
                style: TextStyle(color: AppColors.muted, height: 1.35),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: (pack.logos.length * 64).clamp(110, 330).toDouble(),
                child: ListView.separated(
                  itemCount: pack.logos.length,
                  separatorBuilder: (_, _) => const Divider(height: 10),
                  itemBuilder: (context, index) {
                    final entry = pack.logos[index];
                    final before = currentById[entry.clubId]!;
                    final after = proposedById[entry.clubId]!;
                    return Row(
                      children: [
                        _ClubIdentityBadge(identity: before, size: 36),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 7),
                          child: Icon(Icons.arrow_forward_rounded, size: 17),
                        ),
                        _ClubIdentityBadge(identity: after, size: 36),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            entry.label?.isNotEmpty == true ? entry.label! : before.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.check_rounded),
            label: const Text('Aplicar escudos'),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreDefaults() async {
    final confirmed = await showEditorConfirmation(
      context,
      title: 'Restaurar dados padrão?',
      message: 'O banco original do Tática Manager substituirá todas as alterações ainda não salvas nesta tela. Você poderá revisar o resultado antes de salvar.',
      confirmLabel: 'Usar padrão',
      icon: Icons.restart_alt_rounded,
      accent: AppColors.warning,
    );
    if (!confirmed || !mounted) return;
    try {
      final defaults = ClubIdentityEngine.normalizeAndValidatePack(
        ClubIdentityEngine.defaultPack(),
        expectedIds: _pack!.clubs.map((item) => item.clubId),
      );
      if (!widget.editsDefaultPack) {
        final currentIds = _allPlayerIds(_pack!);
        final defaultIds = _allPlayerIds(defaults);
        if (currentIds.length != defaultIds.length || !currentIds.every(defaultIds.contains)) {
          throw const FormatException(
            'O padrão atual usa IDs de jogadores diferentes deste save. Restaure o banco padrão somente antes de criar uma carreira.',
          );
        }
      }
      _updateEditorState(() {
        _pack = defaults;
        _dirty = true;
        _error = null;
      });
      await showEditorNotice(
        context,
        title: 'Padrão preparado',
        message: 'Os dados originais foram restaurados para revisão. Toque em Salvar alterações para confirmar a mudança.',
        icon: Icons.restart_alt_rounded,
        accent: AppColors.warning,
      );
    } catch (error, stack) {
      await DiagnosticService.instance.record(
        'EDITOR_RESTORE_DEFAULT_ERROR',
        error,
        stack,
        'Falha ao preparar o banco padrão do editor.',
      );
      if (!mounted) return;
      _updateEditorState(() => _error = _ClubEditorScreenState._friendlyError(error));
    }
  }

  Future<void> _save() async {
    final pack = _pack;
    if (pack == null || _saving) return;
    _updateEditorState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(careerControllerProvider.notifier).saveClubIdentityPack(
            careerId: widget.careerId,
            pack: pack,
          );
      if (!mounted) return;
      _updateEditorState(() {
        _saving = false;
        _dirty = false;
      });
      await showEditorNotice(
        context,
        title: 'Alterações salvas',
        message: widget.editsDefaultPack
            ? 'Banco padrão atualizado para as próximas carreiras.'
            : 'Banco desta carreira atualizado.',
      );
    } catch (error, stack) {
      await DiagnosticService.instance.record(
        'EDITOR_SAVE_ERROR',
        error,
        stack,
        'Falha ao salvar as alterações do editor de dados.',
      );
      if (!mounted) return;
      _updateEditorState(() {
        _saving = false;
        _error = _ClubEditorScreenState._friendlyError(error);
      });
    }
  }

  Set<String> _allPlayerIds(ClubIdentityPack pack) => {
        for (final club in pack.clubs)
          for (final player in club.players ?? const <Player>[]) player.id,
        for (final player in pack.freeAgents ?? const <Player>[]) player.id,
      };
}
