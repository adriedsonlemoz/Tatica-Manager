import '../../data/competition_catalog.dart';
import '../../domain/club/club.dart';
import '../../domain/match/match_models.dart';
import '../league/league_engine.dart';

/// Ponto único para geração automática de calendários por formato.
///
/// Não substitui o Match Engine. Apenas escolhe o gerador de fixtures. A base
/// atual suporta formatos de liga; mata-matas/grupos ficam explicitamente
/// bloqueados até suas regras reais serem implementadas, evitando calendários
/// genéricos incorretos para Copa do Brasil/Libertadores/etc.
abstract final class CompetitionScheduleEngine {
  /// Expõe ao seletor se a definição pode entrar em uma carreira sem gerar
  /// calendário fictício. Formatos futuros continuam visíveis apenas depois
  /// que as respectivas regras forem implementadas.
  static String? activationBlockReason(CompetitionSeries competition) {
    if (competition.clubIds.length < 2) {
      return 'A competição precisa de pelo menos dois participantes cadastrados.';
    }
    return switch (competition.format) {
      CompetitionFormat.leagueDoubleRoundRobin ||
      CompetitionFormat.leagueSingleRoundRobin => null,
      CompetitionFormat.knockout =>
        'Mata-mata aguarda regra de chave, ida e volta e desempate.',
      CompetitionFormat.groupAndKnockout =>
        'Grupos e mata-mata aguardam regras de classificação e chave.',
      CompetitionFormat.singleMatch =>
        'Partida única aguarda regras de participante e decisão.',
    };
  }

  static bool canGenerate(CompetitionSeries competition) =>
      activationBlockReason(competition) == null;

  static List<MatchFixture> generate({
    required CompetitionSeries competition,
    required List<Club> clubs,
    required int season,
  }) {
    final blockReason = activationBlockReason(competition);
    if (blockReason != null) {
      throw UnsupportedError('A competição ${competition.id} não pode ser ativada: $blockReason');
    }
    switch (competition.format) {
      case CompetitionFormat.leagueDoubleRoundRobin:
        return LeagueEngine.generateDoubleRoundRobin(
          clubs,
          season: season,
          competitionId: competition.id,
          startDate: DateTime(
            season,
            competition.calendarStartMonth,
            competition.calendarStartDay,
          ),
        );
      case CompetitionFormat.leagueSingleRoundRobin:
        final complete = LeagueEngine.generateDoubleRoundRobin(
          clubs,
          season: season,
          competitionId: competition.id,
          startDate: DateTime(
            season,
            competition.calendarStartMonth,
            competition.calendarStartDay,
          ),
        );
        final firstLegRounds = clubs.length - 1;
        return complete
            .where((fixture) => fixture.round <= firstLegRounds)
            .toList(growable: false);
      case CompetitionFormat.knockout:
      case CompetitionFormat.groupAndKnockout:
      case CompetitionFormat.singleMatch:
        throw StateError('Formato já bloqueado antes da geração.');
    }
  }
}
