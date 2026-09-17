class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.147';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.147',
      title: 'Correção do Build 100',
      changes: [
        'Corrige o único teste de metadados que bloqueava o pipeline após a atualização das locuções.',
        'Mantém em Sobre / Novidades apenas as três releases mais recentes, como definido pelo teste do projeto.',
        'Preserva integralmente as 15 locuções, os novos efeitos e a mixagem de áudio da partida.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.146',
      title: 'Locução oficial da partida',
      changes: [
        'Troca o TTS principal por 15 falas gravadas na mesma voz para os eventos importantes.',
        'Diferencia a locução de gol do mandante e do visitante sem alterar o Match Engine.',
        'Mantém TTS apenas como fallback se um asset de voz não puder ser reproduzido.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.145',
      title: 'Áudio de partida renovado',
      changes: [
        'Substitui o ambiente contínuo por uma torcida tratada e preparada para loop.',
        'Integra novos sons de chute, trave, defesa, gol e pênalti defendido.',
        'Reduz o ganho do ambiente para manter efeitos e narração claros sem chiado constante.',
      ],
    ),
  ];
}
