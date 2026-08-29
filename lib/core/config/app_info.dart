class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.103';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.103',
      title: 'Correção do analyzer do campo',
      changes: [
        'Remove o único import redundante apontado pelo analyzer no teste visual da partida.',
        'Mantém integralmente o novo campo em imagem, jogadores, bola e projeção da 0.1.1.102.',
        'Não altera Match Engine, saves, IDs ou multi-competição.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.102',
      title: 'Campo real como cenário da partida',
      changes: [
        'Usa o novo estádio/gramado em WebP como fundo principal da partida, no mesmo aspecto 2.48 do painel.',
        'Jogadores, bola, destaques e animações continuam sendo desenhados pelo Flame sobre o cenário e seguem os eventos do Match Engine.',
        'Calibra a projeção às linhas reais da imagem e mantém o renderer procedural anterior como fallback seguro.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.101',
      title: 'Workflow do GitHub restaurado',
      changes: [
        'Restaura .github/workflows/flutter-ci.yml removido do pacote anterior ao compactar arquivos ocultos.',
        'O workflow volta a responder a push e workflow_dispatch e continua publicando somente o APK versionado.',
        'Restaura também os .gitignore do projeto/Android sem alterar código, Match Engine, saves ou IDs.',
      ],
    ),
  ];

}
