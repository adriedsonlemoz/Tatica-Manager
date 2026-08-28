import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/career_controller.dart';
import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../data/competition_catalog.dart';
import '../../domain/career/manager_profile.dart';
import '../../domain/club/club.dart';
import '../../domain/club/club_identity.dart';
import '../../domain/club/club_logo_pack.dart';
import '../../domain/player/player.dart';
import '../../game/club/club_identity_engine.dart';
import '../../game/club/club_logo_pack_engine.dart';
import '../../game/club/club_logo_pack_importer.dart';
import '../../game/club/club_pack_importer.dart';
import 'competition_browser_widgets.dart';
import 'kit_editor_screen.dart';
import 'manager_database_editor_screen.dart';
import 'roster_editor_screen.dart';

part 'club_detail_editor_screen.dart';
part 'club_editor_widgets.dart';

class ClubEditorScreen extends ConsumerStatefulWidget {
  const ClubEditorScreen({
    super.key,
    this.careerId,
    this.careerName,
  });

  final String? careerId;
  final String? careerName;

  bool get editsDefaultPack => careerId == null;

  @override
  ConsumerState<ClubEditorScreen> createState() => _ClubEditorScreenState();
}

class _ClubEditorScreenState extends ConsumerState<ClubEditorScreen> {
  ClubIdentityPack? _pack;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  bool _dirty = false;
  CompetitionBrowserLevel _browserLevel = CompetitionBrowserLevel.country;

  static const _logoPackTypes = XTypeGroup(
    label: 'Pack de escudos Tática Manager',
    extensions: ['json', 'tmlogos'],
    mimeTypes: ['application/json', 'application/octet-stream'],
    uniformTypeIdentifiers: ['public.json', 'public.data'],
  );

