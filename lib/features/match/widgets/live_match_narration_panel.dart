import 'package:flutter/material.dart';

import '../../../app/widgets/common.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/club/club.dart';
import '../../../domain/match/match_models.dart';
import '../../../domain/player/player.dart';
import '../match_event_presentation.dart';
import 'live_match_event_widgets.dart';

class LiveMatchNarrationPanel extends StatefulWidget {
  const LiveMatchNarrationPanel({
    super.key,
    required this.events,
    required this.minute,
    required this.home,
    required this.away,
    required this.userClubId,
    required this.playersById,
    this.throughSequence,
  });

  final List<MatchEvent> events;
  final int minute;
  final int? throughSequence;
  final Club home;
  final Club away;
  final String userClubId;
  final Map<String, Player> playersById;

  @override
  State<LiveMatchNarrationPanel> createState() =>
      _LiveMatchNarrationPanelState();
}

class _LiveMatchNarrationPanelState extends State<LiveMatchNarrationPanel> {
  MatchNarrationFilter _filter = MatchNarrationFilter.important;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final narration = MatchEventPresentation.visible(
      widget.events,
      widget.minute,
      limit: _expanded ? 36 : 8,
      throughSequence: widget.throughSequence,
      filter: _filter,
      userClubId: widget.userClubId,
    );
    return SectionCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.graphic_eq_rounded, size: 17, color: AppColors.green),
              SizedBox(width: 7),
              Text(
                'NARRAÇÃO AO VIVO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .45,
                ),
              ),
              Spacer(),
              Text(
                'LANCES DA TRANSMISSÃO',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final filter in MatchNarrationFilter.values) ...[
                  ChoiceChip(
                    label: Text(filter.label),
                    selected: _filter == filter,
                    visualDensity: VisualDensity.compact,
                    onSelected: (_) => setState(() => _filter = filter),
                  ),
                  if (filter != MatchNarrationFilter.values.last)
                    const SizedBox(width: 6),
                ],
              ],
            ),
          ),
          const SizedBox(height: 5),
          if (narration.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Nenhum lance deste filtro até agora.',
                style: TextStyle(color: AppColors.muted),
              ),
            ),
          ...narration.map(
            (event) => MatchNarrationTile(
              event: event,
              teamName: _teamName(event),
              player: widget.playersById[event.playerId],
            ),
          ),
          if (narration.length >= 8 || _expanded)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => setState(() => _expanded = !_expanded),
                icon: Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.history_rounded,
                  size: 16,
                ),
                label: Text(
                  _expanded ? 'Compactar' : 'Abrir últimos lances',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _teamName(MatchEvent event) {
    if (event.teamId == widget.home.id) return widget.home.name;
    if (event.teamId == widget.away.id) return widget.away.name;
    return 'Partida';
  }
}
