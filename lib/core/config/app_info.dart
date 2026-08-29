class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.104';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.104',
      title: 'Campo visual restaurado',
      changes: [
        'Restaura o painel e o renderer visual da partida ao desenho usado na 0.1.1.91, sem voltar o restante do projeto.',
        'Campo, estádio, jogadores e mapeamento visual retornam ao formato anterior, enquanto HUD, replay e eventos atuais permanecem.',
        'Match Engine, CareerState schema 13, saves, IDs e multi-competição continuam intactos.',
      ],
    ),
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
  ];

}
