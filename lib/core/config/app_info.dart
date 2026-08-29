class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.108';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
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
    ReleaseNote(
      version: '0.1.1.106',
      title: 'Campo mais legível e uniformes',
      changes: [
        'Exibe nomes responsivos junto aos jogadores, priorizando o atleta da jogada e evitando sobreposições no campo.',
        'Permite escolher entre três uniformes antes da partida e resolve conflitos de cores automaticamente, com goleiros em kits próprios.',
        'Refina redes, traves, gramado, marcações, bola, sombras e movimentos sem alterar o Match Engine.',
      ],
    ),
  ];

}
