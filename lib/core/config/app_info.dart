class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.135';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.135',
      title: 'Transmissão legível e disciplina integrada',
      changes: [
        'Mantém campo, comandos, estatísticas e narração visíveis sem rolagem.',
        'Dá movimento contextual aos atletas e reduz etiquetas sobrepostas.',
        'Exibe cartões e suspensões na escalação, elenco, perfil e partida.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.134',
      title: 'Correção do analyzer do campo dinâmico',
      changes: [
        'Corrige o único aviso fatal encontrado pelo GitHub Actions no renderer do campo.',
        'Mantém intactas as formações reais, a posse estável e a movimentação por fases.',
        'Libera novamente o pipeline para testes e geração do APK.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.133',
      title: 'Campo ao vivo mais dinâmico',
      changes: [
        'Representa no campo as formações reais escolhidas pelos dois times.',
        'Estabiliza a posse ao vivo e movimenta os blocos conforme bola e domínio.',
        'Melhora nomes, bola, áreas, gols e aproximações dos lances importantes.',
      ],
    ),
  ];
}
