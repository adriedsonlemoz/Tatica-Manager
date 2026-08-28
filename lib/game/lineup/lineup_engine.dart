import '../../domain/formation/formation.dart';
import '../../domain/player/player.dart';

class AssignedPlayer {
  const AssignedPlayer({required this.slot, required this.player, required this.fit});

  final FormationSlot slot;
  final Player player;
  final double fit;

  int get effectiveOverall => LineupEngine.effectiveOverall(player, slot.role);
  bool get outOfPosition => fit < .9;
}

class LineupCandidate {
  const LineupCandidate({
    required this.player,
    required this.role,
    required this.fit,
    required this.effectiveOverall,
  });

  final Player player;
  final PlayerPosition role;
  final double fit;
  final int effectiveOverall;

  bool get natural => fit >= .99;
  bool get secondary => fit >= .9 && fit < .99;
  bool get compatible => fit >= .8;
}

class LineupValidation {
  const LineupValidation({
    required this.isComplete,
    required this.hasGoalkeeper,
    required this.availableOnly,
    required this.averageStrength,
    required this.assignments,
  });

  final bool isComplete;
  final bool hasGoalkeeper;
  final bool availableOnly;
  final int averageStrength;
  final List<AssignedPlayer> assignments;

  bool get isValid => isComplete && hasGoalkeeper && availableOnly;
  bool get valid => isValid;

  String get message {
    if (!isComplete) return 'A escalação precisa ter 11 jogadores únicos.';
    if (!hasGoalkeeper) return 'A escalação precisa de um goleiro compatível.';
    if (!availableOnly) {
      return 'Há jogador lesionado, suspenso ou sem condição na escalação.';
    }
    return 'Escalação válida.';
  }
}

abstract final class LineupEngine {
  static const Map<PlayerPosition, List<PlayerPosition>> compatibility = {
    PlayerPosition.ca: [PlayerPosition.sa, PlayerPosition.pd, PlayerPosition.pe],
    PlayerPosition.sa: [
      PlayerPosition.ca,
      PlayerPosition.pd,
      PlayerPosition.pe,
      PlayerPosition.mei,
    ],
    PlayerPosition.pe: [
      PlayerPosition.ca,
      PlayerPosition.pd,
      PlayerPosition.sa,
      PlayerPosition.mei,
    ],
    PlayerPosition.pd: [
      PlayerPosition.ca,
      PlayerPosition.pe,
      PlayerPosition.sa,
      PlayerPosition.mei,
    ],
    PlayerPosition.mei: [PlayerPosition.mc, PlayerPosition.sa, PlayerPosition.vol],
    PlayerPosition.mc: [PlayerPosition.vol, PlayerPosition.mei],
    PlayerPosition.vol: [PlayerPosition.mc, PlayerPosition.zag],
    PlayerPosition.zag: [PlayerPosition.vol, PlayerPosition.ld, PlayerPosition.le],
    PlayerPosition.ld: [PlayerPosition.zag, PlayerPosition.pd, PlayerPosition.le],
    PlayerPosition.le: [PlayerPosition.zag, PlayerPosition.pe, PlayerPosition.ld],
    PlayerPosition.gol: [],
  };

  static double positionFit(Player player, PlayerPosition role) {
    if (player.primaryPosition == role) return 1;
    if (player.secondaryPositions.contains(role)) return .92;
    if (compatibility[player.primaryPosition]?.contains(role) ?? false) return .80;
    if (role == PlayerPosition.gol ||
        player.primaryPosition == PlayerPosition.gol) {
      return .45;
    }
    return .66;
  }

  static String fitLabel(Player player, PlayerPosition role) {
    final fit = positionFit(player, role);
    if (fit >= .99) return 'Natural';
    if (fit >= .9) return 'Secundária';
    if (fit >= .8) return 'Compatível';
    if (fit <= .45) return 'Incompatível';
    return 'Improvisado';
  }

  static int effectiveOverall(Player player, PlayerPosition role) {
    final conditionMultiplier = .80 + player.condition.clamp(0, 100) / 500;
    final fatiguePenalty = player.fatigue.clamp(0, 100) * .10;
    final moraleMultiplier = .95 + player.morale.clamp(0, 100) / 1000;
    final fit = positionFit(player, role);
    return (player.overall *
                fit *
                conditionMultiplier *
                moraleMultiplier -
            fatiguePenalty)
        .round()
        .clamp(30, 99)
        .toInt();
  }

  static List<LineupCandidate> candidatesForRole(
    List<Player> squad,
    PlayerPosition role, {
    Set<String> excludedIds = const {},
    bool availableOnly = true,
    Set<String>? competitionSuspendedPlayerIds,
  }) {
    final candidates = squad
        .where(
          (player) =>
              !excludedIds.contains(player.id) &&
              (!availableOnly ||
                  _isAvailableForCompetition(
                    player,
                    competitionSuspendedPlayerIds,
                  )),
        )
        .map(
          (player) => LineupCandidate(
            player: player,
            role: role,
            fit: positionFit(player, role),
            effectiveOverall: effectiveOverall(player, role),
          ),
        )
        .toList();
    candidates.sort(_compareCandidates);
    return candidates;
  }

