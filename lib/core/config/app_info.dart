class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.118';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.118',
      title: 'Elenco e Classificação conforme mockups',
      changes: [
        'Reformula o Elenco com cabeçalho do clube, abas, tabela compacta, moral e resumo de nacionalidades.',
        'Reformula a Classificação sem rolagem horizontal e adiciona abas funcionais, informações do campeonato e critérios de desempate.',
        'Adapta integralmente as duas telas aos modos claro e escuro sem alterar dados, Match Engine, saves ou IDs.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.117',
      title: 'Refinamento da Home compacta',
      changes: [
        'Distribui os seis indicadores do Resumo da Temporada em uma única faixa e compacta os atalhos.',
        'Move o ícone de Avançar/Jogar para a direita, melhora espaçamentos e normaliza os escudos da Próxima Partida.',
        'Adiciona retorno explícito ao menu Mais quando aberto pela barra superior, sem alterar a aba raiz.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.116',
      title: 'Correção dos testes da Home e tema',
      changes: [
        'Atualiza a regressão da paleta para as cores atuais do tema claro/escuro.',
        'Faz o teste de avatares validar a nova HomeCleanRankings em vez da ligação removida da Home antiga.',
        'Preserva Home, tema, libGDX, movimentação, Match Engine, saves e IDs.',
      ],
    ),
  ];

}
