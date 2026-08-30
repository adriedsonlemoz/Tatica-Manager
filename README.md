# Tática Manager 2

Reconstrução do Tática Manager em Flutter + Dart, com foco mobile-first, modo retrato, interface esportiva premium e partida 2D com Flame.

Repositório oficial: https://github.com/adriedsonlemoz/Tatica-Manager

**Release atual:** `0.1.1.116`
**Android versionCode:** `117`

## Fonte oficial de versão

A versão visível da release é definida pelo arquivo `VERSION`. O `tool/versioning.py` usa esse valor como fonte canônica, mantém os demais metadados sincronizados e o CI falha quando encontra divergência.

Arquivos de identificação/versionamento incluídos no projeto:

- `VERSION` — fonte canônica da versão visível (`0.1.1.116`);
- `app.json` — identidade externa do aplicativo;
- `pubspec.yaml` — manifesto Flutter, com versão SemVer compatível (`0.1.1+117`);
- Android — plataforma versionada no repositório, com `versionName 0.1.1.116` e `versionCode 117`;
- iOS — catálogo `AppIcon.appiconset` com todos os tamanhos já versionado; a estrutura Xcode completa será sincronizada quando a plataforma iOS for adicionada;
- GitHub Actions — valida a versão embutida no APK antes de publicar o Artifact.

> O Flutter/Dart usa SemVer no `pubspec.yaml`. O quarto componente da release visível permanece em `VERSION`, enquanto o número após `+` é usado como build/versionCode Android. Para `0.1.1.116`, o pubspec é `0.1.1+117`. a próxima entrega normalmente será `0.1.1.117`.


## Estádio imersivo e três novos sistemas — 0.1.1.116

- refaz a tela Estádio seguindo a referência aprovada, com cabeçalho do clube, visão geral com imagem real do asset, bilheteria, manutenção, centro de treinamento, melhorias e próxima melhoria sugerida;
- adiciona os assets `stadium_night.webp` e `covered_stands.webp`, otimizados para cerca de 483 KiB no total;
- cria condição persistente de Gramado, Estrutura, Segurança e Conforto, com desgaste gradual por avanço de dias e manutenção paga para restauração;
- cria Centro de Treinamento com nível 1–5, qualidade derivada, custo de melhoria e obra com prazo;
- transforma melhorias do estádio em obras persistentes com custo, início, data de conclusão, status em andamento/concluído e aplicação real do nível somente no término;
- mantém as melhorias já existentes de arquibancadas, camarotes, lojas, alimentação, publicidade, estacionamento e museu, agora acessíveis em `Ver todas`;
- usa somente Material Icons já disponíveis no Flutter; não adiciona pacote de ícones;
- não altera Match Engine, regras de partidas, músicas ou IDs existentes.

## Correção do cabeçalho da Home — 0.1.1.115

- corrige o erro do GitHub Actions em `home_dashboard_header.dart`, onde `minHeight` foi passado diretamente ao `Container` apesar de esse parâmetro não existir;
- preserva a altura mínima de 104 px por meio de `BoxConstraints(minHeight: 104)`, mantendo o desenho aprovado da Home;
- a correção é restrita ao cabeçalho da Home e não altera dados, navegação, Match Engine, músicas, saves, IDs, regras ou resultados;
- o log da 0.1.1.114 parou no `flutter analyze`, antes dos testes e do build do APK.

## Home alinhada à referência — 0.1.1.114

- usa novamente a referência visual aprovada da Home como base, em vez da interpretação mais verde da versão anterior;
- restaura a barra superior com menu, nome Tática Manager, notificações e caixa de entrada;
- amplia o cabeçalho do clube e remove o cartão do técnico de dentro desse cabeçalho;
- troca o botão principal neon por um verde escuro próximo da referência, com texto branco e ação no extremo direito;
- aumenta os ícones dos seis atalhos e mantém os cards em azul-grafite, sem fundo verde;
- Próxima Partida ganha escudos maiores, nomes completos e mais espaçamento entre competição, data e estádio;
- Resumo da Temporada mantém os seis indicadores em uma linha e recebe divisores verticais como na referência;
- Classificação e Artilharia voltam a ter largura equilibrada, fundo azul-grafite e rodapés de acesso, sem o gradiente verde que dominava os cards;
- Notícias na Home são compactadas para três linhas para preservar o primeiro enquadramento;
- barra inferior perde o grande indicador verde em formato de cápsula e fica mais discreta;
- corrige `player_avatar_identity_test.dart`, que ainda procurava `PlayerCard` no Elenco depois da tela ter sido redesenhada na 0.1.1.113;
- não altera Match Engine, saves, IDs, regras, resultados, músicas ou assets.

## Elenco em lista compacta — 0.1.1.113

- redesenha somente a tela **Elenco** seguindo a referência fornecida: cabeçalho compacto do clube, lista única e resumo no rodapé;
- remove a faixa de abas `Jogadores / Funções / Status` e não cria substitutos para essas abas;
- mantém a busca e os filtros que já existiam, agora acessíveis pelos ícones do topo;
- cada linha usa dados reais do jogador já existentes no save: número, avatar, nome, posição, GER e moral;
- o cabeçalho usa apenas dados já existentes do clube/carreira: escudo, nome, temporada, reputação, saldo e orçamento de transferências;
- o rodapé calcula total de jogadores, brasileiros e estrangeiros diretamente do elenco;
- o atalho da Home abre o Elenco com retorno visível; a aba principal do GameShell continua sem botão de retorno;
- não altera Match Engine, saves, IDs, regras, resultados, músicas ou assets.

## Correção de Sobre / Novidades — 0.1.1.112

- corrige o único teste que falhou no GitHub Actions da 0.1.1.111: `app_info_test.dart` esperava exatamente três releases recentes;
- limita `AppInfo.recentReleases` às três versões mais recentes (`0.1.1.112`, `0.1.1.111` e `0.1.1.110`), mantendo o histórico antigo nos arquivos de documentação;
- preserva integralmente as cinco músicas otimizadas da 0.1.1.111 e não altera player, Match Engine, saves, IDs, regras ou resultados;
- `flutter analyze` já havia passado sem problemas no log da 0.1.1.111; a correção é restrita ao cadastro de novidades/versionamento.

## Músicas do menu mais leves — 0.1.1.111

