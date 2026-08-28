class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.72';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
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
    ReleaseNote(
      version: '0.1.1.70',
      title: 'Correção dos testes da criação e edição',
      changes: [
        'Alinha o teste da aparência ao agrupamento atual de Traços do rosto, preservando olhos, sobrancelhas e recorte de foto.',
        'Alinha o teste da Central de Carreiras ao link Edição extraído para o componente de informações e ao editor padrão/por save.',
        'Não altera UI, gameplay, CareerState schema 11, saves, IDs ou Match Engine.',
      ],
    ),
  ];

}
