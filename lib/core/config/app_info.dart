class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.78';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.78',
      title: 'Virada de temporada multi-competição',
      changes: [
        'Corrige a conclusão da temporada quando fixtures já estão encerrados, mas o flag persistido da competição ainda está desatualizado.',
        'Mantém a conclusão baseada nos jogos reais de cada competição carregada, com fallback seguro para estados sem fixtures.',
        'Atualiza a regressão de fadiga para acompanhar o MatchCareerImpactEngine sem devolver regra ao controller.',
      ],
    ),
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
  ];


}
