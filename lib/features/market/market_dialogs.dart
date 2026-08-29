part of 'market_screen.dart';

class _MarketFiltersSheet extends StatefulWidget {
  const _MarketFiltersSheet({
    required this.initial,
    required this.clubs,
    required this.nationalities,
  });

  final _MarketFilters initial;
  final List<Club> clubs;
  final List<String> nationalities;

  @override
  State<_MarketFiltersSheet> createState() => _MarketFiltersSheetState();
}

class _MarketFiltersSheetState extends State<_MarketFiltersSheet> {
  late String? nationality = widget.initial.nationality;
  late String? clubId = widget.initial.clubId;
  late String? seriesId = widget.initial.seriesId;
  late RangeValues age = RangeValues(
    widget.initial.minAge.toDouble(),
    widget.initial.maxAge.toDouble(),
  );
  late double minOverall = widget.initial.minOverall.toDouble();
  late double minPotential = widget.initial.minPotential.toDouble();
  late int maxValue = widget.initial.maxValue;
  late int maxSalary = widget.initial.maxSalary;
  late bool freeOnly = widget.initial.freeOnly;
  late bool expiringOnly = widget.initial.expiringOnly;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          14,
          18,
          18 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FILTROS AVANÇADOS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: nationality,
                decoration: const InputDecoration(labelText: 'País / nacionalidade'),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('Todos')),
                  ...widget.nationalities.map(
                    (value) => DropdownMenuItem<String?>(
                      value: value,
                      child: Text(value),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => nationality = value),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                initialValue: clubId,
                decoration: const InputDecoration(labelText: 'Clube'),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('Todos')),
                  ...widget.clubs.map(
                    (club) => DropdownMenuItem<String?>(
                      value: club.id,
                      child: Text(club.name),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => clubId = value),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                initialValue: seriesId,
                decoration: const InputDecoration(labelText: 'Liga'),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('Todas')),
                  ...CompetitionCatalog.allSeries.map(
                    (series) => DropdownMenuItem<String?>(
                      value: series.id,
                      child: Text(CompetitionCatalog.displayNameFor(series)),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => seriesId = value),
              ),
              const SizedBox(height: 12),
              Text('Idade ${age.start.round()}–${age.end.round()}'),
              RangeSlider(
                values: age,
                min: 15,
                max: 45,
                divisions: 30,
                labels: RangeLabels(
                  '${age.start.round()}',
                  '${age.end.round()}',
                ),
                onChanged: (value) => setState(() => age = value),
              ),
              Text('Overall mínimo ${minOverall.round()}'),
              Slider(
                value: minOverall,
                min: 35,
                max: 95,
                divisions: 60,
                onChanged: (value) => setState(() => minOverall = value),
              ),
              Text('Potencial mínimo ${minPotential.round()}'),
              Slider(
                value: minPotential,
                min: 35,
                max: 99,
                divisions: 64,
                onChanged: (value) => setState(() => minPotential = value),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                initialValue: maxValue,
                decoration: const InputDecoration(labelText: 'Valor máximo'),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Sem limite')),
                  DropdownMenuItem(value: 1000000, child: Text('R\$ 1 mi')),
                  DropdownMenuItem(value: 5000000, child: Text('R\$ 5 mi')),
                  DropdownMenuItem(value: 10000000, child: Text('R\$ 10 mi')),
                  DropdownMenuItem(value: 25000000, child: Text('R\$ 25 mi')),
                  DropdownMenuItem(value: 50000000, child: Text('R\$ 50 mi')),
                ],
                onChanged: (value) => setState(() => maxValue = value ?? 0),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: maxSalary,
                decoration: const InputDecoration(labelText: 'Salário máximo'),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Sem limite')),
                  DropdownMenuItem(value: 10000, child: Text('R\$ 10 mil')),
                  DropdownMenuItem(value: 25000, child: Text('R\$ 25 mil')),
                  DropdownMenuItem(value: 50000, child: Text('R\$ 50 mil')),
                  DropdownMenuItem(value: 100000, child: Text('R\$ 100 mil')),
                  DropdownMenuItem(value: 250000, child: Text('R\$ 250 mil')),
                ],
                onChanged: (value) => setState(() => maxSalary = value ?? 0),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Somente jogadores livres'),
                value: freeOnly,
                onChanged: (value) => setState(() => freeOnly = value),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Contrato próximo do fim'),
                value: expiringOnly,
                onChanged: (value) => setState(() => expiringOnly = value),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(
                    _MarketFilters(
                      nationality: nationality,
                      clubId: clubId,
                      seriesId: seriesId,
                      minAge: age.start.round(),
                      maxAge: age.end.round(),
                      minOverall: minOverall.round(),
                      minPotential: minPotential.round(),
                      maxValue: maxValue,
                      maxSalary: maxSalary,
                      freeOnly: freeOnly,
                      expiringOnly: expiringOnly,
                    ),
                  ),
                  child: const Text('Aplicar filtros'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showPlayerMarketSheet(
  BuildContext context,
  WidgetRef ref, {
  required _MarketEntry entry,
  required PlayerScoutingReport? report,
  required bool windowOpen,
}) async {
  final player = entry.player;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PlayerAvatar(
                  player: player,
                  size: 62,
                  accentColor: entry.club == null
                      ? AppColors.green
                      : Color(entry.club!.colors.primaryHex),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${entry.club?.name ?? 'Sem clube'} • ${player.primaryPosition.label} • ${player.age} anos',
                        style:  TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _KnowledgeLine(player: player, report: report),
            const SizedBox(height: 8),
            Text(
              report == null
                  ? 'Ainda não observado. Inicie o scouting para revelar avaliação, valor, salário e potencial gradualmente.'
                  : '${report.level.label} • ${report.daysObserved} dia(s) de observação.',
              style:  TextStyle(color: AppColors.muted, fontSize: 11),
            ),
            if (report?.level == ScoutingLevel.complete) ...[
              const SizedBox(height: 7),
              Text(
                'Salário atual ${formatMoney(player.salary)} • contrato até ${player.contract.endSeason} • condição ${player.condition}% • fadiga ${player.fatigue}%',
                style: const TextStyle(fontSize: 11),
              ),
            ],
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (entry.club != null)
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PlayerProfileScreen(
                            playerId: player.id,
                            clubId: entry.club!.id,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_rounded),
                    label: const Text('Ver jogador'),
                  ),
                if (report == null)
                  FilledButton.icon(
                    onPressed: () async {
                      final result = await ref
                          .read(transferControllerProvider)
                          .startScouting(player.id);
                      if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result.message)),
                        );
                      }
                    },
                    icon: const Icon(Icons.visibility_rounded),
                    label: const Text('Observar'),
                  ),
                if (report != null)
                  FilledButton.icon(
                    onPressed: !windowOpen
                        ? null
                        : () {
                            Navigator.of(sheetContext).pop();
                            _showNegotiationDialog(
                              context,
                              ref,
                              entry: entry,
                            );
                          },
                    icon: const Icon(Icons.handshake_rounded),
                    label: const Text('Negociar'),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _showNegotiationDialog(
  BuildContext context,
  WidgetRef ref, {
  required _MarketEntry? entry,
  TransferNegotiation? existing,
}) async {
  if (entry == null) return;
  final player = entry.player;
  final feeController = TextEditingController(
    text: '${entry.free ? 0 : (existing?.counterFee ?? existing?.fee ?? player.marketValue)}',
  );
  final salaryController = TextEditingController(
    text: '${existing?.counterSalary ?? existing?.salary ?? player.salary}',
  );
  final bonusController = TextEditingController(
    text: '${existing?.signingBonus ?? (player.salary * 2)}',
  );
  var years = existing?.contractYears ?? 3;
  var installments = existing?.installments ?? 1;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(existing == null ? 'Enviar proposta' : 'Revisar proposta'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                player.displayName,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: feeController,
                enabled: !entry.free,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: entry.free ? 'Valor da transferência (agente livre)' : 'Valor da transferência',
                  helperText: entry.free ? 'Sem taxa de transferência; negocie salário e bônus.' : null,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: salaryController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Salário mensal'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: bonusController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Bônus de assinatura'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: years,
                decoration: const InputDecoration(labelText: 'Duração'),
                items: List.generate(
                  5,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('${index + 1} ano(s)'),
                  ),
                ),
                onChanged: (value) =>
                    setDialogState(() => years = value ?? years),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: entry.free ? 1 : installments,
                decoration: const InputDecoration(labelText: 'Parcelas'),
                items: List.generate(
                  4,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('${index + 1} parcela(s)'),
                  ),
                ),
                onChanged: entry.free
                    ? null
                    : (value) => setDialogState(
                          () => installments = value ?? installments,
                        ),
              ),
              const SizedBox(height: 9),
               Text(
                'A resposta não é instantânea: o clube e o jogador analisam a proposta ao avançar os dias.',
                style: TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final fee = int.tryParse(feeController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
              final salary = int.tryParse(salaryController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
              final bonus = int.tryParse(bonusController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
              final result = existing == null
                  ? await ref.read(transferControllerProvider).startMarketNegotiation(
                        playerId: player.id,
                        fee: fee,
                        salary: salary,
                        years: years,
                        signingBonus: bonus,
                        installments: entry.free ? 1 : installments,
                      )
                  : await ref.read(transferControllerProvider).reviseMarketNegotiation(
                        negotiationId: existing.id,
                        fee: fee,
                        salary: salary,
                        years: years,
                        signingBonus: bonus,
                        installments: entry.free ? 1 : installments,
                      );
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result.message)),
                );
              }
            },
            child: Text(existing == null ? 'Enviar' : 'Reenviar'),
          ),
        ],
      ),
    ),
  );
  feeController.dispose();
  salaryController.dispose();
  bonusController.dispose();
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
