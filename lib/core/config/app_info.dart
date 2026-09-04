class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.140';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.140',
      title: 'Correção do teste de recompensas',
      changes: [
        'Corrige o cenário de derrota executado após o marco global de 10 partidas.',
        'Registra no teste que os 25 PM desse marco já foram entregues.',
        'Mantém inalterada a lógica real e idempotente de recompensas.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.139',
      title: 'Correção do provider de recompensas',
      changes: [
        'Corrige a conversão entre os repositórios de carreira e recompensas.',
        'Elimina o único erro de análise estática apontado pelo workflow 92.',
        'Preserva carteira, cálculo, notificações e proteção contra duplicação.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.138',
      title: 'Recompensas globais do Manager',
      changes: [
        'Adiciona carteira global de PM separada de clubes e carreiras.',
        'Entrega recompensas atômicas após partidas e temporadas salvas.',
        'Exibe desafios, histórico, saldo compacto e avisos de recompensa.',
      ],
    ),
  ];
}
