import 'dart:math';

import '../../domain/club/club.dart';
import '../../domain/match/match_models.dart';
import '../../domain/player/player.dart';
import '../morale/morale_engine.dart';

class MatchCareerImpact {
  const MatchCareerImpact({
    required this.clubs,
    required this.competitionPlayerStats,
    required this.competitionPlayerDiscipline,
  });

  final List<Club> clubs;
  final Map<String, PlayerSeasonStats> competitionPlayerStats;
  final Map<String, PlayerDiscipline> competitionPlayerDiscipline;
}

/// Aplica ao estado da carreira os efeitos de um resultado já produzido pelo
/// Match Engine ou pelo resolvedor estatístico de segundo plano.
///
/// Lesão, condição, fadiga, moral e os totais globais da temporada continuam
/// no atleta. Estatísticas competitivas e cartões/suspensões ficam separados
/// por torneio, impedindo que um estadual contamine a tabela disciplinar da
/// liga nacional. O campo legado [Player.discipline] pode continuar espelhando
/// a competição principal para preservar as telas/saves já existentes.
abstract final class MatchCareerImpactEngine {
  static MatchCareerImpact apply({
    required List<Club> clubs,
    required MatchResult result,
    required Map<String, Set<String>> participantsByClub,
    required Map<String, Set<String>> startersByClub,
    required Map<String, PlayerSeasonStats> competitionPlayerStats,
    required Map<String, PlayerDiscipline> competitionPlayerDiscipline,
    bool mirrorCompetitionDisciplineToPlayer = false,
  }) {
    final statsByPlayer = <String, PlayerSeasonStats>{
      ...competitionPlayerStats,
    };
    final disciplineByPlayer = <String, PlayerDiscipline>{
      ...competitionPlayerDiscipline,
    };
    final matchClubIds = {result.homeClubId, result.awayClubId};

    // Uma suspensão é cumprida quando o clube disputa uma partida daquela
    // competição, e não quando qualquer outro torneio avança.
    for (final club in clubs.where((club) => matchClubIds.contains(club.id))) {
      for (final player in club.squad) {
        final stored = disciplineByPlayer[player.id] ??
            (mirrorCompetitionDisciplineToPlayer
                ? player.discipline
                : const PlayerDiscipline());
        if (stored.suspendedRounds > 0) {
          disciplineByPlayer[player.id] = stored.copyWith(
            suspendedRounds: stored.suspendedRounds - 1,
          );
        }
      }
    }

    final updatedClubs = clubs.map((club) {
      if (!matchClubIds.contains(club.id)) return club;
      final home = club.id == result.homeClubId;
      final goalsFor = home ? result.score.home : result.score.away;
      final goalsAgainst = home ? result.score.away : result.score.home;
      final form = [
        ...club.recentForm,
        goalsFor > goalsAgainst
            ? 'V'
            : goalsFor == goalsAgainst
                ? 'E'
                : 'D',
      ];
      while (form.length > 5) {
        form.removeAt(0);
      }

      final eventByPlayer = <String, List<MatchEvent>>{};
      for (final event in result.events.where(
        (event) => event.teamId == club.id && event.playerId != null,
      )) {
        eventByPlayer.putIfAbsent(event.playerId!, () => []).add(event);
      }

      final squad = club.squad.map((player) {
        final previousInjury = player.injury;
        final servedInjury = previousInjury == null
            ? null
            : previousInjury.roundsRemaining <= 1
                ? null
                : PlayerInjury(
                    name: previousInjury.name,
                    roundsRemaining: previousInjury.roundsRemaining - 1,
                  );
        final servedDiscipline = disciplineByPlayer[player.id] ??
            (mirrorCompetitionDisciplineToPlayer
                ? player.discipline
                : const PlayerDiscipline());
        final events = eventByPlayer[player.id] ?? const <MatchEvent>[];
        final isStarter = startersByClub[club.id]?.contains(player.id) == true;
        final participated =
            participantsByClub[club.id]?.contains(player.id) == true ||
                events.isNotEmpty ||
                result.events.any(
                  (event) =>
                      event.playerId == player.id ||
                      event.assistPlayerId == player.id ||
                      event.secondaryPlayerId == player.id,
                );
        if (!participated) {
          return player.copyWith(
            injury: servedInjury,
            clearInjury: previousInjury != null && servedInjury == null,
            discipline: mirrorCompetitionDisciplineToPlayer
                ? servedDiscipline
                : player.discipline,
          );
        }

        final substitutionIn = result.events
            .where(
              (event) =>
                  event.type == MatchEventType.substitution &&
                  event.teamId == club.id &&
                  event.playerId == player.id,
            )
            .toList();
        final substitutionOut = result.events
            .where(
              (event) =>
                  event.type == MatchEventType.substitution &&
                  event.teamId == club.id &&
                  event.secondaryPlayerId == player.id,
            )
            .toList();
        final dismissal = events
            .where((event) => event.type == MatchEventType.red)
            .toList();
        final enteredAt = substitutionIn.isNotEmpty
            ? substitutionIn.first.minute
            : 0;
        var leftAt = substitutionOut.isNotEmpty
            ? substitutionOut.first.minute
            : 90;
        if (dismissal.isNotEmpty) {
          leftAt = min(leftAt, dismissal.first.minute);
        }
        final minutesPlayed = max(1, leftAt - enteredAt);

        final goals =
            events.where((event) => event.type == MatchEventType.goal).length;
        final assists = result.events
            .where((event) => event.assistPlayerId == player.id)
            .length;
        final yellows = events
            .where((event) => event.type == MatchEventType.yellow)
            .length;
        final reds =
            events.where((event) => event.type == MatchEventType.red).length;
        final injury = events.any(
          (event) => event.type == MatchEventType.injury,
        )
            ? const PlayerInjury(
                name: 'Desconforto muscular',
                roundsRemaining: 1,
              )
            : servedInjury;
        final rating = (6.3 + goals * .8 + assists * .45 - reds * 1.2)
            .clamp(1.0, 10.0)
            .toDouble();
        final recentRatings = [...player.recentRatings, rating];
        while (recentRatings.length > 5) {
          recentRatings.removeAt(0);
        }

        PlayerSeasonStats addTo(PlayerSeasonStats base) => base.copyWith(
              appearances: base.appearances + 1,
              starts: base.starts + (isStarter ? 1 : 0),
              minutes: base.minutes + minutesPlayed,
              goals: base.goals + goals,
              assists: base.assists + assists,
              yellowCards: base.yellowCards + yellows,
              redCards: base.redCards + reds,
              ratingTotal: base.ratingTotal + rating,
            );

        final stats = addTo(player.stats);
        statsByPlayer[player.id] = addTo(
          statsByPlayer[player.id] ?? const PlayerSeasonStats(),
        );

        var yellowTotal = servedDiscipline.yellowCards + yellows;
        var suspension =
            servedDiscipline.suspendedRounds + (reds > 0 ? 1 : 0);
        if (yellowTotal >= PlayerDiscipline.yellowCardSuspensionThreshold) {
          yellowTotal -= PlayerDiscipline.yellowCardSuspensionThreshold;
          suspension++;
        }
        final competitionDiscipline = servedDiscipline.copyWith(
          yellowCards: yellowTotal,
          redCards: servedDiscipline.redCards + reds,
          suspendedRounds: suspension,
        );
        disciplineByPlayer[player.id] = competitionDiscipline;

        return player.copyWith(
          stats: stats,
          recentRatings: recentRatings,
          injury: injury,
          clearInjury: previousInjury != null && injury == null,
          discipline: mirrorCompetitionDisciplineToPlayer
              ? competitionDiscipline
              : player.discipline,
          fatigue: min(
            100,
            player.fatigue + max(6, (16 * minutesPlayed / 90).round()),
          ),
          condition: max(
            35,
            player.condition - max(3, (7 * minutesPlayed / 90).round()),
          ),
        );
      }).toList();
      final morale = MoraleEngine.moraleFromRecentForm(form);
      return club.copyWith(
        squad: squad
            .map(
              (player) => player.copyWith(
                morale: ((player.morale + morale) / 2).round(),
              ),
            )
            .toList(),
        recentForm: form,
      );
    }).toList(growable: false);

    return MatchCareerImpact(
      clubs: updatedClubs,
      competitionPlayerStats: statsByPlayer,
      competitionPlayerDiscipline: disciplineByPlayer,
    );
  }
}
