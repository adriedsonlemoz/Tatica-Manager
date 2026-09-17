class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.146';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.146',
      title: 'Locução oficial da partida',
      changes: [
        'Troca o TTS principal por 15 falas gravadas na mesma voz para os eventos importantes.',
        'Diferencia a locução de gol do mandante e do visitante sem alterar o Match Engine.',
        'Mantém TTS apenas como fallback se um asset de voz não puder ser reproduzido.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.145',
      title: 'Áudio de partida renovado',
      changes: [
        'Substitui o ambiente contínuo por uma torcida tratada e preparada para loop.',
        'Integra novos sons de chute, trave, defesa, gol e pênalti defendido.',
        'Reduz o ganho do ambiente para manter efeitos e narração claros sem chiado constante.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.144',
      title: 'Elenco organizado e menu ajustado',
      changes: [
        'Organiza o elenco por goleiros, defensores, meio-campistas e atacantes.',
        'Mostra idade e situação real sem repetir a posição do jogador.',
        'Destaca lesões e suspensões e elimina a folga excessiva após Configurações.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.143',
      title: 'Polimento visual orientado por vídeo',
      changes: [
        'Aproveita melhor a altura da transmissão e organiza o fim de jogo.',
        'Aumenta a separação visual entre nomes no campo e corrige a disciplina.',
        'Compacta as prioridades do auxiliar e os atalhos da tela Mais.',
      ],
    ),
  ];
}
