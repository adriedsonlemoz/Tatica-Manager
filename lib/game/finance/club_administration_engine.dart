import 'dart:math';

import '../../domain/club/club.dart';
import '../../domain/finance/club_administration.dart';
import '../../domain/finance/finance.dart';
import '../../domain/finance/sponsorship.dart';
import '../../domain/season/career_state.dart';
import '../../domain/season/inbox_message.dart';
import '../season/inbox_engine.dart';
import '../stadium/stadium_engine.dart';
import 'sponsorship_engine.dart';

class ClubAdministrationResult {
  const ClubAdministrationResult({required this.state, required this.message});

  final CareerState state;
  final String message;
}

abstract final class ClubAdministrationEngine {
  static CareerState ensureInitialized(CareerState state) {
    var club = state.userClub;
    var administration = state.clubAdministration;
    final clubChanged = administration.budgetPlan.clubId.isNotEmpty &&
        administration.budgetPlan.clubId != state.userClubId;

    if (!administration.budgetPlan.isConfigured ||
        administration.budgetPlan.season != state.season ||
        administration.budgetPlan.clubId != state.userClubId) {
      administration = administration.copyWith(
        budgetPlan: _defaultBudgetPlan(club, state.season),
        sponsorshipProposals:
            clubChanged ? const [] : administration.sponsorshipProposals,
      );
    }

    if (club.sponsorships.isEmpty) {
      final legacyContracts = SponsorshipEngine.defaultContracts(
        club,
        season: state.season,
      ).where((contract) => contract.type != SponsorshipType.stadium).toList();
      club = club.copyWith(sponsorships: legacyContracts);
    }

    final activeTypes = club.sponsorships
        .where((contract) => contract.isActiveIn(state.season))
        .map((contract) => contract.type)
        .toSet();
    final existingOfferTypes = administration.sponsorshipProposals
        .where((proposal) => proposal.offeredAt.year == state.season)
        .map((proposal) => proposal.type)
        .toSet();
    final additions = <SponsorshipProposal>[];
    for (final type in SponsorshipType.values) {
      if (activeTypes.contains(type) || existingOfferTypes.contains(type)) {
        continue;
      }
      additions.add(_proposalFor(state, club, type));
    }
    if (additions.isNotEmpty) {
      administration = administration.copyWith(
        sponsorshipProposals: [
          ...administration.sponsorshipProposals,
          ...additions,
        ],
      );
    }

    var next = state.copyWith(
      clubs: _replaceUserClub(state, club),
      clubAdministration: administration,
    );
    next = InboxEngine.appendMessages(
      next,
      additions.map(_messageForProposal).toList(growable: false),
    );
    return _syncNamingRights(next);
  }

  static ClubAdministrationResult allocateBudgets(
    CareerState state,
    Map<ClubDepartment, int> available,
  ) {
    final prepared = ensureInitialized(state);
    final normalized = {
      for (final department in ClubDepartment.values)
        department: max(0, available[department] ?? 0),
    };
    final total = normalized.values.fold<int>(0, (sum, value) => sum + value);
    if (total > prepared.userClub.money) {
      throw StateError(
        'A distribuição supera o saldo disponível do clube.',
      );
    }
    final plan = ClubBudgetPlan(
      season: prepared.season,
      clubId: prepared.userClubId,
      available: normalized,
    );
    final club = prepared.userClub.copyWith(
      transferBudget: normalized[ClubDepartment.transfers] ?? 0,
    );
    return ClubAdministrationResult(
      state: prepared.copyWith(
        clubs: _replaceUserClub(prepared, club),
        clubAdministration:
            prepared.clubAdministration.copyWith(budgetPlan: plan),
      ),
      message: 'Orçamentos departamentais atualizados.',
    );
  }

  static int availableFor(CareerState state, ClubDepartment department) {
    final prepared = ensureInitialized(state);
    if (department == ClubDepartment.transfers) {
      return min(
        prepared.userClub.transferBudget,
        prepared.clubAdministration.budgetPlan.forDepartment(department),
      );
    }
    return prepared.clubAdministration.budgetPlan.forDepartment(department);
  }

  static int spentFor(CareerState state, ClubDepartment department) => state
      .finances
      .where(
        (transaction) =>
            transaction.season == state.season &&
            transaction.amount < 0 &&
            departmentFor(transaction.kind) == department,
      )
      .fold<int>(0, (sum, transaction) => sum + transaction.amount.abs());

