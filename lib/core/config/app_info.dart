class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.123';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.123',
      title: 'Correção dos testes de Finanças e Transferências',
      changes: [
        'Restaura Estádio e Patrocínios como seções expansíveis funcionais dentro dos detalhes financeiros, sem voltar a rolar a tela principal.',
        'Mantém os módulos reais de estádio, patrocínios e orçamentos integrados à tela compacta de Finanças.',
        'Registra a renovação contratual com a data do estado atualizado da carreira para manter o livro-caixa temporalmente consistente.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.122',
      title: 'Limpeza final do analyzer em Finanças',
      changes: [
        'Remove as duas asserções de não-nulo redundantes apontadas pelo Flutter analyzer no saldo projetado de Finanças.',
        'Remove temporariamente o widget privado _FinanceExpansion que estava sem referência após a compactação da tela financeira.',
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
  ];
}
