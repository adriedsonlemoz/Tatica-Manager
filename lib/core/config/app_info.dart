class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.113';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.113',
      title: 'Reintegração da 0.1.1.107 ao renderer libGDX',
      changes: [
        'Reintegra ao MatchPitchGame o movimento com aceleração/frenagem, curvas de trajetória e retorno escalonado à formação, além da memória de âncora dos rótulos de nome, desenvolvidos em paralelo na 0.1.1.107.',
        'Preserva integralmente MatchPitchController, LibGdxMatchPitchController, MainActivity e o pipeline Gradle/Kotlin da integração libGDX.',
        'Restaura os testes de movimento e de continuidade visual dos rótulos; não altera Match Engine, saves, IDs ou CareerState schema 13.',
      ],
    ),
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
  ];

}
