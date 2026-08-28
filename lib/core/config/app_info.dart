class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.61';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.61',
      title: 'Testes alinhados à UI atual',
      changes: [
        'Atualiza três testes estruturais que ainda procuravam textos e arquivos anteriores à remodelação recente.',
        'Criação do técnico valida País; Finanças valida Salários/Patrocínios; avatares da Home são verificados nos widgets modulares.',
        'Não altera código funcional, saves, schema 11, Match Engine ou workflow de CI.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.60',
      title: 'Correção da Home no analyzer',
      changes: [
        'Remove dois parâmetros opcionais de padding nunca utilizados nos cards de Notícias e Rankings.',
        'Corrige os warnings unused_element_parameter apontados pelo Flutter 3.47.1 sem alterar o visual da Home.',
        'Preserva saves, schema 11, Match Engine e workflow de CI.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.59',
      title: 'Nova Home premium',
      changes: [
        'Reorganiza a Home no padrão visual premium do mockup, sem transformar dados em conteúdo estático.',
        'Destaca clube, técnico, próximo jogo, forma, confiança, notícias, classificação e artilheiros com dados reais da carreira.',
        'Preserva atalhos, saves, schema 11, navegação e Match Engine.',
      ],
    ),
  ];

}
