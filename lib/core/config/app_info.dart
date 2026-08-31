class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.122';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.122',
      title: 'Limpeza final do analyzer em Finanças',
      changes: [
        'Remove as duas asserções de não-nulo redundantes apontadas pelo Flutter analyzer no saldo projetado de Finanças.',
        'Remove o widget privado _FinanceExpansion que não era mais utilizado após a compactação da tela financeira.',
        'Preserva integralmente Transferências, contratos, salários, orçamento, caixa, saves e Match Engine da release anterior.',
      ],
    ),
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
  ];
}