  static int _compareCandidates(LineupCandidate a, LineupCandidate b) {
    final effectiveDifference = b.effectiveOverall - a.effectiveOverall;
    // Quando a diferença é irrelevante, preserva a posição mais natural.
    if (effectiveDifference.abs() > 1) return effectiveDifference;
    final fitCompare = b.fit.compareTo(a.fit);
    if (fitCompare != 0) return fitCompare;
    final overallCompare = b.player.overall.compareTo(a.player.overall);
    if (overallCompare != 0) return overallCompare;
    final conditionCompare = b.player.condition.compareTo(a.player.condition);
    if (conditionCompare != 0) return conditionCompare;
    return a.player.displayName.compareTo(b.player.displayName);
  }

  static List<String> autoSelect(
    List<Player> squad,
    FormationType formation, {
    Set<String>? competitionSuspendedPlayerIds,
  }) {
    final slots = _slots(formation);
    final used = <String>{};
    final ids = <String>[];
    for (final slot in slots) {
      final candidates = candidatesForRole(
        squad,
        slot.role,
        excludedIds: used,
        competitionSuspendedPlayerIds: competitionSuspendedPlayerIds,
      );
      if (candidates.isEmpty) break;
      final selected = candidates.first.player;
      used.add(selected.id);
      ids.add(selected.id);
    }
    return ids;
  }

  /// `starterIds` é persistido na mesma ordem dos slots da formação.
  /// Isso garante que uma troca manual permaneça exatamente na posição escolhida
  /// e evita redistribuir silenciosamente os onze jogadores no momento da partida.
  static List<AssignedPlayer> assign(
    List<Player> squad,
    List<String> starterIds,
    FormationType formation,
  ) {
    final slots = _slots(formation);
    final byId = {for (final player in squad) player.id: player};
    final used = <String>{};
    final assignments = <AssignedPlayer>[];
    final count = starterIds.length < slots.length ? starterIds.length : slots.length;
    for (var index = 0; index < count; index++) {
      final id = starterIds[index];
      if (!used.add(id)) continue;
      final player = byId[id];
      if (player == null) continue;
      final slot = slots[index];
      assignments.add(
        AssignedPlayer(
          slot: slot,
          player: player,
          fit: positionFit(player, slot.role),
        ),
      );
    }
    return assignments;
  }

  static FormationSlot? slotForStarter(
    List<String> starterIds,
    FormationType formation,
    String playerId,
  ) {
    final index = starterIds.indexOf(playerId);
    final slots = _slots(formation);
    if (index < 0 || index >= slots.length) return null;
    return slots[index];
  }

  static LineupValidation validate(
    List<Player> squad,
    List<String> starterIds,
    FormationType formation, {
    Set<String>? competitionSuspendedPlayerIds,
  }) {
    final unique = starterIds.toSet();
    final assignments = assign(squad, starterIds, formation);
    final complete =
        starterIds.length == 11 && unique.length == 11 && assignments.length == 11;
    final hasGoalkeeper = assignments.any(
      (assignment) =>
          assignment.slot.role == PlayerPosition.gol && assignment.fit >= .8,
    );
    final availableOnly = assignments.every(
      (assignment) => _isAvailableForCompetition(
        assignment.player,
        competitionSuspendedPlayerIds,
      ),
    );
    final avg = assignments.isEmpty
        ? 0
        : (assignments.fold<int>(
                  0,
                  (sum, assignment) => sum + assignment.effectiveOverall,
                ) /
                assignments.length)
            .round();
    return LineupValidation(
      isComplete: complete,
      hasGoalkeeper: hasGoalkeeper,
      availableOnly: availableOnly,
      averageStrength: avg,
      assignments: assignments,
    );
  }

  static bool _isAvailableForCompetition(
    Player player,
    Set<String>? competitionSuspendedPlayerIds,
  ) {
    if (competitionSuspendedPlayerIds == null) return player.isAvailable;
    if (player.injury != null || player.condition < 35) return false;
    return !competitionSuspendedPlayerIds.contains(player.id);
  }

  static List<String> replaceStarter(
    List<String> starterIds,
    String outgoingId,
    String incomingId,
  ) {
    if (starterIds.contains(incomingId)) return starterIds;
    return starterIds.map((id) => id == outgoingId ? incomingId : id).toList();
  }

  static List<FormationSlot> _slots(FormationType formation) =>
      FormationCatalog.slots[formation] ??
      FormationCatalog.slots[FormationType.f433]!;
}
