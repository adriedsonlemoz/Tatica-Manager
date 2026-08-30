import '../../domain/match/match_models.dart';

enum UiAudioCue { tap, navigation, confirm }

enum MatchAudioCue {
  kickoff,
  halftime,
  secondHalf,
  fulltime,
  goal,
  yellowCard,
  redCard,
  foul,
  substitution,
  pass,
  shot,
  save,
  corner,
  offside,
  goalKick,
  woodwork,
  penalty,
  penaltySaved,
  injury,
}

extension MatchAudioCueX on MatchAudioCue {
  String get label => switch (this) {
        MatchAudioCue.kickoff => 'Início da partida',
        MatchAudioCue.halftime => 'Intervalo',
        MatchAudioCue.secondHalf => 'Início do segundo tempo',
        MatchAudioCue.fulltime => 'Fim de jogo',
        MatchAudioCue.goal => 'Gol',
        MatchAudioCue.yellowCard => 'Cartão amarelo',
        MatchAudioCue.redCard => 'Cartão vermelho',
        MatchAudioCue.foul => 'Falta',
        MatchAudioCue.substitution => 'Substituição',
        MatchAudioCue.pass => 'Passe',
        MatchAudioCue.shot => 'Finalização',
        MatchAudioCue.corner => 'Escanteio',
        MatchAudioCue.offside => 'Impedimento',
        MatchAudioCue.goalKick => 'Tiro de meta',
        MatchAudioCue.save => 'Defesa do goleiro',
        MatchAudioCue.woodwork => 'Bola na trave',
        MatchAudioCue.penalty => 'Pênalti',
        MatchAudioCue.penaltySaved => 'Pênalti defendido',
        MatchAudioCue.injury => 'Lesão',
      };
}

class MenuTrackInfo {
  const MenuTrackInfo({
    required this.asset,
    required this.title,
    required this.artist,
  });

  final String asset;
  final String title;
  final String artist;

  String get displayName => artist.isEmpty ? title : '$artist — $title';
}

abstract final class AudioCatalog {
  static const matchAmbienceAsset =
      'assets/audio/match/stadium_ambience.m4a';

  static const cleanMatchCues = {
    MatchAudioCue.kickoff,
    MatchAudioCue.halftime,
    MatchAudioCue.secondHalf,
    MatchAudioCue.fulltime,
    MatchAudioCue.goal,
    MatchAudioCue.yellowCard,
    MatchAudioCue.redCard,
    MatchAudioCue.substitution,
    MatchAudioCue.shot,
    MatchAudioCue.save,
    MatchAudioCue.woodwork,
    MatchAudioCue.penalty,
    MatchAudioCue.penaltySaved,
    MatchAudioCue.injury,
  };

  static bool isCleanMatchCue(MatchAudioCue cue) => cleanMatchCues.contains(cue);

  // Os títulos abaixo vêm dos próprios nomes dos arquivos fornecidos para o
  // projeto. Os OGG não possuem metadados embutidos, então o catálogo não
  // inventa nomes alternativos nem autores que não estejam identificáveis.
  static const menuTracks = [
    MenuTrackInfo(
      asset: 'assets/audio/menu/menu_jim_yosef_lights.ogg',
      artist: 'Jim Yosef',
      title: 'Lights',
    ),
    MenuTrackInfo(
      asset: 'assets/audio/menu/menu_disfigure_blank.ogg',
      artist: 'Disfigure',
      title: 'Blank',
    ),
    MenuTrackInfo(
      asset: 'assets/audio/menu/menu_deaf_kev_invincible.ogg',
      artist: 'DEAF KEV',
      title: 'Invincible',
    ),
    MenuTrackInfo(
      asset: 'assets/audio/menu/menu_cormak_flavors.ogg',
      artist: 'Cormak',
      title: 'Flavors',
    ),
    MenuTrackInfo(
      asset: 'assets/audio/menu/menu_david_bulla_unexpected.ogg',
      artist: 'David Bulla',
      title: 'Unexpected',
    ),
  ];

  static List<String> get menuAssets =>
      menuTracks.map((track) => track.asset).toList(growable: false);

  static const uiAssets = {
    UiAudioCue.tap: 'assets/audio/ui/navigation.mp3',
    UiAudioCue.navigation: 'assets/audio/ui/navigation.mp3',
    UiAudioCue.confirm: 'assets/audio/ui/confirm.wav',
  };

  static const matchAssets = {
    MatchAudioCue.kickoff: 'assets/audio/match/kickoff.mp3',
    MatchAudioCue.halftime: 'assets/audio/match/halftime.mp3',
    MatchAudioCue.secondHalf: 'assets/audio/match/kickoff.mp3',
    MatchAudioCue.fulltime: 'assets/audio/match/fulltime.mp3',
    MatchAudioCue.goal: 'assets/audio/match/goal.mp3',
    MatchAudioCue.yellowCard: 'assets/audio/match/yellow_card.mp3',
    MatchAudioCue.redCard: 'assets/audio/match/red_card.mp3',
    MatchAudioCue.foul: 'assets/audio/match/foul.mp3',
    MatchAudioCue.substitution: 'assets/audio/match/substitution.wav',
    MatchAudioCue.pass: 'assets/audio/match/pass.mp3',
    MatchAudioCue.corner: 'assets/audio/match/corner.mp3',
    MatchAudioCue.offside: 'assets/audio/match/offside.mp3',
    MatchAudioCue.goalKick: 'assets/audio/match/goal_kick.mp3',
    MatchAudioCue.shot: 'assets/audio/match/shot.mp3',
    MatchAudioCue.save: 'assets/audio/match/save.mp3',
    MatchAudioCue.woodwork: 'assets/audio/match/woodwork.wav',
    MatchAudioCue.penalty: 'assets/audio/match/penalty.wav',
    MatchAudioCue.penaltySaved: 'assets/audio/match/penalty_saved.wav',
    MatchAudioCue.injury: 'assets/audio/match/injury.wav',
  };

  static MatchAudioCue? cueForEvent(MatchEvent event) => switch (event.type) {
        MatchEventType.kickoff => MatchAudioCue.kickoff,
        MatchEventType.shot => MatchAudioCue.shot,
        MatchEventType.save => MatchAudioCue.save,
        MatchEventType.woodwork => MatchAudioCue.woodwork,
        MatchEventType.goal || MatchEventType.ownGoal => MatchAudioCue.goal,
        MatchEventType.foul => MatchAudioCue.foul,
        MatchEventType.yellow => MatchAudioCue.yellowCard,
        MatchEventType.red => MatchAudioCue.redCard,
        MatchEventType.penalty => MatchAudioCue.penalty,
        MatchEventType.penaltySaved => MatchAudioCue.penaltySaved,
        MatchEventType.substitution => MatchAudioCue.substitution,
        MatchEventType.injury => MatchAudioCue.injury,
        MatchEventType.halftime => MatchAudioCue.halftime,
        MatchEventType.fulltime => MatchAudioCue.fulltime,
        MatchEventType.pass => MatchAudioCue.pass,
        MatchEventType.possession => null,
      };
}
