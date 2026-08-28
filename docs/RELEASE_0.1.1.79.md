# Release 0.1.1.79 — Home visual premium

## Escopo

Esta release concentra a revisão visual da Home sem alterar as regras da carreira. A referência aprovada foi reproduzida usando os dados reais já disponíveis no save e dois assets gráficos originais criados especificamente para os cards de estádio.

## Alterações visuais

- cabeçalho do clube passa a ter composição em card, escudo mais valorizado, caixa de entrada destacada e avatar do técnico integrado;
- cards de saldo, transferências, receitas e despesas recebem hierarquia, gradientes e indicadores visuais mais próximos da referência;
- Próxima Partida ganha fundo noturno de estádio, escudos maiores, VS central e uma faixa de preparação integrada;
- Confiança da Diretoria passa a combinar o estádio com capacidade, ingresso e nível real de arquibancadas ao medidor circular de confiança;
- Panorama da Temporada e o botão Avançar são compactados e passam a seguir a mesma linguagem visual;
- os dois novos fundos de estádio ficam em `assets/images/home/` e são otimizados em WebP para reduzir impacto no APK.

## Correção funcional ligada à interface

O card Panorama da Temporada já exibia um chevron, mas não possuía ação. Ele agora abre a classificação existente, evitando uma área que parecia interativa sem funcionar.

## Refatoração

- adiciona `home_visual_components.dart` para recursos visuais reutilizáveis da Home;
- separa confiança/estádio em `home_dashboard_board.dart`;
- separa panorama/avanço em `home_dashboard_controls.dart`;
- mantém `home_dashboard_match.dart` responsável pela composição da próxima partida e da visão principal, sem mover regra de jogo para a UI.

## Compatibilidade

Não há alteração de schema, IDs persistentes ou regras de carreira. Permanecem preservados:

- `CareerState` schema 13;
- saves existentes;
- calendário e fundação multi-competição;
- CPU, mercado, contratos e finanças;
- Match Engine como responsável pela lógica da partida;
- Flame somente como camada visual da partida.

## Validação

`python3 tool/versioning.py verify` deve validar a sincronização da release após o versionamento. O ambiente desta entrega não possui Flutter/Dart instalado, portanto `flutter pub get`, `flutter analyze`, `flutter test` e `flutter build apk --release` dependem do GitHub Actions ou de outro ambiente com Flutter.
