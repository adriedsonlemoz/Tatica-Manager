part of 'manager_database_editor_screen.dart';

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