- mantém as mesmas cinco músicas da playlist padrão e os mesmos nomes/caminhos dos assets;
- troca internamente a codificação das faixas de Vorbis para **Opus em contêiner OGG**, suportado pelo ExoPlayer/Android;
- preserva estéreo e duração completa, com VBR em torno de 64 kbps para reduzir tamanho sem perda perceptível no uso como música de fundo;
- reduz o conjunto das cinco faixas de **10.386.273 bytes para 8.852.371 bytes**, economia de aproximadamente **14,8%**;
- não altera `AudioCatalog`, fluxo do player, efeitos da partida, Match Engine, saves, IDs ou regras.

## Teste da Home sincronizado — 0.1.1.110

- corrige o único teste que falhou no GitHub Actions da 0.1.1.109: 282 testes passaram e 1 falhou;
- atualiza `calendar_and_standings_ui_test.dart` para validar os componentes usados pela Home atual, em vez de procurar widgets removidos de layouts anteriores;
- mantém a Home visualmente inalterada e preserva atalhos, próxima partida, resumo de seis indicadores, classificação/artilharia e notícias;
- mantém `al-sistemas.json` removido e a playlist padrão reduzida para cinco faixas;
- não altera Match Engine, saves, IDs, regras do jogo ou assets.

## Playlist reduzida e versionamento simplificado — 0.1.1.109

- reduz a playlist padrão do menu de 11 para **5 faixas OGG**, exatamente conforme `musicasmenu.zip`;
- mantém apenas Jim Yosef — Lights, Disfigure — Blank, DEAF KEV — Invincible, Cormak — Flavors e David Bulla — Unexpected;
- remove as outras seis faixas do diretório `assets/audio/menu/` e do `AudioCatalog`;
- remove `al-sistemas.json` e elimina sua dependência no CI, testes e utilitário de versionamento;
- passa `VERSION` a ser a fonte canônica da versão visível e mantém o build do `pubspec.yaml` como `versionCode` Android;
- atualiza README, handoff, prompt de continuação, documentação de áudio e documento desta release;
- não altera Match Engine, saves, IDs ou regras do jogo.

## Correção do analyzer da Home — 0.1.1.108

- remove o parâmetro opcional `icon` de `_DashboardSectionHeader`, que não era fornecido por nenhuma chamada e gerava `unused_element_parameter`;
- mantém intacta a aparência atual dos cards de Classificação e Artilharia;
- corrige o único problema reportado pelo `flutter analyze` no log da 0.1.1.107;
- não altera Match Engine, saves, IDs, regras, imagens ou assets.


## Movimentação visual natural — 0.1.1.107

- substitui o deslocamento linear uniforme por estados visuais individuais de velocidade, aceleração e frenagem;
- adiciona pequenas curvas e atrasos determinísticos para que jogadores não saiam e parem todos juntos;
- vincula o atleta ativo ao ponto inicial do lance já produzido pelo Match Engine;
- corrige o pênalti para reposicionar somente cobrador, goleiro e atletas próximos da área, sem puxar os dois times para uma coluna;
- retorna os setores à formação em tempos diferentes e sincroniza passada, inclinação e sombra à velocidade real;
- estabiliza a âncora dos nomes durante o movimento, reduzindo saltos entre cima, lado e baixo;
- não altera Match Engine, resultado, eventos, coordenadas, saves ou regras e não adiciona imagens.


## Campo legível e uniformes seguros — 0.1.1.106

- adiciona nomes compactos e responsivos junto aos jogadores, com prioridade para o atleta da jogada e posicionamento alternativo para evitar sobreposição;
- permite ao usuário escolher o uniforme principal, reserva ou terceiro antes da partida, mostrando a combinação que será usada;
- mede o contraste entre os uniformes e troca automaticamente o kit adversário quando necessário, com fallback visual seguro se todos forem semelhantes;
- dá aos goleiros uniformes próprios e contrastantes, com mangas, luvas e detalhes específicos;
- refina redes com profundidade, traves, gramado, marcações, bola, sombras e interpolação visual dos movimentos;
- não adiciona imagens e preserva integralmente resultados, eventos, coordenadas e regras do Match Engine.


## Partida visual 2.5D — 0.1.1.105

- mantém o campo retangular e a proporção `105 / 68` restaurados na 0.1.1.104;
- jogadores passam a variar de escala e ordem conforme a profundidade visual, melhorando a leitura de quem está à frente/atrás;
- uniformes reais recebem volume, shorts, meias, padrões do clube, sombras e animação de corrida;
- goleiros ficam visualmente diferenciados sem alterar posição ou lógica;
- bola ganha arco/altura e sombra no gramado em passes, chutes, defesas, trave e gol;
- rede reage ao gol e o campo ganha profundidade discreta de iluminação/borda;
- Match Engine, eventos, saves, IDs e multi-competição permanecem intactos.


## Campo visual restaurado — 0.1.1.104

- mantém a base funcional atual e restaura somente a apresentação do campo usada na 0.1.1.91;
- o painel volta à proporção `105 / 68`, com gramado retangular, marcações, gols, arquibancada Canvas e jogadores do renderer anterior;
- o mapeamento visual volta a ser linear dentro do campo, eliminando a projeção e o campo em imagem introduzidos depois da 0.1.1.91;
- HUD atual, placar, timeline, replay, narração, estatísticas, substituições e eventos continuam nas versões atuais;
- preserva Match Engine, `CareerState` schema 13, saves, IDs e multi-competição.

## Correção do analyzer do campo em imagem — 0.1.1.103

- remove o import redundante `dart:ui` de `test/live_match_visual_experience_test.dart`, único problema apontado pelo `flutter analyze` da 0.1.1.102;
- não altera o campo em imagem, projeção, jogadores, bola, HUD, Match Engine, saves, IDs ou multi-competição.

## Campo real como cenário da partida — 0.1.1.102

- adiciona `assets/images/match/match_field.webp`, otimizado em 1550x625 para casar exatamente com o painel 2.48:1 da partida;
- o Flame passa a desenhar esse cenário completo de estádio/gramado como fundo principal, sem redesenhar grama, linhas, gols ou arquibancada quando o asset está disponível;
- jogadores, bola, destaques, replay e animações continuam sobrepostos pelo renderer existente e continuam recebendo somente os eventos/coordernadas do Match Engine;
- recalibra `projectDisplayPoint` ao trapézio real da imagem para manter atletas e bola dentro das linhas do campo;
- mantém `stadium_crowd.webp` e o campo procedural anterior somente como fallback de segurança;
- preserva `CareerState` schema 13, saves, IDs, multi-competição e Match Engine.


