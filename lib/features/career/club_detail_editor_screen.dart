part of 'club_editor_screen.dart';

class _ClubDetailEditorScreen extends StatefulWidget {
  const _ClubDetailEditorScreen({
    required this.identity,
    required this.currentPack,
    required this.allowRosterStructureChanges,
  });

  final ClubIdentity identity;
  final ClubIdentityPack currentPack;
  final bool allowRosterStructureChanges;

  @override
  State<_ClubDetailEditorScreen> createState() => _ClubDetailEditorScreenState();
}

class _ClubDetailEditorScreenState extends State<_ClubDetailEditorScreen> {
  late ClubIdentity _identity;
  String? _error;

  static const _imageTypes = XTypeGroup(
    label: 'Imagem do escudo',
    extensions: ['png', 'jpg', 'jpeg', 'webp'],
    mimeTypes: ['image/png', 'image/jpeg', 'image/webp'],
    uniformTypeIdentifiers: ['public.png', 'public.jpeg', 'org.webmproject.webp'],
  );

  @override
  void initState() {
    super.initState();
    _identity = widget.identity;
  }

  @override
  Widget build(BuildContext context) => PremiumScaffold(
        appBar: GameTopBar(
          title: _identity.name,
          subtitle: 'ID permanente: ${_identity.clubId}',
          actions: [
            IconButton(
              tooltip: 'Aplicar clube',
              onPressed: () => Navigator.pop(context, _identity),
              icon: const Icon(Icons.check_rounded),
            ),
          ],
        ),
        safeBottom: true,
        body: ListView(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
          children: [
            SectionCard(
              child: Row(
                children: [
                  _ClubIdentityBadge(identity: _identity, size: 72),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_identity.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                        const SizedBox(height: 4),
                        Text(
                          '${_identity.nickname} • ${_identity.shortName}',
                          style: TextStyle(color: AppColors.muted),
                        ),
                        const SizedBox(height: 4),
                        Text(_identity.stadium?.name ?? 'Estádio', style: TextStyle(color: AppColors.muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              _InlineMessage(text: _error!, error: true),
            ],
            const SizedBox(height: 12),
            _EditorMenuTile(
              icon: Icons.badge_outlined,
              title: 'Nome e apelido',
              subtitle: 'Nome completo, apelido e sigla',
              onTap: _editIdentity,
            ),
            _EditorMenuTile(
              icon: Icons.stadium_outlined,
              title: 'Estádio',
              subtitle: '${_identity.stadium?.name} • ${_identity.stadium?.capacity ?? 0} lugares',
              onTap: _editStadium,
            ),
            _EditorMenuTile(
              icon: Icons.checkroom_outlined,
              title: 'Uniformes',
              subtitle: 'Principal, visitante, terceiro uniforme e padrões',
              onTap: _editKits,
            ),
            _EditorMenuTile(
              icon: Icons.shield_outlined,
              title: 'Ícone / escudo',
              subtitle: _identity.iconBase64?.isNotEmpty == true
                  ? 'Imagem personalizada carregada'
                  : 'Usando sigla e cores',
              onTap: _editIcon,
            ),
            _EditorMenuTile(
              icon: Icons.groups_rounded,
              title: 'Jogadores',
              subtitle: '${_identity.players?.length ?? 0} atletas • números, overall, atributos e contratos',
              onTap: _editPlayers,
            ),
          ],
        ),
      );

  Future<void> _editIdentity() async {
    final result = await showDialog<ClubIdentity>(
      context: context,
      builder: (context) => _ClubIdentityDialog(identity: _identity),
    );
    if (result != null) setState(() => _identity = result);
  }

  Future<void> _editStadium() async {
    final result = await showDialog<Stadium>(
      context: context,
      builder: (context) => _StadiumDialog(stadium: _identity.stadium!),
    );
    if (result != null) setState(() => _identity = _identity.copyWith(stadium: result));
  }

  Future<void> _editKits() async {
    final result = await Navigator.of(context).push<KitSetResult>(
      MaterialPageRoute(
        builder: (_) => KitSetEditorScreen(
          homeKit: _identity.homeKit!,
          awayKit: _identity.awayKit!,
          thirdKit: _identity.thirdKit!,
          clubName: _identity.name,
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _identity = _identity.copyWith(
        colors: ClubColors(
          primaryHex: result.home.primaryHex,
          secondaryHex: result.home.secondaryHex,
        ),
        homeKit: result.home,
        awayKit: result.away,
        thirdKit: result.third,
      );
    });
  }

  Future<void> _editIcon() async {
    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.shield_outlined, color: AppColors.green, size: 40),
        title: const Text('Ícone / escudo'),
        content: const Text(
          'Escolha uma imagem do aparelho. Formatos aceitos: PNG, JPG e WebP, '
          '32–1024 px e com até 256 KiB.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          if (_identity.iconBase64?.isNotEmpty == true)
            TextButton.icon(
              onPressed: () => Navigator.pop(context, 'remove'),
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
              label: const Text('Remover'),
            ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, 'select'),
            icon: const Icon(Icons.image_outlined),
            label: const Text('Escolher imagem'),
          ),
        ],
      ),
    );
    if (action == 'remove') {
      setState(() => _identity = _identity.copyWith(clearIcon: true));
      return;
    }
    if (action != 'select') return;
    try {
      final file = await openFile(acceptedTypeGroups: const [_imageTypes]);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      ClubIconValidator.validateBytes(bytes);
      setState(() {
        _identity = _identity.copyWith(iconBase64: base64Encode(bytes));
        _error = null;
      });
    } catch (error) {
      setState(() => _error = _ClubEditorScreenState._friendlyError(error));
    }
  }

  Future<void> _editPlayers() async {
    final temporaryPack = ClubIdentityPack(
      name: widget.currentPack.name,
      author: widget.currentPack.author,
      clubs: widget.currentPack.clubs
          .map((club) => club.clubId == _identity.clubId ? _identity : club)
          .toList(growable: false),
      freeAgents: widget.currentPack.freeAgents,
    );
    final result = await Navigator.of(context).push<List<Player>>(
      MaterialPageRoute(
        builder: (_) => RosterEditorScreen(
          title: _identity.name,
          clubId: _identity.clubId,
          players: _identity.players ?? const <Player>[],
          currentPack: temporaryPack,
          allowStructureChanges: widget.allowRosterStructureChanges,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() => _identity = _identity.copyWith(players: result));
    }
  }
}
