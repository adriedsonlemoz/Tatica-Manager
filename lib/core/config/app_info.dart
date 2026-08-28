class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.89';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.89',
      title: 'Home mais legível e informativa',
      changes: [
        'Aumenta tipografia e presença visual de partida, finanças, atalhos, notícias, tabela e artilheiros sem voltar ao layout alto.',
        'Remove os rodapés redundantes da tabela e artilharia e aproveita o espaço livre com últimas partidas quando houver histórico.',
        'Adiciona pontos de atenção nos atalhos apenas quando existe uma pendência real já conhecida pelo jogo.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.88',
      title: 'Home compacta mais legível',
      changes: [
        'Move Avançar/Jogar para o centro da faixa de informações da Próxima Partida, eliminando o horário duplicado.',
        'Aumenta tipografia do topo, atalhos, notícias, classificação e artilheiros mantendo a Home compacta.',
        'Remove escudos da tabela ultracompacta e equilibra melhor o bloco inferior.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.87',
      title: 'Correção do teste estrutural da Home',
      changes: [
        'Atualiza o teste da Home para o rótulo compacto atual de preparação sem alterar código funcional.',
      ],
    ),
  ];


}
