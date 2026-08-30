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
      title: 'Análise estática de Finanças corrigida',
      changes: [
        'Importa o componente compartilhado DashboardSectionHeader na tela de Finanças, corrigindo o símbolo indefinido apontado pelo CI.',
        'Remove duas asserções não nulas redundantes na previsão financeira para manter o flutter analyze sem warnings.',
        'Preserva a lógica financeira, os dados da carreira e todas as integrações existentes.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.120',
      title: 'Correção da compilação de Finanças',
      changes: [
        'Corrige o fechamento de FinanceBalanceOverview que fazia o analisador interpretar os componentes seguintes como classes internas.',
        'Mantém a tela de Finanças e suas integrações existentes sem criar lógica financeira paralela.',
        'Ajusta a lista de Novidades para manter exatamente três releases, conforme validado pelos testes do projeto.',
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
