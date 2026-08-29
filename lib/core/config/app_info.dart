class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.106';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.106',
      title: 'Campo mais legível e uniformes',
      changes: [
        'Exibe nomes responsivos junto aos jogadores, priorizando o atleta da jogada e evitando sobreposições no campo.',
        'Permite escolher entre três uniformes antes da partida e resolve conflitos de cores automaticamente, com goleiros em kits próprios.',
        'Refina redes, traves, gramado, marcações, bola, sombras e movimentos sem alterar o Match Engine.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.105',
      title: 'Partida visual 2.5D',
      changes: [
        'Mantém o campo restaurado da 0.1.1.91 e adiciona escala/ordem por profundidade aos jogadores.',
        'Jogadores ganham uniforme real com volume, sombra, passada animada e goleiros visualmente diferenciados.',
        'Bola ganha altura e sombra próprias nos lances, e a rede reage visualmente ao gol sem alterar o Match Engine.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.104',
      title: 'Campo visual restaurado',
      changes: [
        'Restaura o painel e o renderer visual da partida ao desenho usado na 0.1.1.91, sem voltar o restante do projeto.',
        'Campo, estádio, jogadores e mapeamento visual retornam ao formato anterior, enquanto HUD, replay e eventos atuais permanecem.',
        'Match Engine, CareerState schema 13, saves, IDs e multi-competição continuam intactos.',
      ],
    ),
  ];

}
