class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.80';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.80',
      title: 'Home integrada e mais compacta',
      changes: [
        'Integra melhor o bloco inferior da Home com um painel único, backdrop mais vivo e atalhos coloridos sem perder a identidade do jogo.',
        'Transforma Notícias & Destaques em lista compacta e reduz o volume visual para aproximar mais conteúdo do primeiro enquadramento.',
        'Aproxima Confiança da Diretoria e Panorama da Temporada, além de reforçar navegação para tabela e ranking.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.79',
      title: 'Home visual premium',
      changes: [
        'Reformula a Home com hierarquia mais compacta, fundos de estádio e componentes alinhados à referência visual aprovada.',
        'Integra os dados reais de clube, finanças, partida, estádio e confiança sem criar campos novos no save.',
        'Conecta o Panorama da Temporada à classificação e separa componentes visuais para facilitar manutenção.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.78',
      title: 'Virada de temporada multi-competição',
      changes: [
        'Corrige a conclusão da temporada quando fixtures já estão encerrados, mas o flag persistido da competição ainda está desatualizado.',
        'Mantém a conclusão baseada nos jogos reais de cada competição carregada, com fallback seguro para estados sem fixtures.',
        'Atualiza a regressão de fadiga para acompanhar o MatchCareerImpactEngine sem devolver regra ao controller.',
      ],
    ),
  ];


}
