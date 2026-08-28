import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/career/career_save_summary.dart';
import '../../domain/career/new_career_config.dart';
import '../../domain/club/club_identity.dart';
import '../../core/config/app_preferences.dart';
import '../../core/diagnostics/diagnostic_service.dart';
import '../../game/career/career_factory.dart';
import '../../game/club/club_identity_engine.dart';
import '../../game/contract/contract_lifecycle_engine.dart';
import '../../game/finance/club_administration_engine.dart';
import '../../game/season/inbox_engine.dart';
import '../../game/youth/youth_academy_engine.dart';
import 'game_controller.dart';
import 'live_match_controller.dart';
import 'providers.dart';

final careerControllerProvider = NotifierProvider<CareerController, CareerHubState>(CareerController.new);

class CareerHubState {
  const CareerHubState({
    this.loading = false,
    this.bootstrapped = false,
    this.saves = const [],
    this.lastActiveCareerId,
    this.message,
  });

  final bool loading;
  final bool bootstrapped;
  final List<CareerSaveSummary> saves;
  final String? lastActiveCareerId;
  final String? message;

  CareerSaveSummary? get lastActiveSave {
    final id = lastActiveCareerId;
    if (id == null) return saves.isEmpty ? null : saves.first;
    for (final save in saves) {
      if (save.careerId == id) return save;
    }
    return saves.isEmpty ? null : saves.first;
  }

  CareerHubState copyWith({
    bool? loading,
    bool? bootstrapped,
    List<CareerSaveSummary>? saves,
    String? lastActiveCareerId,
    bool clearLastActiveCareerId = false,
    String? message,
    bool clearMessage = false,
  }) =>
      CareerHubState(
        loading: loading ?? this.loading,
        bootstrapped: bootstrapped ?? this.bootstrapped,
        saves: saves ?? this.saves,
        lastActiveCareerId: clearLastActiveCareerId
            ? null
            : (lastActiveCareerId ?? this.lastActiveCareerId),
        message: clearMessage ? null : (message ?? this.message),
      );
}

class CareerController extends Notifier<CareerHubState> {
  @override
  CareerHubState build() => const CareerHubState();

  Future<void> bootstrap() async {
    if (state.loading || state.bootstrapped) return;
    state = state.copyWith(loading: true, clearMessage: true);
    await refresh(bootstrapped: true);
  }

  Future<void> refresh({bool? bootstrapped}) async {
    try {
      final repository = ref.read(careerRepositoryProvider);
      var saves = await repository.listSaves();
      var migratedLegacySave = false;
      for (final summary in saves) {
        if (!ClubIdentityEngine.legacyIdMap.containsKey(summary.userClubId)) continue;
        final loaded = await repository.load(summary.careerId);
        if (loaded == null) continue;
        final migration = ClubIdentityEngine.migrateLegacyIds(loaded);
        if (!migration.changed) continue;
        await repository.save(migration.state);
        migratedLegacySave = true;
      }
      if (migratedLegacySave) {
        saves = await repository.listSaves();
      }
      var lastActiveCareerId = await repository.loadLastActiveCareerId();
      if (lastActiveCareerId != null && !saves.any((save) => save.careerId == lastActiveCareerId)) {
        lastActiveCareerId = null;
        await repository.saveLastActiveCareerId(null);
      }
      state = CareerHubState(
        loading: false,
        bootstrapped: bootstrapped ?? state.bootstrapped,
        saves: saves,
        lastActiveCareerId: lastActiveCareerId,
      );
    } catch (error, stack) {
      await DiagnosticService.instance.record(
        'CAREER_LIST_ERROR',
        error,
        stack,
        'Falha ao listar ou migrar os saves na Central de Carreiras.',
      );
      state = CareerHubState(
        loading: false,
        bootstrapped: bootstrapped ?? true,
        saves: state.saves,
        lastActiveCareerId: state.lastActiveCareerId,
        message: 'Não foi possível carregar as carreiras: $error',
      );
    }
  }

  Future<bool> openCareer(String careerId) async {
    state = state.copyWith(loading: true, clearMessage: true);
    try {
      final repository = ref.read(careerRepositoryProvider);
      final loadedCareer = await repository.load(careerId);
      if (loadedCareer == null) {
        state = state.copyWith(loading: false, message: 'Carreira não encontrada.');
        return false;
      }
      final identityMigration = ClubIdentityEngine.migrateLegacyIds(loadedCareer);
      final reconciliation = ContractLifecycleEngine.reconcile(identityMigration.state);
      final withAcademy = YouthAcademyEngine.ensureAcademy(reconciliation.state);
      final academyAdded = withAcademy.youthAcademy.length != reconciliation.state.youthAcademy.length;
      final withInbox = InboxEngine.appendEvents(withAcademy, withAcademy.news);
      final inboxBackfilled = withInbox.inbox.length != withAcademy.inbox.length;
      final career = ClubAdministrationEngine.ensureInitialized(withInbox);
      final administrationAdded =
          !withInbox.clubAdministration.budgetPlan.isConfigured ||
          withInbox.clubAdministration.budgetPlan.season != withInbox.season ||
          withInbox.clubAdministration.budgetPlan.clubId != withInbox.userClubId ||
          career.clubAdministration.sponsorshipProposals.length !=
              withInbox.clubAdministration.sponsorshipProposals.length ||
          career.userClub.sponsorships.length !=
              withInbox.userClub.sponsorships.length ||
          career.userClub.stadium.name != withInbox.userClub.stadium.name ||
          career.inbox.length != withInbox.inbox.length;
      if (identityMigration.changed ||
          reconciliation.changed ||
          academyAdded ||
          inboxBackfilled ||
          administrationAdded) {
        await repository.save(career);
      }
      await repository.saveLastActiveCareerId(careerId);
      ref.read(liveMatchControllerProvider.notifier).reset();
      ref.read(gameControllerProvider.notifier).attachCareer(career);
      state = state.copyWith(loading: false, lastActiveCareerId: careerId);
      return true;
    } catch (error, stack) {
      await DiagnosticService.instance.record(
        'CAREER_OPEN_ERROR',
        error,
        stack,
        'Falha ao carregar, reconciliar ou anexar a carreira $careerId.',
      );
      state = state.copyWith(loading: false, message: 'Não foi possível abrir a carreira: $error');
      return false;
    }
  }

