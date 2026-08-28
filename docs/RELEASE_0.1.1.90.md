# Release 0.1.1.90 — Preparação da partida premium

## Escopo

Revisão visual concentrada na tela de preparação pré-jogo. A implementação reutiliza a lógica, os dados e o asset de estádio que já existiam no projeto. Nenhuma regra de partida, save ou arquitetura de gameplay foi criada em paralelo.

## Alterações visuais

- o confronto passa a ocupar um card hero com mandante, visitante, escudos, VS, competição, data, horário, estádio, mando e status real do dia de jogo;
- reutiliza `assets/images/home/match_stadium.webp`, já presente no projeto, sem criar ou adicionar nova imagem;
- o seletor de duração continua usando os presets reais de 1, 2 e 3 minutos por tempo, mas ganha apresentação mais próxima do restante da interface premium;
- Plano de jogo exibe formação, titulares e força de maneira mais hierárquica e mantém Escalação, Tática e melhor escalação disponível;
- Quem vai a campo deixa a grade de cards e passa a desenhar os titulares em um campo tático somente leitura;
- o campo usa diretamente `LineupValidation.assignments`, `FormationSlot.x/y`, número da camisa, posição e OVR efetivo, sem criar lógica paralela de escalação;
- Indisponíveis e Iniciar partida permanecem ligados aos estados e ações existentes.

## Arquivos

- `lib/features/match/pre_match_screen.dart`;
- `lib/features/match/pre_match_visual_components.dart`;
- `test/pre_match_and_lineup_ui_test.dart`;
- `test/pre_match_navigation_test.dart`.

## Compatibilidade

Permanecem preservados `CareerState` schema 13, saves, IDs persistentes, fundação multi-competição, calendário, CPU, mercado, contratos e Match Engine. Flame continua apenas como representação visual da partida.

## Validação

Foram executados preflight estrutural dos Dart alterados e `python3 tool/versioning.py verify`. O ambiente não possui Flutter/Dart, então `flutter pub get`, `flutter analyze`, `flutter test` e `flutter build apk --release` ainda dependem do GitHub Actions.
