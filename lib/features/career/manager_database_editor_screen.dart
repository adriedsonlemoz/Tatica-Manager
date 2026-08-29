import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../app/widgets/manager_avatar.dart';
import '../../core/diagnostics/diagnostic_platform.dart';
import '../../core/diagnostics/diagnostic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/country_catalog.dart';
import '../../domain/career/manager_appearance.dart';
import '../../domain/career/manager_profile.dart';
import '../../domain/club/club_identity.dart';
import '../../domain/formation/formation.dart';
import '../../domain/tactic/tactic.dart';
import '../../game/club/club_identity_engine.dart';
import 'editor_feedback_dialog.dart';
import 'manager_appearance_editor.dart';

part 'manager_editor_screen.dart';

class ManagerDatabaseEditorScreen extends StatefulWidget {
  const ManagerDatabaseEditorScreen({
    super.key,
    required this.pack,
  });

  final ClubIdentityPack pack;

  @override
  State<ManagerDatabaseEditorScreen> createState() =>
      _ManagerDatabaseEditorScreenState();
}

class _ManagerDatabaseEditorScreenState extends State<ManagerDatabaseEditorScreen> {
  static const _jsonType = XTypeGroup(
    label: 'Técnicos Tática Manager',
    extensions: ['json', 'tmclubs'],
    mimeTypes: ['application/json', 'application/octet-stream'],
  );

  late List<ManagerProfile> _managers;
  final _search = TextEditingController();
  final Set<String> _selected = {};
  String _status = 'Todos';

  @override
  void initState() {
    super.initState();
    _managers = [...?widget.pack.managers];
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final filtered = _managers.where((manager) {
      if (query.isNotEmpty &&
          !manager.displayName.toLowerCase().contains(query) &&
          !manager.nickname.toLowerCase().contains(query) &&
          !manager.nationality.toLowerCase().contains(query)) {
        return false;
      }
      if (_status == 'Livres' && manager.currentClubId != null) return false;
      if (_status == 'Em clube' && manager.currentClubId == null) return false;
      return true;
    }).toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
    final clubs = {for (final club in widget.pack.clubs) club.clubId: club.name};
    final employed = _managers.where((manager) => manager.currentClubId != null).length;

    return PremiumScaffold(
      appBar: const GameTopBar(
        title: 'Técnicos',
        subtitle: 'Editar dados do jogo',
      ),
      safeBottom: true,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 8, 14, 12),
        child: FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(_managers),
          icon: const Icon(Icons.check_circle_rounded),
          label: const Text('Aplicar alterações'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
        children: [
          SectionCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(Icons.sports_rounded, color: AppColors.green),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_managers.length} técnicos no banco',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                          Text(
                            '$employed em clubes • ${_managers.length - employed} livres',
                            style:  TextStyle(color: AppColors.muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _createManager,
                        icon: const Icon(Icons.person_add_alt_1_rounded),
                        label: const Text('Criar'),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _importManagers,
                        icon: const Icon(Icons.file_open_rounded),
                        label: const Text('Importar'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _managers.isEmpty ? null : () => _exportManagers(),
                        icon: const Icon(Icons.ios_share_rounded),
                        label: Text(
                          _selected.isEmpty ? 'Exportar dados' : 'Exportar (${_selected.length})',
                          maxLines: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _restoreDefaults,
                        icon: const Icon(Icons.restore_rounded),
                        label: const Text('Padrão'),
                      ),
                    ),
                  ],
                ),
                if (_managers.any((manager) => manager.userCreated)) ...[
                  const SizedBox(height: 3),
                  TextButton.icon(
                    onPressed: () => _exportManagers(customOnly: true),
                    icon: const Icon(Icons.person_pin_outlined, size: 18),
                    label: const Text('Exportar somente personalizados'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _search,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              hintText: 'Pesquisar técnico',
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Limpar pesquisa',
                      onPressed: () {
                        _search.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final value in const ['Todos', 'Em clube', 'Livres'])
                ChoiceChip(
                  label: Text(value),
                  selected: _status == value,
                  onSelected: (_) => setState(() => _status = value),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (filtered.isEmpty)
            const EmptyState(
              icon: Icons.sports_rounded,
              title: 'Nenhum técnico',
              text: 'Crie um técnico ou importe uma base compatível.',
            )
          else
            ...filtered.map((manager) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: _ManagerDatabaseCard(
                    manager: manager,
                    clubName: clubs[manager.currentClubId] ?? 'Livre',
                    selected: _selected.contains(manager.id),
                    onSelect: () => _toggleSelected(manager),
                    onEdit: () => _editManager(manager),
                    onDelete: manager.userCreated ? () => _deleteManager(manager) : null,
                  ),
                )),
        ],
      ),
    );
  }

  void _toggleSelected(ManagerProfile manager) {
    if (manager.id.isEmpty) return;
    setState(() {
      if (!_selected.add(manager.id)) _selected.remove(manager.id);
    });
  }

  Future<void> _createManager() async {
    final manager = await Navigator.of(context).push<ManagerProfile>(
      MaterialPageRoute(
        builder: (_) => ManagerEditorScreen(
          manager: ManagerProfile(
            id: 'manager-custom-${DateTime.now().microsecondsSinceEpoch}',
            displayName: 'Novo técnico',
            nationality: 'Brasil',
            ageAtStart: 35,
            careerStartSeason: 2026,
            userCreated: true,
          ),
          clubs: widget.pack.clubs,
        ),
      ),
    );
    if (manager != null && mounted) setState(() => _managers.add(manager));
  }

