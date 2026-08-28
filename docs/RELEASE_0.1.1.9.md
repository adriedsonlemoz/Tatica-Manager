# Release 0.1.1.9 — Calendário vivo e continuidade da carreira

Esta entrega mantém a arquitetura Flutter/Riverpod existente e concentra mudanças em calendário, avanço diário, mercado/contratos, apresentação das partidas e estabilidade de CI.

## CI e Artifact

- O GitHub Actions publica **somente** `tatica-manager-0.1.1.9.apk`.
- `pubspec.lock` pode existir/ser resolvido no workspace pelo `flutter pub get`, mas não é copiado para `dist/` nem publicado como Artifact.
- A validação de `versionName`/`versionCode` do APK continua obrigatória.

## Pré-jogo e escalação

- A Escalação aberta pela tela de preparação possui botão de voltar.
- Alterações de formação/titulares continuam sendo persistidas pelo `GameController`, portanto o retorno ao pré-jogo não descarta ajustes.

## Classificação e calendário

- Ordem: posição, clube, PTS, J, V, E, D, GP, GC e SG.
- Zonas visuais para Libertadores, outras competições e rebaixamento.
- Calendário mensal com seleção de dias e partidas abaixo.
- Partidas futuras e disputadas podem ser abertas para detalhes; resultados da temporada atual guardam eventos/estatísticas em `matchHistory`.

## Avanço diário, físico e notícias

- O avanço diário continua em `DailyCareerEngine` e registra notícias persistentes.
- Eventos incluem recuperação, contrato próximo do fim, interesse/proposta, próxima partida e treino/recuperação.
- Recuperação diária varia conforme condição, fadiga e lesão; desgaste de jogo continua aplicado após a partida.

## Mercado e contratos

- Compras e vendas são bloqueadas fora das janelas: 1 jan–30 abr e 1 jul–30 set.
- Renovações continuam permitidas fora da janela.
- Tela de contratos diferencia risco de saída, renovação próxima e contrato ativo.

## Partidas

- Eventos exibem tipo do lance, jogador quando disponível e equipe com nome completo.
- Narração e resumo não usam abreviações de clube como FLA/FLU.
- Cartões amarelos e vermelhos entram na apresentação dos acontecimentos importantes.

## Saves e temporadas

- Schema atual: 4, com `news` e `matchHistory` compatíveis com saves antigos.
- `seasonHistory` permanece acumulado entre temporadas; `matchHistory` é reiniciado na virada para limitar crescimento do save.
- O teste de múltiplas temporadas continua cobrindo a progressão até 2040.

## Próxima evolução visual

Com esta base estabilizada, uma release seguinte pode aprofundar a representação 2D em Flame: sprites de jogadores, bola, passes, corridas, posicionamento e animações de eventos. O Match Engine continua sendo a fonte do resultado; Flame apenas reproduz visualmente a timeline.