## Workflow do GitHub restaurado — 0.1.1.101

- restaura `.github/workflows/flutter-ci.yml`, que havia desaparecido do ZIP `0.1.1.100` junto com os arquivos ocultos;
- mantém os gatilhos automáticos por `push` e manual por `workflow_dispatch`, permitindo que o GitHub Manager volte a localizar/iniciar a build;
- restaura também `.gitignore` e `android/.gitignore` da última base válida;
- o workflow continua executando análise, testes e build release e publica **somente o APK versionado** como Artifact;
- nenhuma alteração funcional da base `0.1.1.100` foi removida ou refeita.


## Sincronização de versão — 0.1.1.100

- atualiza a release visível para `0.1.1.100` (versionCode `101`, pubspec `0.1.1+101`);
- não há alterações de código nesta entrega, apenas metadados de versão/documentação;
- não altera campo, jogadores, Match Engine, saves, IDs ou multi-competição.

## Jogadores e gramado mais nítidos — 0.1.1.98

- redesenha os jogadores da partida ao vivo como tokens sólidos de alto contraste (corpo em cápsula única com padrão do uniforme, cabeça simples, sombra e brilho sutis) no lugar da figura anatômica fina que virava mancha na escala real da tela;
- deixa o gramado mais verde/saturado, com listras de corte mais contrastantes, linhas do campo mais grossas e perspectiva mais acentuada para o efeito de câmera de transmissão;
- não altera Match Engine, eventos, placar, saves, IDs ou multi-competição.

## Correção dos testes da transmissão — 0.1.1.97

- corrige a regressão estrutural da partida para validar a perspectiva `_perspectiveInset(...)` e a escala atual `0.58` do campo redesenhado;
- mantém `AppInfo.recentReleases` limitado às três releases mais recentes, como a tela Sobre/Novidades e o teste já esperam;
- não altera o campo, a torcida, Match Engine, saves, IDs ou multi-competição.

## Correção do renderer da bola — 0.1.1.96

- corrige o único erro do `flutter analyze` da 0.1.1.95 no campo redesenhado;
- troca a chamada inexistente `drawMatchBall` pela API real `drawMatchBallGraphic` de `match_ball_styles.dart`;
- elimina também o warning de import não utilizado sem alterar o desenho do campo ou a lógica da partida;
- preserva Match Engine, `CareerState` schema 13, saves, IDs e multi-competição.

## Campo da partida redesenhado — 0.1.1.95

- redesenha o gramado da partida praticamente do zero, com perspectiva mais equilibrada e enquadramento mais próximo do mockup aprovado;
- refaz a moldura do estádio, o entorno do campo, as luzes, a sensação de profundidade, as marcações e os gols;
- reordena os jogadores por profundidade para evitar sobreposição visual ruim e reduz novamente a escala deles dentro do gramado;
- preserva a torcida existente ao fundo, sem tocar em Match Engine, timeline, placar, saves, IDs ou multi-competição.

## Transmissão ao vivo refinada — 0.1.1.94

- suaviza a perspectiva do campo para ficar mais próxima do mockup de transmissão, mantendo o estádio/torcida existente ao fundo;
- reduz o tamanho visual dos jogadores para melhorar leitura das linhas, espaçamento e proporção dentro do gramado;
- amplia placar, faixa da rodada, timeline e controles sem alterar a lógica da partida;
- redesenha posse, chutes, chutes no gol e cartões com indicadores gráficos e contagens derivadas apenas dos eventos já apresentados;
- preserva Match Engine, timeline, `CareerState` schema 13, saves, IDs e multi-competição.

## Torcida integrada à partida — 0.1.1.93

- integra `assets/images/match/stadium_crowd.webp` como fundo da arquibancada da partida, por trás do campo e dos jogadores;
- mantém o estádio desenhado em Canvas como fallback caso o asset não possa ser carregado;
- o asset foi otimizado para WebP (~136 KB), evitando impacto relevante no APK;
- a imagem é somente apresentação: Match Engine, timeline, placar, cartões, substituições e resultado continuam inalterados;
- corrige o único `undefined_identifier` do GitHub Actions da 0.1.1.92 no teste `live_match_visual_experience_test.dart`.

## Partida ao vivo em perspectiva — 0.1.1.92

- reformula apenas a apresentação da partida: o Match Engine continua sendo a única fonte de eventos, placar, cartões e resultado;
- campo Flame passa a usar projeção trapezoidal/perspectivada, gols com profundidade, arquibancadas, público e iluminação desenhados em Canvas, sem novo asset de imagem;
- jogadores de campo ficam maiores e passam a usar `ClubKit` real do mandante/visitante, incluindo padrões de listras, faixa, metades e degradê; goleiros recebem contraste visual próprio somente no renderer;
- placar, faixa da rodada, timeline já apresentada e controles aproximam a tela da referência de transmissão sem antecipar eventos futuros;
- Passagem do Tempo ganha datas Hoje/Amanhã e informa processos que já existem no avanço diário: condição/fadiga, contratos/mercado e calendário/notícias;
- preserva `CareerState` schema 13, saves, IDs, multi-competição, CPU e Match Engine.

## Tipografia responsiva da Home e correção de analyzer — 0.1.1.91

- aumenta em 3 px/lp a base das fontes da Home, usando encaixe responsivo em áreas estreitas e sem alterar as dimensões dos cards;
- tabela compacta passa a exibir o nome completo dos clubes;
- botão central usa `AVANÇAR DIA` e `JOGAR PARTIDA`, competição aparece como `Brasileiro Série A` e escudos da Próxima Partida crescem 10 px;
- Últimas Partidas passa a indicar também a rodada com o rótulo `RODADA`;
- corrige os quatro problemas apontados pelo `flutter analyze` da 0.1.1.90 no novo pré-jogo: import da extension `PlayerPositionX`, parâmetro opcional não utilizado e aspas do teste estrutural;
- preserva `CareerState` schema 13, saves, IDs, multi-competição, CPU, mercado, contratos e Match Engine.

## Preparação da partida premium — 0.1.1.90

