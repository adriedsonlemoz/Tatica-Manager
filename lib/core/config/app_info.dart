class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.113';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.113',
      title: 'Elenco em lista compacta',
      changes: [
        'Redesenha a tela Elenco no formato compacto da referência, com cabeçalho do clube e uma única lista de jogadores.',
        'Remove a faixa de abas e mantém busca e filtros existentes apenas nos ícones do topo.',
        'Mostra número, jogador, posição, GER, moral e o resumo de brasileiros/estrangeiros usando somente dados já existentes no save.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.112',
      title: 'Novidades limitada às três releases recentes',
      changes: [
        'Corrige o teste de Sobre / Novidades que falhava porque a lista havia acumulado mais de três releases.',
        'Mantém na tela somente as três releases mais recentes, preservando o histórico completo nos documentos de release.',
        'Não altera músicas, player, Match Engine, saves, IDs, regras ou resultados do jogo.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.111',
      title: 'Músicas do menu mais leves',
      changes: [
        'Recomprime as cinco músicas padrão do menu com Opus em contêiner OGG, preservando estéreo e duração completa.',
        'Reduz o conjunto das cinco faixas em cerca de 15% sem alterar a playlist, os nomes ou o comportamento do player.',
        'Mantém Match Engine, saves, IDs, efeitos sonoros e regras do jogo inalterados.',
      ],
    ),
  ];

}
