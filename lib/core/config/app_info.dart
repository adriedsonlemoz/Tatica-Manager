class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.110';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.110',
      title: 'Teste da Home sincronizado',
      changes: [
        'Atualiza o teste estrutural da Home para os componentes realmente usados pelo layout atual.',
        'Remove expectativas obsoletas de widgets antigos sem alterar a interface ou a lógica do jogo.',
        'Mantém Match Engine, saves, playlist reduzida e regras do jogo inalterados.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.109',
      title: 'Playlist reduzida e versionamento simples',
      changes: [
        'Mantém somente as cinco músicas de menu fornecidas na lista reduzida e remove as outras seis faixas antigas.',
        'Remove al-sistemas.json e passa VERSION a ser a fonte canônica da versão visível, com CI e testes atualizados.',
        'Atualiza a documentação da release sem alterar Match Engine, saves, IDs ou regras do jogo.',
      ],
    ),
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
  ];

}