- remodela o pré-jogo usando apenas os dados e funções já existentes da carreira;
- destaca o confronto com escudos, VS, competição, data, horário, estádio, mando e status do dia de jogo;
- mantém o seletor real de duração de 1/2/3 min por tempo em apresentação mais integrada;
- reorganiza Plano de jogo com formação, titulares, força, Escalação, Tática e autoescalação;
- substitui a grade de titulares por um campo tático somente leitura alimentado por `LineupValidation.assignments`;
- reutiliza `assets/images/home/match_stadium.webp` já presente no projeto; nenhuma imagem nova foi criada;
- preserva Match Engine, Flame, saves, IDs, calendário e fundação multi-competição.

## Ajustes finos da Home — 0.1.1.89

- aumenta fontes de finanças, próximo jogo, estádio, atalhos, notícias, classificação e artilheiros sem recuperar alturas excessivas;
- aumenta os escudos e a área visual da Próxima Partida, além de dar mais presença à faixa Dia de jogo/Preparação;
- remove os rodapés redundantes Ver tabela e Ver ranking e mantém os próprios cards como acesso às telas completas;
- mostra até quatro notícias recentes e aproveita o espaço inferior com uma faixa compacta de últimas partidas baseada em `matchHistory` quando a altura da tela comporta;
- pontos de atenção nos atalhos aparecem somente para estados reais já existentes: escalação inválida, dia de jogo, proposta financeira pendente e jogador lesionado;
- preserva `CareerState` schema 13, saves, IDs persistentes, fundação multi-competição e Match Engine.

## Correção do CI — 0.1.1.87

- o GitHub Actions da 0.1.1.86 confirmou `flutter analyze` sem problemas e executou 271 testes; 270 passaram;
- a única falha era estrutural: o teste da Home ainda procurava `PREPARAÇÃO EM ANDAMENTO`, enquanto o card compacto atual usa `PREPARAÇÃO • ...`;
- atualiza somente a expectativa do teste, sem alterar a Home, partida, saves, IDs, multi-competição ou Match Engine.

## Correção do CI — 0.1.1.86

- corrige o único `undefined_identifier` apontado pelo `flutter analyze` da 0.1.1.85 em `live_substitution_pause_test.dart`;
- a expectativa que procura `Confirmar ${plannedChanges.length} trocas` passa a usar string raw, evitando interpolação dentro do próprio teste;
- não altera o fluxo de substituições, a Home compacta, saves, IDs, fundação multi-competição ou Match Engine.

## Home compacta — 0.1.1.85

- reduz significativamente altura do cabeçalho, finanças, próxima partida, preparação, confiança, panorama e atalhos;
- move o comando Avançar para o cabeçalho da Próxima Partida, eliminando a faixa verde isolada que ocupava uma linha inteira;
- Confiança da Diretoria passa a exibir porcentagem primeiro e estádio depois, sem foto do estádio;
- Notícias, classificação e artilheiros passam a compartilhar a mesma linha em larguras de telefone compatíveis, com fallback responsivo para telas mais estreitas;
- o quadro do escudo no cabeçalho usa as cores reais disponíveis do clube em vez de forçar borda verde;
- reduz padding inferior da Home porque a navegação do `GameShell` já fica fora da área útil do conteúdo;
- preserva `CareerState` schema 13, saves, IDs, multi-competição, CPU, mercado, contratos e Match Engine.

## Política obrigatória de release

Toda correção, alteração, refatoração ou entrega deve atualizar a versão antes de ser publicada. O padrão visível é `A.B.C.D`; para esta linha, a próxima entrega normalmente será `0.1.1.115`, salvo quando houver um incremento funcional maior.

Antes de publicar:

```bash
python3 tool/versioning.py sync
python3 tool/versioning.py verify
```

O workflow usa a plataforma Android versionada, cache de Flutter/Pub/Gradle e executa `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --release`, além de conferir o `versionName`/`versionCode` do APK. Não recria `android/` e não executa `flutter clean` em runner novo. O `flutter pub get` resolve as dependências no workspace, mas o CI publica **somente o APK versionado** como Artifact. O `pubspec.lock` não é disponibilizado nos Artifacts.


## Fluxo de substituições em lote — 0.1.1.84

- a janela de substituições não fecha mais ao preparar a primeira troca;
- permite adicionar várias trocas, revisar a lista e remover uma preparação antes de confirmar;
- apenas `Confirmar trocas` altera a partida, e cancelar a janela descarta todo o lote;
- o `LiveMatchController` valida o lote inteiro antes de aplicar, evitando estado parcial;
- várias trocas confirmadas juntas usam uma única janela, respeitando cinco substituições, três janelas e a exceção do intervalo;
- preserva Match Engine, Flame apenas visual, `CareerState` schema 13, saves, IDs e fundação multi-competição.

## Regra de substituições — 0.1.1.83

- mantém o limite de cinco jogadores substituídos por partida e adiciona o limite de três janelas durante o tempo regulamentar;
- várias trocas feitas no mesmo minuto contam como uma única janela;
- substituições feitas no intervalo continuam contando no total de cinco, mas não gastam uma janela;
- a regra passa a ser centralizada em `LiveSubstitutionRules` e usada pelo `LiveMatchController` e pela tela, evitando depender apenas de bloqueio visual;
- o sheet mostra jogadores usados e janelas consumidas;
- testes funcionais cobrem quinta/sexta troca, repetição no mesmo minuto, quarta janela e exceção do intervalo;
- não altera `CareerState` schema 13, saves, IDs, calendário multi-competição ou o Match Engine de simulação.

## Correção de teste — 0.1.1.82

- corrige a única falha restante do GitHub Actions da 0.1.1.81, depois de 266 testes aprovados;
- a expectativa de `Departamento\nMédico` passa a usar string raw no teste estrutural, preservando literalmente o escape presente no código Flutter;
- não altera a Home, os fundos WebP, dados, saves, IDs, fundação multi-competição ou Match Engine.

## Correção da Home — 0.1.1.81

- corrige o erro de sintaxe identificado pelo GitHub Actions na 0.1.1.80: `_HomeBackdrop` não era fechado antes de `_DayAdvanceTransition`;
- elimina os 33 erros em cascata do analyzer causados pelo aninhamento acidental das classes seguintes;
- adiciona uma regressão estrutural específica para esse fechamento;
- não altera layout, assets, dados, saves, IDs, fundação multi-competição ou Match Engine.

## Revisão integrada da Home — 0.1.1.80

