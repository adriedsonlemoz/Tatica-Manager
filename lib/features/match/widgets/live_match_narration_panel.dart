import 'package:flutter/material.dart';

import '../../../app/widgets/common.dart';
import '../../../app/widgets/player_avatar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/club/club.dart';
import '../../../domain/match/match_models.dart';
import '../../../domain/player/player.dart';
import '../match_event_presentation.dart';
import 'live_match_event_widgets.dart';

class LiveMatchNarrationPanel extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final narration = MatchEventPresentation.visible(
      events,
      minute,
      limit: 2,
      throughSequence: throughSequence,
      filter: MatchNarrationFilter.important,
      userClubId: userClubId,
    );
    return SectionCard(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 7),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.graphic_eq_rounded,
                size: 15,
                color: AppColors.green,
              ),
              const SizedBox(width: 6),
              const Text(
                'NARRAÇÃO AO VIVO',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .35,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _openHistory(context),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  minimumSize: const Size(0, 27),
                ),
                icon: const Icon(Icons.history_rounded, size: 14),
                label: const Text('Histórico', style: TextStyle(fontSize: 9.5)),
              ),
            ],
          ),
          Expanded(
            child: narration.isEmpty
                ? const Center(
                    child: Text(
                      'Aguardando o primeiro lance importante.',
                      style: TextStyle(color: AppColors.muted, fontSize: 10),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final event in narration)
                        Expanded(
                          child: _CompactNarrationLine(
                            event: event,
                            teamName: _teamName(event),
                            player: playersById[event.playerId],
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  String _teamName(MatchEvent event) {
    if (event.teamId == home.id) return home.name;
    if (event.teamId == away.id) return away.name;
    return 'Partida';
  }

  Future<void> _openHistory(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        backgroundColor: AppColors.background,
        barrierColor: Colors.black.withValues(alpha: .72),
        builder: (_) => _NarrationHistorySheet(
          events: events,
          minute: minute,
          throughSequence: throughSequence,
          home: home,
          away: away,
          userClubId: userClubId,
          playersById: playersById,
        ),
      );
}

class _CompactNarrationLine extends StatelessWidget {
  const _CompactNarrationLine({
    required this.event,
    required this.teamName,
    required this.player,
  });

  final MatchEvent event;
  final String teamName;
  final Player? player;

  @override
  Widget build(BuildContext context) {
    final color = matchEventColor(event.type);
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(
            "${event.minute}'",
            style: TextStyle(
              color: color,
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Container(
          width: 21,
          height: 21,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(matchEventIcon(event.type), size: 12, color: color),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                MatchEventPresentation.headline(event.type, teamName),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 9.2, fontWeight: FontWeight.w900),
              ),
              Text(
                MatchEventPresentation.narration(event, teamName),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted, fontSize: 8.5),
              ),
            ],
          ),
        ),
        if (player != null) ...[
          const SizedBox(width: 5),
          PlayerAvatar(player: player!, size: 23, accentColor: color),
        ],
      ],
    );
  }
}

class _NarrationHistorySheet extends StatefulWidget {
  const _NarrationHistorySheet({
    required this.events,
    required this.minute,
    required this.throughSequence,
    required this.home,
    required this.away,
    required this.userClubId,
    required this.playersById,
  });

  final List<MatchEvent> events;
  final int minute;
  final int? throughSequence;
  final Club home;
  final Club away;
  final String userClubId;
  final Map<String, Player> playersById;

  @override
  State<_NarrationHistorySheet> createState() =>
      _NarrationHistorySheetState();
}

class _NarrationHistorySheetState extends State<_NarrationHistorySheet> {
  MatchNarrationFilter filter = MatchNarrationFilter.important;

  @override
  Widget build(BuildContext context) {
    final narration = MatchEventPresentation.visible(
      widget.events,
      widget.minute,
      limit: 80,
      throughSequence: widget.throughSequence,
      filter: filter,
      userClubId: widget.userClubId,
    );
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .76,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              'Histórico da transmissão',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                for (final item in MatchNarrationFilter.values) ...[
                  ChoiceChip(
                    label: Text(item.label),
                    selected: filter == item,
                    selectedColor: AppColors.green.withValues(alpha: .18),
                    side: BorderSide(
                      color: filter == item
                          ? AppColors.green
                          : AppColors.border,
                    ),
                    onSelected: (_) => setState(() => filter = item),
                  ),
                  if (item != MatchNarrationFilter.values.last)
                    const SizedBox(width: 6),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: narration.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum lance deste filtro até agora.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                    itemCount: narration.length,
                    itemBuilder: (context, index) {
                      final event = narration[index];
                      return MatchNarrationTile(
                        event: event,
                        teamName: _teamName(event),
                        player: widget.playersById[event.playerId],
                      );
                    },
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
