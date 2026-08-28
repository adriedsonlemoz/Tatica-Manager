import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/season/career_event.dart';

class NewsHighlightsScreen extends StatefulWidget {
  const NewsHighlightsScreen({
    super.key,
    required this.events,
    required this.onEventTap,
  });

  final List<CareerEvent> events;
  final void Function(BuildContext context, CareerEvent event) onEventTap;

  @override
  State<NewsHighlightsScreen> createState() => _NewsHighlightsScreenState();
}

class _NewsHighlightsScreenState extends State<NewsHighlightsScreen> {
  String _filter = 'Todos';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.events.where((event) {
      if (_filter == 'Todos') return true;
      return _category(event.type) == _filter;
    }).toList(growable: false);

    final categories = <String>{
      'Todos',
      for (final event in widget.events) _category(event.type),
    }.toList(growable: false);

    return PremiumScaffold(
      appBar: const GameTopBar(
        title: 'Notícias & Destaques',
        subtitle: 'Acompanhe o que acontece na sua carreira',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
        children: [
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 7),
              itemBuilder: (context, index) {
                final value = categories[index];
                final selected = value == _filter;
                return ChoiceChip(
                  label: Text(value),
                  selected: selected,
                  onSelected: (_) => setState(() => _filter = value),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            const EmptyState(
              icon: Icons.newspaper_rounded,
              title: 'Nenhuma notícia nesta categoria',
              text: 'Avance os dias para gerar novos acontecimentos na carreira.',
            )
          else
            ...filtered.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: _NewsEventCard(
                  event: event,
                  onTap: () => widget.onEventTap(context, event),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _category(CareerEventType type) => switch (type) {
        CareerEventType.training => 'Treino',
        CareerEventType.transferOffer => 'Mercado',
        CareerEventType.contractExpiring => 'Elenco',
        CareerEventType.managerOffer => 'Clube',
        CareerEventType.nextMatch => 'Partidas',
        CareerEventType.playerRecovered || CareerEventType.injuryEnded => 'Médico',
        CareerEventType.suspensionEnded => 'Elenco',
        CareerEventType.seasonStarted => 'Clube',
        CareerEventType.info => 'Geral',
      };
}

class _NewsEventCard extends StatelessWidget {
  const _NewsEventCard({required this.event, required this.onTap});

  final CareerEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _accent(event.type);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [accent.withValues(alpha: .12), AppColors.surface],
            ),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: accent.withValues(alpha: .22)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_icon(event.type), color: accent, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _category(event.type).toUpperCase(),
                            style: TextStyle(color: accent, fontSize: 8, fontWeight: FontWeight.w900),
                          ),
                        ),
                        Text(shortDate(event.date), style: const TextStyle(color: AppColors.muted, fontSize: 8)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(event.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(
                      event.message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, color: AppColors.muted, height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  static String _category(CareerEventType type) => switch (type) {
        CareerEventType.training => 'Treino',
        CareerEventType.transferOffer => 'Mercado',
        CareerEventType.contractExpiring => 'Elenco',
        CareerEventType.managerOffer => 'Clube',
        CareerEventType.nextMatch => 'Partidas',
        CareerEventType.playerRecovered || CareerEventType.injuryEnded => 'Médico',
        CareerEventType.suspensionEnded => 'Elenco',
        CareerEventType.seasonStarted => 'Clube',
        CareerEventType.info => 'Geral',
      };

  static IconData _icon(CareerEventType type) => switch (type) {
        CareerEventType.playerRecovered || CareerEventType.injuryEnded => Icons.healing_rounded,
        CareerEventType.suspensionEnded => Icons.gavel_rounded,
        CareerEventType.contractExpiring => Icons.description_rounded,
        CareerEventType.transferOffer => Icons.swap_horiz_rounded,
        CareerEventType.managerOffer => Icons.business_center_rounded,
        CareerEventType.nextMatch => Icons.sports_soccer_rounded,
        CareerEventType.training => Icons.fitness_center_rounded,
        CareerEventType.seasonStarted => Icons.emoji_events_rounded,
        CareerEventType.info => Icons.newspaper_rounded,
      };

  static Color _accent(CareerEventType type) => switch (type) {
        CareerEventType.transferOffer => const Color(0xFF5EC8FF),
        CareerEventType.managerOffer => const Color(0xFFFFC857),
        CareerEventType.playerRecovered || CareerEventType.injuryEnded => const Color(0xFF62DCC9),
        CareerEventType.contractExpiring || CareerEventType.suspensionEnded => const Color(0xFFFFB14A),
        CareerEventType.nextMatch => AppColors.green,
        CareerEventType.training => const Color(0xFF8EEA3C),
        CareerEventType.seasonStarted => const Color(0xFFFFD166),
        CareerEventType.info => const Color(0xFFB9C3C1),
      };
}
