enum Mentality { defensive, balanced, attacking }
enum Pressing { low, medium, high }
enum MatchTempo { slow, normal, fast }
enum DefensiveLine { low, medium, high }
enum BuildUp { short, balanced, direct }

extension MentalityX on Mentality {
  String get label => switch (this) {
        Mentality.defensive => 'Defensiva',
        Mentality.balanced => 'Equilibrada',
        Mentality.attacking => 'Ofensiva',
      };
}

extension PressingX on Pressing {
  String get label => switch (this) {
        Pressing.low => 'Baixa',
        Pressing.medium => 'Média',
        Pressing.high => 'Alta',
      };
}

extension MatchTempoX on MatchTempo {
  String get label => switch (this) {
        MatchTempo.slow => 'Lento',
        MatchTempo.normal => 'Normal',
        MatchTempo.fast => 'Rápido',
      };
}

extension DefensiveLineX on DefensiveLine {
  String get label => switch (this) {
        DefensiveLine.low => 'Baixa',
        DefensiveLine.medium => 'Média',
        DefensiveLine.high => 'Alta',
      };
}

extension BuildUpX on BuildUp {
  String get label => switch (this) {
        BuildUp.short => 'Curta',
        BuildUp.balanced => 'Equilibrada',
        BuildUp.direct => 'Direta',
      };
}

class Tactic {
  const Tactic({
    this.mentality = Mentality.balanced,
    this.pressing = Pressing.medium,
    this.tempo = MatchTempo.normal,
    this.defensiveLine = DefensiveLine.medium,
    this.buildUp = BuildUp.balanced,
  });

  final Mentality mentality;
  final Pressing pressing;
  final MatchTempo tempo;
  final DefensiveLine defensiveLine;
  final BuildUp buildUp;

  Tactic copyWith({
    Mentality? mentality,
    Pressing? pressing,
    MatchTempo? tempo,
    DefensiveLine? defensiveLine,
    BuildUp? buildUp,
  }) =>
      Tactic(
        mentality: mentality ?? this.mentality,
        pressing: pressing ?? this.pressing,
        tempo: tempo ?? this.tempo,
        defensiveLine: defensiveLine ?? this.defensiveLine,
        buildUp: buildUp ?? this.buildUp,
      );

  Map<String, dynamic> toJson() => {
        'mentality': mentality.name,
        'pressing': pressing.name,
        'tempo': tempo.name,
        'defensiveLine': defensiveLine.name,
        'buildUp': buildUp.name,
      };

  factory Tactic.fromJson(Map<String, dynamic> json) => Tactic(
        mentality: Mentality.values.firstWhere((e) => e.name == json['mentality'], orElse: () => Mentality.balanced),
        pressing: Pressing.values.firstWhere((e) => e.name == json['pressing'], orElse: () => Pressing.medium),
        tempo: MatchTempo.values.firstWhere((e) => e.name == json['tempo'], orElse: () => MatchTempo.normal),
        defensiveLine: DefensiveLine.values.firstWhere((e) => e.name == json['defensiveLine'], orElse: () => DefensiveLine.medium),
        buildUp: BuildUp.values.firstWhere((e) => e.name == json['buildUp'], orElse: () => BuildUp.balanced),
      );
}
