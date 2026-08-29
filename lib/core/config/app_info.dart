class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.109';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
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
    ReleaseNote(
      version: '0.1.1.107',
      title: 'Campo Android com libGDX',
      changes: [
        'Integra libGDX 1.14.2 no retângulo do campo da partida no Android, mantendo HUD e controles em Flutter.',
        'O Match Engine continua em Dart e envia ao renderer apenas eventos, coordenadas, escalações, nomes e uniformes já resolvidos.',
        'Preserva o Flame como fallback fora do Android e mantém saves, IDs, CareerState schema 13 e multi-competição intactos.',
      ],
    ),
  ];

}
