class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.91';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.91',
      title: 'Home com tipografia ampliada',
      changes: [
        'Aumenta em 3 px/lp a base tipográfica da Home com encaixe responsivo, mantendo as dimensões atuais dos cards.',
        'Mostra nomes completos na tabela, usa Brasileiro Série A, AVANÇAR DIA/JOGAR PARTIDA e amplia os escudos do confronto em 10 px.',
        'Corrige os erros de analyzer do pré-jogo da 0.1.1.90 sem alterar o design ou as regras da partida.',
      ],
    ),
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
  ];


}
