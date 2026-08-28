class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.81';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.81',
      title: 'Correção da Home 0.1.1.80',
      changes: [
        'Corrige o fechamento da classe de fundo da Home que interrompia o flutter analyze.',
        'Mantém intacto o novo layout visual, os dois fundos de estádio e todos os dados reais exibidos na Home.',
        'Adiciona regressão estrutural para impedir que componentes da Home voltem a ficar aninhados por erro de fechamento.',
      ],
    ),
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
  ];


}
