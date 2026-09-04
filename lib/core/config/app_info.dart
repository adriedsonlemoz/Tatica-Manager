class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.137';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.137',
      title: 'Correção dos rótulos do auxiliar',
      changes: [
        'Importa diretamente os rótulos de formação e tática usados pela nova tela.',
        'Corrige os quatro erros undefined_getter apontados pelo workflow 90.',
        'Mantém inalteradas as regras da IA, do treino e do Match Engine.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.136',
      title: 'Auxiliar técnico e treino assistido',
      changes: [
        'Adiciona IA local para treino, escalação e plano tático.',
        'Permite gestão automática diária ou plano de treino manual.',
        'Corrige o único teste obsoleto apontado pelo workflow 89.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.135',
      title: 'Transmissão legível e disciplina integrada',
      changes: [
        'Mantém campo, comandos, estatísticas e narração visíveis sem rolagem.',
        'Dá movimento contextual aos atletas e reduz etiquetas sobrepostas.',
        'Exibe cartões e suspensões na escalação, elenco, perfil e partida.',
      ],
    ),
  ];
}
