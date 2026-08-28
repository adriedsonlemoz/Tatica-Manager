class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.57';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.57',
      title: 'Correção do áudio e novo repositório',
      changes: [
        'Corrige a cópia sequencial das músicas para a tipagem do Flutter 3.47.1 sem carregar arquivos inteiros em memória.',
        'Atualiza documentação e metadados para o novo repositório oficial Tatica-Manager.',
        'Preserva saves, schema 11, Match Engine e workflow de CI.',
      ],
    ),
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
  ];

}
