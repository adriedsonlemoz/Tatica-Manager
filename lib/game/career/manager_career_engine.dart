import '../../domain/career/manager_career.dart';
import '../../domain/career/manager_profile.dart';
import '../../domain/club/club.dart';
import '../../domain/season/career_event.dart';
import '../../domain/season/career_state.dart';
import '../league/league_catch_up_engine.dart';
import '../lineup/lineup_engine.dart';

class ManagerJobVacancy {
  const ManagerJobVacancy({
    required this.club,
    required this.interestScore,
    required this.requiredReputation,
    required this.reason,
  });

  final Club club;
  final int interestScore;
  final int requiredReputation;
  final String reason;

  bool get canApply => interestScore >= 50;
}

class ManagerCareerDailyUpdate {
  const ManagerCareerDailyUpdate({required this.state, this.event});

  final CareerState state;
  final CareerEvent? event;
}

abstract final class ManagerCareerEngine {
  static int reputationFor(CareerState state) {
    final clubReputation = state.userClub.reputation;
    final userStanding = state.standings.where(
      (row) => row.clubId == state.userClubId,
    ).firstOrNull;
    final currentPosition = state.standings.indexWhere(
          (row) => row.clubId == state.userClubId,
        ) +
        1;
    var score = clubReputation;
    if (state.managerEmployed &&
        userStanding != null &&
        userStanding.played > 0 &&
        currentPosition > 0) {
      if (currentPosition <= 4) {
        score += 7;
      } else if (currentPosition <= 8) {
        score += 3;
      } else if (currentPosition >= 17) {
        score -= 7;
      } else if (currentPosition >= 13) {
        score -= 3;
      }
    }
    for (final summary in state.seasonHistory) {
      if (summary.position <= 4) {
        score += 3;
      } else if (summary.position >= 17) {
        score -= 2;
      }
    }
    if (state.managerUnemployed) score -= 2;
    return score.clamp(40, 95).toInt();
  }

  static List<ManagerJobVacancy> availableJobs(CareerState state) {
    final managerRating = reputationFor(state);
    final activeTenure = state.managerCareer.activeTenure;
    final lastTenure = state.managerCareer.tenures.isEmpty
        ? null
        : state.managerCareer.tenures.last;
    String? recentlyLeftClubId;
    final lastExitDate = lastTenure?.endedAt;
    if (activeTenure == null && lastTenure != null && lastExitDate != null) {
      final daysSinceExit = state.currentDate.difference(lastExitDate).inDays;
      if (daysSinceExit <= 30) recentlyLeftClubId = lastTenure.clubId;
    }
    final currentClubId = activeTenure?.clubId ?? recentlyLeftClubId;
    final vacancies = <ManagerJobVacancy>[];

    for (final club in state.clubs) {
      if (club.id == currentClubId) continue;
      final variance = (_stableHash(
                '${club.id}-${state.season}-${state.currentDate.month}',
              ) %
              17) -
          8;
      final interest = (62 + managerRating - club.reputation + variance)
          .clamp(25, 95)
          .toInt();
      final monthlySignal =
          _stableHash('${club.id}-${state.currentDate.year}-${state.currentDate.month}') % 4;
      if (monthlySignal == 0 && interest < 70) continue;
      vacancies.add(
        ManagerJobVacancy(
          club: club,
          interestScore: interest,
          requiredReputation: (club.reputation - 4).clamp(40, 95).toInt(),
          reason: interest >= 75
              ? 'A diretoria considera seu perfil prioridade para o projeto.'
              : interest >= 60
                  ? 'O clube busca um treinador para elevar o desempenho.'
                  : 'A vaga está aberta, mas a concorrência pelo cargo é alta.',
        ),
      );
    }

    vacancies.sort((a, b) {
      final interest = b.interestScore.compareTo(a.interestScore);
      if (interest != 0) return interest;
      return b.club.reputation.compareTo(a.club.reputation);
    });

    if (vacancies.length >= 3) return vacancies;
    final existing = vacancies.map((item) => item.club.id).toSet();
    final fallback = state.clubs
        .where((club) => club.id != currentClubId && !existing.contains(club.id))
        .toList()
      ..sort((a, b) => a.reputation.compareTo(b.reputation));
    for (final club in fallback) {
      vacancies.add(
        ManagerJobVacancy(
          club: club,
          interestScore: (68 + managerRating - club.reputation).clamp(50, 90).toInt(),
          requiredReputation: (club.reputation - 5).clamp(40, 95).toInt(),
          reason: 'A diretoria abriu processo para um novo comando técnico.',
        ),
      );
      if (vacancies.length >= 3) break;
    }
    return vacancies;
  }

