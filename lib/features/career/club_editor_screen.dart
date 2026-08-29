import 'dart:convert' show base64Decode, base64Encode;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/career_controller.dart';
import '../../app/widgets/common.dart';
import '../../core/diagnostics/diagnostic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/competition_catalog.dart';
import '../../domain/career/manager_profile.dart';
import '../../domain/club/club.dart';
import '../../domain/club/club_identity.dart';
import '../../domain/club/club_logo_pack.dart';
import '../../domain/player/player.dart';
import '../../game/club/club_identity_engine.dart';
import '../../game/club/club_icon_validator.dart';
import '../../game/club/club_logo_pack_engine.dart';
import '../../game/club/club_logo_pack_importer.dart';
import '../../game/club/club_pack_importer.dart';
import 'competition_browser_widgets.dart';
import 'editor_feedback_dialog.dart';
import 'game_data_editor_tutorial_screen.dart';
import 'kit_editor_screen.dart';
import 'manager_database_editor_screen.dart';
import 'roster_editor_screen.dart';

part 'club_detail_editor_screen.dart';
part 'club_editor_import_actions.dart';
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

  void _updateEditorState(VoidCallback update) => setState(update);

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
    } catch (error, stack) {
      await DiagnosticService.instance.record(
        'EDITOR_LOAD_ERROR',
        error,
        stack,
        'Falha ao abrir o editor de dados do jogo.',
      );
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _friendlyError(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.editsDefaultPack ? 'Editar dados do jogo' : 'Editor da carreira';
    final subtitle = widget.editsDefaultPack
        ? 'Padrão para novas carreiras'
        : widget.careerName ?? 'Personalização do save';

    return PremiumScaffold(
      appBar: GameTopBar(
        title: title,
        subtitle: subtitle,
        actions: [
          IconButton(
            tooltip: 'Tutorial de edição',
            onPressed: _openTutorial,
            icon: const Icon(Icons.school_outlined),
          ),
        ],
      ),
      safeBottom: true,
      bottomNavigationBar: _pack == null
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: FilledButton.icon(
                onPressed: _saving || !_dirty ? null : _ClubEditorImportActions(this)._save,
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _EditorQuickAction(
                      icon: Icons.inventory_2_outlined,
                      label: 'Pacote',
                      tooltip: 'Importar pacote completo',
                      onTap: _saving ? null : _ClubEditorImportActions(this)._importPack,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _EditorQuickAction(
                      icon: Icons.restart_alt_rounded,
                      label: 'Padrão',
                      tooltip: 'Usar padrão original',
                      onTap: _saving ? null : _ClubEditorImportActions(this)._restoreDefaults,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _EditorQuickAction(
                      icon: Icons.collections_outlined,
                      label: 'Escudos',
                      tooltip: 'Importar somente escudos',
                      onTap: _saving ? null : _ClubEditorImportActions(this)._importLogoPack,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 15, color: AppColors.muted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Pacote completo inclui clubes, jogadores, técnicos e escudos. Limite: 8 MiB.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                    ),
                  ),
                ],
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

  Future<void> _openTutorial() => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const GameDataEditorTutorialScreen()),
      );

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