- evolui a Home da 0.1.1.79 sem criar dados novos: o bloco inferior agora fica enquadrado em um painel único, com backdrop mais vivo e linguagem visual mais coesa;
- os atalhos passam a usar cards fixos, coloridos e mais compactos, reduzindo sensação de blocos soltos;
- Notícias & Destaques deixa o carrossel e vira uma lista compacta, trazendo mais informação para o primeiro enquadramento;
- Confiança da Diretoria e Panorama da Temporada ficam mais próximos, enquanto tabela e artilharia ganham rodapés de navegação mais claros;
- preserva `CareerState` schema 13, saves, fundação multi-competição, CPU, finanças e Match Engine.

## Revisão visual da Home — 0.1.1.79

- aproxima a Home da referência visual aprovada sem inventar informações: clube, temporada, finanças, próximo jogo, estádio, classificação e confiança continuam vindo do save;
- adiciona dois fundos originais otimizados para os cards de Próxima Partida e Estádio;
- reorganiza cabeçalho, finanças, partida, confiança, panorama e avanço, mantendo notícias, atalhos e rankings existentes abaixo do primeiro bloco da Home;
- corrige o chevron sem ação do Panorama da Temporada, que agora abre a classificação já existente;
- preserva `CareerState` schema 13, saves, IDs persistentes, fundação multi-competição, CPU, mercado, contratos e Match Engine.

## Correção de CI — 0.1.1.78

O GitHub Actions da 0.1.1.77 passou pelo `flutter analyze` sem problemas e executou 266 testes: 262 passaram e quatro falharam. Três falhas tinham a mesma causa: `seasonComplete` confiava no flag persistido `CompetitionSeasonState.completed`, que podia ficar desatualizado em fluxos legados que já haviam marcado todos os fixtures como disputados. A conclusão da temporada agora deriva dos fixtures de cada competição carregada e usa o flag apenas como fallback quando não existe calendário. O quarto teste era estrutural e ainda procurava a lógica de fadiga dentro do `LiveMatchController`; ele foi atualizado para validar a delegação ao `MatchCareerImpactEngine`, onde a regra continua implementada.

## Correção de CI — 0.1.1.77

O GitHub Actions da 0.1.1.76 avançou até `flutter analyze` e revelou dois erros da mesma causa em `competition_state_engine.dart`: a lista vazia usada para competições sem tabela foi inferida como `List<dynamic>`. A correção tipa explicitamente o resultado como `List<Standing>` e adiciona teste de regressão para esse caminho, sem alterar schema 13, calendários, saves, IDs ou Match Engine.

## Fundação multi-competição — 0.1.1.76

A carreira agora persiste `CompetitionSeasonState` por competição: tabela, progresso, estatísticas e disciplina não dependem mais de um único estado global. Os fixtures continuam num calendário global, com metadados de fase/grupo/confronto, permitindo que o mesmo clube participe de torneios simultâneos. O Match Engine continua único e desacoplado do save; `MatchCareerImpactEngine` aplica seus resultados à competição correta. Competições internacionais futuras possuem espaço próprio no catálogo, sem serem associadas artificialmente a um país. Detalhes em `docs/MULTI_COMPETITION_FOUNDATION.md` e `docs/RELEASE_0.1.1.76.md`.

## Etapa atual

A `0.1.1.75` introduz a configuração de ligas por save sem adicionar competições fictícias. A criação passa a oferecer Rápido, Equilibrado, Mundo amplo e Personalizado; a liga do clube escolhido permanece completa e o `CareerState` schema 12 persiste o nível de cada competição. Ligas completas continuam no Match Engine atual, enquanto partidas CPU de futuras ligas em segundo plano podem usar uma resolução estatística agregada sem Flame. O SQLite v3 passa a manter resumo leve dos cards da Central de Carreiras, de modo que `listSaves()` não precise selecionar/desserializar o payload completo. A criação reutiliza o pacote de clubes já carregado e a temporada deriva seu total real de rodadas. Saves e IDs existentes são preservados.

A `0.1.1.74` substitui integralmente a música de menu anterior pelas 11 faixas OGG fornecidas para o projeto, removendo `football.mp3` e os cinco loops M4A antigos. O mesmo `AudioManager` passa a expor faixa atual, seleção manual e próxima música, enquanto a playlist personalizada do aparelho continua compatível. A tela de Áudio ganha um componente separado para a playlist navegável. A apresentação exibida somente na primeira entrada da carreira também é reorganizada para aproximar o botão da matéria, eliminar o grande vazio vertical e integrar melhor o conteúdo ao azul-grafite, sem alterar a flag do onboarding, saves, `CareerState` schema 11, SQLite v2, IDs ou Match Engine.

A `0.1.1.73` corrige o único teste restante do GitHub Actions da 0.1.1.72. O código funcional já estava correto: a confirmação de salvamento havia sido modularizada para `club_editor_import_actions.dart` e `editor_feedback_dialog.dart`, enquanto `editor_experience_test.dart` ainda procurava `_showSaveConfirmation` e o `AlertDialog` antigo somente em `club_editor_screen.dart`. O teste agora valida a composição atual (`_save` + `showEditorNotice` + `AlertDialog` central) sem reintroduzir código obsoleto. UI, `CareerState` schema 11, SQLite v2, IDs, saves e Match Engine permanecem inalterados.

A `0.1.1.72` corrige os nove warnings `invalid_use_of_protected_member` encontrados pelo GitHub Actions na 0.1.1.71. A causa era a refatoração das ações do editor para uma `extension`, que passou a chamar o método protegido `State.setState` fora de um membro da própria subclasse de `State`. As ações continuam modularizadas em `club_editor_import_actions.dart`, mas agora solicitam a atualização por `_updateEditorState`, definido dentro de `_ClubEditorScreenState`. Não há mudança visual nem de comportamento do editor, `CareerState` permanece no schema 11, SQLite v2, IDs/saves e Match Engine não mudam.

A `0.1.1.71` aprimora a Central de Carreiras e a edição sem alterar o Match Engine: os saves ficam em cards acionáveis com escudo, colocação, próximo jogo e lixeira direta; a tela inicial passa a usar logo arredondada, “Carregar jogo salvo” e um rodapé Beta 2.0 que abre a Central de Diagnóstico. Técnicos sem aparência personalizada passam a receber faces estáveis e distintas por perfil. A Central de Edição é apresentada como “Editar dados do jogo”, mantém clubes em tela própria, ganha tutorial interno, ações de importação/restauração compactas, confirmações personalizadas e mensagens centrais. A edição de técnicos coloca Exportar dados e Padrão lado a lado, e a bola da partida passa a ser escolhida visualmente usando o mesmo catálogo gráfico aplicado pelo renderer. O diagnóstico passa a exibir contexto/stack e registrar também falhas operacionais de carreira/editor. `CareerState` permanece no schema 11, SQLite v2, IDs e saves existentes são preservados.

