class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.68';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.68',
      title: 'Correção final do analyze e Novidades',
      changes: [
        'Corrige o lint null-aware no cabeçalho reutilizável dos painéis sem alterar o layout.',
        'Sobre / Novidades volta a manter exatamente as três releases previstas pelo teste de regressão.',
        'Preserva gameplay, CareerState schema 11, saves, IDs e Match Engine.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.67',
      title: 'Correção do analyze após a auditoria visual',
      changes: [
        'Corrige o encadeamento duplicado que quebrava a compilação do limite de cinco substituições.',
        'Dia de Jogo passa a importar explicitamente as extensões de rótulo de pressão e formação.',
        'Remove dois avisos de código não utilizado em Finanças sem alterar comportamento ou layout.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.66',
      title: 'Consistência visual e navegação entre módulos',
      changes: [
        'Cards que aparentam ação agora abrem módulos existentes em Dia de Jogo, Contratos, Base e Finanças, sem criar funções novas.',
        'Acentos muito escuros recebem contraste seguro, fundos aninhados de Patrocínios são simplificados e o Estádio alinha o estado dos botões ao caixa e orçamento disponíveis.',
        'Finanças passa a conectar Estádio, Contratos e Mercado, enquanto telas abertas como módulos secundários preservam um retorno visível.',
      ],
    ),
  ];

}