  static CareerState leaveCurrentClub(CareerState state) {
    if (state.managerUnemployed) return state;
    final currentClubId = state.userClubId;
    final tenures = state.managerCareer.tenures.map((tenure) {
      if (!tenure.active || tenure.clubId != currentClubId) return tenure;
      return tenure.copyWith(
        endedAt: state.currentDate,
        endSeason: state.season,
        endReason: 'Pedido de demissão',
      );
    }).toList(growable: false);
    final clubs = state.clubs
        .map(
          (club) => club.id == currentClubId
              ? club.copyWith(managerName: 'Interino')
              : club,
        )
        .toList(growable: false);
    final userManager = state.manager.copyWith(clearCurrentClub: true);
    final managers = <ManagerProfile>[
      for (final manager in state.managers)
        if (manager.id != state.manager.id &&
            manager.currentClubId != currentClubId)
          manager,
      userManager,
      ManagerProfile(
        id: 'manager-interim-$currentClubId-${state.careerId}-${state.season}',
        displayName: 'Interino',
        nationality: 'Brasil',
        ageAtStart: 45,
        careerStartSeason: state.season,
        currentClubId: currentClubId,
        reputation: 45,
        overall: 55,
      ),
    ];
    return state.copyWith(
      manager: userManager,
      managers: managers,
      clubs: clubs,
      managerCareer: state.managerCareer.copyWith(
        status: ManagerEmploymentStatus.unemployed,
        tenures: tenures,
      ),
    );
  }

  static CareerState acceptJob(CareerState state, String clubId) {
    final base = state.managerUnemployed
        ? LeagueCatchUpEngine.resolvePastFixtures(state)
        : state;
    final vacancy = availableJobs(base)
        .where((item) => item.club.id == clubId)
        .firstOrNull;
    final offered = base.managerCareer.offers.any(
      (offer) => offer.clubId == clubId && offer.isActiveOn(base.currentDate),
    );
    if (vacancy == null && !offered) {
      throw StateError('Esta vaga não está disponível neste momento.');
    }
    if (!offered && vacancy != null && !vacancy.canApply) {
      throw StateError('A diretoria ainda não considera seu perfil suficiente para esta vaga.');
    }
    final newClub = base.clubs.firstWhere((club) => club.id == clubId);
    final previousClubId = base.userClubId;
    var tenures = [...base.managerCareer.tenures];
    if (base.managerEmployed) {
      tenures = tenures.map((tenure) {
        if (!tenure.active || tenure.clubId != previousClubId) return tenure;
        return tenure.copyWith(
          endedAt: base.currentDate,
          endSeason: base.season,
          endReason: 'Mudança de clube',
        );
      }).toList();
    }
    tenures.add(
      ManagerClubTenure(
        clubId: clubId,
        startedAt: base.currentDate,
        startSeason: base.season,
      ),
    );
    final clubs = base.clubs.map((club) {
      if (club.id == previousClubId && previousClubId != clubId && base.managerEmployed) {
        return club.copyWith(managerName: 'Interino');
      }
      if (club.id == clubId) {
        return club.copyWith(managerName: base.manager.displayName);
      }
      return club;
    }).toList(growable: false);
    final starters = LineupEngine.autoSelect(newClub.squad, base.formation);
    final history = [...base.managerHistory];
    final seasonIndex = history.lastIndexWhere((entry) => entry.season == base.season);
    final snapshot = ManagerCareerHistoryEntry.fromProfile(
      base.manager,
      season: base.season,
      clubId: clubId,
    );
    if (seasonIndex >= 0) {
      history[seasonIndex] = snapshot;
    } else {
      history.add(snapshot);
    }
    final userManager = base.manager.copyWith(currentClubId: clubId);
    final managers = <ManagerProfile>[
      for (final manager in base.managers)
        if (manager.id != base.manager.id)
          manager.currentClubId == clubId
              ? manager.copyWith(clearCurrentClub: true)
              : manager,
      if (base.managerEmployed && previousClubId != clubId)
        ManagerProfile(
          id: 'manager-interim-$previousClubId-${base.careerId}-${base.season}',
          displayName: 'Interino',
          nationality: 'Brasil',
          ageAtStart: 45,
          careerStartSeason: base.season,
          currentClubId: previousClubId,
          reputation: 45,
          overall: 55,
        ),
      userManager,
    ];
    return base.copyWith(
      manager: userManager,
      managers: managers,
      userClubId: clubId,
      clubs: clubs,
      starterIds: starters,
      finances: const [],
      managerHistory: history,
      clearLastMatch: true,
      managerCareer: ManagerCareerState(
        status: ManagerEmploymentStatus.employed,
        tenures: tenures,
        offers: const [],
      ),
    );
  }

