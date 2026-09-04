class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.139';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
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
    ReleaseNote(
      version: '0.1.1.137',
      title: 'Correção dos rótulos do auxiliar',
      changes: [
        'Importa diretamente os rótulos de formação e tática usados pela nova tela.',
        'Corrige os quatro erros undefined_getter apontados pelo workflow 90.',
        'Mantém inalteradas as regras da IA, do treino e do Match Engine.',
      ],
    ),
  ];
}
