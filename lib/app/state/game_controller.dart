import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/save/career_repository.dart';
import '../../core/diagnostics/diagnostic_service.dart';
import '../../domain/career/manager_profile.dart';
import '../../domain/formation/formation.dart';
import '../../domain/season/career_event.dart';
import '../../domain/season/career_state.dart';
import '../../domain/tactic/tactic.dart';
import '../../domain/training/training_plan.dart';
import '../../game/assistant/technical_assistant_engine.dart';
import '../../game/career/manager_career_engine.dart';
import '../../game/finance/club_administration_engine.dart';
import '../../game/lineup/lineup_engine.dart';
import '../../game/season/daily_career_engine.dart';
import '../../game/season/season_engine.dart';
import '../../game/training/training_engine.dart';
import 'providers.dart';

final gameControllerProvider =
    NotifierProvider<GameController, GameState>(GameController.new);

class GameState {
  const GameState({this.career, this.message});

  final CareerState? career;
  final String? message;

  bool get hasCareer => career != null;

  GameState copyWith({
    CareerState? career,
    bool clearCareer = false,
    String? message,
    bool clearMessage = false,
  }) =>
      GameState(
        career: clearCareer ? null : (career ?? this.career),
        message: clearMessage ? null : (message ?? this.message),
      );
}

class GameController extends Notifier<GameState> {
  @override
  GameState build() => const GameState();

  CareerRepository get _repository => ref.read(careerRepositoryProvider);

  void attachCareer(CareerState career) {
    state = GameState(career: career);
  }

  void detachCareer() {
    state = const GameState();
  }

  void clearMessage() => state = state.copyWith(clearMessage: true);

  void showMessage(String message) {
    state = state.copyWith(message: message);
  }

  Future<bool> commitCareer(CareerState next, {String? message}) async {
    try {
      await _repository.save(next);
      state = state.copyWith(
        career: next,
        message: message,
        clearMessage: message == null,
      );
      return true;
    } catch (error, stack) {
      await DiagnosticService.instance.record(
        'CAREER_SAVE_ERROR',
        error,
        stack,
        'A alteração foi mantida fora da tela porque a gravação local falhou.',
      );
      state = state.copyWith(
        message: 'Não foi possível salvar a alteração. Tente novamente.',
      );
      return false;
    }
  }

  Future<void> setFormation(FormationType formation) async {
    final career = state.career;
    if (career == null || career.managerUnemployed) return;
    final fixture = career.nextUserFixture;
    final suspended = fixture == null
        ? null
        : career.suspendedPlayerIdsForCompetition(fixture.competitionId);
    final starters = LineupEngine.autoSelect(
      career.userClub.squad,
      formation,
      competitionSuspendedPlayerIds: suspended,
    );
    final next = career.copyWith(formation: formation, starterIds: starters);
    await commitCareer(next);
  }

  Future<void> setTactic(Tactic tactic) async {
    final career = state.career;
    if (career == null || career.managerUnemployed) return;
    await commitCareer(career.copyWith(tactic: tactic));
  }

  Future<void> setTrainingPlan(TrainingPlan plan) async {
    final career = state.career;
    if (career == null || career.managerUnemployed) return;
    await commitCareer(
      career.copyWith(trainingPlan: plan),
      message:
          'Plano de treino ${plan.focus.label.toLowerCase()} definido.',
    );
  }

  Future<void> setAssistantTrainingAutomation(bool enabled) async {
    final career = state.career;
    if (career == null || career.managerUnemployed) return;
    final recommended = TrainingEngine.recommend(career);
    final plan = enabled
        ? recommended.copyWith(managedByAssistant: true)
        : career.trainingPlan.copyWith(managedByAssistant: false);
    await commitCareer(
      career.copyWith(trainingPlan: plan),
      message: enabled
          ? 'O auxiliar passou a ajustar a carga de treino a cada dia.'
          : 'Gestão automática de treino desativada.',
    );
  }

  Future<void> applyAssistantRecommendations() async {
    final career = state.career;
    if (career == null || career.managerUnemployed) return;
    final report = TechnicalAssistantEngine.analyze(career);
    final plan = report.recommendedTraining.copyWith(
      managedByAssistant: career.trainingPlan.managedByAssistant,
    );
    await commitCareer(
      career.copyWith(
        formation: report.recommendedFormation,
        starterIds: report.recommendedStarterIds,
        tactic: report.recommendedTactic,
        trainingPlan: plan,
      ),
      message:
          'Recomendações aplicadas: treino, escalação e plano tático atualizados.',
    );
  }

