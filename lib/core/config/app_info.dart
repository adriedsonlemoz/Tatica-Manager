class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.120';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.120',
      title: 'Transferências centralizadas e Finanças compactas',
      changes: [
        'Centraliza compras, vendas, renovações e empréstimos em Negociações persistidas; nenhum acordo altera elenco, contrato ou caixa antes da conclusão.',
        'Integra orçamento de transferências, caixa, parcelas, luvas, folha salarial, contratos e retorno automático de empréstimos à mesma carreira.',
        'Mantém Finanças sem rolagem na tela principal e leva histórico, patrocínios e orçamentos para detalhes expansíveis.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.119',
      title: 'Finanças conectadas à carreira',
      changes: [
        'Redesenha Finanças com Resumo, Receitas, Despesas e Salários, usando exclusivamente o livro-caixa real da carreira.',
        'Adiciona gráfico mensal, distribuição de gastos, filtros por categoria e previsão calculada a partir de meses fechados com lançamentos.',
        'Conecta Estádio, Mercado, Contratos, Patrocínios e Orçamentos; novos lançamentos de transferência e renovação passam a usar a data da carreira.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.118',
      title: 'Pré-jogo alinhado à referência',
      changes: [
        'Redesenha o Pré-jogo com confronto tático, escalações prováveis, desfalques e os três atalhos Escalação, Tática e Uniformes.',
        'Usa formação, tática, força, titulares, desfalques e forma recente derivados dos dados reais da carreira, sem técnico, clima ou árbitro inventados.',
        'Adiciona simulação direta pelo mesmo LiveMatchController e move a escolha de uniformes para um pop-up centralizado.',
      ],
    ),
  ];
}
