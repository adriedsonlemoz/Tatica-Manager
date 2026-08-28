import '../club/club_identity.dart';
import '../formation/formation.dart';
import '../season/league_loading.dart';
import '../settings/match_presentation_settings.dart';
import '../tactic/tactic.dart';
import 'manager_profile.dart';

class NewCareerConfig {
  const NewCareerConfig({
    required this.careerName,
    required this.manager,
    required this.clubId,
    required this.formation,
    required this.tactic,
    this.matchDuration = MatchDurationPreset.normal,
    this.leagueSetup,
    this.clubIdentityPack,
  });

  final String careerName;
  final ManagerProfile manager;
  final String clubId;
  final FormationType formation;
  final Tactic tactic;
  final MatchDurationPreset matchDuration;
  final CareerLeagueSetup? leagueSetup;

  /// Pacote já carregado durante o fluxo de criação. Reutilizá-lo evita ler e
  /// normalizar novamente toda a base ao confirmar a carreira.
  final ClubIdentityPack? clubIdentityPack;
}
