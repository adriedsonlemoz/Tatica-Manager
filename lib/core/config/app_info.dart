class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.125';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.125',
      title: 'Escalação integrada ao novo design',
      changes: [
        'Redesenha a aba Escalação com o mesmo campo compacto da tela de Táticas e remove o título interno excessivo.',
        'Mantém formação, autoescalação, troca de titulares, perfis e status reais dos jogadores.',
        'Substitui a lista vertical por banco e elenco paginados, preservando acesso a todos sem rolagem na tela principal.',
      ],
    ),
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
  ];
}
