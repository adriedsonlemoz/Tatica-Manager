class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.74';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
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
    ReleaseNote(
      version: '0.1.1.72',
      title: 'Correção do analyzer no editor de dados',
      changes: [
        'Corrige nove warnings do analyzer causados pelo uso direto de setState dentro da extension extraída do editor.',
        'As ações continuam separadas em arquivo próprio, mas a atualização de estado volta a ocorrer por um método do próprio State.',
        'Não altera UI, saves, CareerState schema 11, SQLite v2, IDs ou Match Engine.',
      ],
    ),
  ];

}
