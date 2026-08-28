import 'package:flutter/services.dart';

import '../../domain/match/match_models.dart';

/// Feedback tátil centralizado. Nesta versão, apenas gols podem vibrar.
/// A camada reage à apresentação e nunca interfere no Match Engine.
abstract final class HapticFeedbackService {
  static Future<void> interfaceTap({required bool enabled}) async {
    if (!enabled) return;
    // Intencionalmente sem vibração para botões, cards, navegação e menus.
  }

  static Future<void> matchEvent(
    MatchEvent event, {
    required bool enabled,
  }) async {
    if (!enabled) return;
    if (event.type != MatchEventType.goal && event.type != MatchEventType.ownGoal) {
      return;
    }
    await _safe(HapticFeedback.mediumImpact);
  }

  static Future<void> _safe(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // Vibração indisponível não pode interromper a partida.
    }
  }
}
