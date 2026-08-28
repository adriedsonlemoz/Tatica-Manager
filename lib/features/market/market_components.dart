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

class _NegotiationsTab extends ConsumerWidget {
  const _NegotiationsTab({required this.negotiations, required this.entries});

  final List<TransferNegotiation> negotiations;
  final List<_MarketEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (negotiations.isEmpty) {
      return const _EmptyMarketState(
        icon: Icons.handshake_outlined,
        title: 'Nenhuma negociação ativa',
        message: 'Envie uma proposta por um jogador observado.',
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 110),
      children: negotiations.map((negotiation) {
        final entry = entries
            .where((item) => item.player.id == negotiation.playerId)
            .firstOrNull;
        return _NegotiationCard(
          negotiation: negotiation,
          entry: entry,
          onRevise: negotiation.status == TransferNegotiationStatus.countered
              ? () => _showNegotiationDialog(
                    context,
                    ref,
                    entry: entry,
                    existing: negotiation,
                  )
              : null,
          onComplete: negotiation.status == TransferNegotiationStatus.accepted
              ? () async {
                  final result = await ref
                      .read(transferControllerProvider)
                      .completeMarketNegotiation(negotiation.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result.message)),
                    );
                  }
                }
              : null,
          onClose: () => ref
              .read(transferControllerProvider)
              .closeMarketNegotiation(negotiation.id),
        );
      }).toList(growable: false),
    );
  }
}

class _IncomingOffersTab extends ConsumerWidget {
  const _IncomingOffersTab({required this.events});

  final List<CareerEvent> events;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (events.isEmpty) {
      return const _EmptyMarketState(
        icon: Icons.mark_email_read_outlined,
        title: 'Sem propostas recebidas',
        message: 'Ofertas da CPU pelo seu elenco aparecerão aqui.',
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 110),
      children: events.map((event) {
        return SectionCard(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              const Icon(Icons.mark_email_unread_rounded, color: AppColors.green),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title,
                        style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    Text(
                      event.message,
                      style: const TextStyle(color: AppColors.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => showIncomingTransferOfferDialog(
                  context,
                  ref,
                  eventId: event.id,
                ),
                child: const Text('Analisar'),
              ),
            ],
          ),
        );
      }).toList(growable: false),
    );
  }
}

class _NegotiationHistoryTab extends StatelessWidget {
  const _NegotiationHistoryTab({required this.negotiations, required this.entries});

  final List<TransferNegotiation> negotiations;
  final List<_MarketEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (negotiations.isEmpty) {
      return const _EmptyMarketState(
        icon: Icons.history_rounded,
        title: 'Histórico vazio',
        message: 'Negociações concluídas, recusadas ou encerradas ficarão aqui.',
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 110),
      children: negotiations.map((negotiation) {
        final entry = entries
            .where((item) => item.player.id == negotiation.playerId)
            .firstOrNull;
        return _NegotiationCard(
          negotiation: negotiation,
          entry: entry,
          compact: true,
        );
      }).toList(growable: false),
    );
  }
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
    required this.negotiation,
    required this.entry,
    this.onRevise,
    this.onComplete,
    this.onClose,
    this.compact = false,
  });

  final TransferNegotiation negotiation;
  final _MarketEntry? entry;
  final VoidCallback? onRevise;
  final VoidCallback? onComplete;
  final VoidCallback? onClose;
  final bool compact;

  @override
  Widget build(BuildContext context) {
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
                      '${negotiation.status.label} • ${entry?.club?.shortName ?? 'Sem clube'}',
                      style: const TextStyle(color: AppColors.green, fontSize: 10),
                    ),
                  ],
                ),
              ),
              Text(
                formatMoney(negotiation.fee),
                style: const TextStyle(fontWeight: FontWeight.w900),
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
              _MiniTag('Salário ${formatMoney(negotiation.salary)}'),
              _MiniTag('${negotiation.contractYears} ano(s)'),
              _MiniTag('Bônus ${formatMoney(negotiation.signingBonus)}'),
              _MiniTag('${negotiation.installments} parcela(s)'),
              if (negotiation.otherClubsInterested > 0)
                _MiniTag('${negotiation.otherClubsInterested} rival(is)'),
            ],
          ),
          if (negotiation.counterFee != null || negotiation.counterSalary != null) ...[
            const SizedBox(height: 8),
            Text(
              'Contraproposta: ${negotiation.counterFee == null ? '—' : formatMoney(negotiation.counterFee!)} • salário ${negotiation.counterSalary == null ? '—' : formatMoney(negotiation.counterSalary!)}',
              style: const TextStyle(
                color: AppColors.warning,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          if (!compact && (onRevise != null || onComplete != null || onClose != null)) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (onRevise != null)
                  OutlinedButton.icon(
                    onPressed: onRevise,
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Revisar'),
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
                    child: const Text('Encerrar'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
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