A `0.1.1.70` corrige os dois testes que interromperam o GitHub Actions depois que os 238 testes anteriores passaram. A falha não estava no código funcional: o editor de aparência foi reorganizado em `TRAÇOS DO ROSTO`, mas o teste ainda procurava os antigos cards separados `OLHOS`/`SOBRANCELHAS`; e o atalho padrão da Central de Edição foi movido para `career_hub_info_links.dart`, enquanto o teste continuava lendo apenas `career_hub_screen.dart`. Os testes agora acompanham a composição atual e continuam protegendo olhos, sobrancelhas, recorte de foto, editor padrão e editor por save. UI, gameplay, `CareerState` schema 11, saves, IDs e Match Engine não mudam.

A `0.1.1.69` reformula o fluxo de criação da carreira e clareia a identidade do Tática Manager com base azul-grafite, cards em camadas e verde reservado aos destaques. Formação e clubes ficam mais compactos, a seleção de técnicos perde pesquisa/filtros, a aparência é agrupada em componentes menores, a assinatura deixa o papel branco provisório e uma apresentação de chegada usa técnico, clube, escudo, competição, temporada e data reais somente na primeira entrada da nova carreira. A primeira abertura do aplicativo passa a exigir aceite de Termos de Uso com Política de Privacidade interna, e a Central de Carreiras ganha links discretos para Sobre, Como funciona, Termos, Privacidade, Edição e Configurações. A duração visual passa a 1, 2 ou 3 minutos por tempo e pode ser escolhida já na criação da carreira; saves antigos 4/6/8 são convertidos para os presets equivalentes sem subir o `CareerState` schema 11 e sem alterar o Match Engine.

A `0.1.1.68` corrige o único lint restante revelado pelo `flutter analyze` no GitHub Actions da 0.1.1.67: o `DashboardSectionHeader` passa a usar elemento null-aware para o `trailing`. A revisão da etapa seguinte do CI também encontrou uma inconsistência já presente em Sobre / Novidades, que tinha quatro releases apesar do teste exigir três; a lista volta ao limite histórico sem alterar visual, gameplay, `CareerState` schema 11, saves, IDs ou Match Engine.

A `0.1.1.67` corrige os erros reais apontados pelo `flutter analyze` no GitHub Actions da 0.1.1.66: remove o encadeamento `.where` duplicado que deixou o cálculo de substituições sintaticamente inválido, adiciona os imports das extensões que fornecem `label` para pressão e formação no Dia de Jogo e elimina dois avisos de código não utilizado em Finanças. Não há mudança visual, de schema, save, IDs ou regras do Match Engine.

A `0.1.1.66` faz a auditoria de consistência da reformulação visual: áreas que exibiam seta, destaque ou aparência de ação passam a abrir módulos já existentes; Finanças conecta categorias a Estádio, Contratos e Mercado; cards da Base e o resumo de Contratos respondem ao toque; cores de clubes muito escuras ganham contraste seguro; Patrocínios evita fundos de cards aninhados; e o Estádio só habilita obras quando orçamento reservado e caixa do clube permitem. A arquitetura, o `CareerState` schema 11, saves, IDs e o Match Engine permanecem inalterados.

A `0.1.1.65` reformula visualmente Contratos, Categoria de Base, Departamento Médico, Estádio, Dia de Jogo e Finanças sem adicionar sistemas fictícios: os painéis usam contratos, base, condição/fadiga/lesões, infraestrutura/receitas do estádio, preparação real da partida e transações financeiras já persistidas. O Estádio recebe uma cena noturna animada via `CustomPaint`, enquanto os novos layouts ficam separados em componentes menores. A partida ao vivo passa a impor no `LiveMatchController` o limite de cinco substituições e impede o retorno de atleta já substituído; a UI apenas expõe a contagem. `CareerState` permanece no schema 11 e saves/IDs não mudam.

A `0.1.1.62` adiciona packs separados de escudos no formato `tatica-manager-logos` v1. A Central de Edição pode importar de 1 a 20 logos por arquivo `.tmlogos`/JSON, sempre vinculados ao ID permanente do clube, com validação das imagens e prévia antes de aplicar. O recurso altera somente `iconBase64`, preservando nomes, jogadores, técnicos, estádio, uniformes, saves, schema 11 e Match Engine.

A `0.1.1.61` alinha os três testes estruturais que falharam depois que o analyzer da 0.1.1.60 passou: a criação do técnico agora é validada pelo rótulo atual `País`, Finanças pelas seções remodeladas `Salários` e `Patrocínios`, e os avatares da Home pelos widgets modulares `home_dashboard_news.dart`/`home_dashboard_rankings.dart`. Não há alteração de código funcional, saves, schema 11, Match Engine ou workflow.

A `0.1.1.60` corrige os dois warnings `unused_element_parameter` apontados pelo GitHub Actions na Home 0.1.1.59. Os cards de Notícias e Rankings deixam de declarar um `padding` opcional que nunca recebia valor diferente do padrão; o layout visual permanece igual e não há alteração em saves, schema 11, Match Engine ou workflow.

A `0.1.1.59` remodela a Home no padrão visual premium da referência, usando dados reais de clube, técnico, próximo jogo, classificação, notícias e artilheiros sem alterar saves ou Match Engine.

A `0.1.1.58` remove o import redundante de `dart:ui` em `diagnostic_service.dart` apontado pelo `flutter analyze` no GitHub Actions. A correção não altera o comportamento da Central de Diagnóstico, áudio, saves, Match Engine ou workflow.

A `0.1.1.57` corrige o bloqueio real do GitHub Actions da 0.1.1.56 em `audio_file_store.dart`: a importação múltipla continua sequencial e em streaming, mas deixa de usar `Stream.pipe(IOSink)`, incompatível com a tipagem `Uint8List` do Flutter 3.47.1, e passa a gravar cada chunk no mesmo `IOSink`. A release também migra documentação e metadados para o repositório oficial `https://github.com/adriedsonlemoz/Tatica-Manager`, sem alterar saves, schema 11, Match Engine ou workflow.

