class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.110';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.110',
      title: 'Campo libGDX contido e refinado',
      changes: [
        'Prende o SurfaceView libGDX ao retângulo do campo usando Hybrid Composition real e tamanho 105:68 controlado pelo Flutter.',
        'Estabiliza a escala com FitViewport e melhora jogadores, goleiros, bola, redes, gramado, sombras e nomes.',
        'Preserva Match Engine, Flame fallback, saves, IDs e CareerState schema 13.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.109',
      title: 'Compatibilidade libGDX com AGP 9',
      changes: [
        'Corrige o build Android que falhava ao registrar os natives do libGDX no sourceSets com um Provider.',
        'Passa a usar a Variant Sources API oficial e liga a tarefa de extração dos natives diretamente ao diretório JNI gerado.',
        'Não altera Match Engine, renderer, saves, IDs ou CareerState schema 13.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.108',
      title: 'Correção do analyzer do libGDX',
      changes: [
        'Corrige os oito lints que faziam o GitHub Actions parar no flutter analyze antes da compilação Android.',
        'Remove o import redundante do bridge libGDX e marca explicitamente os membros que implementam MatchPitchController.',
        'Não altera o Match Engine, o renderer libGDX, saves, IDs ou CareerState schema 13.',
      ],
    ),
  ];

}
