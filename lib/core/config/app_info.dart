class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.119';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
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
    ReleaseNote(
      version: '0.1.1.117',
      title: 'Correção de consistência do Estádio',
      changes: [
        'Corrige os dois testes que bloquearam o CI da 0.1.1.116 sem remover os novos sistemas do Estádio.',
        'Aplica acento legível baseado na cor do clube e limita a disponibilidade de obras ao menor valor entre caixa e orçamento do estádio.',
        'Mantém Match Engine, músicas, saves e regras de partida inalterados.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.116',
      title: 'Estádio imersivo e novos sistemas',
      changes: [
        'Redesenha o Estádio conforme a referência aprovada usando as duas imagens otimizadas do estádio.',
        'Cria manutenção persistente, Centro de Treinamento e obras com prazo/status que só aplicam melhorias na conclusão.',
        'Mantém Match Engine, músicas, IDs e resultados de partidas inalterados.',
      ],
    ),
  ];
}
