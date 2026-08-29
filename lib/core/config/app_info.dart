class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.97';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.97',
      title: 'Correção dos testes da transmissão',
      changes: [
        'Atualiza a regressão visual da partida para a nova perspectiva e escala do campo redesenhado.',
        'Restaura a tela Sobre/Novidades para manter exatamente as três releases mais recentes.',
        'Não altera campo, Match Engine, eventos, saves, IDs ou multi-competição.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.96',
      title: 'Correção do renderer da bola',
      changes: [
        'Corrige o único erro de analyzer da 0.1.1.95 no campo redesenhado.',
        'Usa a API real drawMatchBallGraphic do sistema de estilos da bola e elimina o warning de import não utilizado.',
        'Não altera o novo campo, Match Engine, eventos, saves, IDs ou multi-competição.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.95',
      title: 'Campo da partida redesenhado',
      changes: [
        'Refaz o gramado da partida com perspectiva mais equilibrada, moldura de estádio e marcações/gols redesenhados do zero.',
        'Reordena o desenho dos jogadores por profundidade e reduz novamente a escala visual para aproximar o enquadramento do mockup.',
        'Mantém torcida, Match Engine, eventos, placar, saves, IDs e fundação multi-competição intactos.',
      ],
    ),
  ];

}
