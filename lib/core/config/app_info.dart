class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.82';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.82',
      title: 'Correção do teste da Home',
      changes: [
        'Corrige a única falha restante do GitHub Actions após 266 testes já aprovados.',
        'A regressão passa a comparar literalmente o escape de quebra de linha usado no rótulo Departamento Médico.',
        'Não altera layout, assets, saves, dados ou lógica do jogo.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.81',
      title: 'Correção de sintaxe da Home',
      changes: [
        'Corrige o fechamento da classe de backdrop que causava erros em cascata no analyzer.',
        'Preserva integralmente o layout visual e os assets da Home 0.1.1.80.',
        'Adiciona regressão estrutural para proteger a composição da Home.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.80',
      title: 'Home integrada e mais compacta',
      changes: [
        'Integra melhor o bloco inferior da Home com painel único e backdrop mais vivo.',
        'Transforma Notícias & Destaques em lista compacta e reforça atalhos, tabela e artilharia.',
        'Mantém todos os dados ligados ao save e preserva a arquitetura do jogo.',
      ],
    ),
  ];


}
