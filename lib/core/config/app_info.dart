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
