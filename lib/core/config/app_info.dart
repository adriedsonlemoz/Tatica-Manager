class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.71';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
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
    ReleaseNote(
      version: '0.1.1.69',
      title: 'Criação de carreira e identidade azul-grafite',
      changes: [
        'Adota azul-grafite como base do jogo, mantendo o verde como destaque e clareando também a Home.',
        'Compacta formação, clubes e técnicos, remodela aparência e contrato e adiciona a apresentação única da chegada do treinador.',
        'Inclui Termos/Privacidade na primeira abertura e reduz a transmissão para 1, 2 ou 3 minutos por tempo sem alterar o Match Engine.',
      ],
    ),
  ];

}