  static ClubDepartment? departmentFor(FinanceKind kind) => switch (kind) {
        FinanceKind.playerPurchase || FinanceKind.transferOut =>
          ClubDepartment.transfers,
        FinanceKind.wages || FinanceKind.contractRenewal =>
          ClubDepartment.payroll,
        FinanceKind.stadiumInvestment => ClubDepartment.stadium,
        FinanceKind.operations => ClubDepartment.operations,
        _ => null,
      };

  static ClubAdministrationResult updateStadiumProfile(
    CareerState state, {
    required String name,
    required int ticketPrice,
  }) {
    final prepared = ensureInitialized(state);
    final namingSponsor = _activeNamingSponsor(prepared);
    final stadium = StadiumEngine.updateProfile(
      stadium: prepared.userClub.stadium,
      baseName: name,
      ticketPrice: ticketPrice,
      namingSponsor: namingSponsor,
    );
    final club = prepared.userClub.copyWith(stadium: stadium);
    return ClubAdministrationResult(
      state: prepared.copyWith(clubs: _replaceUserClub(prepared, club)),
      message: 'Dados do estádio atualizados.',
    );
  }

  static ClubAdministrationResult upgradeStadium(
    CareerState state,
    StadiumFacility facility, {
    bool negotiated = false,
  }) {
    final prepared = ensureInitialized(state);
    final club = prepared.userClub;
    final cost = negotiated
        ? StadiumEngine.negotiatedUpgradeCost(club: club, facility: facility)
        : StadiumEngine.upgradeCost(club.stadium, facility);
    if (cost <= 0) {
      throw StateError('${facility.label} já está no nível máximo.');
    }
    final stadiumBudget = availableFor(prepared, ClubDepartment.stadium);
    if (cost > stadiumBudget) {
      throw StateError('O orçamento do Estádio não cobre esta melhoria.');
    }
    if (cost > club.money) {
      throw StateError('O clube não possui saldo para esta melhoria.');
    }

    final upgraded = StadiumEngine.upgrade(club.stadium, facility);
    final plan = prepared.clubAdministration.budgetPlan.spend(
      ClubDepartment.stadium,
      cost,
    );
    final nextClub = club.copyWith(
      money: club.money - cost,
      stadium: upgraded,
    );
    final transaction = FinanceTransaction(
      id: 'stadium-${prepared.season}-${prepared.roundIndex}-${facility.name}-${StadiumEngine.facilityLevel(upgraded, facility)}',
      season: prepared.season,
      round: prepared.currentRound,
      kind: FinanceKind.stadiumInvestment,
      description:
          '${facility.label} — ${StadiumEngine.isLocked(club.stadium, facility) ? 'desbloqueio' : 'melhoria'} para o nível ${StadiumEngine.facilityLevel(upgraded, facility)}',
      amount: -cost,
      createdAt: prepared.currentDate,
    );
    return ClubAdministrationResult(
      state: prepared.copyWith(
        clubs: _replaceUserClub(prepared, nextClub),
        finances: [...prepared.finances, transaction],
        clubAdministration:
            prepared.clubAdministration.copyWith(budgetPlan: plan),
      ),
      message: negotiated
          ? '${facility.label}: obra negociada e iniciada com desconto.'
          : '${facility.label} evoluiu para o nível ${StadiumEngine.facilityLevel(upgraded, facility)}.',
    );
  }

  static ClubAdministrationResult acceptSponsorship(
    CareerState state,
    String proposalId,
  ) {
    final prepared = expireProposals(ensureInitialized(state));
    final proposal = _proposal(prepared, proposalId);
    if (!proposal.canRespond || proposal.isExpiredAt(prepared.currentDate)) {
      throw StateError('Esta proposta não está mais disponível.');
    }
    final hasActiveType = prepared.userClub.sponsorships.any(
      (contract) =>
          contract.type == proposal.type &&
          contract.isActiveIn(prepared.season),
    );
    if (hasActiveType) {
      throw StateError('Já existe um contrato ativo para esta categoria.');
    }
    final contract = proposal.toContract(prepared.season);
    var stadium = prepared.userClub.stadium;
    if (proposal.type == SponsorshipType.stadium) {
      stadium = StadiumEngine.applyNamingRights(stadium, proposal.sponsorName);
    }
    final club = prepared.userClub.copyWith(
      stadium: stadium,
      sponsorships: [...prepared.userClub.sponsorships, contract],
    );
    final proposals = prepared.clubAdministration.sponsorshipProposals
        .map(
          (item) => item.id == proposalId
              ? item.copyWith(status: SponsorshipProposalStatus.accepted)
              : item,
        )
        .toList(growable: false);
    return ClubAdministrationResult(
      state: prepared.copyWith(
        clubs: _replaceUserClub(prepared, club),
        clubAdministration: prepared.clubAdministration.copyWith(
          sponsorshipProposals: proposals,
        ),
      ),
      message: 'Proposta de ${proposal.sponsorName} aceita.',
    );
  }

