class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.101';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.101',
      title: 'Token do jogador refeito do zero',
      changes: [
        'Refaz o token do jogador como um disco chapado único, sem cabeça separada acima do corpo.',
        'Elimina o efeito "bobblehead" da versão anterior, mantendo padrão do uniforme e cor de goleiro.',
        'Não altera Match Engine, gramado, saves, IDs ou multi-competição.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.100',
      title: 'Sincronização de versão',
      changes: [
        'Sincroniza a versão da release para 0.1.1.100 (versionCode 101, pubspec 0.1.1+101).',
        'Não há alterações de código nesta release.',
        'Não altera campo, jogadores, Match Engine, saves, IDs ou multi-competição.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.98',
      title: 'Jogadores e gramado mais nítidos',
      changes: [
        'Redesenha os jogadores como tokens sólidos de alto contraste no lugar da figura anatômica fina que virava mancha na escala real da tela.',
        'Deixa o gramado mais verde/saturado, com listras de corte mais contrastantes, linhas mais grossas e perspectiva mais acentuada.',
        'Não altera Match Engine, eventos, placar, saves, IDs ou multi-competição.',
      ],
    ),
  ];

}