  Future<void> _editManager(ManagerProfile current) async {
    final manager = await Navigator.of(context).push<ManagerProfile>(
      MaterialPageRoute(
        builder: (_) => ManagerEditorScreen(manager: current, clubs: widget.pack.clubs),
      ),
    );
    if (manager == null || !mounted) return;
    setState(() {
      final index = _managers.indexWhere((item) => item.id == current.id);
      if (index >= 0) _managers[index] = manager;
    });
  }

  void _deleteManager(ManagerProfile manager) {
    if (!manager.userCreated) return;
    setState(() {
      _managers.removeWhere((item) => item.id == manager.id);
      _selected.remove(manager.id);
    });
  }

  Future<void> _restoreDefaults() async {
    final confirmed = await showEditorConfirmation(
      context,
      title: 'Restaurar técnicos padrão?',
      message: 'A lista atual de técnicos será substituída pela base original do Tática Manager. Técnicos personalizados e alterações ainda não aplicadas nesta tela serão descartados.',
      confirmLabel: 'Usar padrão',
      icon: Icons.restore_rounded,
      accent: AppColors.warning,
    );
    if (!confirmed || !mounted) return;
    final defaults = ClubIdentityEngine.defaultPack().managers ?? const <ManagerProfile>[];
    setState(() {
      _managers = [...defaults];
      _selected.clear();
    });
    await showEditorNotice(
      context,
      title: 'Técnicos restaurados',
      message: 'A base padrão foi preparada. Toque em Aplicar alterações para retornar à Central de Edição e depois salve o banco.',
      icon: Icons.restore_rounded,
      accent: AppColors.warning,
    );
  }

  Future<void> _importManagers() async {
    try {
      final file = await openFile(acceptedTypeGroups: const [_jsonType]);
      if (file == null) return;
      if (await file.length() > 8 * 1024 * 1024) {
        throw const FormatException('O arquivo é grande demais. Limite: 8 MiB.');
      }
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map || decoded['format'] != ClubIdentityPack.format) {
        throw const FormatException('Use um pacote Tática Manager compatível.');
      }
      final raw = decoded['managers'] ?? decoded['coaches'];
      if (raw is! List) throw const FormatException('O pacote não contém uma lista de técnicos.');
      final imported = raw
          .whereType<Map>()
          .map((item) => ManagerProfile.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false);
      final byId = {for (final manager in _managers) manager.id: manager};
      for (var index = 0; index < imported.length; index++) {
        final item = imported[index];
        final id = item.id.isEmpty
            ? 'manager-imported-${DateTime.now().microsecondsSinceEpoch}-$index'
            : item.id;
        byId[id] = item.copyWith(id: id);
      }
      if (!mounted) return;
      setState(() => _managers = byId.values.toList(growable: true));
      await showEditorNotice(
        context,
        title: 'Técnicos importados',
        message: '${imported.length} perfil(is) foram lidos do pacote. Revise a lista antes de aplicar as alterações.',
      );
    } catch (error, stack) {
      await DiagnosticService.instance.record(
        'MANAGER_IMPORT_ERROR',
        error,
        stack,
        'Falha ao importar técnicos no editor de dados.',
      );
      if (!mounted) return;
      await showEditorNotice(
        context,
        title: 'Não foi possível importar',
        message: error is FormatException ? error.message.toString() : error.toString(),
        icon: Icons.error_outline_rounded,
        accent: AppColors.danger,
      );
    }
  }

  Future<void> _exportManagers({bool customOnly = false}) async {
    final selected = customOnly
        ? _managers.where((manager) => manager.userCreated).toList()
        : _selected.isEmpty
            ? _managers
            : _managers.where((manager) => _selected.contains(manager.id)).toList();
    if (selected.isEmpty) return;
    final exportPack = ClubIdentityPack(
      name: widget.pack.name,
      author: widget.pack.author,
      clubs: widget.pack.clubs,
      freeAgents: widget.pack.freeAgents,
      managers: selected,
    );
    const fileName = 'tatica-manager-tecnicos.json';
    final path = await const DiagnosticPlatform().exportTextFile(exportPack.encode(), fileName);
    if (!mounted) return;
    await showEditorNotice(
      context,
      title: path == null ? 'Falha ao exportar' : 'Dados exportados',
      message: path == null
          ? 'Não foi possível exportar os técnicos para o armazenamento do aparelho.'
          : '${selected.length} técnico(s) exportado(s) para:\n$path',
      icon: path == null ? Icons.error_outline_rounded : Icons.ios_share_rounded,
      accent: path == null ? AppColors.danger : AppColors.green,
    );
  }
}

class _ManagerDatabaseCard extends StatelessWidget {
  const _ManagerDatabaseCard({
    required this.manager,
    required this.clubName,
    required this.selected,
    required this.onSelect,
    required this.onEdit,
    this.onDelete,
  });

  final ManagerProfile manager;
  final String clubName;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => SectionCard(
        padding: EdgeInsets.zero,
        borderColor: selected ? AppColors.green : null,
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 5, 9),
            child: Row(
              children: [
                ManagerAvatar(manager: manager, size: 52),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(manager.preferredName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5)),
                      const SizedBox(height: 2),
                      Text(
                        '${CountryCatalog.flagOf(manager.nationality)} ${manager.nationality} • ${manager.ageAtStart} anos',
                        style:  TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$clubName • ${manager.style} • Rep. ${manager.reputation}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                Checkbox(value: selected, onChanged: (_) => onSelect()),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete?.call();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Editar')),
                    if (onDelete != null) const PopupMenuItem(value: 'delete', child: Text('Excluir')),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
