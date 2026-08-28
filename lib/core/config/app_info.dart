class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.59';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.59',
      title: 'Nova Home premium',
      changes: [
        'Reorganiza a Home no padrão visual premium do mockup, sem transformar dados em conteúdo estático.',
        'Destaca clube, técnico, próximo jogo, forma, confiança, notícias, classificação e artilheiros com dados reais da carreira.',
        'Preserva atalhos, saves, schema 11, navegação e Match Engine.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.58',
      title: 'Correção da análise estática',
      changes: [
        'Remove o import redundante de dart:ui da Central de Diagnóstico apontado pelo Flutter 3.47.1.',
        'Preserva o comportamento da Central de Diagnóstico, áudio, saves, Match Engine e workflow de CI.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.57',
      title: 'Correção do áudio e novo repositório',
      changes: [
        'Corrige a cópia sequencial das músicas para a tipagem do Flutter 3.47.1 sem carregar arquivos inteiros em memória.',
        'Atualiza documentação e metadados para o repositório oficial Tatica-Manager.',
        'Preserva saves, schema 11, Match Engine e workflow de CI.',
      ],
    ),
  ];

}