  Future<bool> createCareer(NewCareerConfig config) async {
    state = state.copyWith(loading: true, clearMessage: true);
    try {
      final now = DateTime.now();
      final careerId = 'career-${now.microsecondsSinceEpoch}';
      final defaultClubPack = await loadClubIdentityPack();
      final repository = ref.read(careerRepositoryProvider);
      final defaultSettings = AppPreferences.decodeGameSettings(
        await repository.loadAppValue(AppPreferences.defaultGameSettingsKey),
      );
      final career = CareerFactory.create(
        careerId: careerId,
        careerName: config.careerName.trim(),
        manager: config.manager,
        userClubId: config.clubId,
        formation: config.formation,
        tactic: config.tactic,
        seed: now.microsecondsSinceEpoch & 0x7fffffff,
        clubIdentityPack: defaultClubPack,
        settings: defaultSettings.copyWith(
          matchDurationMinutes: config.matchDuration.minutes,
        ),
      );
      await repository.save(career);
      await repository.saveAppValue(
        AppPreferences.careerIntroPendingKey(careerId),
        'true',
      );
      await repository.saveLastActiveCareerId(careerId);
      ref.read(liveMatchControllerProvider.notifier).reset();
      ref.read(gameControllerProvider.notifier).attachCareer(career);
      final saves = await repository.listSaves();
      state = CareerHubState(
        loading: false,
        bootstrapped: true,
        saves: saves,
        lastActiveCareerId: careerId,
      );
      return true;
    } catch (error, stack) {
      await DiagnosticService.instance.record(
        'CAREER_CREATE_ERROR',
        error,
        stack,
        'Falha durante a criação e persistência de uma nova carreira.',
      );
      state = state.copyWith(loading: false, message: 'Falha ao criar a carreira: $error');
      return false;
    }
  }

  Future<void> closeActiveCareer() async {
    ref.read(liveMatchControllerProvider.notifier).reset();
    ref.read(gameControllerProvider.notifier).detachCareer();
    await refresh();
  }

  Future<bool> deleteCareer(String careerId) async {
    state = state.copyWith(loading: true, clearMessage: true);
    try {
      final currentId = ref.read(gameControllerProvider).career?.careerId;
      final repository = ref.read(careerRepositoryProvider);
      await repository.delete(careerId);
      await repository.saveAppValue(
        AppPreferences.careerIntroPendingKey(careerId),
        null,
      );
      if (currentId == careerId) {
        ref.read(liveMatchControllerProvider.notifier).reset();
        ref.read(gameControllerProvider.notifier).detachCareer();
      }
      await refresh();
      return true;
    } catch (error, stack) {
      await DiagnosticService.instance.record(
        'CAREER_DELETE_ERROR',
        error,
        stack,
        'Falha ao excluir a carreira $careerId e seus metadados locais.',
      );
      state = state.copyWith(loading: false, message: 'Não foi possível apagar a carreira: $error');
      return false;
    }
  }

  Future<ClubIdentityPack> loadClubIdentityPack({String? careerId}) async {
    final repository = ref.read(careerRepositoryProvider);
    if (careerId == null) {
      final stored = await repository.loadDefaultClubIdentityPack();
      if (stored == null) return ClubIdentityEngine.defaultPack();
      return ClubIdentityEngine.normalizeAndValidatePack(stored);
    }

    final loaded = await repository.load(careerId);
    if (loaded == null) {
      throw StateError('Carreira não encontrada.');
    }
    final migration = ClubIdentityEngine.migrateLegacyIds(loaded);
    if (migration.changed) {
      await repository.save(migration.state);
      await refresh();
    }
    return ClubIdentityEngine.packFromCareer(migration.state);
  }

  Future<void> saveClubIdentityPack({
    required ClubIdentityPack pack,
    String? careerId,
  }) async {
    final repository = ref.read(careerRepositoryProvider);
    if (careerId == null) {
      final normalized = ClubIdentityEngine.normalizeAndValidatePack(pack);
      await repository.saveDefaultClubIdentityPack(normalized);
      return;
    }

    final loaded = await repository.load(careerId);
    if (loaded == null) {
      throw StateError('Carreira não encontrada.');
    }
    final migration = ClubIdentityEngine.migrateLegacyIds(loaded);
    final updated = ClubIdentityEngine.applyPack(migration.state, pack);
    await repository.save(updated);

    final activeCareer = ref.read(gameControllerProvider).career;
    if (activeCareer?.careerId == careerId) {
      ref.read(gameControllerProvider.notifier).attachCareer(updated);
    }
    await refresh();
  }

  Future<void> resetDefaultClubIdentityPack() async {
    await ref.read(careerRepositoryProvider).saveDefaultClubIdentityPack(null);
  }

  void clearMessage() => state = state.copyWith(clearMessage: true);
}
