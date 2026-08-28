class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.88';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.88',
      title: 'Home compacta mais legível',
      changes: [
        'Move Avançar/Jogar para a coluna central da Próxima Partida e remove o horário duplicado desse bloco.',
        'Aumenta tipografia e presença visual de atalhos, notícias, classificação e artilheiros sem voltar aos cards excessivamente altos.',
        'Remove escudos da tabela ultracompacta e equilibra melhor as alturas do bloco inferior.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.87',
      title: 'Correção do teste da Home compacta',
      changes: [
        'Atualiza o teste estrutural da Home para o rótulo compacto de preparação realmente usado no layout.',
        'Preserva integralmente o layout e a lógica da 0.1.1.86.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.86',
      title: 'Correção do teste de substituições',
      changes: [
        'Corrige a interpolação indevida no teste estrutural do fluxo de substituições em lote.',
        'Não altera a lógica da partida ou o layout.',
      ],
    ),
  ];


}
