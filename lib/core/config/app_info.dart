class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.148';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.148',
      title: 'Locução oficial sem fallback',
      changes: [
        'Remove o fallback para a voz TTS antiga do Android nos eventos da partida.',
        'Converte as 15 locuções oficiais para WAV PCM 48 kHz estéreo para maior compatibilidade.',
        'Se uma locução oficial falhar, o evento fica sem voz em vez de usar uma voz diferente.',
      ],
    ),
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
        'Adiciona 15 falas pré-gravadas na mesma identidade vocal para os eventos importantes.',
        'Diferencia a locução de gol do mandante e do visitante sem alterar o Match Engine.',
        'Registra a primeira integração das locuções oficiais na camada de áudio.',
      ],
    ),
  ];
}