  static CareerState declineOffer(CareerState state, String offerId) =>
      state.copyWith(
        managerCareer: state.managerCareer.copyWith(
          offers: state.managerCareer.offers
              .where((offer) => offer.id != offerId)
              .toList(growable: false),
        ),
      );

  static ManagerCareerDailyUpdate advanceDay(CareerState state) {
    final activeOffers = state.managerCareer.offers
        .where((offer) => offer.isActiveOn(state.currentDate))
        .toList(growable: true);
    var next = state.copyWith(
      managerCareer: state.managerCareer.copyWith(offers: activeOffers),
    );

    final cadence = state.managerUnemployed ? 5 : 17;
    final dayKey = _dayOfYear(state.currentDate);
    if ((dayKey + state.season + reputationFor(state)) % cadence != 0) {
      return ManagerCareerDailyUpdate(state: next);
    }

    final existingClubIds = activeOffers.map((offer) => offer.clubId).toSet();
    final candidates = availableJobs(next)
        .where(
          (vacancy) =>
              vacancy.interestScore >= (state.managerUnemployed ? 55 : 68) &&
              !existingClubIds.contains(vacancy.club.id),
        )
        .toList();
    if (candidates.isEmpty) return ManagerCareerDailyUpdate(state: next);

    final vacancy = candidates.first;
    final offer = ManagerJobOffer(
      id: 'manager-offer-${state.currentDate.year}-${state.currentDate.month}-${state.currentDate.day}-${vacancy.club.id}',
      clubId: vacancy.club.id,
      createdAt: state.currentDate,
      expiresAt: state.currentDate.add(const Duration(days: 7)),
      interestScore: vacancy.interestScore,
      reason: vacancy.reason,
    );
    next = next.copyWith(
      managerCareer: next.managerCareer.copyWith(
        offers: [...activeOffers, offer],
      ),
    );
    return ManagerCareerDailyUpdate(
      state: next,
      event: CareerEvent(
        id: offer.id,
        date: state.currentDate,
        type: CareerEventType.managerOffer,
        title: state.managerUnemployed ? 'Convite para voltar ao banco' : 'Proposta para comandar outro clube',
        message:
            '${vacancy.club.name} demonstrou interesse no seu trabalho. A proposta fica disponível por 7 dias.',
        clubId: vacancy.club.id,
      ),
    );
  }

  static int _stableHash(String value) {
    var hash = 17;
    for (final code in value.codeUnits) {
      hash = (hash * 31 + code) & 0x7fffffff;
    }
    return hash;
  }

  static int _dayOfYear(DateTime date) =>
      date.difference(DateTime(date.year, 1, 1)).inDays + 1;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