A `0.1.1.53` alinha os dois testes restantes da Caixa de Entrada às três propostas comerciais criadas junto da carreira. Idempotência e tombstone continuam sendo validados pela mensagem-alvo, sem alterar código funcional, Match Engine, administração, schema ou saves da 0.1.1.52.

A `0.1.1.49` integra o novo áudio de menu/interface, corrige defaults de narração e velocidade, centraliza feedback tátil e avisos, adiciona bola visual personalizável, foto própria do técnico com editor compacto, navegação hierárquica de Clubes e acabamento em Contratos/Classificação, preservando o schema 9 e o Match Engine.

A `0.1.1.48` corrige os dois testes estruturais restantes revelados pelo GitHub Actions da 0.1.1.47. Os testes agora acompanham a modularização real da Central de Mercado e validam `PlayerAvatar` em `market_components.dart`, além da abertura de `showIncomingTransferOfferDialog` pela Home e pela aba de propostas recebidas. Não há alteração funcional, de save, IDs, schema ou Match Engine.

A `0.1.1.47` é uma release corretiva do CI da 0.1.1.46: corrige as strings monetárias `R$` dos filtros do Mercado, o import explícito de `ManagerCareerHistoryEntry` no engine da carreira do técnico e a tipagem inteira da receita de hospitalidade do Estádio. Não altera schema 9, saves, IDs, regras do mercado, finanças ou Match Engine.

A `0.1.1.46` transforma o Mercado em uma Central de Mercado com busca/filtros avançados, scouting progressivo, negociações persistentes, contrapropostas e parcelamento financeiro real; adiciona Categoria de Base, Departamento Médico e Caixa de Entrada persistentes e conectados ao avanço diário. Home, classificação, clubes, calendário e estatísticas passam a compartilhar navegação por jogador/clube/partida, o ranking de técnicos evolui com a carreira e escudos personalizados usam fundo neutro/transparência e `BoxFit.contain`. O `CareerState` sobe ao schema 9 com novos campos opcionais e leitura retrocompatível do schema 8.

A `0.1.1.45` evolui o ciclo do dia de jogo e a carreira profissional do treinador: o pré-jogo mostra titulares antes dos indisponíveis e pode aplicar a melhor escalação, a Home recebe transição diária e apresentação especial ao chegar a uma partida, o calendário deixa de concentrar rodadas aos domingos, a Escalação ganha campo mais alto/banco por setores/inelegíveis separados e as substituições mantêm o relógio pausado até a alteração ser aplicada pelo `LiveMatchController` ao Match Engine. O treinador agora possui trajetória persistida, pode deixar o clube, procurar vagas e receber propostas de acordo com reputação/desempenho.

A `0.1.1.44` evolui áudio, Classificação e Finanças, adiciona a primeira versão do módulo de Estádio e uma base persistível de patrocinadores. A Classificação mostra movimento entre rodadas e o nome completo da competição; Finanças passa a separar receitas/despesas por área, exibe maiores salários clicáveis e receitas comerciais do estádio. O Match Engine agora transforma o segundo amarelo em vermelho, remove o atleta das assignments ativas e impede participação posterior; Flame apenas representa visualmente a expulsão. Os principais efeitos e a navegação usam os sons enviados, e a música inicia desligada por padrão.

A `0.1.1.43` corrige o único teste restante revelado pelo GitHub Actions da 0.1.1.42: o teste de identidade visual passa a reconhecer o novo `PlayerCard` do Elenco e valida que ele contém `PlayerAvatar`, em vez de procurar os parâmetros antigos `showAvatar`/`showCondition` do `PlayerRow`. Nenhuma lógica ou UI foi alterada.

A `0.1.1.42` corrige o único bloqueio do `flutter analyze` da 0.1.1.41: adiciona o import da extensão `PlayerPositionX` no campo da Escalação para resolver `PlayerPosition.label`, sem alterar lógica, saves, IDs ou Match Engine.

A `0.1.1.41` reformula Elenco/Escalação com cards e status compartilhados, campo horizontal com avatar e OVR efetivo, Autoescalação/trocas por função, foto personalizada no editor, forma recente, mute rápido e tática ao vivo compacta. A penalidade por posição continua centralizada no `LineupEngine` e consumida pelo Match Engine.

