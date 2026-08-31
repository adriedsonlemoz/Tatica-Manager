part of 'market_screen.dart';

class _SearchTab extends ConsumerWidget {
  const _SearchTab({required this.entries, required this.windowOpen});

  final List<_MarketEntry> entries;
  final bool windowOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(gameControllerProvider).career!;
    if (entries.isEmpty) {
      return const _EmptyMarketState(
        icon: Icons.search_off_rounded,
        title: 'Nenhum jogador encontrado',
        message: 'Ajuste os filtros para ampliar a busca.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 110),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final report = MarketCareerEngine.reportFor(career, entry.player.id);
        return _MarketPlayerCard(
          entry: entry,
          report: report,
          onTap: () => _showPlayerMarketSheet(
            context,
            ref,
            entry: entry,
            report: report,
            windowOpen: windowOpen,
          ),
        );
      },
    );
  }
}

class _ScoutingTab extends ConsumerWidget {
  const _ScoutingTab({required this.entries});

  final List<_MarketEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(gameControllerProvider).career!;
    if (entries.isEmpty) {
      return const _EmptyMarketState(
        icon: Icons.visibility_outlined,
        title: 'Nenhum jogador em observação',
        message: 'Abra um jogador em Buscar e inicie a observação.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 110),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final report = MarketCareerEngine.reportFor(career, entry.player.id)!;
        return _MarketPlayerCard(
          entry: entry,
          report: report,
          showScoutingProgress: true,
          onTap: () => _showPlayerMarketSheet(
            context,
            ref,
            entry: entry,
            report: report,
            windowOpen: TransferWindowEngine.isOpen(career.currentDate),
          ),
        );
      },
    );
  }
}

enum _NegotiationFilter { all, received, active, history }

class _NegotiationsTab extends ConsumerStatefulWidget {
  const _NegotiationsTab({required this.career});

  final CareerState career;

  @override
  ConsumerState<_NegotiationsTab> createState() => _NegotiationsTabState();
}

class _NegotiationsTabState extends ConsumerState<_NegotiationsTab> {
  _NegotiationFilter _filter = _NegotiationFilter.all;

  @override
  Widget build(BuildContext context) {
    final negotiations = widget.career.transferNegotiations.where((item) {
      return switch (_filter) {
        _NegotiationFilter.all => true,
        _NegotiationFilter.received =>
          item.status == TransferNegotiationStatus.received,
        _NegotiationFilter.active =>
          item.status.isOpen && item.status != TransferNegotiationStatus.received,
        _NegotiationFilter.history => !item.status.isOpen,
      };
    }).toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 110),
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _NegotiationFilter.values.map((filter) {
            final label = switch (filter) {
              _NegotiationFilter.all => 'Todas',
              _NegotiationFilter.received => 'Recebidas',
              _NegotiationFilter.active => 'Em andamento',
              _NegotiationFilter.history => 'Histórico',
            };
            return ChoiceChip(
              label: Text(label),
              selected: _filter == filter,
              onSelected: (_) => setState(() => _filter = filter),
            );
          }).toList(growable: false),
        ),
        const SizedBox(height: 10),
        if (negotiations.isEmpty)
          _EmptyMarketState(
            icon: _filter == _NegotiationFilter.history
                ? Icons.history_rounded
                : Icons.handshake_outlined,
            title: _filter == _NegotiationFilter.received
                ? 'Sem propostas recebidas'
                : _filter == _NegotiationFilter.history
                    ? 'Histórico vazio'
                    : 'Nenhuma negociação aqui',
            message: _filter == _NegotiationFilter.received
                ? 'Ofertas por jogadores do seu elenco chegam nesta Central.'
                : _filter == _NegotiationFilter.history
                    ? 'Acordos concluídos, recusados ou cancelados aparecerão aqui.'
                    : 'Compras, vendas, renovações e empréstimos usam esta mesma Central.',
          )
        else
          ...negotiations.map((negotiation) {
            final entry = _entryForNegotiation(widget.career, negotiation);
            return _NegotiationCard(
              career: widget.career,
              negotiation: negotiation,
              entry: entry,
              compact: !negotiation.status.isOpen,
              onAccept:
                  negotiation.status == TransferNegotiationStatus.received
                      ? () => _runAndShow(
                            context,
                            ref
                                .read(transferControllerProvider)
                                .acceptReceivedNegotiation(negotiation.id),
                          )
                      : null,
              onReject:
                  negotiation.status == TransferNegotiationStatus.received
                      ? () => _runAndShow(
                            context,
                            ref
                                .read(transferControllerProvider)
                                .rejectReceivedNegotiation(negotiation.id),
                          )
                      : null,
              onRevise: negotiation.status == TransferNegotiationStatus.countered
                  ? () {
                      if (negotiation.kind == TransferNegotiationKind.loan) return;
                      if (negotiation.kind ==
                          TransferNegotiationKind.contractRenewal) {
                        _showRenewalNegotiationDialog(
                          context,
                          ref,
                          player: entry?.player,
                          existing: negotiation,
                        );
                      } else {
                        _showNegotiationDialog(
                          context,
                          ref,
                          entry: entry,
                          existing: negotiation,
                        );
                      }
                    }
                  : null,
              onComplete: negotiation.status == TransferNegotiationStatus.accepted
                  ? () => _runAndShow(
                        context,
                        ref
                            .read(transferControllerProvider)
                            .completeMarketNegotiation(negotiation.id),
                      )
                  : null,
              onClose: negotiation.status.isOpen &&
                      negotiation.status != TransferNegotiationStatus.received
                  ? () => _runAndShow(
                        context,
                        ref
                            .read(transferControllerProvider)
                            .closeMarketNegotiation(negotiation.id),
                      )
                  : null,
            );
          }),
      ],
    );
  }

  Future<void> _runAndShow(
    BuildContext context,
    Future<TransferOperationResult> result,
  ) async {
    final operation = await result;
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(operation.message)),
    );
  }
}

