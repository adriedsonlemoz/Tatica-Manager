import '../../domain/club/club.dart';
import '../../domain/player/player.dart';
import '../../domain/season/career_state.dart';
import '../lineup/lineup_engine.dart';

class ContractLifecycleResult {
  const ContractLifecycleResult({
    required this.state,
    required this.releasedPlayers,
    required this.changed,
  });

  final CareerState state;
  final List<Player> releasedPlayers;
  final bool changed;

  Set<String> get releasedPlayerIds =>
      releasedPlayers.map((player) => player.id).toSet();
}

abstract final class ContractLifecycleEngine {
  static bool isExpired(Player player, int season) =>
      player.contract.endSeason < season;

  static bool expiresThisSeason(Player player, int season) =>
      player.contract.endSeason == season;

  static bool expiresNextSeason(Player player, int season) =>
      player.contract.endSeason == season + 1;

  static List<Player> expiringThisSeason(CareerState state) =>
      _userContractPlayers(state)
          .where((player) => expiresThisSeason(player, state.season))
          .toList();

  /// Reconciles the single canonical expiration rule used everywhere:
  /// a contract is expired only when its end season is before the current
  /// career season. Calling this method repeatedly is intentionally idempotent.
  static ContractLifecycleResult reconcile(CareerState state) {
    final released = <Player>[];
    final activeIds = <String>{};
    final clubs = <Club>[];
    var changed = false;

    for (final club in state.clubs) {
      final squad = <Player>[];
      for (final player in club.squad) {
        if (isExpired(player, state.season)) {
          released.add(
            player.copyWith(
              clearClubId: true,
              listed: true,
              availableForLoan: false,
              clearLoan: true,
            ),
          );
          changed = true;
        } else {
          squad.add(player);
          activeIds.add(player.id);
        }
      }
      clubs.add(
        squad.length == club.squad.length ? club : club.copyWith(squad: squad),
      );
    }

    final freeById = <String, Player>{};
    for (final player in state.freeAgents) {
      if (activeIds.contains(player.id)) {
        changed = true;
        continue;
      }
      if (freeById.containsKey(player.id)) changed = true;
      freeById[player.id] = player;
    }
    for (final player in released) {
      if (!activeIds.contains(player.id)) {
        freeById[player.id] = player;
      }
    }

    final userClub = clubs.firstWhere((club) => club.id == state.userClubId);
    final userSquadIds = userClub.squad.map((player) => player.id).toSet();
    var starters = state.starterIds
        .where(userSquadIds.contains)
        .toList(growable: false);
    if (starters.length != state.starterIds.length) {
      starters = LineupEngine.autoSelect(userClub.squad, state.formation);
      changed = true;
    }

    final freeAgents = freeById.values.toList(growable: false);
    if (freeAgents.length != state.freeAgents.length) changed = true;

    final next = changed
        ? state.copyWith(
            clubs: clubs,
            freeAgents: freeAgents,
            starterIds: starters,
          )
        : state;

    return ContractLifecycleResult(
      state: next,
      releasedPlayers: released,
      changed: changed,
    );
  }

  static List<Player> _userContractPlayers(CareerState state) {
    final players = <Player>[];
    for (final club in state.clubs) {
      for (final player in club.squad) {
        final belongsToUser =
            (club.id == state.userClubId && player.loan == null) ||
                player.loan?.parentClubId == state.userClubId;
        if (belongsToUser) players.add(player);
      }
    }
    return players;
  }
}
