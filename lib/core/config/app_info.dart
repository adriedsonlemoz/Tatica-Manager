class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.129';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.129',
      title: 'Confiabilidade da carreira e diretoria',
      changes: [
        'Confirma o save antes de atualizar a sessão e preserva falhas de migração para recuperação.',
        'Adiciona meta anual e confiança da diretoria com dados reais da tabela e caixa.',
        'Usa perfis dos técnicos CPU nas formações e táticas e arquiva notícias antigas da carreira.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.128',
      title: 'Notícias ampliadas e perfis de técnicos',
      changes: [
        'Adiciona prévias de confronto, panorama semanal da tabela e reportagens após as partidas já simuladas.',
        'Substitui os técnicos genéricos do banco padrão por perfis fictícios, variados e completos.',
        'Amplia a tela e a seleção de técnico com dados pessoais, contrato, experiência, estilo e situação real na carreira.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.127',
      title: 'Retorno do pré-jogo e setores do elenco',
      changes: [
        'Restaura o botão explícito de retorno quando Escalação é aberta pelo pré-jogo, preservando os ajustes realizados.',
        'Organiza banco e elenco por goleiros, defensores, meio-campistas, atacantes e indisponíveis dentro da paginação compacta.',
        'Corrige os dois testes restantes do log 81 sem reintroduzir rolagem vertical.',
      ],
    ),
  ];
}