_MarketEntry? _entryForNegotiation(
  CareerState career,
  TransferNegotiation negotiation,
) {
  for (final club in career.clubs) {
    final player = club.squad
        .where((item) => item.id == negotiation.playerId)
        .firstOrNull;
    if (player != null) {
      return _MarketEntry(
        player: player,
        club: club,
        free: false,
        seriesId: CompetitionCatalog.primarySeriesForClub(club.id).id,
      );
    }
  }
  final player = career.freeAgents
      .where((item) => item.id == negotiation.playerId)
      .firstOrNull;
  if (player == null) return null;
  return _MarketEntry(player: player, club: null, free: true, seriesId: null);
}

class _MarketPlayerCard extends StatelessWidget {
  const _MarketPlayerCard({
    required this.entry,
    required this.report,
    required this.onTap,
    this.showScoutingProgress = false,
  });

  final _MarketEntry entry;
  final PlayerScoutingReport? report;
  final VoidCallback onTap;
  final bool showScoutingProgress;

  @override
  Widget build(BuildContext context) {
    final player = entry.player;
    final accent = entry.club == null
        ? AppColors.green
        : Color(entry.club!.colors.primaryHex);
    return SectionCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              PlayerAvatar(player: player, size: 46, accentColor: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${entry.club?.shortName ?? 'Sem clube'} • ${player.primaryPosition.label} • ${player.age} anos • ${player.nationality}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.muted, fontSize: 10),
                    ),
                    const SizedBox(height: 5),
                    _KnowledgeLine(player: player, report: report),
                    if (showScoutingProgress) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${report!.level.label} • ${report!.daysObserved} dia(s) observado',
                        style: const TextStyle(
                          color: AppColors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _KnowledgeLine extends StatelessWidget {
  const _KnowledgeLine({required this.player, required this.report});

  final Player player;
  final PlayerScoutingReport? report;

  @override
  Widget build(BuildContext context) {
    final level = report?.level;
    final text = switch (level) {
      null => 'OVR —  • POT —  • Valor —',
      ScoutingLevel.initial =>
        'OVR ~${(player.overall - 4).clamp(35, 99)}–${(player.overall + 4).clamp(35, 99)} • POT — • Valor —',
      ScoutingLevel.observed =>
        'OVR ${player.overall} • POT ~${(player.potential - 5).clamp(player.overall, 99)}–${(player.potential + 5).clamp(player.overall, 99)} • ${formatMoney((player.marketValue * .9).round())}–${formatMoney((player.marketValue * 1.1).round())}',
      ScoutingLevel.complete =>
        'OVR ${player.overall} • POT ${player.potential} • ${formatMoney(player.marketValue)}',
    };
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: level == ScoutingLevel.complete ? AppColors.green : AppColors.muted,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _NegotiationCard extends StatelessWidget {
  const _NegotiationCard({
    required this.career,
    required this.negotiation,
    required this.entry,
    this.onAccept,
    this.onReject,
    this.onRevise,
    this.onComplete,
    this.onClose,
    this.compact = false,
  });

  final CareerState career;
  final TransferNegotiation negotiation;
  final _MarketEntry? entry;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onRevise;
  final VoidCallback? onComplete;
  final VoidCallback? onClose;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final source = career.clubs
        .where((club) => club.id == negotiation.fromClubId)
        .firstOrNull;
    final target = career.clubs
        .where((club) => club.id == negotiation.toClubId)
        .firstOrNull;
    final counterpart = switch (negotiation.kind) {
      TransferNegotiationKind.contractRenewal => 'Seu elenco',
      _ when negotiation.fromClubId == career.userClubId =>
        target?.shortName ?? 'Clube interessado',
      _ => source?.shortName ?? 'Agente livre',
    };
    final headlineValue = switch (negotiation.kind) {
      TransferNegotiationKind.permanentTransfer => formatMoney(negotiation.fee),
      TransferNegotiationKind.contractRenewal => 'Renovação',
      TransferNegotiationKind.loan => negotiation.loanEndDate == null
          ? 'Empréstimo'
          : 'até ${_shortDate(negotiation.loanEndDate!)}',
    };
    final valueStyle = TextStyle(
      color: negotiation.kind == TransferNegotiationKind.contractRenewal
          ? AppColors.green
          : null,
      fontWeight: FontWeight.w900,
      fontSize: 12,
    );
    return SectionCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (entry != null)
                PlayerAvatar(
                  player: entry!.player,
                  size: 40,
                  accentColor: entry!.club == null
                      ? AppColors.green
                      : Color(entry!.club!.colors.primaryHex),
                ),
              if (entry != null) const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry?.player.displayName ?? 'Jogador indisponível',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      '${negotiation.kind.shortLabel} • ${negotiation.status.label} • $counterpart',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.green, fontSize: 10),
                    ),
                  ],
                ),
              ),
              Text(
                headlineValue,
                textAlign: TextAlign.end,
                style: valueStyle,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            negotiation.message,
            style: const TextStyle(color: AppColors.muted, fontSize: 11),
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _MiniTag('Salário ${formatMoney(negotiation.salary)}/mês'),
              if (negotiation.kind != TransferNegotiationKind.loan)
                _MiniTag('${negotiation.contractYears} ano(s)'),
              if (negotiation.kind == TransferNegotiationKind.loan &&
                  negotiation.loanEndDate != null)
                _MiniTag('Retorno ${_shortDate(negotiation.loanEndDate!)}'),
              if (negotiation.kind != TransferNegotiationKind.loan &&
                  negotiation.signingBonus > 0)
                _MiniTag('Luvas ${formatMoney(negotiation.signingBonus)}'),
              if (negotiation.kind == TransferNegotiationKind.permanentTransfer &&
                  negotiation.installments > 1)
                _MiniTag('${negotiation.installments} parcelas'),
              if (negotiation.otherClubsInterested > 0)
                _MiniTag('${negotiation.otherClubsInterested} rival(is)'),
            ],
          ),
          if (negotiation.counterFee != null || negotiation.counterSalary != null) ...[
            const SizedBox(height: 8),
            Text(
              _counterText(negotiation),
              style: const TextStyle(
                color: AppColors.warning,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          if (!compact &&
              (onAccept != null ||
                  onReject != null ||
                  onRevise != null ||
                  onComplete != null ||
                  onClose != null)) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (onAccept != null)
                  FilledButton.icon(
                    onPressed: onAccept,
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Aceitar bases'),
                  ),
                if (onReject != null)
                  OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Recusar'),
                  ),
                if (onRevise != null)
                  OutlinedButton.icon(
                    onPressed: onRevise,
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Contrapropor'),
                  ),
                if (onComplete != null)
                  FilledButton.icon(
                    onPressed: onComplete,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Concluir'),
                  ),
                if (onClose != null)
                  TextButton(
                    onPressed: onClose,
                    child: const Text('Cancelar'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _shortDate(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

  static String _counterText(TransferNegotiation negotiation) {
    if (negotiation.kind == TransferNegotiationKind.contractRenewal) {
      return 'Contraproposta salarial: ${negotiation.counterSalary == null ? '—' : '${formatMoney(negotiation.counterSalary!)}/mês'}';
    }
    return 'Contraproposta: ${negotiation.counterFee == null ? '—' : formatMoney(negotiation.counterFee!)} • salário ${negotiation.counterSalary == null ? '—' : '${formatMoney(negotiation.counterSalary!)}/mês'}';
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(text, style: const TextStyle(fontSize: 10)),
      );
}

class _WindowStatus extends StatelessWidget {
  const _WindowStatus({required this.open, required this.date});
  final bool open;
  final DateTime date;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: (open ? AppColors.green : AppColors.warning).withValues(alpha: .10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: open ? AppColors.green : AppColors.warning),
        ),
        child: Row(
          children: [
            Icon(
              open ? Icons.lock_open_rounded : Icons.lock_clock_rounded,
              color: open ? AppColors.green : AppColors.warning,
              size: 19,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${TransferWindowEngine.statusLabel(date)} • ${TransferWindowEngine.rulesLabel}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
              ),
            ),
          ],
        ),
      );
}

class _EmptyMarketState extends StatelessWidget {
  const _EmptyMarketState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: AppColors.muted),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 5),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
      );
}

