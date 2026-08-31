class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.121';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.121',
      title: 'Correção do build de Finanças e Transferências',
      changes: [
        'Corrige o fechamento de FinanceBalanceOverview que fazia os demais componentes financeiros serem interpretados como classes internas e bloqueava a análise estática.',
        'Restaura os imports explícitos de CareerState em Finanças e TransferOperationResult na Central de Negociações.',
        'Mantém intactas as regras e integrações da central de transferências, contratos, salários, orçamento e livro-caixa da 0.1.1.120.',
      ],
    ),
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
  ];
}
