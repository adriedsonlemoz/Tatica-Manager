class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.112';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.112',
      title: 'Correção Kotlin do renderer libGDX',
      changes: [
        'Encadeia crowdPulse do painter principal até a pintura da torcida, eliminando o unresolved reference do compileReleaseKotlin.',
        'Adiciona regressão estrutural para impedir que esse parâmetro visual se perca em futuras refatorações.',
        'Preserva Match Engine, SurfaceView 105:68, Hybrid Composition, FitViewport, saves, IDs e CareerState schema 13.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.111',
      title: 'Correção do teste do campo libGDX',
      changes: [
        'Atualiza a regressão visual que ainda exigia o antigo AspectRatio mesmo após o campo passar a usar tamanho explícito 105:68.',
        'Mantém SizedBox, clipping, Hybrid Composition e FitViewport sem alterar o renderer ou o Match Engine.',
        'Preserva Flame fallback, saves, IDs e CareerState schema 13.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.110',
      title: 'Campo libGDX contido e refinado',
      changes: [
        'Prende o SurfaceView libGDX ao retângulo do campo usando Hybrid Composition real e tamanho 105:68 controlado pelo Flutter.',
        'Estabiliza a escala com FitViewport e melhora jogadores, goleiros, bola, redes, gramado, sombras e nomes.',
        'Preserva Match Engine, Flame fallback, saves, IDs e CareerState schema 13.',
      ],
    ),
  ];

}
