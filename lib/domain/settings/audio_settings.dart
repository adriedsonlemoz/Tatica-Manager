class AudioSettings {
  const AudioSettings({
    this.musicEnabled = true,
    this.interfaceEnabled = true,
    this.matchEnabled = true,
    this.cleanAudio = true,
    this.narrationEnabled = false,
    this.masterVolume = .78,
    this.musicVolume = .12,
    this.interfaceVolume = .28,
    this.matchVolume = .48,
    this.narrationVolume = .72,
    this.useCustomMenuMusic = false,
    this.customMenuTracks = const [],
    this.customMatchSounds = const {},
  });

  final bool musicEnabled;
  final bool interfaceEnabled;
  final bool matchEnabled;
  final bool cleanAudio;
  final bool narrationEnabled;
  final double masterVolume;
  final double musicVolume;
  final double interfaceVolume;
  final double matchVolume;
  final double narrationVolume;
  final bool useCustomMenuMusic;
  final List<String> customMenuTracks;
  final Map<String, String> customMatchSounds;

  AudioSettings copyWith({
    bool? musicEnabled,
    bool? interfaceEnabled,
    bool? matchEnabled,
    bool? cleanAudio,
    bool? narrationEnabled,
    double? masterVolume,
    double? musicVolume,
    double? interfaceVolume,
    double? matchVolume,
    double? narrationVolume,
    bool? useCustomMenuMusic,
    List<String>? customMenuTracks,
    Map<String, String>? customMatchSounds,
  }) =>
      AudioSettings(
        musicEnabled: musicEnabled ?? this.musicEnabled,
        interfaceEnabled: interfaceEnabled ?? this.interfaceEnabled,
        matchEnabled: matchEnabled ?? this.matchEnabled,
        cleanAudio: cleanAudio ?? this.cleanAudio,
        narrationEnabled: narrationEnabled ?? this.narrationEnabled,
        masterVolume: _volume(masterVolume ?? this.masterVolume),
        musicVolume: _volume(musicVolume ?? this.musicVolume),
        interfaceVolume: _volume(interfaceVolume ?? this.interfaceVolume),
        matchVolume: _volume(matchVolume ?? this.matchVolume),
        narrationVolume: _volume(narrationVolume ?? this.narrationVolume),
        useCustomMenuMusic: useCustomMenuMusic ?? this.useCustomMenuMusic,
        customMenuTracks: customMenuTracks ?? this.customMenuTracks,
        customMatchSounds: customMatchSounds ?? this.customMatchSounds,
      );

  Map<String, dynamic> toJson() => {
        'musicEnabled': musicEnabled,
        'interfaceEnabled': interfaceEnabled,
        'matchEnabled': matchEnabled,
        'cleanAudio': cleanAudio,
        'narrationEnabled': narrationEnabled,
        'masterVolume': masterVolume,
        'musicVolume': musicVolume,
        'interfaceVolume': interfaceVolume,
        'matchVolume': matchVolume,
        'narrationVolume': narrationVolume,
        'useCustomMenuMusic': useCustomMenuMusic,
        'customMenuTracks': customMenuTracks,
        'customMatchSounds': customMatchSounds,
      };

  factory AudioSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AudioSettings();
    final tracks = ((json['customMenuTracks'] as List?) ?? const [])
        .whereType<String>()
        .where((path) => path.isNotEmpty)
        .toList(growable: false);
    final overrides = <String, String>{};
    final rawOverrides = json['customMatchSounds'];
    if (rawOverrides is Map) {
      for (final entry in rawOverrides.entries) {
        final key = entry.key;
        final value = entry.value;
        if (key is String && value is String && value.isNotEmpty) {
          overrides[key] = value;
        }
      }
    }
    return AudioSettings(
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      interfaceEnabled: json['interfaceEnabled'] as bool? ?? true,
      matchEnabled: json['matchEnabled'] as bool? ?? true,
      cleanAudio: json['cleanAudio'] as bool? ?? true,
      narrationEnabled: json['narrationEnabled'] as bool? ?? false,
      masterVolume: _volume((json['masterVolume'] as num?)?.toDouble() ?? .78),
      musicVolume: _volume((json['musicVolume'] as num?)?.toDouble() ?? .12),
      interfaceVolume: _volume((json['interfaceVolume'] as num?)?.toDouble() ?? .28),
      matchVolume: _volume((json['matchVolume'] as num?)?.toDouble() ?? .48),
      narrationVolume: _volume(
        (json['narrationVolume'] as num?)?.toDouble() ?? .72,
      ),
      useCustomMenuMusic: json['useCustomMenuMusic'] as bool? ?? false,
      customMenuTracks: tracks,
      customMatchSounds: overrides,
    );
  }

  static double _volume(double value) => value.clamp(0.0, 1.0).toDouble();
}
