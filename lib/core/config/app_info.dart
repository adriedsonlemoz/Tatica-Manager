class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.112';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
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
    ReleaseNote(
      version: '0.1.1.110',
      title: 'Teste da Home sincronizado',
      changes: [
        'Atualiza o teste estrutural da Home para os componentes realmente usados pelo layout atual.',
        'Remove expectativas obsoletas de widgets antigos sem alterar a interface ou a lógica do jogo.',
        'Mantém Match Engine, saves, playlist reduzida e regras do jogo inalterados.',
      ],
    ),
  ];

}
