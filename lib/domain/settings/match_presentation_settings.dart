enum MatchDurationPreset {
  quick(1, 'Rápida', '1 min/tempo'),
  normal(2, 'Normal', '2 min/tempo'),
  complete(3, 'Completa', '3 min/tempo');

  const MatchDurationPreset(this.minutes, this.label, this.shortLabel);

  /// Minutos reais de apresentação para cada tempo da partida.
  final int minutes;
  final String label;
  final String shortLabel;

  static MatchDurationPreset fromMinutes(Object? value) {
    final minutes = value is num ? value.toInt() : 2;
    for (final preset in MatchDurationPreset.values) {
      if (preset.minutes == minutes) return preset;
    }

    // Saves até 0.1.1.68 armazenavam a duração total da transmissão
    // (4/6/8 min). Convertemos sem alterar o schema e limitamos o máximo
    // aos novos 3 minutos por tempo.
    return switch (minutes) {
      4 => MatchDurationPreset.quick,
      6 => MatchDurationPreset.normal,
      8 => MatchDurationPreset.complete,
      _ => MatchDurationPreset.normal,
    };
  }
}