  static ClubAdministrationResult rejectSponsorship(
    CareerState state,
    String proposalId,
  ) {
    final prepared = ensureInitialized(state);
    final proposal = _proposal(prepared, proposalId);
    if (!proposal.canRespond) {
      throw StateError('Esta proposta já foi encerrada.');
    }
    final proposals = prepared.clubAdministration.sponsorshipProposals
        .map(
          (item) => item.id == proposalId
              ? item.copyWith(status: SponsorshipProposalStatus.rejected)
              : item,
        )
        .toList(growable: false);
    return ClubAdministrationResult(
      state: prepared.copyWith(
        clubAdministration: prepared.clubAdministration.copyWith(
          sponsorshipProposals: proposals,
        ),
      ),
      message: 'Proposta de ${proposal.sponsorName} recusada.',
    );
  }

  static ClubAdministrationResult counterSponsorship(
    CareerState state,
    String proposalId, {
    required int requestedAnnualValue,
  }) {
    final prepared = expireProposals(ensureInitialized(state));
    final proposal = _proposal(prepared, proposalId);
    if (!proposal.canRespond) {
      throw StateError('Esta proposta já foi encerrada.');
    }
    if (requestedAnnualValue <= proposal.annualValue) {
      throw StateError('A contraproposta deve superar o valor original.');
    }
    if (requestedAnnualValue > (proposal.annualValue * 1.20).round()) {
      throw StateError('O patrocinador aceita negociar no máximo 20%.');
    }
    final ceiling = (proposal.annualValue *
            (1.04 + prepared.userClub.reputation.clamp(1, 100) / 1000))
        .round();
    final sponsorResponse = min(requestedAnnualValue, ceiling);
    final proposals = prepared.clubAdministration.sponsorshipProposals
        .map(
          (item) => item.id == proposalId
              ? item.copyWith(
                  negotiatedAnnualValue: sponsorResponse,
                  status: SponsorshipProposalStatus.countered,
                )
              : item,
        )
        .toList(growable: false);
    return ClubAdministrationResult(
      state: prepared.copyWith(
        clubAdministration: prepared.clubAdministration.copyWith(
          sponsorshipProposals: proposals,
        ),
      ),
      message: sponsorResponse == requestedAnnualValue
          ? 'O patrocinador aceitou o valor e aguarda sua decisão final.'
          : 'O patrocinador apresentou uma contraproposta de valor.',
    );
  }

  static CareerState advanceDay(CareerState state) =>
      expireProposals(ensureInitialized(state));

  static CareerState expireProposals(CareerState state) {
    var changed = false;
    final proposals = state.clubAdministration.sponsorshipProposals
        .map((proposal) {
          if (proposal.canRespond && proposal.isExpiredAt(state.currentDate)) {
            changed = true;
            return proposal.copyWith(status: SponsorshipProposalStatus.expired);
          }
          return proposal;
        })
        .toList(growable: false);
    return changed
        ? state.copyWith(
            clubAdministration: state.clubAdministration.copyWith(
              sponsorshipProposals: proposals,
            ),
          )
        : state;
  }

