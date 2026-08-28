# Release 0.1.1.80 — Home mais integrada

## Escopo

Esta release evolui a revisão visual da Home feita na 0.1.1.79. O objetivo aqui não foi reinventar o fluxo, mas integrar melhor a metade inferior da tela, aproximar mais conteúdo do primeiro enquadramento e deixar o conjunto menos fragmentado.

## Alterações visuais

- adiciona um backdrop próprio da Home com glows sutis para amarrar melhor o topo e o bloco inferior;
- enquadra atalhos, notícias, classificação e artilharia em um painel inferior único, reduzindo a sensação de cards soltos;
- converte os atalhos Táticas, Calendário, Finanças, Base e Departamento Médico em cards compactos, coloridos e fixos;
- transforma Notícias & Destaques em lista compacta, substituindo o carrossel horizontal para aproximar mais informação da primeira dobra;
- reorganiza a visão principal para aproximar Confiança da Diretoria e Panorama da Temporada, mantendo a próxima partida como card principal;
- reforça tabela e artilharia com rodapés de navegação mais claros.

## Refatoração

- `home_dashboard_match.dart` reorganiza a composição principal e aproxima confiança/panorama em uma linha responsiva;
- `home_dashboard_controls.dart` amplia o card Panorama da Temporada e adiciona tratamento visual próprio;
- `home_dashboard_news.dart` passa a concentrar a nova lista compacta de notícias e os atalhos coloridos;
- `home_dashboard_rankings.dart` recebe rodapés reutilizáveis para os acessos completos de tabela e ranking;
- `home_screen.dart` aplica o novo backdrop e agrupa o bloco inferior em um painel único.

## Compatibilidade

Não há alteração de schema, IDs persistentes, regras da carreira ou dados do save. Permanecem preservados:

- `CareerState` schema 13;
- saves existentes;
- fundação multi-competição;
- CPU, mercado, contratos e finanças;
- Match Engine como responsável pela lógica da partida;
- Flame somente como camada visual da partida.

## Validação

- `python3 tool/versioning.py verify` deve validar a sincronização da release após o versionamento;
- o ambiente desta entrega não possui Flutter/Dart instalado, então `flutter pub get`, `flutter analyze`, `flutter test` e `flutter build apk --release` dependem do GitHub Actions ou de outro ambiente com Flutter.
