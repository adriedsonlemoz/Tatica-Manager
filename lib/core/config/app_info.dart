class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.90';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.90',
      title: 'Preparação da partida premium',
      changes: [
        'Reorganiza o pré-jogo com confronto em destaque, status do dia de jogo e informações reais de competição, data, hora, estádio e mando.',
        'Refaz duração e plano de jogo mantendo as mesmas funções e regras já existentes.',
        'Substitui a grade de titulares por um campo tático somente leitura usando as posições reais da formação e OVR efetivo.',
      ],
    ),
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
  ];


}