  static ClubBudgetPlan _defaultBudgetPlan(Club club, int season) {
    final total = max(0, club.money);
    final transfer = min(total, max(0, club.transferBudget));
    final remaining = max(0, total - transfer);
    final payroll = (remaining * .34).round();
    final stadium = (remaining * .22).round();
    final youth = (remaining * .14).round();
    final infrastructure = (remaining * .12).round();
    final operations =
        max(0, remaining - payroll - stadium - youth - infrastructure);
    return ClubBudgetPlan(
      season: season,
      clubId: club.id,
      available: {
        ClubDepartment.transfers: transfer,
        ClubDepartment.payroll: payroll,
        ClubDepartment.infrastructure: infrastructure,
        ClubDepartment.youthAcademy: youth,
        ClubDepartment.stadium: stadium,
        ClubDepartment.operations: operations,
      },
    );
  }

  static SponsorshipProposal _proposalFor(
    CareerState state,
    Club club,
    SponsorshipType type,
  ) {
    final reputation = club.reputation.clamp(1, 100).toInt();
    final base = 900000 + reputation * 43000;
    final multiplier = switch (type) {
      SponsorshipType.main => 2.1,
      SponsorshipType.kit => 1.35,
      SponsorshipType.stadium => 1.15,
      SponsorshipType.sleeve => .72,
      SponsorshipType.commercial => .58,
    };
    final sponsorName = switch (type) {
      SponsorshipType.main => 'Banco Horizonte',
      SponsorshipType.kit => 'Vértice Sports',
      SponsorshipType.stadium => 'Conecta Brasil',
      SponsorshipType.sleeve => 'Energia Viva',
      SponsorshipType.commercial => 'Mercado Central',
    };
    final objective = switch (type) {
      SponsorshipType.main => 'Terminar a temporada entre os oito primeiros.',
      SponsorshipType.kit => 'Manter exposição do uniforme durante toda a temporada.',
      SponsorshipType.stadium => 'Utilizar os naming rights em jogos como mandante.',
      SponsorshipType.sleeve => 'Alcançar ao menos 70% de ocupação média.',
      SponsorshipType.commercial => 'Fortalecer as ações comerciais do clube.',
    };
    return SponsorshipProposal(
      id: '${club.id}-${state.season}-${type.name}',
      sponsorName: sponsorName,
      type: type,
      annualValue: (base * multiplier).round(),
      durationSeasons: type == SponsorshipType.kit ? 3 : 2,
      performanceBonus: (base * .18).round(),
      objective: objective,
      conditions:
          'Receita dividida pelas ${state.totalUserRounds} rodadas; bônus depende do objetivo esportivo/comercial.',
      offeredAt: state.currentDate,
      expiresAt: state.currentDate.add(const Duration(days: 21)),
    );
  }

  static InboxMessage _messageForProposal(SponsorshipProposal proposal) =>
      InboxMessage(
        id: 'inbox-sponsor-${proposal.id}',
        date: proposal.offeredAt,
        senderType: InboxSenderType.sponsor,
        sender: proposal.sponsorName,
        subject: 'Nova proposta de patrocínio',
        body:
            '${proposal.sponsorName} enviou uma proposta de ${proposal.type.label}. Abra Finanças para analisar valores, duração, bônus e condições.',
        sponsorshipProposalId: proposal.id,
        actionType: InboxActionType.sponsorship,
        important: true,
      );

  static SponsorshipProposal _proposal(CareerState state, String proposalId) {
    try {
      return state.clubAdministration.sponsorshipProposals.firstWhere(
        (proposal) => proposal.id == proposalId,
      );
    } on StateError {
      throw StateError('Proposta de patrocínio não encontrada.');
    }
  }

  static List<Club> _replaceUserClub(CareerState state, Club club) => state.clubs
      .map((item) => item.id == state.userClubId ? club : item)
      .toList(growable: false);

  static String? _activeNamingSponsor(CareerState state) {
    for (final contract in state.userClub.sponsorships) {
      if (contract.type == SponsorshipType.stadium &&
          contract.isActiveIn(state.season)) {
        return contract.sponsorName;
      }
    }
    return null;
  }

  static CareerState _syncNamingRights(CareerState state) {
    final sponsor = _activeNamingSponsor(state);
    final stadium = state.userClub.stadium;
    final nextStadium = sponsor == null
        ? StadiumEngine.restoreOriginalName(stadium)
        : StadiumEngine.applyNamingRights(stadium, sponsor);
    if (nextStadium.name == stadium.name &&
        nextStadium.originalName == stadium.originalName) {
      return state;
    }
    final club = state.userClub.copyWith(stadium: nextStadium);
    return state.copyWith(clubs: _replaceUserClub(state, club));
  }
}
