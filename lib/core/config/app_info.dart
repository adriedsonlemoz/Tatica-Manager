class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.65';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.65',
      title: 'Módulos mais vivos e substituições corrigidas',
      changes: [
        'Contratos, Base, Departamento Médico, Estádio, Dia de Jogo e Finanças recebem uma composição visual mais viva usando os dados e ações já existentes.',
        'O Estádio ganha uma apresentação noturna animada em CustomPaint e os novos painéis são divididos em componentes menores, sem criar sistemas paralelos.',
        'A partida ao vivo limita o clube do usuário a cinco substituições e impede que um jogador substituído retorne ao jogo.',
      ],
    ),
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
  ];

}
