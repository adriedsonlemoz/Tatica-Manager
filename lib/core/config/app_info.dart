class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.124';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.124',
      title: 'Calendário, Táticas e Configurações redesenhados',
      changes: [
        'Adapta Calendário, Táticas e Configurações aos mockups em telas fixas e responsivas, sem rolagem nas páginas principais.',
        'Calendário usa somente partidas e eventos reais; Táticas mantém apenas formação e as cinco instruções já suportadas pelo Match Engine.',
        'Configurações preserva áudio, vibração, duração, bola e carreira, reativa a velocidade 1x/2x/4x e mantém as ações avançadas acessíveis.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.123',
      title: 'Correção dos testes de Finanças e Transferências',
      changes: [
        'Restaura Estádio e Patrocínios como seções expansíveis funcionais dentro dos detalhes financeiros, sem voltar a rolar a tela principal.',
        'Mantém os módulos reais de estádio, patrocínios e orçamentos integrados à tela compacta de Finanças.',
        'Registra a renovação contratual com a data do estado atualizado da carreira para manter o livro-caixa temporalmente consistente.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.122',
      title: 'Limpeza final do analyzer em Finanças',
      changes: [
        'Remove as duas asserções de não-nulo redundantes apontadas pelo Flutter analyzer no saldo projetado de Finanças.',
        'Remove temporariamente o widget privado _FinanceExpansion que estava sem referência após a compactação da tela financeira.',
        'Preserva integralmente Transferências, contratos, salários, orçamento, caixa, saves e Match Engine da release anterior.',
      ],
    ),
  ];
}
