enum MatchDurationPreset {
  quick(4, 'Rápida', '4 min'),
  normal(6, 'Normal', '6 min'),
  complete(8, 'Completa', '8 min');

  const MatchDurationPreset(this.minutes, this.label, this.shortLabel);

  final int minutes;
  final String label;
  final String shortLabel;

  static MatchDurationPreset fromMinutes(Object? value) {
    final minutes = value is num ? value.toInt() : 6;
    return MatchDurationPreset.values.firstWhere(
      (preset) => preset.minutes == minutes,
      orElse: () => MatchDurationPreset.normal,
    );
  }
}