A fundação já possui múltiplas carreiras, controladores separados e Match Engine modular. A `0.1.1.6` introduziu calendário diário, preparação pré-jogo, indisponibilidade de atletas e etapas completas da partida. A `0.1.1.7` oficializou o novo ícone e estabilizou o build em JVM 17. A `0.1.1.8` corrige vendas/negociações e adiciona histórico de temporadas. A `0.1.1.9` amplia calendário, notícias, recuperação, mercado/contratos e apresentação dos eventos da partida, além de publicar somente o APK nos Artifacts. A `0.1.1.10` corrige o CI removendo um import não utilizado que bloqueava `flutter analyze`. A `0.1.1.11` torna os testes de versionamento dinâmicos para evitar falhas a cada nova release. A `0.1.1.12` centraliza o ciclo de vida dos contratos, libera jogadores vencidos sem duplicação e reconcilia saves antigos ao abrir a carreira. A `0.1.1.13` substitui os clubes padrão por identidades fictícias com IDs neutros. A `0.1.1.14` amplia essa base para um editor completo de clube, estádio, uniformes, ícone, elencos, jogadores e livres, com pacote comunitário v2 e proteção dos IDs persistentes. A `0.1.1.15` reorganiza a criação de carreira com caminho Países > Brasil > Liga > Série A > Clubes, grade em duas colunas, overall/estrelas/orçamento, amplia o perfil e histórico do técnico e reforça a validação de escudos personalizados. A `0.1.1.16` corrige os cinco lints apontados pelo GitHub Actions da 0.1.1.14 e reforça a disciplina de versionamento/CI antes de novas entregas. A `0.1.1.17` reorganiza editor e criação de carreira, adiciona seletor visual de cores, importação XML com tratamento de encoding, origem estruturada do técnico e fluxo de criação em quatro etapas. A `0.1.1.18` corrige os seis erros de análise estática encontrados pelo GitHub Actions da 0.1.1.17 nos testes do editor, sem alterar a lógica do jogo. A `0.1.1.19` remove o import redundante de `dart:typed_data` detectado pelo `flutter analyze` da 0.1.1.18, sem alterar a lógica do jogo. A `0.1.1.20` alinha a mensagem visual do seletor de escudo ao limite de 32–1024 px, corrigindo o único teste restante do CI da 0.1.1.19. A `0.1.1.21` inicia o mercado CPU orientado por carências de elenco, com recrutamento direcionado, proteção do clube do usuário e limite de negócios por rodada. A `0.1.1.22` adiciona notícias de mercado, venda estratégica, concorrência controlada por jogadores e proteção financeira por operação. A `0.1.1.23` torna propostas da CPU por atletas do usuário realmente negociáveis, com aceite, recusa, contraproposta, expiração e preparação estrutural do mercado para futuras ligas. A `0.1.1.24` fecha a primeira fase do mercado com prioridade estável por janela e alvos alternativos, amplia a classificação compacta da Home, melhora o avanço diário e deixa a criação de carreira mais compacta e visual. A `0.1.1.25` corrige três lints `unnecessary_non_null_assertion` encontrados pelo GitHub Actions da 0.1.1.24 nos testes do mercado, sem alterar a lógica do jogo. A `0.1.1.26` corrige a promoção de nulabilidade desses mesmos testes após o analyzer da 0.1.1.25 apontar `unchecked_use_of_nullable_value`, novamente sem alterar a lógica funcional. A `0.1.1.27` corrige os oito testes revelados depois que o analyzer passou: usa compradores de força compatível nos fixtures de proposta, mantém o teto salarial real da CPU e dá prioridade ao título de contratação de destaque para atletas de overall elevado. A `0.1.1.28` inicia a evolução gráfica dos jogadores com avatares 2D determinísticos por ID, integra rostos ao Elenco, Perfil, Mercado, negociações e notícias e preserva schema, IDs e lógica do jogo. A `0.1.1.29` moderniza a partida ao vivo com placar compacto sempre visível, narração contínua, notificações de eventos, substituições com avatares, ajustes táticos completos e representação Flame das trajetórias já calculadas pelo Match Engine. A `0.1.1.30` transforma o campo 2D em orientação horizontal 105:68, mantendo o aplicativo em retrato e rotacionando somente a representação das coordenadas da timeline para preparar passes, chutes e movimentação lateral sem alterar o Match Engine. A `0.1.1.31` evolui a criação de carreira e o ciclo da partida com bandeiras reais, aparência persistente do treinador, formações compactas e animadas, preparação pré-jogo mais organizada, pós-jogo em duas etapas com avatares nos eventos, ajustes ao vivo mais visuais e mensagens de avanço diário integradas ao layout. A `0.1.1.32` inicia a camada de transmissão da partida com replay de gols derivado da timeline, câmera/zoom discreto, jogadores reagindo aos lances, overlays animados para eventos e cronômetro mais vivo, mantendo Flame somente como representação visual. A `0.1.1.33` aprofunda a partida 2D com mergulhos do goleiro, comemorações em grupo, pênaltis apresentados como momento especial, bola na trave gerada pelo Match Engine, replay de trave/pênalti defendido, transições de intervalo/fim e estádio/torcida mais vivos. A `0.1.1.35` corrige os cinco bloqueios do `flutter analyze` revelados pelo GitHub Actions da 0.1.1.33, preservando integralmente a partida 2D avançada. A `0.1.1.36` adiciona a primeira camada completa de áudio: cinco músicas originais de menu em reprodução aleatória, efeitos de interface e partida, volumes independentes, importação de playlist/sons do aparelho e integração reativa aos `MatchEvent` sem mover regras para Flame. A `0.1.1.37` acrescenta narração falada opcional por TTS do aparelho, com liga/desliga e volume próprios, sem narrar posse/passes e sem adicionar locuções gravadas ao APK.

Para continuar o projeto em outra IA, comece por `AI_HANDOFF.md` e `docs/PROMPT_CONTINUACAO_IA.md`.

Consulte também `docs/RELEASE_0.1.1.37.md`, `docs/RELEASE_0.1.1.36.md`, `docs/AUDIO_SYSTEM.md`, `docs/RELEASE_0.1.1.35.md`, `docs/RELEASE_0.1.1.34.md`, `docs/RELEASE_0.1.1.33.md`, `docs/RELEASE_0.1.1.32.md`, `docs/RELEASE_0.1.1.31.md`, `docs/RELEASE_0.1.1.30.md`, `docs/RELEASE_0.1.1.29.md`, `docs/RELEASE_0.1.1.28.md`, `docs/RELEASE_0.1.1.27.md`, `docs/RELEASE_0.1.1.26.md`, `docs/RELEASE_0.1.1.25.md`, `docs/RELEASE_0.1.1.24.md`, `docs/RELEASE_0.1.1.23.md`, `docs/RELEASE_0.1.1.22.md`, `docs/RELEASE_0.1.1.21.md`, `docs/CPU_MARKET.md`, `docs/RELEASE_0.1.1.20.md`, `docs/RELEASE_0.1.1.19.md`, `docs/RELEASE_0.1.1.18.md`, `docs/RELEASE_0.1.1.17.md`, `docs/RELEASE_0.1.1.16.md`, `docs/RELEASE_0.1.1.15.md`, `docs/RELEASE_0.1.1.14.md`, `docs/RELEASE_0.1.1.13.md`, `docs/CLUB_IDENTITIES.md`, `docs/RELEASE_0.1.1.12.md`, `docs/RELEASE_0.1.1.11.md`, `docs/RELEASE_0.1.1.10.md`, `docs/RELEASE_0.1.1.9.md`, `docs/RELEASE_0.1.1.8.md`, `docs/RELEASE_0.1.1.7.md`, `docs/RELEASE_0.1.1.6.md`, `docs/RELEASE_0.1.1.5.md`, `docs/RELEASE_0.1.1.4.md`, `docs/RELEASE_0.1.1.3.md`, `docs/ETAPA_1.md`, `docs/CARREIRAS_E_ESTADO.md`, `docs/REFATORACAO_CONTROLLERS.md` e `docs/REFATORACAO_MATCH_ENGINE.md`.


### Narração falada opcional

A release 0.1.1.37 usa TTS do próprio aparelho para narrar lances importantes. O recurso pode ser ligado/desligado e possui volume próprio em Configurações → Áudio. Posse e passes não são falados, e o Match Engine continua independente da camada de áudio.
