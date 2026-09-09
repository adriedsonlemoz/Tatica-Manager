class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.143';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.143',
      title: 'Polimento visual orientado por vídeo',
      changes: [
        'Aproveita melhor a altura da transmissão e organiza o fim de jogo.',
        'Aumenta a separação visual entre nomes no campo e corrige a disciplina.',
        'Compacta as prioridades do auxiliar e os atalhos da tela Mais.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.142',
      title: 'Correção do analyzer do polimento',
      changes: [
        'Adapta o controle do Avançar Dia ao NotifierProvider do Riverpod 3.',
        'Restaura o import explícito do diálogo de notícias.',
        'Corrige a sintaxe do teste da apresentação inicial da carreira.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.141',
      title: 'Polimento visual e avisos globais',
      changes: [
        'Prioriza recompensas em um card global que desliza pelo topo.',
        'Melhora tipografia, leitura de notícias e apresentação da carreira.',
        'Torna o avanço de dia natural e mantém o Dia de Jogo sem rolagem.',
      ],
    ),
  ];
}
