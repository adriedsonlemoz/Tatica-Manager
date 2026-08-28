class ReleaseNote {
  const ReleaseNote({required this.version, required this.title, required this.changes});

  final String version;
  final String title;
  final List<String> changes;
}

abstract final class AppInfo {
  static const String version = '0.1.1.85';
  static const String contactEmail = 'adriedson@outlook.com';
  static const String pixKey = 'adriedson@outlook.com';

  static const List<ReleaseNote> recentReleases = [
    ReleaseNote(
      version: '0.1.1.85',
      title: 'Home mais compacta',
      changes: [
        'Compacta cabeçalho, finanças, próxima partida, preparação, confiança, panorama e atalhos para reduzir rolagem.',
        'Move Avançar para a Próxima Partida e coloca Notícias, classificação e artilheiros na mesma linha quando há largura suficiente.',
        'Remove a foto do estádio da Confiança da Diretoria e usa melhor as cores reais do clube no quadro do escudo.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.84',
      title: 'Trocas preparadas em lote',
      changes: [
        'A janela de substituições permanece aberta para preparar várias trocas antes de confirmar.',
        'Permite revisar e remover trocas preparadas, aplicando o lote apenas no botão Confirmar trocas.',
        'Mantém cinco substituições, três janelas e o intervalo sem consumir janela, com validação central no controller.',
      ],
    ),
    ReleaseNote(
      version: '0.1.1.83',
      title: 'Substituições com janelas',
      changes: [
        'Mantém o limite de cinco jogadores substituídos e passa a respeitar no máximo três janelas durante o jogo.',
        'Várias trocas feitas no mesmo minuto usam a mesma janela e o intervalo não consome uma oportunidade.',
        'Centraliza a regra fora da UI e adiciona testes funcionais para impedir regressão para substituições ilimitadas.',
      ],
    ),
  ];


}
