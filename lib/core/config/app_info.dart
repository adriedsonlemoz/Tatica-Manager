class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.131';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.131',
      title: 'Correção do analyzer no cartão amarelo',
      changes: [
        'Remove operadores nulos redundantes após a validação do jogador advertido.',
        'Elimina os três avisos fatais apontados pelo log 84 sem alterar a regra dos cartões.',
        'Documenta a análise visual do campo separadamente da correção técnica desta entrega.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.130',
      title: 'Simulação de partidas mais realista',
      changes: [
        'Usa atributos por setor, estado físico e técnica para gerar força, chances e finalizações.',
        'Recalibra faltas, cartões, lesões e reação tática ao placar durante a partida.',
        'Faz ligas de segundo plano registrar eventos, estatísticas individuais e suspensões reais.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.129',
      title: 'Confiabilidade da carreira e diretoria',
      changes: [
        'Confirma o save antes de atualizar a sessão e preserva falhas de migração para recuperação.',
        'Adiciona meta anual e confiança da diretoria com dados reais da tabela e caixa.',
        'Usa perfis dos técnicos CPU nas formações e táticas e arquiva notícias antigas da carreira.',
      ],
    ),
  ];
}
