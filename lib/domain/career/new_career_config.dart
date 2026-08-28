import '../formation/formation.dart';
import '../tactic/tactic.dart';
import 'manager_profile.dart';

class NewCareerConfig {
  const NewCareerConfig({
    required this.careerName,
    required this.manager,
    required this.clubId,
    required this.formation,
    required this.tactic,
  });

  final String careerName;
  final ManagerProfile manager;
  final String clubId;
  final FormationType formation;
  final Tactic tactic;
}
