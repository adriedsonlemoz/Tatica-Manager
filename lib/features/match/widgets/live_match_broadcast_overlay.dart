import 'dart:async';

import 'package:flutter/material.dart';

import '../../../domain/match/match_models.dart';
import '../../../domain/player/player.dart';
import '../match_event_presentation.dart';
import 'live_match_event_hero.dart';

class LiveMatchBroadcastOverlay extends StatefulWidget {
  const LiveMatchBroadcastOverlay({
    super.key,
    required this.event,
    required this.teamName,
    required this.replayActive,
    required this.onSkipReplay,
    this.player,
    this.secondaryPlayer,
    this.assistPlayer,
  });

  final MatchEvent? event;
  final String teamName;
  final bool replayActive;
  final VoidCallback onSkipReplay;
  final Player? player;
  final Player? secondaryPlayer;
  final Player? assistPlayer;

  @override
  State<LiveMatchBroadcastOverlay> createState() =>
      _LiveMatchBroadcastOverlayState();
}

class _LiveMatchBroadcastOverlayState extends State<LiveMatchBroadcastOverlay> {
  Timer? _hideTimer;
  bool _eventVisible = false;
  String? _lastEventKey;

  @override
  void initState() {
    super.initState();
    _reactToEvent();
  }

  @override
  void didUpdateWidget(covariant LiveMatchBroadcastOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _reactToEvent();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _reactToEvent() {
    final event = widget.event;
    if (event == null || !MatchEventPresentation.isMajor(event.type)) return;
    final key = '${event.minute}:${event.sequence}:${event.type.name}';
    if (_lastEventKey == key) return;
    _lastEventKey = key;
    _hideTimer?.cancel();
    _eventVisible = true;
    _hideTimer = Timer(
      Duration(milliseconds: _visibleDuration(event.type)),
      () {
        if (mounted) setState(() => _eventVisible = false);
      },
    );
    if (mounted) setState(() {});
  }

  int _visibleDuration(MatchEventType type) => switch (type) {
        MatchEventType.goal || MatchEventType.ownGoal => 2450,
        MatchEventType.woodwork || MatchEventType.penaltySaved => 2150,
        MatchEventType.substitution || MatchEventType.red => 2050,
        _ => 1750,
      };

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: widget.replayActive
                  ? _ReplayBar(
                      key: const ValueKey('replay'),
                      event: widget.event,
                      onSkip: widget.onSkipReplay,
                    )
                  : const SizedBox.shrink(key: ValueKey('live')),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: IgnorePointer(
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                offset: _eventVisible && !widget.replayActive
                    ? Offset.zero
                    : const Offset(0, .28),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 190),
                  opacity: _eventVisible && !widget.replayActive ? 1 : 0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 9),
                    child: widget.event == null
                        ? const SizedBox.shrink()
                        : LiveMatchEventHero(
                            event: widget.event!,
                            teamName: widget.teamName,
                            player: widget.player,
                            secondaryPlayer: widget.secondaryPlayer,
                            assistPlayer: widget.assistPlayer,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
}

class _ReplayBar extends StatelessWidget {
  const _ReplayBar({
    super.key,
    required this.event,
    required this.onSkip,
  });

  final MatchEvent? event;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: .74),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: .20)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.replay_rounded, size: 15, color: Colors.white),
                const SizedBox(width: 5),
                Text(
                  _label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .8,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black.withValues(alpha: .62),
              visualDensity: VisualDensity.compact,
            ),
            icon: const Icon(Icons.skip_next_rounded, size: 16),
            label: const Text('Pular', style: TextStyle(fontSize: 10)),
          ),
        ],
      );

  String get _label => switch (event?.type) {
        MatchEventType.woodwork => 'REPLAY • TRAVE',
        MatchEventType.penaltySaved => 'REPLAY • PÊNALTI',
        _ => 'REPLAY',
      };
}
