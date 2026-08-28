import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../app/widgets/manager_avatar.dart';
import '../../core/diagnostics/diagnostic_platform.dart';
import '../../core/theme/app_colors.dart';
import '../../data/country_catalog.dart';
import '../../domain/career/manager_appearance.dart';
import '../../domain/career/manager_profile.dart';
import '../../domain/club/club_identity.dart';
import '../../domain/formation/formation.dart';
import '../../domain/tactic/tactic.dart';
import '../../game/club/club_identity_engine.dart';
import 'manager_appearance_editor.dart';

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

class _ManagerDatabaseEditorScreenState
    extends State<ManagerDatabaseEditorScreen> {
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

    return PremiumScaffold(
      appBar: const GameTopBar(
        title: 'Técnicos',
        subtitle: 'Central de Edição',
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
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _createManager,
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('Criar técnico'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _importManagers,
                  icon: const Icon(Icons.file_open_rounded),
                  label: const Text('Importar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _managers.isEmpty ? null : () => _exportManagers(),
            icon: const Icon(Icons.ios_share_rounded),
            label: Text(_selected.isEmpty
                ? 'Exportar todos'
                : 'Exportar selecionados (${_selected.length})'),
          ),
          if (_managers.any((manager) => manager.userCreated)) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _exportManagers(customOnly: true),
              icon: const Icon(Icons.person_pin_outlined),
              label: const Text('Exportar personalizados'),
            ),
          ],
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _restoreDefaults,
            icon: const Icon(Icons.restore_rounded),
            label: const Text('Restaurar técnicos originais'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _search,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Pesquisar técnico',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const ['Todos', 'Em clube', 'Livres']
                .map((value) => DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    ))
                .toList(growable: false),
            onChanged: (value) => setState(() => _status = value ?? 'Todos'),
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            const EmptyState(
              icon: Icons.sports_rounded,
              title: 'Nenhum técnico',
              text: 'Crie um técnico ou importe uma base compatível.',
            )
          else
            ...filtered.map((manager) {
              final selected = _selected.contains(manager.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SectionCard(
                  padding: const EdgeInsets.all(10),
                  borderColor: selected ? AppColors.green : null,
                  child: Row(
                    children: [
                      Checkbox(
                        value: selected,
                        onChanged: (_) => _toggleSelected(manager),
                      ),
                      ManagerAvatar(manager: manager, size: 58),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              manager.preferredName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${CountryCatalog.flagOf(manager.nationality)} ${manager.nationality} • ${manager.ageAtStart} anos',
                              style: const TextStyle(color: AppColors.muted),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${clubs[manager.currentClubId] ?? 'Livre'} • ${manager.style} • Rep. ${manager.reputation}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') _editManager(manager);
                          if (value == 'delete') _deleteManager(manager);
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Editar'),
                          ),
                          if (manager.userCreated)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Excluir'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
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
    if (manager != null && mounted) {
      setState(() => _managers.add(manager));
    }
  }

  Future<void> _editManager(ManagerProfile current) async {
    final manager = await Navigator.of(context).push<ManagerProfile>(
      MaterialPageRoute(
        builder: (_) => ManagerEditorScreen(
          manager: current,
          clubs: widget.pack.clubs,
        ),
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

  void _restoreDefaults() {
    final defaults = ClubIdentityEngine.defaultPack().managers ?? const <ManagerProfile>[];
    setState(() {
      _managers = [...defaults];
      _selected.clear();
    });
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
      if (raw is! List) {
        throw const FormatException('O pacote não contém uma lista de técnicos.');
      }
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
      _show('Técnicos importados com sucesso.');
    } catch (error) {
      if (!mounted) return;
      _show(error is FormatException ? error.message.toString() : error.toString());
    }
  }

  Future<void> _exportManagers({bool customOnly = false}) async {
    final selected = customOnly
        ? _managers.where((manager) => manager.userCreated).toList()
        : _selected.isEmpty
            ? _managers
            : _managers
                .where((manager) => _selected.contains(manager.id))
                .toList();
    if (selected.isEmpty) return;
    final exportPack = ClubIdentityPack(
      name: widget.pack.name,
      author: widget.pack.author,
      clubs: widget.pack.clubs,
      freeAgents: widget.pack.freeAgents,
      managers: selected,
    );
    const fileName = 'tatica-manager-tecnicos.json';
    final path = await const DiagnosticPlatform().exportTextFile(
      exportPack.encode(),
      fileName,
    );
    if (!mounted) return;
    _show(
      path == null
          ? 'Não foi possível exportar os técnicos.'
          : 'Técnicos exportados para $path',
    );
  }

  void _show(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class ManagerEditorScreen extends StatefulWidget {
  const ManagerEditorScreen({
    super.key,
    required this.manager,
    required this.clubs,
  });

  final ManagerProfile manager;
  final List<ClubIdentity> clubs;

  @override
  State<ManagerEditorScreen> createState() => _ManagerEditorScreenState();
}

class _ManagerEditorScreenState extends State<ManagerEditorScreen> {
  late final TextEditingController _name;
  late final TextEditingController _nickname;
  late final TextEditingController _age;
  late final TextEditingController _style;
  late final TextEditingController _reputation;
  late final TextEditingController _experience;
  late final TextEditingController _overall;
  late final TextEditingController _contractUntil;
  DateTime? _birthDate;
  late String _nationality;
  late String? _clubId;
  late FormationType _formation;
  late Mentality _mentality;
  late ManagerAppearance _appearance;

  @override
  void initState() {
    super.initState();
    final manager = widget.manager;
    _name = TextEditingController(text: manager.displayName);
    _nickname = TextEditingController(text: manager.nickname);
    _age = TextEditingController(text: '${manager.ageAtStart}');
    _style = TextEditingController(text: manager.style);
    _reputation = TextEditingController(text: '${manager.reputation}');
    _experience = TextEditingController(text: '${manager.experienceYears}');
    _overall = TextEditingController(text: '${manager.overall}');
    _contractUntil = TextEditingController(
      text: manager.contractUntilSeason?.toString() ?? '',
    );
    _birthDate = manager.birthDate;
    _nationality = CountryCatalog.all.any((item) => item.name == manager.nationality)
        ? manager.nationality
        : 'Brasil';
    _clubId = widget.clubs.any((club) => club.clubId == manager.currentClubId)
        ? manager.currentClubId
        : null;
    _formation = manager.preferredFormation;
    _mentality = manager.preferredMentality;
    _appearance = manager.appearance;
  }

  @override
  void dispose() {
    _name.dispose();
    _nickname.dispose();
    _age.dispose();
    _style.dispose();
    _reputation.dispose();
    _experience.dispose();
    _overall.dispose();
    _contractUntil.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preview = widget.manager.copyWith(
      displayName: _name.text.trim().isEmpty ? 'Técnico' : _name.text.trim(),
      nickname: _nickname.text.trim(),
      nationality: _nationality,
      appearance: _appearance,
    );
    return PremiumScaffold(
      appBar: const GameTopBar(title: 'Editar técnico', subtitle: 'Perfil completo'),
      safeBottom: true,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 8, 14, 12),
        child: FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_rounded),
          label: const Text('Salvar técnico'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        children: [
          SectionCard(
            child: Row(
              children: [
                ManagerAvatar(manager: preview, size: 82),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(preview.preferredName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 18)),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => _editAppearance(preview),
                        icon: const Icon(Icons.face_retouching_natural_rounded),
                        label: const Text('Aparência / foto'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SectionCard(
            child: Column(
              children: [
                TextField(
                  controller: _name,
                  maxLength: 50,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  onChanged: (_) => setState(() {}),
                ),
                TextField(
                  controller: _nickname,
                  maxLength: 24,
                  decoration: const InputDecoration(labelText: 'Apelido'),
                  onChanged: (_) => setState(() {}),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _age,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Idade'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _nationality,
                        decoration: const InputDecoration(labelText: 'País'),
                        items: CountryCatalog.all
                            .map((item) => DropdownMenuItem(
                                  value: item.name,
                                  child: Text(item.label),
                                ))
                            .toList(growable: false),
                        onChanged: (value) =>
                            setState(() => _nationality = value ?? 'Brasil'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.cake_outlined, color: AppColors.green),
                  title: const Text('Data de nascimento'),
                  subtitle: Text(
                    _birthDate == null
                        ? 'Não informada'
                        : '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_birthDate != null)
                        IconButton(
                          tooltip: 'Remover data',
                          onPressed: () => setState(() => _birthDate = null),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      IconButton(
                        tooltip: 'Escolher data',
                        onPressed: _pickBirthDate,
                        icon: const Icon(Icons.calendar_month_rounded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SectionCard(
            child: Column(
              children: [
                DropdownButtonFormField<String?>(
                  value: _clubId,
                  decoration: const InputDecoration(labelText: 'Clube atual'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Livre'),
                    ),
                    ...widget.clubs.map((club) => DropdownMenuItem<String?>(
                          value: club.clubId,
                          child: Text(club.name),
                        )),
                  ],
                  onChanged: (value) => setState(() => _clubId = value),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _contractUntil,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Contrato até a temporada',
                    hintText: 'Ex.: 2028',
                  ),
                ),
                TextField(
                  controller: _style,
                  maxLength: 30,
                  decoration: const InputDecoration(labelText: 'Estilo de jogo'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _reputation,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Reputação'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _overall,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Nível geral'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _experience,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Experiência'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<FormationType>(
                  value: _formation,
                  decoration: const InputDecoration(labelText: 'Formação preferida'),
                  items: FormationType.values
                      .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(value.label),
                          ))
                      .toList(growable: false),
                  onChanged: (value) =>
                      setState(() => _formation = value ?? FormationType.f433),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Mentality>(
                  value: _mentality,
                  decoration: const InputDecoration(labelText: 'Mentalidade preferida'),
                  items: Mentality.values
                      .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(value.label),
                          ))
                      .toList(growable: false),
                  onChanged: (value) =>
                      setState(() => _mentality = value ?? Mentality.balanced),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial = _birthDate ?? DateTime(now.year - (int.tryParse(_age.text) ?? 35));
    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1930),
      lastDate: DateTime(now.year - 18, now.month, now.day),
    );
    if (selected == null || !mounted) return;
    final age = now.year - selected.year -
        ((now.month < selected.month ||
                (now.month == selected.month && now.day < selected.day))
            ? 1
            : 0);
    setState(() {
      _birthDate = selected;
      _age.text = '$age';
    });
  }

  Future<void> _editAppearance(ManagerProfile preview) async {
    final value = await showManagerAppearanceEditor(
      context,
      previewManager: preview,
    );
    if (value != null && mounted) setState(() => _appearance = value);
  }

  void _save() {
    try {
      final age = int.tryParse(_age.text.trim());
      if (age == null) throw const FormatException('Digite uma idade válida.');
      final contractText = _contractUntil.text.trim();
      final contractUntil = contractText.isEmpty ? null : int.tryParse(contractText);
      if (contractText.isNotEmpty && contractUntil == null) {
        throw const FormatException('Digite uma temporada de contrato válida.');
      }
      final manager = ManagerProfile.normalized(
        id: widget.manager.id,
        displayName: _name.text,
        nickname: _nickname.text,
        nationality: _nationality,
        ageAtStart: age,
        careerStartSeason: widget.manager.careerStartSeason,
        appearance: _appearance,
        birthDate: _birthDate,
        currentClubId: _clubId,
        contractUntilSeason: _clubId == null ? null : contractUntil,
        reputation: int.tryParse(_reputation.text.trim()) ?? 50,
        style: _style.text,
        preferredFormation: _formation,
        preferredMentality: _mentality,
        experienceYears: int.tryParse(_experience.text.trim()) ?? 0,
        overall: int.tryParse(_overall.text.trim()) ?? 65,
        userCreated: widget.manager.userCreated,
      );
      Navigator.of(context).pop(manager);
    } on FormatException catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message.toString())));
    }
  }
}
