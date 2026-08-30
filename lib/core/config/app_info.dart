class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.108';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.108',
      title: 'Correção do analyzer da Home',
      changes: [
        'Remove o parâmetro opcional de ícone que não era usado no cabeçalho de classificação e artilharia.',
        'Elimina o único warning apontado pelo flutter analyze da 0.1.1.107 sem mudar o visual atual da Home.',
        'Preserva Match Engine, saves, IDs e regras do jogo.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.107',
      title: 'Movimentação visual natural',
      changes: [
        'Jogadores aceleram, freiam e mudam de direção com trajetórias visuais mais orgânicas, sem alterar os eventos do Match Engine.',
        'Pênaltis movimentam somente os atletas envolvidos próximos da área, eliminando o agrupamento magnético observado.',
        'Passadas, sombras e nomes acompanham melhor o movimento real, com retorno à formação em tempos diferentes por setor.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.106',
      title: 'Campo mais legível e uniformes',
      changes: [
        'Exibe nomes responsivos junto aos jogadores, priorizando o atleta da jogada e evitando sobreposições no campo.',
        'Permite escolher entre três uniformes antes da partida e resolve conflitos de cores automaticamente, com goleiros em kits próprios.',
        'Refina redes, traves, gramado, marcações, bola, sombras e movimentos sem alterar o Match Engine.',
      ],
    ),
  ];

}
