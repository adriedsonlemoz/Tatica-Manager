import 'dart:async';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../app/widgets/player_avatar.dart';
import '../../core/media/player_photo_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/editor_input_formatters.dart';
import '../../core/utils/formatters.dart';
import '../../domain/contract/contract.dart';
import '../../domain/player/player.dart';
import '../../domain/player/player_attributes.dart';
import '../../game/player/player_factory.dart';

class PlayerDatabaseEditorScreen extends StatefulWidget {
  const PlayerDatabaseEditorScreen({
    super.key,
    required this.player,
    required this.clubName,
    this.freeAgent = false,
  });

  final Player player;
  final String clubName;
  final bool freeAgent;

  @override
  State<PlayerDatabaseEditorScreen> createState() => _PlayerDatabaseEditorScreenState();
}

class _PlayerDatabaseEditorScreenState extends State<PlayerDatabaseEditorScreen> {
  late final Map<String, TextEditingController> _c;
  late PlayerPosition _primaryPosition;
  late Set<PlayerPosition> _secondaryPositions;
  late PreferredFoot _preferredFoot;
  String? _error;
  final PlayerPhotoStore _photoStore = const PlayerPhotoStore();
  String? _customAvatarPath;
  String? _pendingPhotoPath;
  bool _photoBusy = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final p = widget.player;
    _customAvatarPath = p.customAvatarPath;
    _primaryPosition = p.primaryPosition;
    _secondaryPositions = p.secondaryPositions.toSet();
    _preferredFoot = p.preferredFoot;
    _c = {
      'firstName': TextEditingController(text: p.firstName),
      'lastName': TextEditingController(text: p.lastName),
      'displayName': TextEditingController(text: p.displayName),
      'birthDate': TextEditingController(text: fullDate(p.birthDate)),
      'age': TextEditingController(text: '${p.age}'),
      'nationality': TextEditingController(text: p.nationality),
      'shirtNumber': TextEditingController(text: '${p.shirtNumber}'),
      'heightCm': TextEditingController(text: '${p.heightCm}'),
      'weightKg': TextEditingController(text: '${p.weightKg}'),
      'overall': TextEditingController(text: '${p.overall}'),
      'potential': TextEditingController(text: '${p.potential}'),
      'marketValue': TextEditingController(text: '${p.marketValue}'),
      'salary': TextEditingController(text: formatEditableMoney(p.contract.salary)),
      'endSeason': TextEditingController(text: '${p.contract.endSeason}'),
      'finishing': TextEditingController(text: '${p.technical.finishing}'),
      'passing': TextEditingController(text: '${p.technical.passing}'),
      'crossing': TextEditingController(text: '${p.technical.crossing}'),
      'control': TextEditingController(text: '${p.technical.control}'),
      'dribbling': TextEditingController(text: '${p.technical.dribbling}'),
      'tackling': TextEditingController(text: '${p.technical.tackling}'),
      'speed': TextEditingController(text: '${p.physical.speed}'),
      'acceleration': TextEditingController(text: '${p.physical.acceleration}'),
      'strength': TextEditingController(text: '${p.physical.strength}'),
      'stamina': TextEditingController(text: '${p.physical.stamina}'),
      'agility': TextEditingController(text: '${p.physical.agility}'),
      'positioning': TextEditingController(text: '${p.mental.positioning}'),
      'vision': TextEditingController(text: '${p.mental.vision}'),
      'decision': TextEditingController(text: '${p.mental.decision}'),
      'concentration': TextEditingController(text: '${p.mental.concentration}'),
      'leadership': TextEditingController(text: '${p.mental.leadership}'),
      'gkReflexes': TextEditingController(text: '${p.goalkeeper.reflexes}'),
      'gkPositioning': TextEditingController(text: '${p.goalkeeper.positioning}'),
      'gkSaving': TextEditingController(text: '${p.goalkeeper.saving}'),
      'gkRushingOut': TextEditingController(text: '${p.goalkeeper.rushingOut}'),
      'gkAerial': TextEditingController(text: '${p.goalkeeper.aerial}'),
      'skinTone': TextEditingController(text: '${p.visual.skinTone}'),
      'hairStyle': TextEditingController(text: '${p.visual.hairStyle}'),
      'hairColor': TextEditingController(text: '${p.visual.hairColor}'),
      'bodyType': TextEditingController(text: '${p.visual.bodyType}'),
      'visualHeight': TextEditingController(text: p.visual.visualHeight.toStringAsFixed(2)),
      'bootStyle': TextEditingController(text: '${p.visual.bootStyle}'),
    };
  }

  @override
  void dispose() {
    if (!_saved && _pendingPhotoPath != null) {
      unawaited(_photoStore.deleteManagedPhoto(_pendingPhotoPath));
    }
    for (final controller in _c.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PremiumScaffold(
        appBar: GameTopBar(
          title: 'Editar jogador',
          subtitle: '${widget.player.id} • ${widget.clubName}',
          actions: [
            IconButton(
              tooltip: 'Salvar jogador',
              onPressed: _submit,
              icon: const Icon(Icons.check_rounded),
            ),
          ],
        ),
        safeBottom: true,
        body: ListView(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
          children: [
            if (_error != null) ...[
              _ErrorBox(text: _error!),
              const SizedBox(height: 12),
            ],
            _EditorSection(
              title: 'Identidade',
              icon: Icons.badge_outlined,
              children: [
                _photoEditor(),
                const SizedBox(height: 4),
                TextField(
                  controller: _c['firstName'],
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                TextField(
                  controller: _c['lastName'],
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Sobrenome'),
                ),
                TextField(
                  controller: _c['displayName'],
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Nome exibido'),
                ),
                TextField(
                  controller: _c['birthDate'],
                  readOnly: true,
                  onTap: _pickBirthDate,
                  decoration: InputDecoration(
                    labelText: 'Nascimento',
                    hintText: 'DD/MM/AAAA',
                    suffixIcon: IconButton(
                      tooltip: 'Escolher data',
                      onPressed: _pickBirthDate,
                      icon: const Icon(Icons.calendar_month_outlined),
                    ),
                  ),
                ),
                _numberField('age', 'Idade'),
                TextField(
                  controller: _c['nationality'],
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Nacionalidade'),
                ),
                if (!widget.freeAgent) _numberField('shirtNumber', 'Número da camisa'),
              ],
            ),
            const SizedBox(height: 12),
            _EditorSection(
              title: 'Posição e nível',
              icon: Icons.sports_soccer_rounded,
              children: [
                DropdownButtonFormField<PlayerPosition>(
                  initialValue: _primaryPosition,
                  decoration: const InputDecoration(labelText: 'Posição principal'),
                  items: PlayerPosition.values
                      .map((position) => DropdownMenuItem(value: position, child: Text(position.label)))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _primaryPosition = value;
                      _secondaryPositions.remove(value);
                    });
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Posições secundárias', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted)),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: PlayerPosition.values
                      .where((position) => position != _primaryPosition)
                      .map(
                        (position) => FilterChip(
                          label: Text(position.label),
                          selected: _secondaryPositions.contains(position),
                          onSelected: (selected) => setState(() {
                            if (selected) {
                              _secondaryPositions.add(position);
                            } else {
                              _secondaryPositions.remove(position);
                            }
                          }),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<PreferredFoot>(
                  initialValue: _preferredFoot,
                  decoration: const InputDecoration(labelText: 'Pé preferido'),
                  items: PreferredFoot.values
                      .map(
                        (foot) => DropdownMenuItem(
                          value: foot,
                          child: Text(switch (foot) {
                            PreferredFoot.right => 'Direito',
                            PreferredFoot.left => 'Esquerdo',
                            PreferredFoot.both => 'Ambos',
                          }),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _preferredFoot = value ?? _preferredFoot),
                ),
                _numberField('heightCm', 'Altura (cm)'),
                _numberField('weightKg', 'Peso (kg)'),
                _numberField('overall', 'Overall'),
                _numberField('potential', 'Potencial'),
                _numberField('marketValue', 'Valor de mercado'),
              ],
            ),
            const SizedBox(height: 12),
            _EditorSection(
              title: 'Contrato',
              icon: Icons.description_outlined,
              children: [
                _moneyField('salary', 'Salário mensal'),
                _numberField('endSeason', 'Temporada final do contrato'),
              ],
            ),
            const SizedBox(height: 12),
            _EditorSection(
              title: 'Atributos técnicos',
              icon: Icons.tune_rounded,
              children: [
                _numberField('finishing', 'Finalização'),
                _numberField('passing', 'Passe'),
                _numberField('crossing', 'Cruzamento'),
                _numberField('control', 'Controle'),
                _numberField('dribbling', 'Drible'),
                _numberField('tackling', 'Desarme'),
              ],
            ),
            const SizedBox(height: 12),
            _EditorSection(
              title: 'Atributos físicos',
              icon: Icons.fitness_center_rounded,
              children: [
                _numberField('speed', 'Velocidade'),
                _numberField('acceleration', 'Aceleração'),
                _numberField('strength', 'Força'),
                _numberField('stamina', 'Resistência'),
                _numberField('agility', 'Agilidade'),
              ],
            ),
            const SizedBox(height: 12),
            _EditorSection(
              title: 'Atributos mentais',
              icon: Icons.psychology_alt_outlined,
              children: [
                _numberField('positioning', 'Posicionamento'),
                _numberField('vision', 'Visão'),
                _numberField('decision', 'Decisão'),
                _numberField('concentration', 'Concentração'),
                _numberField('leadership', 'Liderança'),
              ],
            ),
            const SizedBox(height: 12),
            _EditorSection(
              title: 'Goleiro',
              icon: Icons.sports_handball_outlined,
              children: [
                _numberField('gkReflexes', 'Reflexos'),
                _numberField('gkPositioning', 'Posicionamento do goleiro'),
                _numberField('gkSaving', 'Defesa'),
                _numberField('gkRushingOut', 'Saída do gol'),
                _numberField('gkAerial', 'Jogo aéreo'),
              ],
            ),
            const SizedBox(height: 12),
            _EditorSection(
              title: 'Visual 2D',
              icon: Icons.face_retouching_natural_outlined,
              children: [
                _numberField('skinTone', 'Tom de pele (índice)'),
                _numberField('hairStyle', 'Estilo de cabelo (índice)'),
                _numberField('hairColor', 'Cor do cabelo (índice)'),
                _numberField('bodyType', 'Tipo físico (índice)'),
                TextField(
                  controller: _c['visualHeight'],
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Escala visual de altura'),
                ),
                _numberField('bootStyle', 'Chuteira (índice)'),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _recalculateOverall,
              icon: const Icon(Icons.calculate_outlined),
              label: const Text('Recalcular overall pelos atributos'),
            ),
            const SizedBox(height: 10),
            Text(
              'Lesões, cartões, condição física, fadiga, estatísticas e histórico são estado da carreira e não são sobrescritos por este editor em saves existentes.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted, height: 1.4),
            ),
          ],
        ),
      );

  Widget _photoEditor() {
    final previewPlayer = widget.player.copyWith(
      customAvatarPath: _customAvatarPath,
      clearCustomAvatar: _customAvatarPath == null,
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlayerAvatar(player: previewPlayer, size: 86),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Foto / avatar',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                 Text(
                  'PNG, JPG/JPEG ou WebP, até 8 MB. A imagem é centralizada, recortada e salva em cópia privada otimizada.',
                  style: TextStyle(color: AppColors.muted, fontSize: 10.5, height: 1.35),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 7,
                  runSpacing: 6,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: _photoBusy ? null : _pickPhoto,
                      icon: _photoBusy
                          ? const SizedBox.square(
                              dimension: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.photo_library_outlined, size: 17),
                      label: Text(_customAvatarPath == null ? 'Importar' : 'Trocar'),
                    ),
                    if (_customAvatarPath != null)
                      OutlinedButton.icon(
                        onPressed: _photoBusy ? null : _removePhoto,
                        icon: const Icon(Icons.delete_outline_rounded, size: 17),
                        label: const Text('Remover'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final source = await openFile(
      acceptedTypeGroups: [PlayerPhotoStore.acceptedImages],
    );
    if (source == null || !mounted) return;
    setState(() {
      _photoBusy = true;
      _error = null;
    });
    try {
      final imported = await _photoStore.importPhoto(
        playerId: widget.player.id,
        source: source,
      );
      if (!mounted) {
        await _photoStore.deleteManagedPhoto(imported);
        return;
      }
      final previousPending = _pendingPhotoPath;
      setState(() {
        _customAvatarPath = imported;
        _pendingPhotoPath = imported;
        _photoBusy = false;
      });
      if (previousPending != null && previousPending != imported) {
        await _photoStore.deleteManagedPhoto(previousPending);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _photoBusy = false;
        _error = _friendly(error);
      });
    }
  }

  Future<void> _removePhoto() async {
    final pending = _pendingPhotoPath;
    if (pending != null) await _photoStore.deleteManagedPhoto(pending);
    if (!mounted) return;
    setState(() {
      _pendingPhotoPath = null;
      _customAvatarPath = null;
      _error = null;
    });
  }

  Widget _moneyField(String key, String label) => TextField(
        controller: _c[key],
        keyboardType: TextInputType.number,
        inputFormatters: const [BrazilianMoneyInputFormatter()],
        decoration: InputDecoration(labelText: label),
      );

  Future<void> _pickBirthDate() async {
    final current = _parseDate(_c['birthDate']!.text) ?? DateTime(2000, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(1940),
      lastDate: DateTime(2011, 12, 31),
      helpText: 'Data de nascimento',
      cancelText: 'Cancelar',
      confirmText: 'Usar data',
    );
    if (picked == null || !mounted) return;
    setState(() => _c['birthDate']!.text = fullDate(picked));
  }

  DateTime? _parseDate(String source) {
    final value = source.trim();
    final brazilian = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(value);
    if (brazilian != null) {
      final day = int.parse(brazilian.group(1)!);
      final month = int.parse(brazilian.group(2)!);
      final year = int.parse(brazilian.group(3)!);
      final date = DateTime(year, month, day);
      if (date.year == year && date.month == month && date.day == day) return date;
      return null;
    }
    return DateTime.tryParse(value);
  }

  Widget _numberField(String key, String label) => TextField(
        controller: _c[key],
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
      );

  TechnicalAttributes _technical() => TechnicalAttributes(
        finishing: _int('finishing'),
        passing: _int('passing'),
        crossing: _int('crossing'),
        control: _int('control'),
        dribbling: _int('dribbling'),
        tackling: _int('tackling'),
      );

  PhysicalAttributes _physical() => PhysicalAttributes(
        speed: _int('speed'),
        acceleration: _int('acceleration'),
        strength: _int('strength'),
        stamina: _int('stamina'),
        agility: _int('agility'),
      );

  MentalAttributes _mental() => MentalAttributes(
        positioning: _int('positioning'),
        vision: _int('vision'),
        decision: _int('decision'),
        concentration: _int('concentration'),
        leadership: _int('leadership'),
      );

  GoalkeeperAttributes _goalkeeper() => GoalkeeperAttributes(
        reflexes: _int('gkReflexes'),
        positioning: _int('gkPositioning'),
        saving: _int('gkSaving'),
        rushingOut: _int('gkRushingOut'),
        aerial: _int('gkAerial'),
      );

  int _int(String key) {
    final value = int.tryParse(_c[key]!.text.trim());
    if (value == null) throw FormatException('Preencha corretamente o campo ${_labelFor(key)}.');
    return value;
  }

  double _double(String key) {
    final value = double.tryParse(_c[key]!.text.trim().replaceAll(',', '.'));
    if (value == null) throw FormatException('Preencha corretamente o campo ${_labelFor(key)}.');
    return value;
  }

  void _recalculateOverall() {
    try {
      final overall = OverallCalculator.calculate(
        position: _primaryPosition,
        technical: _technical(),
        physical: _physical(),
        mental: _mental(),
        goalkeeper: _goalkeeper(),
      );
      setState(() {
        _c['overall']!.text = '$overall';
        final potential = int.tryParse(_c['potential']!.text) ?? overall;
        if (potential < overall) _c['potential']!.text = '$overall';
        _error = null;
      });
    } catch (error) {
      setState(() => _error = _friendly(error));
    }
  }

  void _submit() {
    try {
      final birthDate = _parseDate(_c['birthDate']!.text);
      if (birthDate == null) throw const FormatException('Escolha uma data de nascimento válida.');
      final firstName = _c['firstName']!.text.trim();
      final lastName = _c['lastName']!.text.trim();
      final displayName = _c['displayName']!.text.trim();
      if (firstName.isEmpty && lastName.isEmpty) {
        throw const FormatException('Informe ao menos nome ou sobrenome.');
      }
      if (displayName.isEmpty) throw const FormatException('Informe o nome exibido.');

      final result = widget.player.copyWith(
        firstName: firstName,
        lastName: lastName,
        displayName: displayName,
        birthDate: birthDate,
        age: _range(_int('age'), 15, 50, 'Idade'),
        nationality: _c['nationality']!.text.trim(),
        primaryPosition: _primaryPosition,
        secondaryPositions: _secondaryPositions.toList(growable: false),
        preferredFoot: _preferredFoot,
        heightCm: _range(_int('heightCm'), 140, 220, 'Altura'),
        weightKg: _range(_int('weightKg'), 45, 150, 'Peso'),
        shirtNumber: widget.freeAgent ? 0 : _range(_int('shirtNumber'), 1, 99, 'Número da camisa'),
        overall: _range(_int('overall'), 1, 99, 'Overall'),
        potential: _range(_int('potential'), 1, 99, 'Potencial'),
        technical: _validatedAttributes(_technical(), 'Técnicos'),
        physical: _validatedAttributes(_physical(), 'Físicos'),
        mental: _validatedAttributes(_mental(), 'Mentais'),
        goalkeeper: _validatedAttributes(_goalkeeper(), 'Goleiro'),
        marketValue: _range(_int('marketValue'), 0, 2000000000, 'Valor de mercado'),
        contract: PlayerContract(
          salary: _range(parseEditableMoney(_c['salary']!.text), 0, 100000000, 'Salário'),
          endSeason: _range(_int('endSeason'), 1900, 2200, 'Fim do contrato'),
        ),
        customAvatarPath: _customAvatarPath,
        clearCustomAvatar: _customAvatarPath == null,
        visual: VisualProfile(
          skinTone: _range(_int('skinTone'), 0, 5, 'Tom de pele'),
          hairStyle: _range(_int('hairStyle'), 0, 7, 'Estilo de cabelo'),
          hairColor: _range(_int('hairColor'), 0, 4, 'Cor do cabelo'),
          bodyType: _range(_int('bodyType'), 0, 3, 'Tipo físico'),
          visualHeight: _double('visualHeight').clamp(.5, 1.5).toDouble(),
          bootStyle: _range(_int('bootStyle'), 0, 5, 'Chuteira'),
        ),
      );
      if (result.potential < result.overall) {
        throw const FormatException('O potencial não pode ser menor que o overall.');
      }
      _saved = true;
      Navigator.pop(context, result);
    } catch (error) {
      setState(() => _error = _friendly(error));
    }
  }

  T _validatedAttributes<T>(T attributes, String group) {
    Map<String, dynamic> values;
    if (attributes is TechnicalAttributes) {
      values = attributes.toJson();
    } else if (attributes is PhysicalAttributes) {
      values = attributes.toJson();
    } else if (attributes is MentalAttributes) {
      values = attributes.toJson();
    } else if (attributes is GoalkeeperAttributes) {
      values = attributes.toJson();
    } else {
      return attributes;
    }
    for (final entry in values.entries) {
      final value = entry.value as int;
      if (value < 1 || value > 99) {
        throw FormatException('$group: todos os atributos devem ficar entre 1 e 99.');
      }
    }
    return attributes;
  }

  int _range(int value, int min, int max, String label) {
    if (value < min || value > max) {
      throw FormatException('$label deve ficar entre $min e $max.');
    }
    return value;
  }

  static String _friendly(Object error) =>
      error.toString().replaceFirst('FormatException: ', '').replaceFirst('Bad state: ', '');

  static String _labelFor(String key) => switch (key) {
        'finishing' => 'Finalização',
        'passing' => 'Passe',
        'crossing' => 'Cruzamento',
        'control' => 'Controle',
        'dribbling' => 'Drible',
        'tackling' => 'Desarme',
        'speed' => 'Velocidade',
        'acceleration' => 'Aceleração',
        'strength' => 'Força',
        'stamina' => 'Resistência',
        'agility' => 'Agilidade',
        'positioning' => 'Posicionamento',
        'vision' => 'Visão',
        'decision' => 'Decisão',
        'concentration' => 'Concentração',
        'leadership' => 'Liderança',
        _ => key,
      };
}

class _EditorSection extends StatelessWidget {
  const _EditorSection({required this.title, required this.icon, required this.children});
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.green, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            ...children.expand((child) => [child, const SizedBox(height: 8)]),
          ],
        ),
      );
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.danger.withValues(alpha: .35)),
        ),
        child: Text(text),
      );
}
