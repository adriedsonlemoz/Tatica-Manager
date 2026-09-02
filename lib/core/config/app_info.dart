class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.127';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.127',
      title: 'Retorno do pré-jogo e setores do elenco',
      changes: [
        'Restaura o botão explícito de retorno quando Escalação é aberta pelo pré-jogo, preservando os ajustes realizados.',
        'Organiza banco e elenco por goleiros, defensores, meio-campistas, atacantes e indisponíveis dentro da paginação compacta.',
        'Corrige os dois testes restantes do log 81 sem reintroduzir rolagem vertical.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.126',
      title: 'Correção do analyzer no campo compartilhado',
      changes: [
        'Importa a extensão de PlayerPosition usada para exibir a posição dos jogadores no campo compacto.',
        'Corrige o único erro do log 80 sem alterar o visual, a escalação ou o Match Engine.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.125',
      title: 'Escalação integrada ao novo design',
      changes: [
        'Redesenha a aba Escalação com o mesmo campo compacto da tela de Táticas e remove o título interno excessivo.',
        'Mantém formação, autoescalação, troca de titulares, perfis e status reais dos jogadores.',
        'Substitui a lista vertical por banco e elenco paginados, preservando acesso a todos sem rolagem na tela principal.',
      ],
    ),
  ];
}
