class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.95';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.95',
      title: 'Campo da partida redesenhado',
      changes: [
        'Refaz o gramado da partida com perspectiva mais equilibrada, moldura de estádio e marcações/gols redesenhados do zero.',
        'Reordena o desenho dos jogadores por profundidade e reduz novamente a escala visual para aproximar o enquadramento do mockup.',
        'Mantém torcida, Match Engine, eventos, placar, saves, IDs e fundação multi-competição intactos.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.94',
      title: 'Transmissão ao vivo refinada',
      changes: [
        'Aproxima o campo do enquadramento do mockup, com perspectiva mais suave e jogadores menores e melhor espaçados.',
        'Redesenha posse, chutes, chutes no gol e cartões com leitura de transmissão e reforça timeline, controles, rodada e placar.',
        'Mantém a torcida existente como fundo e preserva integralmente o Match Engine e os eventos já calculados.',
      ],
    ),
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
  ];


}
