# Release 0.1.1.85 — Home mais compacta

## Escopo

Esta release revisa apenas a apresentação da Home sobre a base 0.1.1.84. Não altera regras da carreira, Match Engine, saves, IDs ou a fundação multi-competição.

## Comparação aplicada

- cabeçalho do clube reduzido, mantendo escudo, nome, temporada, próximo jogo, e-mail e técnico;
- cards financeiros passam de um bloco alto para uma faixa compacta;
- Próxima Partida reduz altura do cenário, informações e preparação;
- `Avançar` deixa de ocupar uma linha própria e passa ao canto superior direito do card de próxima partida;
- Confiança da Diretoria passa a mostrar primeiro o medidor percentual e depois o resumo do estádio;
- a foto do estádio é removida desse card, mantendo nome, capacidade, ingresso e arquibancada;
- Panorama da Temporada é reduzido e continua ligado à classificação;
- os cinco atalhos ficam mais baixos e preservam as mesmas ações existentes;
- Notícias, classificação e artilheiros passam a usar a mesma linha em larguras de telefone compatíveis, com fallback para empilhamento em telas muito estreitas;
- a tabela ganha modo ultracompacto para preservar os cinco primeiros colocados e o clube do usuário quando ele estiver fora do top 5;
- o quadro do escudo passa a derivar o acento das cores reais disponíveis do clube, evitando a borda verde fixa;
- o padding inferior da Home é reduzido porque a barra inferior do `GameShell` já ocupa espaço fora da área de conteúdo.

## Arquivos principais

- `lib/features/home/home_screen.dart`
- `lib/features/home/home_dashboard_header.dart`
- `lib/features/home/home_dashboard_match.dart`
- `lib/features/home/home_dashboard_board.dart`
- `lib/features/home/home_dashboard_controls.dart`
- `lib/features/home/home_dashboard_news.dart`
- `lib/features/home/home_dashboard_rankings.dart`
- `lib/features/home/home_overview_widgets.dart`
- `lib/features/home/home_visual_components.dart`
- `test/calendar_and_standings_ui_test.dart`

## Compatibilidade

Permanecem preservados `CareerState` schema 13, saves, IDs persistentes, calendário e fundação multi-competição, CPU, mercado, contratos, finanças, Match Engine e Flame apenas como camada visual.

## Validação

O versionamento deve ser validado por `python3 tool/versioning.py verify`. O ambiente local desta entrega não possui Flutter/Dart, então `flutter pub get`, `flutter analyze`, `flutter test` e `flutter build apk --release` dependem do GitHub Actions ou de ambiente com Flutter instalado.
