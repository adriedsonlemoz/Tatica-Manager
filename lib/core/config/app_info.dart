class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.64';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.64',
      title: 'Correção do editor de escudos',
      changes: [
        'Corrige os imports usados pela edição individual e visualização de escudos personalizados.',
        'ClubIconValidator e as funções Base64 ficam disponíveis corretamente para os arquivos part do editor.',
        'Packs, saves, schema 11, Match Engine e workflow permanecem inalterados.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.63',
      title: 'Home, packs e áudio pós-jogo',
      changes: [
        'Home ganha resumo financeiro, estádio, preparação integrada ao próximo jogo, ranking compacto e Notícias & Destaques próprio.',
        'Pacote completo passa a deixar explícita a importação conjunta de clubes, jogadores, técnicos e escudos por IDs permanentes.',
        'Fim da partida encerra ambiente, efeitos e narração para evitar áudio residual antes de retomar a música de menu.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.62',
      title: 'Packs de escudos por ID',
      changes: [
        'Adiciona importação de vários escudos em um único arquivo .tmlogos/JSON.',
        'Cada imagem é associada exclusivamente ao ID permanente do clube, com prévia antes de aplicar.',
        'Packs podem ser parciais e não alteram nomes, elencos, técnicos, estádio, uniformes ou Match Engine.',
      ],
    ),
  ];

}
