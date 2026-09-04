enum TrainingFocus { recovery, balanced, tactical, physical, technical }

enum TrainingIntensity { light, normal, high }

extension TrainingFocusX on TrainingFocus {
  String get label => switch (this) {
        TrainingFocus.recovery => 'Recuperação',
        TrainingFocus.balanced => 'Equilibrado',
        TrainingFocus.tactical => 'Tático',
        TrainingFocus.physical => 'Físico',
        TrainingFocus.technical => 'Técnico',
      };

  String get description => switch (this) {
        TrainingFocus.recovery =>
          'Prioriza condição física e redução de fadiga.',
        TrainingFocus.balanced =>
          'Mantém recuperação e carga de trabalho em equilíbrio.',
        TrainingFocus.tactical =>
          'Prepara os titulares e reforça confiança no plano de jogo.',
        TrainingFocus.physical =>
          'Usa carga maior quando há intervalo seguro até a partida.',
        TrainingFocus.technical =>
          'Sessão moderada voltada ao trabalho com bola.',
      };
}

extension TrainingIntensityX on TrainingIntensity {
  String get label => switch (this) {
        TrainingIntensity.light => 'Leve',
        TrainingIntensity.normal => 'Normal',
        TrainingIntensity.high => 'Alta',
      };
}

class TrainingPlan {
  const TrainingPlan({
    this.focus = TrainingFocus.balanced,
    this.intensity = TrainingIntensity.normal,
    this.managedByAssistant = true,
  });

  final TrainingFocus focus;
  final TrainingIntensity intensity;
  final bool managedByAssistant;

  TrainingPlan copyWith({
    TrainingFocus? focus,
    TrainingIntensity? intensity,
    bool? managedByAssistant,
  }) =>
      TrainingPlan(
        focus: focus ?? this.focus,
        intensity: intensity ?? this.intensity,
        managedByAssistant:
            managedByAssistant ?? this.managedByAssistant,
      );

  Map<String, dynamic> toJson() => {
        'focus': focus.name,
        'intensity': intensity.name,
        'managedByAssistant': managedByAssistant,
      };

  factory TrainingPlan.fromJson(Map<String, dynamic> json) => TrainingPlan(
        focus: TrainingFocus.values.firstWhere(
          (value) => value.name == json['focus'],
          orElse: () => TrainingFocus.balanced,
        ),
        intensity: TrainingIntensity.values.firstWhere(
          (value) => value.name == json['intensity'],
          orElse: () => TrainingIntensity.normal,
        ),
        managedByAssistant: json['managedByAssistant'] as bool? ?? true,
      );
}
