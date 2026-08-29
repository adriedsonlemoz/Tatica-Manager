class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.115';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.115',
      title: 'Correção do tema claro no analyzer',
      changes: [
        'Corrige o import de AppColors e dois const incompatíveis com a paleta adaptativa no pré-jogo/partida.',
        'Corrige as seis expectativas literais do teste de calendário/Home que impediam o flutter analyze.',
        'Preserva Home clara, modo escuro, libGDX, movimentação, Match Engine, saves e IDs.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.114',
      title: 'Home clara e tema global',
      changes: [
        'Reformula a Home em cards claros e responsivos com ação contextual, seis atalhos, próxima partida, resumo, classificação, artilharia e notícias.',
        'Torna o modo claro o padrão e adiciona modo escuro persistente nas Configurações e antes da carreira.',
        'Preserva renderer libGDX, movimentação, Match Engine, saves, IDs e CareerState schema 13.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.113',
      title: 'Movimentação natural integrada ao libGDX',
      changes: [
        'Porta para o renderer libGDX aceleração, frenagem, trajetórias curvas e saídas escalonadas desenvolvidas no Work.',
        'Corrige a apresentação visual de pênaltis e escalona o retorno à formação por setor, mantendo o Match Engine intacto.',
        'Sincroniza passada, inclinação e sombra à velocidade e estabiliza as âncoras dos nomes; Flame mantém o mesmo refinamento como fallback.',
      ],
    ),
  ];

}
