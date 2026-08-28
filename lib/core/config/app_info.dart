class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.87';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.87',
      title: 'Correção do teste da Home compacta',
      changes: [
        'Atualiza o teste estrutural para o rótulo compacto PREPARAÇÃO usado pela Home atual.',
        'O GitHub Actions anterior já confirmou flutter analyze sem problemas e 270 de 271 testes aprovados.',
        'Não altera UI, partida, saves, IDs, multi-competição ou Match Engine.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.86',
      title: 'Correção do CI de substituições',
      changes: [
        'Corrige a expectativa estrutural do fluxo de substituições em lote que fazia o analyzer interpretar plannedChanges como identificador do teste.',
        'Mantém intactos o fluxo de várias trocas, a regra de cinco substituições em três janelas e a Home compacta.',
        'Não altera saves, IDs, multi-competição ou Match Engine.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.85',
      title: 'Home mais compacta',
      changes: [
        'Compacta cabeçalho, finanças, próxima partida, preparação, confiança, panorama e atalhos para reduzir rolagem.',
        'Move Avançar para a Próxima Partida e coloca Notícias, classificação e artilheiros na mesma linha quando há largura suficiente.',
        'Remove a foto do estádio da Confiança da Diretoria e usa melhor as cores reais do clube no quadro do escudo.',
      ],
    ),
  ];


}
