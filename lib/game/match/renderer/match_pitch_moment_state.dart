import '../../../domain/match/match_models.dart';
import 'match_player_motion.dart';
import 'match_player_visuals.dart';

class MatchPitchMomentState {
  final Set<int> _homeCelebrating = <int>{};
  final Set<int> _awayCelebrating = <int>{};

  bool _homeKeeperDiving = false;
  bool _awayKeeperDiving = false;
  double _homeKeeperDiveDirection = 0;
  double _awayKeeperDiveDirection = 0;
  bool? _penaltyTakerHome;
  int? _penaltyTakerIndex;
  bool? _penaltyDefendingHome;

  double crowdIntensity = .12;

  void reactTo(MatchEventType type) {
    crowdIntensity = crowdIntensity < crowdLevel(type)
        ? crowdLevel(type)
        : crowdIntensity;
  }

  void update(double dt) {
    crowdIntensity = (crowdIntensity - dt * .22).clamp(.12, 1.0).toDouble();
  }

  void setPenalty({
    required bool takerHome,
    required int takerIndex,
  }) {
    _penaltyTakerHome = takerHome;
    _penaltyTakerIndex = takerIndex;
    _penaltyDefendingHome = !takerHome;
  }

  void setKeeperDive({
    required bool defendingHome,
    required FieldPoint target,
  }) {
    final direction = target.x < .5 ? -1.0 : 1.0;
    if (defendingHome) {
      _homeKeeperDiving = true;
      _homeKeeperDiveDirection = direction;
    } else {
      _awayKeeperDiving = true;
      _awayKeeperDiveDirection = direction;
    }
  }

  void markCelebration(
    bool home,
    int scorerIndex,
    List<FieldPoint> targets,
  ) {
    final set = home ? _homeCelebrating : _awayCelebrating;
    set.add(scorerIndex);
    final scorer = targets[scorerIndex];
    final candidates = List<int>.generate(targets.length, (index) => index)
      ..remove(scorerIndex)
      ..sort(
        (a, b) => MatchPlayerMotion.distanceSquared(targets[a], scorer)
            .compareTo(MatchPlayerMotion.distanceSquared(targets[b], scorer)),
      );
    set.addAll(candidates.take(3));
  }

  MatchPlayerPose poseFor(bool home, int index) {
    if (index == 0 &&
        ((home && _homeKeeperDiving) || (!home && _awayKeeperDiving))) {
      return MatchPlayerPose.goalkeeperDive;
    }
    if ((home ? _homeCelebrating : _awayCelebrating).contains(index)) {
      return MatchPlayerPose.celebration;
    }
    if (_penaltyTakerHome == home && _penaltyTakerIndex == index) {
      return MatchPlayerPose.penaltyReady;
    }
    if (_penaltyDefendingHome == home && index == 0) {
      return MatchPlayerPose.penaltyReady;
    }
    return MatchPlayerPose.normal;
  }

  double diveDirection(bool home) =>
      home ? _homeKeeperDiveDirection : _awayKeeperDiveDirection;

  void clear() {
    _homeKeeperDiving = false;
    _awayKeeperDiving = false;
    _homeCelebrating.clear();
    _awayCelebrating.clear();
    _penaltyTakerHome = null;
    _penaltyTakerIndex = null;
    _penaltyDefendingHome = null;
  }

  static double crowdLevel(MatchEventType type) => switch (type) {
        MatchEventType.goal || MatchEventType.ownGoal => 1.0,
        MatchEventType.woodwork || MatchEventType.penaltySaved => .84,
        MatchEventType.shot || MatchEventType.save || MatchEventType.penalty => .68,
        MatchEventType.red => .62,
        MatchEventType.yellow || MatchEventType.substitution => .45,
        _ => .28,
      };
}
