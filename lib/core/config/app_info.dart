class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.115';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.115',
      title: 'Correção do cabeçalho da Home',
      changes: [
        'Corrige o erro de análise estática causado pelo uso inválido de minHeight no Container do cabeçalho da Home.',
        'Mantém a altura mínima planejada usando BoxConstraints, sem desfazer o alinhamento visual da Home.',
        'Não altera Match Engine, músicas, saves, IDs, regras ou resultados do jogo.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.114',
      title: 'Home alinhada à referência',
      changes: [
        'Corrige a paleta da Home, removendo o verde excessivo dos cards e usando o verde escuro apenas na ação principal.',
        'Restaura o cabeçalho superior, amplia os ícones dos atalhos e aproxima Próxima Partida, Resumo, Classificação e Artilharia da referência fornecida.',
        'Corrige também o teste do Elenco que ainda esperava PlayerCard depois da nova lista compacta.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.113',
      title: 'Elenco em lista compacta',
      changes: [
        'Redesenha a tela Elenco no formato compacto da referência, com cabeçalho do clube e uma única lista de jogadores.',
        'Remove a faixa de abas e mantém busca e filtros existentes apenas nos ícones do topo.',
        'Mostra número, jogador, posição, GER, moral e o resumo de brasileiros/estrangeiros usando somente dados já existentes no save.',
      ],
    ),
  ];

}
