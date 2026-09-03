class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.133';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.133',
      title: 'Campo ao vivo mais dinâmico',
      changes: [
        'Representa no campo as formações reais escolhidas pelos dois times.',
        'Estabiliza a posse ao vivo e movimenta os blocos conforme bola e domínio.',
        'Melhora nomes, bola, áreas, gols e aproximações dos lances importantes.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.132',
      title: 'Correção do teste da simulação CPU',
      changes: [
        'Atualiza o teste estrutural para a arquitetura realista vigente do Match Engine.',
        'Mantém eventos completos e substituições automáticas nas partidas CPU em segundo plano.',
        'Preserva o analyzer já aprovado e não altera a apresentação visual da partida.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.131',
      title: 'Correção do analyzer no cartão amarelo',
      changes: [
        'Remove operadores nulos redundantes após a validação do jogador advertido.',
        'Elimina os três avisos fatais apontados pelo log 84 sem alterar a regra dos cartões.',
        'Documenta a análise visual do campo separadamente da correção técnica desta entrega.',
      ],
    ),
  ];
}
