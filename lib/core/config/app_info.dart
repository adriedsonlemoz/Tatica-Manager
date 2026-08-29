class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.117';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.117',
      title: 'Refinamento da Home compacta',
      changes: [
        'Distribui os seis indicadores do Resumo da Temporada em uma única faixa e compacta os atalhos.',
        'Move o ícone de Avançar/Jogar para a direita, melhora espaçamentos e normaliza os escudos da Próxima Partida.',
        'Adiciona retorno explícito ao menu Mais quando aberto pela barra superior, sem alterar a aba raiz.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.116',
      title: 'Correção dos testes da Home e tema',
      changes: [
        'Atualiza a regressão da paleta para as cores atuais do tema claro/escuro.',
        'Faz o teste de avatares validar a nova HomeCleanRankings em vez da ligação removida da Home antiga.',
        'Preserva Home, tema, libGDX, movimentação, Match Engine, saves e IDs.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.115',
      title: 'Correção do tema claro no analyzer',
      changes: [
        'Corrige o import de AppColors e dois const incompatíveis com a paleta adaptativa no pré-jogo/partida.',
        'Corrige as seis expectativas literais do teste de calendário/Home que impediam o flutter analyze.',
        'Preserva Home clara, modo escuro, libGDX, movimentação, Match Engine, saves e IDs.',
      ],
    ),
  ];

}
