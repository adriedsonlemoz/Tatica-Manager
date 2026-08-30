class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.117';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.117',
      title: 'Correção de consistência do Estádio',
      changes: [
        'Corrige os dois testes que bloquearam o CI da 0.1.1.116 sem remover os novos sistemas do Estádio.',
        'Aplica acento legível baseado na cor do clube e limita a disponibilidade de obras ao menor valor entre caixa e orçamento do estádio.',
        'Mantém Match Engine, músicas, saves e regras de partida inalterados.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.116',
      title: 'Estádio imersivo e novos sistemas',
      changes: [
        'Redesenha o Estádio conforme a referência aprovada usando as duas imagens otimizadas do estádio.',
        'Cria manutenção persistente, Centro de Treinamento e obras com prazo/status que só aplicam melhorias na conclusão.',
        'Mantém Match Engine, músicas, IDs e resultados de partidas inalterados.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.115',
      title: 'Correção do cabeçalho da Home',
      changes: [
        'Corrige o erro de análise estática causado pelo uso inválido de minHeight no Container do cabeçalho da Home.',
        'Mantém a altura mínima planejada usando BoxConstraints, sem desfazer o alinhamento visual da Home.',
        'Não altera Match Engine, músicas, saves, IDs, regras ou resultados do jogo.',
      ],
    ),
  ];

}
