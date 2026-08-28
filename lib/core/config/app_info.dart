class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.77';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.77',
      title: 'Correção da fundação multi-competição',
      changes: [
        'Corrige a tipagem da classificação em competições sem tabela apontada pelo GitHub Actions.',
        'Adiciona regressão para o caminho sem standings, sem mudar calendário, saves ou IDs.',
        'Mantém o CareerState schema 13 e o Match Engine exatamente na arquitetura da 0.1.1.76.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.76',
      title: 'Fundação para múltiplas competições',
      changes: [
        'Calendário, classificação, estatísticas e disciplina passam a ter estado independente por competição, permitindo torneios simultâneos no mesmo save.',
        'Fixtures ganham metadados de fase, grupo e confronto, e jogos CPU avançam pela data correta sem criar outro Match Engine.',
        'Saves antigos são migrados para o schema 13 preservando IDs; o erro de analyzer da seleção de ligas também foi corrigido.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.75',
      title: 'Seleção de ligas e saves mais leves',
      changes: [
        'A criação de carreira ganha presets de ligas e modo personalizado, mantendo obrigatoriamente completa a competição do clube escolhido.',
        'Ligas completas continuam no Match Engine; competições em segundo plano ficam preparadas para resolução estatística CPU mais barata, sem Flame.',
        'O save passa ao schema 12 e o SQLite v3 lista carreiras por resumo leve, sem desserializar o payload completo de cada save.',
      ],
    ),
  ];

}