  Future<void> replaceStarter(String outgoingId, String incomingId) async {
    final career = state.career;
    if (career == null || career.managerUnemployed) return;
    final starters = LineupEngine.replaceStarter(
      career.starterIds,
      outgoingId,
      incomingId,
    );
    final fixture = career.nextUserFixture;
    final validation = LineupEngine.validate(
      career.userClub.squad,
      starters,
      career.formation,
      competitionSuspendedPlayerIds: fixture == null
          ? null
          : career.suspendedPlayerIdsForCompetition(fixture.competitionId),
    );
    if (!validation.valid) {
      showMessage(validation.message);
      return;
    }
    await commitCareer(
      career.copyWith(starterIds: starters),
      message: 'Escalação atualizada.',
    );
  }


  Future<void> autoSelectLineup() async {
    final career = state.career;
    if (career == null || career.managerUnemployed) return;
    final fixture = career.nextUserFixture;
    final suspended = fixture == null
        ? null
        : career.suspendedPlayerIdsForCompetition(fixture.competitionId);
    final starters = LineupEngine.autoSelect(
      career.userClub.squad,
      career.formation,
      competitionSuspendedPlayerIds: suspended,
    );
    final validation = LineupEngine.validate(
      career.userClub.squad,
      starters,
      career.formation,
      competitionSuspendedPlayerIds: suspended,
    );
    await commitCareer(
      career.copyWith(starterIds: starters),
      message: validation.valid
          ? 'Escalação ajustada com os jogadores disponíveis.'
          : validation.message,
    );
  }


  Future<void> updateManagerProfile(ManagerProfile manager, {String? message}) async {
    final career = state.career;
    if (career == null) return;
    final updatedHistory = career.managerHistory
        .map(
          (entry) => entry.season == career.season
              ? ManagerCareerHistoryEntry.fromProfile(
                  manager,
                  season: entry.season,
                  clubId: entry.clubId,
                )
              : entry,
        )
        .toList(growable: false);
    await commitCareer(
      career.copyWith(
        manager: manager,
        managerHistory: updatedHistory,
      ),
      message: message ?? 'Perfil do treinador atualizado.',
    );
  }


  Future<void> leaveCurrentClub() async {
    final career = state.career;
    if (career == null || career.managerUnemployed) return;
    final clubName = career.userClub.name;
    final next = ManagerCareerEngine.leaveCurrentClub(career);
    await commitCareer(
      next,
      message: 'Você deixou o $clubName. Procure uma nova oportunidade para continuar a carreira.',
    );
  }

  Future<bool> acceptManagerJob(String clubId) async {
    final career = state.career;
    if (career == null) return false;
    try {
      final clubName = career.clubs.firstWhere((club) => club.id == clubId).name;
      final next = ClubAdministrationEngine.ensureInitialized(
        ManagerCareerEngine.acceptJob(career, clubId),
      );
      await commitCareer(
        next,
        message: 'Novo desafio: você assumiu o $clubName.',
      );
      return true;
    } on StateError catch (error) {
      showMessage(error.message.toString());
      return false;
    }
  }

  Future<void> declineManagerOffer(String offerId) async {
    final career = state.career;
    if (career == null) return;
    await commitCareer(
      ManagerCareerEngine.declineOffer(career, offerId),
      message: 'Proposta de trabalho recusada.',
    );
  }

  Future<void> advanceDay() async {
    final career = state.career;
    if (career == null) return;
    if (career.seasonComplete) {
      showMessage('A temporada terminou. Inicie a próxima temporada.');
      return;
    }
    if (career.isMatchDay) {
      showMessage('Hoje é dia de jogo. Prepare a equipe antes de continuar.');
      return;
    }

    try {
      final advance = DailyCareerEngine.advance(career);
      final next = advance.state;
      final important = advance.events
          .where((event) => event.type != CareerEventType.training)
          .toList();
      await commitCareer(
        next,
        message: next.isMatchDay
            ? 'Dia de jogo! Confira a escalação antes da partida.'
            : important.isNotEmpty
                ? important.first.message
                : next.managerUnemployed
                    ? 'Dia avançado. Novas vagas e propostas podem surgir.'
                    : 'Dia avançado. Treino e recuperação atualizados.',
      );
    } on StateError catch (error) {
      showMessage(error.message.toString());
    }
  }

  Future<void> updateSettings(GameSettings settings) async {
    final career = state.career;
    if (career == null) return;
    await commitCareer(career.copyWith(settings: settings));
  }

  Future<void> advanceSeason() async {
    final career = state.career;
    if (career == null || !career.seasonComplete) return;
    final next = SeasonEngine.advance(career);
    await commitCareer(
      next,
      message: 'Temporada ${next.season} iniciada.',
    );
  }
}
