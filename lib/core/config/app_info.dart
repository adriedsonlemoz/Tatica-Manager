class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.93';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.93',
      title: 'Torcida integrada à partida',
      changes: [
        'Integra a torcida noturna como fundo real do estádio atrás do campo em perspectiva, mantendo o Canvas como fallback.',
        'O asset é convertido para WebP otimizado e carregado apenas pela camada visual da partida.',
        'Corrige o único erro de analyzer do GitHub Actions da 0.1.1.92 no teste visual da partida.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.92',
      title: 'Partida em perspectiva',
      changes: [
        'Reformula o campo Flame com perspectiva, estádio desenhado em Canvas e jogadores maiores usando os padrões reais dos uniformes dos clubes.',
        'Aproxima placar, rodada, timeline e controles da linguagem de transmissão sem revelar eventos futuros nem alterar o Match Engine.',
        'Remodela a Passagem do Tempo com datas e processos reais da carreira, sem adicionar imagens ou alterar saves.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.91',
      title: 'Home com tipografia ampliada',
      changes: [
        'Aumenta em 3 px/lp a base tipográfica da Home com encaixe responsivo, mantendo as dimensões atuais dos cards.',
        'Mostra nomes completos na tabela, usa Brasileiro Série A, AVANÇAR DIA/JOGAR PARTIDA e amplia os escudos do confronto em 10 px.',
        'Corrige os erros de analyzer do pré-jogo da 0.1.1.90 sem alterar o design ou as regras da partida.',
      ],
    ),
  ];


}
