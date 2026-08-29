import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../../domain/match/match_models.dart';
import '../../../domain/player/player.dart';
import '../../../game/match/renderer/match_pitch_game.dart';
import 'live_match_broadcast_overlay.dart';
import 'live_match_phase_transition_overlay.dart';

class LiveMatchPitchPanel extends StatelessWidget {
  const LiveMatchPitchPanel({
    super.key,
    required this.game,
    required this.event,
    required this.teamName,
    required this.replayActive,
    required this.score,
    required this.phaseTransition,
    this.player,
    this.secondaryPlayer,
    this.assistPlayer,
  });

  final MatchPitchGame game;
  final MatchEvent? event;
  final String teamName;
  final bool replayActive;
  final MatchScore score;
  final LiveMatchPhaseTransition? phaseTransition;
  final Player? player;
  final Player? secondaryPlayer;
  final Player? assistPlayer;

  @override
  Widget build(BuildContext context) => AspectRatio(
            aspectRatio: 2.20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  GameWidget(game: game),
                  LiveMatchBroadcastOverlay(
                    event: event,
                    teamName: teamName,
                    player: player,
                    secondaryPlayer: secondaryPlayer,
                    assistPlayer: assistPlayer,
                    replayActive: replayActive,
                    onSkipReplay: game.skipReplay,
                  ),
                  LiveMatchPhaseTransitionOverlay(
                    phase: phaseTransition,
                    score: score,
                  ),
                ],
              ),
            ),
      );
}