class _MarketEntry {
  const _MarketEntry({
    required this.player,
    required this.club,
    required this.free,
    required this.seriesId,
  });

  final Player player;
  final Club? club;
  final bool free;
  final String? seriesId;
}

class _MarketFilters {
  const _MarketFilters({
    this.nationality,
    this.clubId,
    this.seriesId,
    this.minAge = 15,
    this.maxAge = 45,
    this.minOverall = 35,
    this.minPotential = 35,
    this.maxValue = 0,
    this.maxSalary = 0,
    this.freeOnly = false,
    this.expiringOnly = false,
  });

  final String? nationality;
  final String? clubId;
  final String? seriesId;
  final int minAge;
  final int maxAge;
  final int minOverall;
  final int minPotential;
  final int maxValue;
  final int maxSalary;
  final bool freeOnly;
  final bool expiringOnly;

  bool get isActive =>
      nationality != null ||
      clubId != null ||
      seriesId != null ||
      minAge != 15 ||
      maxAge != 45 ||
      minOverall != 35 ||
      minPotential != 35 ||
      maxValue > 0 ||
      maxSalary > 0 ||
      freeOnly ||
      expiringOnly;

  String get summary {
    final values = <String>[];
    if (nationality != null) values.add(nationality!);
    if (clubId != null) values.add('clube');
    if (seriesId != null) values.add(CompetitionCatalog.displayNameForId(seriesId!));
    if (minAge != 15 || maxAge != 45) values.add('$minAge–$maxAge anos');
    if (minOverall > 35) values.add('OVR ≥ $minOverall');
    if (minPotential > 35) values.add('POT ≥ $minPotential');
    if (maxValue > 0) values.add('valor ≤ ${formatMoney(maxValue)}');
    if (maxSalary > 0) values.add('salário ≤ ${formatMoney(maxSalary)}');
    if (freeOnly) values.add('livres');
    if (expiringOnly) values.add('contrato curto');
    return values.join(' • ');
  }
}