  static const _fileTypes = XTypeGroup(
    label: 'Pacote completo Tática Manager',
    extensions: ['json', 'tmclubs', 'tmpack', 'xml'],
    mimeTypes: ['application/json', 'application/xml', 'text/xml', 'application/octet-stream'],
    uniformTypeIdentifiers: ['public.json', 'public.data'],
  );

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    try {
      final pack = await ref
          .read(careerControllerProvider.notifier)
          .loadClubIdentityPack(careerId: widget.careerId);
      if (!mounted) return;
      setState(() {
        _pack = pack;
        _loading = false;
        _error = null;
        _dirty = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _friendlyError(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.editsDefaultPack ? 'Editor do banco' : 'Editor da carreira';
    final subtitle = widget.editsDefaultPack
        ? 'Padrão para novas carreiras'
        : widget.careerName ?? 'Personalização do save';

    return PremiumScaffold(
      appBar: GameTopBar(title: title, subtitle: subtitle),
      safeBottom: true,
      bottomNavigationBar: _pack == null
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: FilledButton.icon(
                onPressed: _saving || !_dirty ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(_saving ? 'Salvando...' : 'Salvar alterações'),
              ),
            ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null && _pack == null) {
      return EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Não foi possível abrir o editor',
        text: _error!,
      );
    }
    final pack = _pack!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.dataset_outlined, color: AppColors.green),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.editsDefaultPack
                          ? 'Edite o banco que será usado por todas as novas carreiras.'
                          : 'As mudanças afetam somente esta carreira.',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.editsDefaultPack
                    ? 'IDs internos não são editáveis. Você pode personalizar identidade, '
                        'estádio, uniformes, ícone, jogadores e técnicos, além de importar bancos '
                        'criados pela comunidade.'
                    : 'Em saves existentes, IDs e quantidade de jogadores são preservados. '
                        'Dados transitórios da carreira, como estatísticas, lesões e cartões, '
                        'não são apagados pelo editor.',
                style: TextStyle(color: AppColors.muted, height: 1.4),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _saving ? null : _importPack,
                      icon: const Icon(Icons.file_open_rounded),
                      label: const Text('Importar pacote completo'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _saving ? null : _restoreDefaults,
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('Usar padrão'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _saving ? null : _importLogoPack,
                  icon: const Icon(Icons.collections_rounded),
                  label: const Text('Importar somente escudos'),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Pacote completo: clubes + jogadores + técnicos + escudos. '
                'Também é possível importar apenas escudos por ID permanente. '
                'Limite de 8 MiB por arquivo.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          _InlineMessage(text: _error!, error: true),
        ],
        const SizedBox(height: 12),
        SectionCard(
          padding: EdgeInsets.zero,
          child: ListTile(
            onTap: _saving ? null : _editManagers,
            leading: const Icon(Icons.sports_rounded, color: AppColors.green),
            title: const Text('Técnicos', style: TextStyle(fontWeight: FontWeight.w900)),
            subtitle: Text('${pack.managers?.length ?? 0} técnicos • criar, editar, importar e exportar'),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
        ),
        const SizedBox(height: 8),
        SectionCard(
          padding: EdgeInsets.zero,
          child: ListTile(
            onTap: _saving ? null : _editFreeAgents,
            leading: const Icon(Icons.groups_2_outlined, color: AppColors.green),
            title: const Text('Jogadores livres', style: TextStyle(fontWeight: FontWeight.w900)),
            subtitle: Text('${pack.freeAgents?.length ?? 0} atletas disponíveis no banco'),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
        ),
        const SizedBox(height: 14),
        CompetitionBreadcrumb(
          level: _browserLevel,
          country: CompetitionCatalog.brazil.name,
          championship: CompetitionCatalog.brazil.championships.first.name,
          series: CompetitionCatalog.brazil.championships.first.series.first.name,
          onNavigate: (level) => setState(() => _browserLevel = level),
        ),
        const SizedBox(height: 10),
        ..._competitionStage(pack),
      ],
    );
  }


  List<Widget> _competitionStage(ClubIdentityPack pack) {
    final country = CompetitionCatalog.brazil;
    final championship = country.championships.first;
    final series = championship.series.first;
    return switch (_browserLevel) {
      CompetitionBrowserLevel.country => [
          CompetitionStageTile(
            icon: Icons.public_rounded,
            title: country.name,
            subtitle: '${country.championships.length} campeonato disponível',
            onTap: () => setState(() => _browserLevel = CompetitionBrowserLevel.championship),
          ),
        ],
      CompetitionBrowserLevel.championship => [
          CompetitionStageTile(
            icon: Icons.emoji_events_outlined,
            title: championship.name,
            subtitle: '${championship.series.length} série disponível',
            onTap: () => setState(() => _browserLevel = CompetitionBrowserLevel.series),
          ),
        ],
      CompetitionBrowserLevel.series => [
          CompetitionStageTile(
            icon: Icons.sports_soccer_rounded,
            title: series.name,
            subtitle: '${series.clubIds.length} clubes',
            onTap: () => setState(() => _browserLevel = CompetitionBrowserLevel.clubs),
          ),
        ],
      CompetitionBrowserLevel.clubs => [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${series.name.toUpperCase()} • CLUBES',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Text('${series.clubIds.length} equipes', style: const TextStyle(color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 8),
          ...series.clubIds.map((clubId) {
            final identity = pack.clubs.firstWhere((club) => club.clubId == clubId);
            return Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _ClubIdentityTile(
                identity: identity,
                onTap: _saving ? null : () => _editClub(identity),
              ),
            );
          }),
        ],
    };
  }

  Future<void> _editClub(ClubIdentity identity) async {
    final result = await Navigator.of(context).push<ClubIdentity>(
      MaterialPageRoute(
        builder: (_) => _ClubDetailEditorScreen(
          identity: identity,
          currentPack: _pack!,
          allowRosterStructureChanges: widget.editsDefaultPack,
        ),
      ),
    );
    if (result == null || !mounted) return;
    try {
      final clubs = _pack!.clubs
          .map((item) => item.clubId == result.clubId ? result : item)
          .toList(growable: false);
      final normalized = ClubIdentityEngine.normalizeAndValidatePack(
        ClubIdentityPack(
          name: _pack!.name,
          author: _pack!.author,
          clubs: clubs,
          freeAgents: _pack!.freeAgents,
          managers: _pack!.managers,
        ),
        expectedIds: _pack!.clubs.map((item) => item.clubId),
        fallbackPack: _pack,
      );
      setState(() {
        _pack = normalized;
        _dirty = true;
        _error = null;
      });
    } catch (error) {
      setState(() => _error = _friendlyError(error));
    }
  }

  Future<void> _editManagers() async {
    final result = await Navigator.of(context).push<List<ManagerProfile>>(
      MaterialPageRoute(
        builder: (_) => ManagerDatabaseEditorScreen(
          pack: _pack!,
        ),
      ),
    );
    if (result == null || !mounted) return;
    try {
      final normalized = ClubIdentityEngine.normalizeAndValidatePack(
        ClubIdentityPack(
          name: _pack!.name,
          author: _pack!.author,
          clubs: _pack!.clubs,
          freeAgents: _pack!.freeAgents,
          managers: result,
        ),
        expectedIds: _pack!.clubs.map((item) => item.clubId),
        fallbackPack: _pack,
      );
      setState(() {
        _pack = normalized;
        _dirty = true;
        _error = null;
      });
    } catch (error) {
      setState(() => _error = _friendlyError(error));
    }
  }

  Future<void> _editFreeAgents() async {
    final result = await Navigator.of(context).push<List<Player>>(
      MaterialPageRoute(
        builder: (_) => RosterEditorScreen(
          title: 'Banco de jogadores livres',
          players: _pack!.freeAgents ?? const <Player>[],
          currentPack: _pack!,
          allowStructureChanges: widget.editsDefaultPack,
          freeAgents: true,
        ),
      ),
    );
    if (result == null || !mounted) return;
    try {
      final normalized = ClubIdentityEngine.normalizeAndValidatePack(
        ClubIdentityPack(
          name: _pack!.name,
          author: _pack!.author,
          clubs: _pack!.clubs,
          freeAgents: result,
          managers: _pack!.managers,
        ),
        expectedIds: _pack!.clubs.map((item) => item.clubId),
        fallbackPack: _pack,
      );
      setState(() {
        _pack = normalized;
        _dirty = true;
        _error = null;
      });
    } catch (error) {
      setState(() => _error = _friendlyError(error));
    }
  }

  Future<void> _importPack() async {
    try {
      final file = await openFile(acceptedTypeGroups: const [_fileTypes]);
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
      setState(() {
        _pack = normalized;
        _dirty = true;
        _error = null;
      });
      final playerCount = _allPlayerIds(normalized).length;
      final logoCount = normalized.clubs.where((club) => club.iconBase64?.isNotEmpty == true).length;
      _show(
        'Pacote “${normalized.name}” carregado: ${normalized.clubs.length} clubes, '
        '$playerCount jogadores, ${normalized.managers?.length ?? 0} técnicos e '
        '$logoCount escudos. Revise e toque em Salvar alterações.',
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(error));
    }
  }

  Future<bool?> _confirmFullPackImport(ClubIdentityPack pack) {
    final playerCount = _allPlayerIds(pack).length;
    final logoCount = pack.clubs
        .where((club) => club.iconBase64?.isNotEmpty == true)
        .length;
    final managerCount = pack.managers?.length ?? 0;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.inventory_2_rounded, color: AppColors.green, size: 42),
        title: const Text('Importar pacote completo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pack.name, style: const TextStyle(fontWeight: FontWeight.w900)),
            if (pack.author?.isNotEmpty == true) ...[
              const SizedBox(height: 3),
              Text('Por ${pack.author}', style: const TextStyle(color: AppColors.muted)),
            ],
            const SizedBox(height: 12),
            _PackSummaryRow(icon: Icons.shield_outlined, label: 'Clubes', value: '${pack.clubs.length}'),
            _PackSummaryRow(icon: Icons.groups_2_outlined, label: 'Jogadores', value: '$playerCount'),
            _PackSummaryRow(icon: Icons.sports_rounded, label: 'Técnicos', value: '$managerCount'),
            _PackSummaryRow(icon: Icons.image_outlined, label: 'Escudos', value: '$logoCount'),
            const SizedBox(height: 10),
            const Text(
              'Clubes, elencos, técnicos e escudos são aplicados juntos usando os IDs '
              'internos permanentes. Em uma carreira existente, os IDs de jogadores '
              'continuam obrigatoriamente preservados.',
              style: TextStyle(color: AppColors.muted, height: 1.35),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.download_done_rounded),
            label: const Text('Carregar pacote'),
          ),
        ],
      ),
    );
  }

  Future<void> _importLogoPack() async {
    try {
      final file = await openFile(acceptedTypeGroups: const [_logoPackTypes]);
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
      final confirmed = await _confirmLogoPackImport(
        pack: normalized,
        current: current,
        proposed: proposed,
      );
      if (confirmed != true || !mounted) return;
      setState(() {
        _pack = proposed;
        _dirty = true;
        _error = null;
      });
      _show(
        '${normalized.logos.length} escudo(s) carregado(s). '
        'Revise e toque em Salvar alterações.',
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(error));
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
        icon: const Icon(Icons.collections_rounded, color: AppColors.green, size: 42),
        title: const Text('Importar pack de escudos'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${pack.name} • ${pack.logos.length} escudo(s)',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              if (pack.author?.isNotEmpty == true) ...[
                const SizedBox(height: 3),
                Text('Por ${pack.author}', style: TextStyle(color: AppColors.muted)),
              ],
              const SizedBox(height: 8),
              Text(
                'A associação usa somente o ID permanente do clube. '
                'Nomes, elencos, uniformes, estádio e técnicos não serão alterados.',
                style: TextStyle(color: AppColors.muted, height: 1.35),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: (pack.logos.length * 72).clamp(120, 360).toDouble(),
                child: ListView.separated(
                  itemCount: pack.logos.length,
                  separatorBuilder: (_, _) => const Divider(height: 12),
                  itemBuilder: (context, index) {
                    final entry = pack.logos[index];
                    final before = currentById[entry.clubId]!;
                    final after = proposedById[entry.clubId]!;
                    return Row(
                      children: [
                        _ClubIdentityBadge(identity: before, size: 40),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.arrow_forward_rounded, size: 18),
                        ),
                        _ClubIdentityBadge(identity: after, size: 40),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.label?.isNotEmpty == true ? entry.label! : before.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                              Text(
                                '${before.name} • ${entry.clubId}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.muted),
                              ),
                            ],
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.check_rounded),
            label: const Text('Aplicar escudos'),
          ),
        ],
      ),
    );
  }

  void _restoreDefaults() {
    try {
      final defaults = ClubIdentityEngine.normalizeAndValidatePack(
        ClubIdentityEngine.defaultPack(),
        expectedIds: _pack!.clubs.map((item) => item.clubId),
      );
      if (!widget.editsDefaultPack) {
        final currentIds = _allPlayerIds(_pack!);
        final defaultIds = _allPlayerIds(defaults);
        if (currentIds.length != defaultIds.length ||
            !currentIds.every(defaultIds.contains)) {
          throw const FormatException(
            'O padrão atual usa IDs de jogadores diferentes deste save. '
            'Restaure o banco padrão somente antes de criar uma carreira.',
          );
        }
      }
      setState(() {
        _pack = defaults;
        _dirty = true;
        _error = null;
      });
    } catch (error) {
      setState(() => _error = _friendlyError(error));
    }
  }

  Future<void> _save() async {
    final pack = _pack;
    if (pack == null || _saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(careerControllerProvider.notifier).saveClubIdentityPack(
            careerId: widget.careerId,
            pack: pack,
          );
      if (!mounted) return;
      setState(() {
        _saving = false;
        _dirty = false;
      });
      await _showSaveConfirmation(
        widget.editsDefaultPack
            ? 'Banco padrão atualizado para as próximas carreiras.'
            : 'Banco desta carreira atualizado.',
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = _friendlyError(error);
      });
    }
  }


  Future<void> _showSaveConfirmation(String message) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 42),
        title: const Text('Alterações salvas'),
        content: Text(message, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Set<String> _allPlayerIds(ClubIdentityPack pack) => {
        for (final club in pack.clubs)
          for (final player in club.players ?? const <Player>[]) player.id,
        for (final player in pack.freeAgents ?? const <Player>[]) player.id,
      };

  void _show(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  static String _friendlyError(Object error) {
    if (error is FormatException) return error.message.toString();
    final text = error.toString();
    return text.startsWith('Bad state: ') ? text.substring(11) : text;
  }
}

class _PackSummaryRow extends StatelessWidget {
  const _PackSummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.green),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
      );
}
