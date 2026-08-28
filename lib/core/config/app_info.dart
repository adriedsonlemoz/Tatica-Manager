class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.73';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
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
    ReleaseNote(
      version: '0.1.1.71',
      title: 'Carreiras, edição e diagnóstico aprimorados',
      changes: [
        'Saves passam a mostrar escudo, colocação e próximo jogo com exclusão direta; a tela inicial ganha versão clicável para o diagnóstico.',
        'Editor de dados recebe tutorial, ações compactas, confirmações e mensagens centrais; técnicos padrão deixam de compartilhar a mesma face.',
        'Bolas passam a ser escolhidas visualmente e o diagnóstico exibe contexto/stack e registra falhas operacionais de carreira e edição.',
      ],
    ),
  ];

}
