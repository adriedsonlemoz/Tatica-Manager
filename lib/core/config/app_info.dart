class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.56';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.56',
      title: 'Técnicos, Finanças e experiência',
      changes: [
        'Mantém vibração apenas em gols e prepara a música mais cedo sem duplicar o player.',
        'Remodela Finanças com resumo visual, gráficos leves e seções expansíveis.',
        'Adiciona escolha de técnico, banco completo no editor e migração de saves para schema 11.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.55',
      title: 'Campo fixo durante replay',
      changes: [
        'Remove o deslocamento da câmera que movia o gramado para os lados durante replays.',
        'Elimina a faixa preta que podia aparecer na lateral do campo.',
        'Preserva replay, animações dos jogadores, bola, timeline e Match Engine.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.54',
      title: 'Áudio estável e diagnóstico interno',
      changes: [
        'Importa várias músicas em sequência por stream, reduzindo o pico de memória.',
        'Corrige a persistência da tela de áudio sem acessar Riverpod durante dispose.',
        'Adiciona Central de Diagnóstico com erros recentes, última saída Android e exportação TXT.',
      ],
    ),
  ];

}
