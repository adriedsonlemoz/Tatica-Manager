class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.75';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.75',
      title: 'Seleção de ligas e saves mais leves',
      changes: [
        'A criação de carreira ganha presets de ligas e modo personalizado, mantendo obrigatoriamente completa a competição do clube escolhido.',
        'Ligas completas continuam no Match Engine; competições em segundo plano ficam preparadas para resolução estatística CPU mais barata, sem Flame.',
        'O save passa ao schema 12 e o SQLite v3 lista carreiras por resumo leve, sem desserializar o payload completo de cada save.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.74',
      title: 'Nova playlist e apresentação refinada',
      changes: [
        'A música padrão anterior sai do projeto e a playlist passa a usar somente 11 faixas OGG otimizadas, com seleção manual e próxima faixa no mesmo player.',
        'Configurações mostra a música atual e mantém compatibilidade com playlist personalizada do aparelho.',
        'A apresentação da primeira carreira fica mais integrada ao visual e elimina o grande vazio entre a matéria e o botão de entrada.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.73',
      title: 'Correção do teste de salvamento do editor',
      changes: [
        'Corrige o único teste restante do CI, que ainda procurava a confirmação antiga de salvamento apenas no arquivo principal do editor.',
        'O teste passa a acompanhar a composição modular atual entre tela, ações de salvamento e diálogo central.',
        'Não altera UI, saves, CareerState schema 11, SQLite v2, IDs ou Match Engine.',
      ],
    ),
  ];

}
