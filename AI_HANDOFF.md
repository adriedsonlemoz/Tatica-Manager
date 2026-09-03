# Tática Manager 2 — Handoff para outra IA ou desenvolvedor

> Documento de entrada para continuar o projeto sem perder contexto, arquitetura ou regras de release.

## Projeto

- **Nome:** Tática Manager 2
- **Produto:** Tática Manager
- **Repositório oficial:** https://github.com/adriedsonlemoz/Tatica-Manager
- **Stack:** Flutter + Dart, Riverpod, SQLite (`sqflite`) e Flame para a representação 2D da partida
- **Release deste handoff:** `0.1.1.131`
- **Android versionCode:** `132`
- **Orientação:** somente retrato
- **Objetivo:** jogo de gestão de futebol com carreira de várias temporadas; a base atual possui liga nacional de 20 clubes, mas os sistemas devem permanecer preparados para múltiplas ligas, além de mercado, contratos, finanças, táticas, escalação e partida 2D.





## Estado funcional da release 0.1.1.131

## Correção do analyzer no cartão amarelo

- Remove operadores nulos redundantes dentro do ramo em que o jogador advertido já foi validado como não nulo.
- Elimina os três avisos fatais do log 84 sem alterar as probabilidades ou regras disciplinares.
- A análise do vídeo da apresentação da partida foi mantida separada: nenhuma mudança visual do campo integra esta microcorreção.

Consulte `docs/RELEASE_0.1.1.131.md`.

## Estado funcional da release 0.1.1.130

## Simulação de partidas mais realista

- Corrige os imports de `FormationTypeX` e `MentalityX` que bloqueavam `flutter analyze` nas telas de técnico.
- `MatchStrengthCalculator` combina overall efetivo com finalização, criação, marcação, físico e atributos de goleiro por setor.
- `MatchProbabilityCalculator` calcula volume de gols, chutes e faltas pelo confronto; quem perde passa a assumir mais risco após os 55 minutos.
- Cartões, faltas e lesões respeitam perfil do atleta, pressão, minuto e carga física; a CPU também usa até três trocas em suas partidas de fundo.
- O resolvedor CPU usa o Match Engine mesmo em competição de segundo plano, preservando gols, artilharia, cartões, suspensões, fadiga e lesões.

Consulte `docs/RELEASE_0.1.1.130.md`.

## Estado funcional da release 0.1.1.129

## Confiabilidade, diretoria e técnicos CPU

- `GameController.commitCareer` só atualiza a sessão após a confirmação do SQLite e registra falhas de gravação no diagnóstico.
- Migrações V1 preservam payloads inválidos em `career_save_recovery`; o upgrade também executa todas as etapas necessárias de forma sequencial.
- `BoardObjective` persiste meta anual e confiança; a Home mostra a meta e o avanço diário produz avaliação semanal baseada na tabela e no caixa.
- `LiveRoundSimulator` e as simulações de competição usam formação e estilo do `ManagerProfile` do clube CPU.
- Notícias recentes ficam limitadas a 120 e o arquivo persistente retém até 400 eventos antigos; a tela de notícias consulta os dois conjuntos.
- Formatos de copas/grupos continuam bloqueados por `CompetitionScheduleEngine.activationBlockReason` até que regras e dados reais sejam cadastrados.

Consulte `docs/RELEASE_0.1.1.129.md`.

## Estado funcional da release 0.1.1.128

## Notícias e técnicos mais completos

- `CareerNewsEngine` cria prévia de confronto, panorama semanal da tabela e reportagens pós-jogo exclusivamente a partir de fixtures, tabela, jogadores e Match Engine já persistidos.
- O banco padrão passa a ter um técnico fictício e distinto por clube; o banco legado com todos os nomes `Técnico CPU` é reparado durante a normalização.
- A escolha de técnico e `ManagerProfileScreen` exibem origem, contrato, experiência, estilo, formação, mentalidade, tempo no cargo e situação real.
- A geração dos jogadores permanece a mesma: nomes fictícios, atributos e visual estáveis pelo seed, sem mudança nas regras.

Consulte `docs/RELEASE_0.1.1.128.md`.

## Estado funcional da release 0.1.1.127

## Correções do log 81

- Escalação aberta pelo pré-jogo recebe retorno explícito, preservando as alterações feitas.
- Banco e elenco continuam paginados, agora ordenados e identificados por setores, com indisponíveis ao final.
- O analyzer passou no workflow 81; os dois testes estruturais restantes foram corrigidos.

Consulte `docs/RELEASE_0.1.1.127.md`.

## Estado funcional da release 0.1.1.126

## Correção do log 80

- `CompactFormationPitch` agora importa `player.dart`, disponibilizando `PlayerPositionX.label`.
- O único erro do analyzer no log 80 é corrigido sem mudança visual ou funcional.

Consulte `docs/RELEASE_0.1.1.126.md`.

## Estado funcional da release 0.1.1.125

## Escalação integrada ao novo design

- A aba Escalação compartilha o campo compacto com Táticas e usa o cabeçalho padrão, sem o antigo título interno grande.
- Formação, autoescalação, troca de titulares, perfis e disponibilidade continuam conectados aos dados reais da carreira.
- Banco e elenco usam paginação horizontal de cinco atletas, mantendo a página principal sem rolagem vertical.

Consulte `docs/RELEASE_0.1.1.125.md`.

## Estado funcional da release 0.1.1.124

## Calendário, Táticas e Configurações fiéis aos mockups

- Calendário usa layout fixo com Mês, Agenda e Resultados; pagina listas maiores sem rolagem e mostra apenas partidas e eventos persistidos.
- Táticas usa campo vertical, formação, titulares e banco reais; mantém apenas Mentalidade, Pressão, Linha defensiva, Ritmo e Construção, já suportados pelo Match Engine.
- Configurações usa cartões compactos sem rolagem para áudio, vibração, velocidade, duração, bola, perfil, carreira e informações do jogo.
- `matchSpeed` 1x/2x/4x volta a atuar no relógio de apresentação da partida, sem alterar simulação, resultado ou estatísticas.
- As ações antigas de áudio avançado, aparência, novidades, contato, Pix, voltar às carreiras e exclusão continuam acessíveis.

Consulte `docs/RELEASE_0.1.1.124.md`.

## Estado funcional da release 0.1.1.123

## Correção do log 77

- `flutter analyze --no-pub` já passava sem problemas no log 77.
- 291 testes passavam e 3 falhavam por regressões pontuais da reorganização recente de Finanças/Transferências.
- As seções expansíveis de Estádio e Patrocínios voltaram de forma funcional apenas no modal de detalhes, mantendo a tela financeira principal sem rolagem.
- A renovação contratual agora grava o lançamento financeiro com `next.currentDate`, isto é, a data do estado efetivamente persistido.


- corrige os três warnings restantes do log 76 sem alterar comportamento funcional: duas asserções de não-nulo redundantes no saldo projetado e o widget privado `_FinanceExpansion` sem uso;
- a tela de Finanças continua compacta e integrada ao mesmo `CareerState.finances`, orçamento, caixa e folha já persistidos;
- Transferências, contratos, empréstimos, saves, schema 14 e Match Engine permanecem inalterados.

Consulte `docs/RELEASE_0.1.1.123.md`.

## Estado funcional da release 0.1.1.121

- corrige a falha de análise estática do log 75 sem mudar o comportamento funcional da release 0.1.1.120;
- `FinanceBalanceOverview` volta a encerrar corretamente o método `build` e a própria classe, tornando `FinanceBalanceChart`, `FinanceCategoryAmount`, `FinanceSalaryPanel` e os demais componentes financeiros novamente tipos de nível superior válidos;
- `FinancesScreen` importa explicitamente `CareerState` e `MarketScreen` importa `transfer.dart` para disponibilizar `TransferOperationResult` aos arquivos `part`;
- a ordenação de contratos deixa de usar cascade desnecessário, eliminando o único aviso independente registrado pelo analyzer;
- Transferências centralizadas, Finanças compactas, persistência, schema 14 e Match Engine permanecem inalterados.

Consulte `docs/RELEASE_0.1.1.121.md`.


## Estado funcional da release 0.1.1.120

- `TransferNegotiation` passa a representar compra, venda, renovação e empréstimo, com status recebido, em análise, contraproposta, acordo possível, recusada, concluída ou encerrada;
- `MarketCareerEngine` é a fonte de verdade para iniciar, revisar, responder, concluir e encerrar negociações; nenhuma proposta altera jogador, contrato, elenco ou caixa antes da conclusão explícita;
- Mercado preserva busca, filtros e perfis, agora organizado nas abas Mercado, Observados e Negociações; Home e Caixa de entrada abrem a Central de Negociações para propostas e respostas;
- `PlayerLoan` persiste clube de origem e prazo: o atleta emprestado sai temporariamente do elenco/folha da origem, entra no elenco/folha do receptor, permanece renovável pelo dono do contrato e retorna automaticamente no prazo;
- compras, vendas, luvas e renovações gravam `FinanceTransaction` com `career.currentDate`; parcelas futuras não geram caixa negativo, ficam pendentes quando o comprador não pode pagar e registram compra ou venda no livro-caixa do usuário quando liquidadas;
- propostas abertas reservam orçamento de transferências, entrada e luvas para impedir compromissos simultâneos acima dos valores reais disponíveis;
- `FinancesScreen` mantém Resumo sem rolagem vertical; previsões, distribuição, histórico, patrocínios e orçamentos ficam em painéis de detalhes, usando somente os dados persistidos;
- schema de carreira 14 mantém retrocompatibilidade com saves antigos sem campos de empréstimo ou tipo de negociação.

Consulte `docs/RELEASE_0.1.1.120.md`.


## Estado funcional da release 0.1.1.119

- redesenha `FinancesScreen` com abas Resumo, Receitas, Despesas e Salários, preservando `CareerState.finances` como livro-caixa único;
- `FinanceDashboardEngine` reconstrói saldos mensais a partir do caixa atual e dos lançamentos persistidos, sem salvar ou manter uma segunda lista de valores;
- a previsão usa somente até três meses fechados que já possuem lançamentos; sem histórico, a UI informa a indisponibilidade em vez de inventar números;
- categorias, filtros e atalhos levam aos módulos reais de Estádio, Mercado, Contratos, Patrocínios e Orçamentos;
- novos lançamentos de compra, venda, renovação e bônus de assinatura usam `career.currentDate`; dados antigos com data do aparelho são ajustados apenas para a visualização financeira;
- não adiciona categorias sem fluxo real, como Base ou Comissão técnica, e não altera Match Engine, resultados, schema, IDs ou saves.

Consulte `docs/RELEASE_0.1.1.119.md`.


## Estado funcional da release 0.1.1.118

- redesenha `PreMatchScreen` seguindo a referência aprovada, sem técnico, clima ou árbitro;
- `PreMatchReferenceHero` exibe competição, clubes, data/hora, estádio e forma recente calculada dos dois clubes;
- `PreMatchTacticalComparison` usa formação/tática real do usuário e a mesma derivação CPU de `LiveRoundSimulator` para o rival, com força calculada por `MatchStrengthCalculator`;
- `PreMatchProbableLineups` exibe os titulares reais do usuário e os onze selecionados para a CPU por `LineupEngine.autoSelect`;
- `PreMatchAbsences` compara lesões, suspensões da competição e baixa condição dos dois clubes;
- os três cards aprovados abrem Escalação, Tática e o seletor de Uniformes em diálogo centralizado;
- `Simular` reutiliza `LiveMatchController.prepareMatch()` e `finishMatch()` e segue diretamente ao `ResultScreen`;
- duração da transmissão deixa o Pré-jogo, mas permanece nas Configurações;
- Match Engine, estádio, músicas, persistência e regras de resultado permanecem inalterados.

Consulte `docs/RELEASE_0.1.1.118.md`.


## Estado funcional da release 0.1.1.117

- corrige os dois testes de `visual_navigation_consistency_test.dart` que bloquearam o CI da 0.1.1.116, enquanto o `flutter analyze` já estava limpo;
- `StadiumOverviewCard` usa acento legível derivado da cor primária do clube e contraste calculado quando há ícone sobre esse acento;
- `StadiumScreen` calcula fundos realmente disponíveis com `min(orçamento do estádio, caixa do clube)` e repassa esse limite para a lista de obras e para a melhoria sugerida;
- a melhoria sugerida não abre a ação quando o saldo/orçamento é insuficiente e comunica esse estado diretamente no card;
- mantém integralmente os três sistemas criados na 0.1.1.116, os assets do estádio, Match Engine e playlist.

Consulte `docs/RELEASE_0.1.1.117.md`.


## Estado funcional da release 0.1.1.116

- redesenha `StadiumScreen` conforme a referência visual aprovada, usando os assets WebP do estádio em vez do antigo `CustomPainter`;
- mantém dados reais de clube, temporada, saldo, orçamento, estádio, capacidade, ingresso e projeção de público;
- adiciona ao `Stadium` quatro condições persistentes (`pitchCondition`, `structureCondition`, `securityCondition`, `comfortCondition`), nível de centro de treinamento e histórico de `StadiumProject`;
- `StadiumEngine.advanceDay` conclui obras vencidas e aplica desgaste gradual das condições;
- `ClubAdministrationEngine.upgradeStadium` agora inicia uma obra e só aplica o nível quando o prazo termina;
- adiciona manutenção geral e melhoria do centro de treinamento usando orçamento do departamento Estádio e transações financeiras existentes;
- preserva retrocompatibilidade: saves antigos recebem valores padrão e lista de obras vazia;
- mantém Match Engine, partidas, músicas e IDs existentes inalterados.

Consulte `docs/RELEASE_0.1.1.116.md`.


## Estado funcional da release 0.1.1.115

- corrige a falha de análise estática da 0.1.1.114 em `HomeClubHeader`;
- substitui o uso inválido de `Container(minHeight: 104)` por `constraints: BoxConstraints(minHeight: 104)`;
- mantém o mesmo objetivo visual e não desfaz a revisão da Home da 0.1.1.114;
- preserva Match Engine, saves, schema, IDs, regras, resultados, playlist e assets.

Consulte `docs/RELEASE_0.1.1.115.md`.

## Estado funcional da release 0.1.1.114

- realinha a Home à segunda referência visual fornecida pelo usuário, removendo o excesso de verde observado no print real;
- restaura `HomeTopBar`, amplia o cabeçalho do clube e usa o verde escuro somente na ação principal;
- aumenta os ícones dos seis atalhos, mantém seus cards em azul-grafite e reforça Próxima Partida/Resumo sem mudar os dados consumidos;
- Classificação e Artilharia passam a dividir a largura igualmente, usam fundo azul-grafite e rodapés discretos em vez do gradiente verde;
- compacta Notícias para três entradas na Home e deixa a barra inferior sem indicador em cápsula;
- corrige o teste de identidade visual do Elenco para acompanhar `_SquadTable`/`_SquadPlayerRow`, eliminando a falha real do log 65 sem reintroduzir `PlayerCard`;
- preserva Match Engine, saves, schema, IDs, regras, resultados, playlist e assets.

Consulte `docs/RELEASE_0.1.1.114.md`.

## Estado funcional da release 0.1.1.113

- redesenha a tela `SquadScreen` no formato compacto da referência fornecida pelo usuário;
- elimina a faixa de abas de Elenco e usa uma lista única com colunas de número, jogador, posição, GER e moral;
- preserva busca e filtros existentes em ações compactas no AppBar, sem criar novos módulos;
- exibe no topo apenas dados que já existem em `CareerState`/`Club` e no rodapé totais derivados do próprio elenco;
- o acesso pela Home passa `showBackButton: true`, enquanto a aba do `GameShell` mantém o comportamento de navegação atual;
- preserva Match Engine, saves, schema, IDs, regras, resultados, playlist e assets.

Consulte `docs/RELEASE_0.1.1.113.md`.

## Estado funcional da release 0.1.1.112

- corrige a falha de `app_info_test.dart` observada no GitHub Actions da 0.1.1.111;
- mantém `AppInfo.recentReleases` com exatamente as três versões mais recentes, como a tela Sobre / Novidades e o teste esperam;
- preserva o histórico completo de releases na pasta `docs/`, sem acumular todas elas na lista exibida pelo aplicativo;
- não altera as cinco músicas otimizadas, player, Match Engine, saves, IDs, regras ou resultados.

Consulte `docs/RELEASE_0.1.1.112.md`.

## Estado funcional da release 0.1.1.111

- mantém as cinco músicas padrão escolhidas na 0.1.1.109, sem adicionar ou remover faixas;
- recomprime somente esses assets de Vorbis para Opus dentro de OGG, em estéreo e com duração integral;
- reduz o conjunto de 10.386.273 para 8.852.371 bytes (~14,8%), sem mudar nomes de arquivos nem `AudioCatalog`;
- preserva player, efeitos, Match Engine, saves, IDs e regras.

Consulte `docs/RELEASE_0.1.1.111.md`.

## Estado funcional da release 0.1.1.110

- corrige o teste estrutural da Home que ainda esperava componentes de layouts anteriores;
- mantém o layout atual sem recolocar `HomeFinanceGrid`, `HomeMainOverview`, `HomeRecentMatches` ou `_CompactAdvanceButton` apenas para satisfazer o teste antigo;
- passa a validar `HomePrimaryActionButton`, `HomeQuickAccess`, `HomeNextMatchCard`, `HomeSeasonSummaryRow`, `HomeLeagueAndScorers` e `HomeNewsHighlights`;
- preserva Match Engine, saves, IDs, regras e a playlist reduzida da 0.1.1.109.

Consulte `docs/RELEASE_0.1.1.110.md`.

## Estado funcional da release 0.1.1.109

- reduz a playlist padrão do menu para exatamente cinco faixas OGG fornecidas em `musicasmenu.zip` e remove as outras seis;
- remove `al-sistemas.json` e todas as dependências funcionais desse arquivo no versionamento, testes e GitHub Actions;
- adota `VERSION` como fonte canônica da release visível; o build do `pubspec.yaml` continua sendo o `versionCode` Android;
- atualiza a documentação obrigatória desta entrega;
- preserva Match Engine, saves, IDs, regras e resultados da partida.

Consulte `docs/RELEASE_0.1.1.109.md`.

## Estado funcional da release 0.1.1.108

- corrige o único warning apontado pelo `flutter analyze` da 0.1.1.107;
- remove o parâmetro opcional `icon` de `_DashboardSectionHeader`, pois nenhuma chamada o utilizava;
- preserva o visual atual de Classificação/Artilharia e não altera Match Engine, saves, IDs ou regras.

Consulte `docs/RELEASE_0.1.1.108.md`.

## Estado funcional da release 0.1.1.107

- substitui a interpolação linear uniforme do renderer por estados individuais de velocidade, aceleração, frenagem, atraso e curvatura determinística;
- conecta visualmente o atleta ativo ao `event.start` já produzido pelo Match Engine, sem modificar a timeline;
- corrige a apresentação de pênaltis para mover somente cobrador, goleiro e jogadores que realmente precisam sair da área;
- escalona o retorno à formação por setores, sincroniza a passada à velocidade e estabiliza as âncoras dos nomes;
- preserva integralmente Match Engine, resultados, eventos, coordenadas, `CareerState` schema 13, IDs, saves e multi-competição; nenhuma imagem foi adicionada.

Consulte `docs/RELEASE_0.1.1.107.md`.

## Estado funcional da release 0.1.1.106

- adiciona seleção pré-jogo entre os três uniformes cadastrados do clube do usuário e resolve automaticamente a combinação adversária com maior contraste;
- exibe nomes compactos e responsivos junto aos jogadores, com posicionamento adaptativo para reduzir colisões e prioridade para goleiro/atleta da jogada;
- diferencia goleiros com kits calculados especificamente para a partida, mangas longas, luvas e detalhes próprios;
- refina redes e traves em profundidade, marcações, textura procedural do gramado, bola, sombras e suavização visual dos movimentos;
- preserva integralmente o Match Engine, seus resultados/eventos/coordenadas, `CareerState` schema 13, IDs, saves e multi-competição; nenhuma imagem foi adicionada.

Consulte `docs/RELEASE_0.1.1.106.md`.

## Estado funcional da release 0.1.1.105

- mantém o campo restaurado da 0.1.1.91/0.1.1.104 e adiciona profundidade apenas aos elementos móveis da partida;
- jogadores ganham escala por profundidade, ordenação visual única entre os dois times, uniforme real com volume, sombras, animação de passada e goleiro diferenciado;
- bola ganha arco/altura visual com sombra independente e a rede reage a gols já apresentados;
- preserva HUD, replay, Match Engine, `CareerState` schema 13, IDs, saves e multi-competição.

Consulte `docs/RELEASE_0.1.1.105.md`.

## Estado funcional da release 0.1.1.104

- restaura somente o renderer visual da partida ao padrão existente na 0.1.1.91, sem reverter o restante do projeto;
- o painel volta à proporção `105 / 68`, com campo retangular, estádio Canvas, jogadores e mapeamento linear anteriores;
- remove do caminho de renderização o campo WebP e a projeção introduzidos nas releases posteriores, mantendo esses assets apenas como arquivos não utilizados por enquanto;
- preserva HUD, placar, timeline, replay, narração, estatísticas, substituições, Match Engine, `CareerState` schema 13, IDs, saves e multi-competição.

Consulte `docs/RELEASE_0.1.1.104.md`.

## Estado funcional da release 0.1.1.103

- corrige o único problema de analyzer da 0.1.1.102 removendo o import redundante `dart:ui` do teste visual da partida;
- preserva integralmente o novo campo em imagem, projeção, jogadores, bola, HUD, Match Engine, `CareerState` schema 13, saves, IDs e multi-competição.

Consulte `docs/RELEASE_0.1.1.103.md`.

## Estado funcional da release 0.1.1.102

- integra `assets/images/match/match_field.webp` como cenário completo principal da partida ao vivo, com gramado, linhas, gols, arquibancada e iluminação já incorporados na imagem;
- o Flame deixa de redesenhar o campo procedural no caminho normal e passa a sobrepor apenas jogadores, bola, destaques e animações;
- calibra a projeção dos `FieldPoint` ao trapézio real do novo asset, preservando a rotação horizontal já existente e sem modificar coordenadas/eventos do Match Engine;
- mantém `stadium_crowd.webp` e o renderer procedural anterior como fallback caso o novo asset falhe ao decodificar;
- preserva `CareerState` schema 13, IDs, saves, multi-competição e Match Engine.

Consulte `docs/RELEASE_0.1.1.102.md`.

## Estado funcional da release 0.1.1.101

- restaura `.github/workflows/flutter-ci.yml`, removido do pacote 0.1.1.100 porque o ZIP não continha arquivos ocultos;
- o workflow restaurado mantém `push`, `pull_request` e `workflow_dispatch`, usa Flutter estável versionado e publica somente `tatica-manager-<versão>.apk` como Artifact;
- restaura também `.gitignore` e `android/.gitignore` da última base válida;
- preserva integralmente as alterações de código da 0.1.1.100, `CareerState` schema 13, saves, IDs, multi-competição e Match Engine.

Consulte `docs/RELEASE_0.1.1.101.md`.

## Estado funcional da release 0.1.1.100

- atualiza a release visível para `0.1.1.100` (versionCode `101`, pubspec `0.1.1+101`);
- não há alterações de código nesta entrega, apenas metadados de versão/documentação;
- não altera campo, jogadores, Match Engine, eventos, placar, `CareerState` schema 13, saves, IDs ou multi-competição.

Consulte `docs/RELEASE_0.1.1.100.md`.

## Estado funcional da release 0.1.1.98

- redesenha os jogadores da partida ao vivo como tokens sólidos de alto contraste (corpo em cápsula única com padrão do uniforme, cabeça simples, sombra e brilho sutis) no lugar da figura anatômica fina que virava mancha na escala real da tela;
- deixa o gramado mais verde/saturado, com listras de corte mais contrastantes, linhas do campo mais grossas e perspectiva mais acentuada para o efeito de câmera de transmissão;
- não altera Match Engine, eventos, placar, `CareerState` schema 13, saves, IDs ou multi-competição.

Consulte `docs/RELEASE_0.1.1.98.md`.

## Estado funcional da release 0.1.1.97

- corrige as duas falhas de teste restantes do GitHub Actions da 0.1.1.96 depois de `flutter analyze` passar sem problemas;
- atualiza `live_match_visual_experience_test.dart` para a nova perspectiva e escala do campo redesenhado;
- limita `AppInfo.recentReleases` às três releases mais recentes, preservando o contrato da tela Sobre/Novidades;
- não altera campo, torcida, Match Engine, `CareerState` schema 13, saves, IDs ou multi-competição.

Consulte `docs/RELEASE_0.1.1.97.md`.

## Estado funcional da release 0.1.1.96

- corrige o único erro `undefined_method` revelado pelo GitHub Actions da 0.1.1.95 em `match_pitch_visuals.dart`;
- usa `drawMatchBallGraphic`, que é a API real já existente em `match_ball_styles.dart`, eliminando também o warning de import não utilizado;
- não altera o campo redesenhado, a torcida, o Match Engine, `CareerState` schema 13, saves, IDs ou multi-competição.

Consulte `docs/RELEASE_0.1.1.96.md`.

## Estado funcional da release 0.1.1.95

- redesenha o gramado da partida praticamente do zero para se reaproximar do mockup aprovado;
- adota nova geometria do campo, marcações mais limpas, gols refeitos, moldura de estádio e iluminação/entorno melhor equilibrados;
- passa a desenhar os jogadores respeitando profundidade visual e reduz novamente a escala deles dentro do campo, sem alterar coordenadas ou eventos do Match Engine;
- mantém a torcida WebP como fundo, preserva `CareerState` schema 13, IDs, saves, multi-competição e Flame exclusivamente como apresentação visual.

Consulte `docs/RELEASE_0.1.1.95.md`.

## Estado funcional da release 0.1.1.94

- aproxima novamente a partida ao vivo do mockup aprovado, reduzindo a perspectiva exagerada do campo e a escala dos bonecos sem alterar coordenadas/eventos do Match Engine;
- reforça placar, rodada, timeline e controles como elementos de transmissão;
- transforma posse, chutes, chutes no gol e cartões em um painel visual mais próximo da referência, calculado somente com eventos já apresentados;
- mantém o asset de torcida da 0.1.1.93 como fundo e o Canvas como fallback;
- preserva `CareerState` schema 13, IDs, saves, multi-competição e Flame exclusivamente como apresentação visual.

Consulte `docs/RELEASE_0.1.1.94.md`.

## Estado funcional da release 0.1.1.93

- integra a torcida noturna criada para a partida como asset WebP otimizado, carregado apenas pela camada visual Flame;
- o asset fica atrás do campo em perspectiva, jogadores, bola e eventos, preservando Canvas como fallback caso a imagem falhe;
- corrige o único erro `undefined_identifier` do GitHub Actions da 0.1.1.92 em `live_match_visual_experience_test.dart`;
- preserva Match Engine, timeline, placar, cartões, substituições, saves, IDs e fundação multi-competição.

Consulte `docs/RELEASE_0.1.1.93.md`.

## Estado funcional da release 0.1.1.92

- reformula o renderer Flame da partida para uma apresentação horizontal em perspectiva sem tocar no Match Engine;
- desenha gramado trapezoidal, linhas projetadas, gols com profundidade, arquibancadas, torcida e iluminação diretamente por Canvas, sem criar imagem nova;
- jogadores ficam maiores, recebem variações visuais determinísticas e usam os padrões reais de `homeKit`/`awayKit` já persistidos nos clubes;
- placar, faixa da rodada, controles e timeline de eventos já apresentados passam a seguir uma linguagem de transmissão mais próxima da referência;
- remodela a Passagem do Tempo com Hoje/Amanhã e processos reais do avanço diário, mantendo o mesmo `advanceDay()`;
- preserva `CareerState` schema 13, IDs, saves, calendário multi-competição, CPU, mercado, contratos e Match Engine.

Consulte `docs/RELEASE_0.1.1.92.md`.

## Estado funcional da release 0.1.1.91

- aumenta em 3 px/lp a base tipográfica da Home sem aumentar as dimensões declaradas dos cards, usando `FittedBox` nas áreas mais estreitas;
- tabela compacta passa a usar o nome completo dos clubes;
- Próxima Partida usa escudos 10 px maiores, `AVANÇAR DIA` e `JOGAR PARTIDA`, e a Home encurta `Campeonato Brasileiro Série A` para `Brasileiro Série A`;
- Últimas Partidas recebe indicação de rodada e rótulo `RODADA`;
- corrige os quatro problemas de analyzer da 0.1.1.90 no pré-jogo sem alterar o design aprovado;
- preserva `CareerState` schema 13, IDs, saves, calendário multi-competição, CPU, mercado, contratos e Match Engine.

Consulte `docs/RELEASE_0.1.1.91.md`.

## Estado funcional da release 0.1.1.90

- remodela visualmente a Preparação da Partida sem alterar regras do jogo;
- adiciona hero do confronto com dados reais e reutiliza o fundo de estádio já existente na Home;
- reorganiza duração da transmissão e plano de jogo mantendo os mesmos comandos atuais;
- mostra os 11 titulares em campo tático somente leitura usando as coordenadas reais da formação e OVR efetivo;
- mantém indisponíveis separados e preserva o fluxo real de iniciar partida pelo `LiveMatchController`;
- preserva `CareerState` schema 13, IDs, saves, calendário multi-competição, CPU, mercado, contratos e Match Engine.

Consulte `docs/RELEASE_0.1.1.90.md`.

## Estado funcional da release 0.1.1.89

- refina tipografia e proporções da Home mantendo a densidade da 0.1.1.88;
- aumenta escudos da Próxima Partida, informações do estádio, data/hora e faixa Dia de jogo/Preparação;
- aumenta títulos de Finanças, atalhos, Notícias, classificação e artilheiros;
- remove os rodapés Ver tabela/Ver ranking e torna os cards de classificação e artilharia acionáveis;
- passa a mostrar até quatro notícias e adiciona Últimas Partidas com dados de `matchHistory` quando existe espaço vertical suficiente;
- atalhos podem exibir ponto de atenção apenas para condições reais existentes no estado da carreira;
- preserva `CareerState` schema 13, IDs, saves, calendário multi-competição, CPU, mercado, contratos e Match Engine.

Consulte `docs/RELEASE_0.1.1.89.md`.

## Estado funcional da release 0.1.1.88

- refina a densidade visual da Home sem sacrificar legibilidade;
- move Avançar/Jogar para o centro da faixa de informações da Próxima Partida, substituindo o horário duplicado;
- aumenta tipografia de próximo jogo, atalhos, notícias, classificação e artilheiros;
- remove escudos da tabela ultracompacta e equilibra a altura do bloco Notícias / Série A / Artilheiros;
- preserva `CareerState` schema 13, IDs, saves, calendário multi-competição, CPU, mercado, contratos e Match Engine.

Consulte `docs/RELEASE_0.1.1.88.md`.

## Estado funcional da release 0.1.1.87

- corrige a única falha do GitHub Actions da 0.1.1.86 depois de `flutter analyze` passar e 270 de 271 testes serem aprovados;
- atualiza `calendar_and_standings_ui_test.dart` para procurar o rótulo compacto atual `PREPARAÇÃO • ...`, em vez do texto antigo `PREPARAÇÃO EM ANDAMENTO`;
- não altera código funcional da Home, partida, saves, IDs, fundação multi-competição ou Match Engine.

Consulte `docs/RELEASE_0.1.1.87.md`.

## Estado funcional da release 0.1.1.86

- corrige o único erro `undefined_identifier` do GitHub Actions da 0.1.1.85 em `test/live_substitution_pause_test.dart`;
- usa string raw na expectativa que valida o texto dinâmico `Confirmar ${plannedChanges.length} trocas`, evitando que o próprio teste tente resolver `plannedChanges`;
- não altera código funcional da partida, fluxo de substituições, Home, saves, IDs, fundação multi-competição ou Match Engine.

Consulte `docs/RELEASE_0.1.1.86.md`.

## Estado funcional da release 0.1.1.85

- compacta a Home para reduzir rolagem e aproximar proporções da referência enviada pelo usuário;
- reduz cabeçalho, finanças, próxima partida, preparação e atalhos sem alterar os dados exibidos;
- move Avançar para o canto superior direito da Próxima Partida;
- reorganiza Confiança da Diretoria para porcentagem primeiro e estádio depois, removendo a foto do estádio;
- passa a compor Notícias, classificação e artilheiros na mesma linha em larguras compatíveis, com modo ultracompacto da tabela;
- usa melhor as cores reais do clube no quadro do escudo e preserva `CareerState` schema 13, saves, IDs, multi-competição, CPU, mercado, contratos e Match Engine.

Consulte `docs/RELEASE_0.1.1.85.md`.

## Estado funcional da release 0.1.1.84

- melhora o fluxo da janela de substituições: a escolha de uma troca não fecha mais o sheet;
- permite preparar várias trocas, revisar/remover o lote e aplicar somente ao tocar em `Confirmar trocas`;
- adiciona `substituteMany` ao `LiveMatchController`, validando o lote completo antes de modificar a sessão e ressimulando apenas uma vez;
- várias trocas confirmadas juntas permanecem no mesmo minuto e consomem uma única janela;
- cancelar o sheet não aplica nenhuma troca preparada;
- preserva cinco substituições, três janelas, intervalo sem consumir janela, Match Engine, Flame somente visual, `CareerState` schema 13, saves, IDs e multi-competição.

Consulte `docs/RELEASE_0.1.1.84.md`.

## Estado funcional da release 0.1.1.83

- completa a regra de substituições da partida ao vivo com cinco jogadores no máximo e três janelas durante o tempo regulamentar;
- várias trocas feitas no mesmo minuto usam a mesma janela e o intervalo não consome uma janela, embora continue contando no limite de cinco jogadores;
- centraliza a regra em `lib/game/match/live_substitution_rules.dart`, com `LiveMatchController` mantendo a aplicação e a UI apenas antecipando/exibindo o estado;
- substitui o teste puramente textual por regressões funcionais da regra e mantém o bloqueio de retorno de jogador já substituído;
- preserva `CareerState` schema 13, IDs, saves, calendário multi-competição, CPU, mercado, contratos, finanças e o Match Engine de simulação.

Consulte `docs/RELEASE_0.1.1.83.md`.

## Estado funcional da release 0.1.1.82

- corrige a única falha restante do GitHub Actions da 0.1.1.81: 266 testes passaram e apenas a expectativa estrutural de `Departamento\nMédico` falhou;
- usa string raw para comparar literalmente o escape `\n` presente no código Flutter, sem modificar o rótulo ou a UI;
- preserva integralmente layout, assets WebP, `CareerState` schema 13, IDs, saves, fundação multi-competição, CPU, mercado, contratos, finanças e Match Engine.

Consulte `docs/RELEASE_0.1.1.82.md`.

## Estado funcional da release 0.1.1.81

- corrige a causa real dos 33 erros do `flutter analyze` da 0.1.1.80: faltava fechar `_HomeBackdrop` antes das classes `_DayAdvanceTransition` e `_UnemployedHome`;
- adiciona regressão estrutural em `calendar_and_standings_ui_test.dart` para proteger esse fechamento;
- preserva integralmente o layout visual da Home 0.1.1.80 e seus dois assets WebP;
- não altera `CareerState` schema 13, IDs, saves, calendário multi-competição, CPU, mercado, contratos, finanças ou Match Engine.

Consulte `docs/RELEASE_0.1.1.81.md`.

## Estado funcional da release 0.1.1.80

- refina a Home recém-reformulada para deixá-la mais integrada visualmente sem mexer nas regras da carreira;
- adiciona um backdrop próprio para a Home e enquadra atalhos, notícias, classificação e artilharia dentro de um bloco inferior mais coeso;
- substitui o carrossel de notícias por uma lista compacta para aproximar mais conteúdo do primeiro enquadramento;
- reorganiza a visão principal aproximando Confiança da Diretoria e Panorama da Temporada, além de reforçar acessos de tabela e ranking;
- preserva `CareerState` schema 13, IDs, saves, calendário multi-competição, CPU, mercado, contratos, finanças e Match Engine.

Consulte `docs/RELEASE_0.1.1.80.md`.

## Estado funcional da release 0.1.1.79

- reformula visualmente a Home seguindo a referência aprovada, mantendo todos os valores exibidos ligados aos dados reais do save;
- adiciona fundos originais de estádio para Próxima Partida e card do estádio, otimizados em WebP;
- reorganiza cabeçalho, cards financeiros, partida, confiança da diretoria, panorama da temporada e avanço;
- conecta o Panorama da Temporada à classificação existente, corrigindo o chevron que antes aparentava interação sem ação;
- separa componentes visuais da Home em arquivos menores sem criar arquitetura paralela;
- preserva `CareerState` schema 13, IDs, saves, calendário multi-competição, CPU, mercado, contratos e Match Engine.

Consulte `docs/RELEASE_0.1.1.79.md`.

## Estado funcional da release 0.1.1.78

- corrige o bloqueio de virada de temporada visto no GitHub Actions da 0.1.1.77: `CareerState.seasonComplete` passa a verificar os fixtures efetivamente disputados de cada competição carregada, evitando depender de um flag `completed` persistido que pode estar desatualizado em fluxos legados;
- mantém `CompetitionSeasonState.completed` como fallback apenas para competições carregadas sem fixtures persistidos;
- atualiza `match_participation_fatigue_test.dart` para validar a arquitetura atual: `LiveMatchController` monta participantes e delega a aplicação física/estatística ao `MatchCareerImpactEngine`;
- preserva `CareerState` schema 13, IDs, saves, calendário multi-competição, CPU, classificação e Match Engine.

Consulte `docs/RELEASE_0.1.1.78.md`.

## Estado funcional da release 0.1.1.77

- corrige os dois erros `map_value_type_not_assignable` / `argument_type_not_assignable` revelados pelo GitHub Actions da 0.1.1.76;
- `CompetitionStateEngine` passa a declarar explicitamente `List<Standing>` no caminho de competição sem tabela, eliminando a inferência `List<dynamic>`;
- adiciona regressão para competição sem classificação, sem mudar `CareerState` schema 13, IDs, saves, calendário multi-competição ou Match Engine.

Consulte `docs/RELEASE_0.1.1.77.md`.

## Estado funcional da release 0.1.1.76

- evolui `CareerState` para schema 13 com `CompetitionSeasonState` independente por `competitionId`;
- mantém fixtures em um calendário global conciliado, permitindo o mesmo clube em liga, estadual e copa sem duplicar elenco ou Match Engine;
- separa classificação, estatísticas e disciplina por competição e mantém `standings`/`roundIndex` legados como espelho da competição principal;
- adiciona metadados de fase/grupo/confronto/ida-volta em `MatchFixture` e preserva os IDs históricos da Série A;
- jogos CPU de todas as competições carregadas avançam pela data correta; `full` continua no Match Engine e `background` no resolvedor estatístico leve;
- o Match Engine não foi refatorado desnecessariamente: ele já devolve `MatchResult` sem conhecer `CareerState`, tabela ou persistência;
- o catálogo passa a suportar futuramente torneios internacionais fora da hierarquia de um país, sem cadastrar competições fictícias nesta release;
- corrige o erro real do GitHub Actions em `league_selection_step.dart` (`AppColors.text` inexistente) e o lint correspondente do teste;
- migrações de identidade alcançam também participantes e classificações persistidas dentro de fases/grupos.

Consulte `docs/MULTI_COMPETITION_FOUNDATION.md` e `docs/RELEASE_0.1.1.76.md`.

## Estado funcional da release 0.1.1.75

### Seleção de ligas e carregamento por save

- `CareerLeagueSetup` (schema 12) persiste `full`, `background` e `unloaded` por `competitionId`; a competição do clube do usuário é sempre `full`.
- A criação usa `CareerLeaguePlanner` e `LeagueSelectionStep`; presets trabalham somente com `CompetitionCatalog`, sem dados fictícios.
- `CareerFactory` materializa apenas clubes de competições carregadas. A Série A atual continua completa e com 38 rodadas derivadas do calendário.
- `CpuFixtureResolver` mantém `MatchEngine.simulate` para ligas completas e usa `BackgroundFixtureResolver` apenas em competição explicitamente `background`; Flame continua visual.
- SQLite v3 adiciona resumo de save e `listSaves()` não seleciona `payload`; migração v2 -> v3 preserva o JSON original e preenche metadados derivados.
- Alterar ligas depois de iniciar a carreira continua desabilitado até existir política segura de reconstrução de calendário/tabela/estatísticas.
- Detalhes técnicos: `docs/LEAGUE_LOADING.md`.


- remove integralmente a música padrão anterior (`football.mp3` e `menu_01.m4a` a `menu_05.m4a`) e passa a usar somente as 11 faixas OGG fornecidas para o projeto;
- mantém `AudioManager` como único player e adiciona estado de faixa atual, seleção manual e comando de próxima música, preservando shuffle/loop e playlist personalizada;
- extrai a interface navegável da playlist para `menu_music_player_card.dart`, evitando ampliar ainda mais `audio_settings_screen.dart`;
- reorganiza `career_arrival_screen.dart` para integrar melhor a matéria ao azul-grafite e eliminar o grande vazio entre conteúdo e botão, preservando dados reais da carreira e a flag de primeira entrada;
- atualiza testes de áudio/onboarding e impede `tool/generate_audio_assets.py` de recriar a playlist M4A antiga;
- a evolução de áudio herdada da 0.1.1.74 continua preservada; a 0.1.1.75 eleva o estado atual para `CareerState` schema 12 e SQLite v3, mantendo IDs, saves, controllers e o Match Engine único.

## Estado funcional da release 0.1.1.73

- corrige o único teste estrutural restante mostrado pelo GitHub Actions da 0.1.1.72, depois de 245 testes já terem passado;
- atualiza `editor_experience_test.dart` para acompanhar a modularização atual do editor, validando navegação no arquivo principal, `_save`/`showEditorNotice` em `club_editor_import_actions.dart` e o `AlertDialog` central em `editor_feedback_dialog.dart`;
- não reintroduz `_showSaveConfirmation`, não altera código funcional, UI, `CareerState` schema 11, SQLite v2, IDs, saves ou Match Engine.

## Estado funcional da release 0.1.1.72

- corrige os nove warnings `invalid_use_of_protected_member` apontados pelo `flutter analyze` no GitHub Actions da 0.1.1.71;
- mantém `club_editor_import_actions.dart` separado, mas remove chamadas diretas ao `State.setState` de dentro da extension;
- adiciona `_updateEditorState` em `_ClubEditorScreenState`, fazendo a mutação de estado ocorrer novamente dentro de um membro válido da subclasse de `State`;
- preserva integralmente UI, importação/restauração/salvamento, `CareerState` schema 11, SQLite v2, IDs, saves e Match Engine.

## Estado funcional da release 0.1.1.71

- Central de Carreiras remove o botão Continuar e a edição por save; cada save é um card acionável com escudo, colocação atual, próximo jogo e lixeira direta com confirmação personalizada;
- cabeçalho inicial usa logo arredondada, subtítulo `Carregar jogo salvo` e rodapé `Tática Manager Beta 2.0` ligado à Central de Diagnóstico;
- técnicos que não possuem aparência própria recebem identidade visual determinística baseada no perfil/ID, evitando faces idênticas sem adicionar campos obrigatórios ao save;
- Central de Edição passa a se chamar `Editar dados do jogo`, mantém clubes em tela própria, inclui tutorial interno, ações compactas para pacote/Padrão/escudos e confirmações antes de restaurações;
- feedback de importação/salvamento deixa o snackbar claro no rodapé e usa diálogo central personalizado; confirmações de pacote usam margem lateral mínima;
- editor de técnicos reorganiza ações, coloca `Exportar dados` e `Padrão` lado a lado e exige confirmação para restaurar a base;
- Configurações exibe quatro modelos de bola diretamente na tela e o preview compartilha o mesmo renderer visual usado durante a partida;
- Central de Diagnóstico passa a organizar erros, contexto/origem e stack trace e registra também falhas capturadas de abertura/criação/exclusão de carreira e operações do editor;
- arquivos grandes de edição foram separados em componentes/parts menores, preservando arquitetura, `CareerState` schema 11, SQLite v2, IDs, saves, Match Engine e Flame somente visual.


## Estado funcional da release 0.1.1.70

- corrige os dois testes estruturais que falharam no GitHub Actions da 0.1.1.69, depois de 238 testes já terem passado;
- atualiza o teste do editor de aparência para o agrupamento atual `TRAÇOS DO ROSTO`, mantendo verificações de Olhos, Sobrancelhas, recorte horizontal e zoom;
- atualiza o teste da Central de Carreiras para acompanhar `career_hub_screen.dart`, `career_hub_info_links.dart` e `club_editor_screen.dart`, preservando editor padrão e por save;
- não altera código funcional, visual, CareerState schema 11, saves, IDs, controllers ou Match Engine.

## Estado funcional da release 0.1.1.69

- troca a base quase preta do aplicativo por azul-grafite em camadas e mantém o verde como acento, incluindo a Home para evitar áreas ainda excessivamente escuras;
- compacta os cards de formação e clubes, amplia a presença dos escudos e remove pesquisa/filtros da seleção de técnicos;
- reorganiza aparência do técnico em grupos reutilizáveis, remodela a assinatura do contrato e adiciona apresentação editorial da chegada com dados reais da carreira;
- adiciona aceite inicial de Termos de Uso, Política de Privacidade interna e links de Sobre/Como funciona/Termos/Privacidade/Edição/Configurações na Central de Carreiras;
- reduz a duração visual para 1, 2 ou 3 minutos por tempo, com escolha durante a criação e migração de leitura dos presets antigos 4/6/8 para 1/2/3;
- usa `app_meta` já existente para preferências globais, aceite legal e flag da apresentação, sem alterar o banco SQLite v2 nem o `CareerState` schema 11;
- preserva IDs persistentes, saves existentes, controllers e Match Engine; Flame continua apenas representando a partida.

## Estado funcional da release 0.1.1.68

- corrige o único lint `use_null_aware_elements` do GitHub Actions em `management_dashboard_widgets.dart`, usando o elemento null-aware `?trailing` exigido pelo Dart atual;
- revisa preventivamente a etapa de testes e restaura `AppInfo.recentReleases` para exatamente três itens, conforme protegido por `app_info_test.dart`;
- não altera visual, navegação, gameplay, `CareerState` schema 11, IDs, saves ou Match Engine.

## Estado funcional da release 0.1.1.67

- corrige o erro `dot_shorthand_undefined_member` em `LiveMatchController`, removendo um `.where` duplicado e solto após a contagem de substituições;
- importa explicitamente `formation.dart` e `tactic.dart` no Dia de Jogo para disponibilizar `FormationTypeX.label` e `PressingX.label`;
- remove o import não utilizado do domínio financeiro e a variável local `budget` sem uso, eliminando os dois warnings restantes do log;
- não altera o visual da 0.1.1.66, regras de gameplay, `CareerState` schema 11, IDs, saves ou Match Engine.

## Estado funcional da release 0.1.1.66

- audita a reformulação visual da 0.1.1.65 e diferencia melhor conteúdo informativo de conteúdo acionável;
- Dia de Jogo liga posição, forma, moral, condição, pressão e formação aos módulos já existentes; o estádio do confronto também abre a tela correspondente;
- Contratos permite filtrar tocando no resumo e os cards da Base abrem o perfil do jogador por toda a área útil;
- Finanças conecta Estádio, folha salarial/Contratos e Transferências/Mercado, remove o efeito de card dentro de card em Patrocínios e dá retorno visível ao Mercado quando aberto como módulo secundário;
- tema/AppBar e acentos de clubes muito escuros recebem tratamento de contraste; o Estádio corrige o texto sobre a cena e alinha a disponibilidade das obras ao menor valor entre orçamento reservado e caixa atual;
- preserva `CareerState` schema 11, IDs persistentes, saves, controllers e Match Engine; nenhuma regra foi movida para Flame.

## Estado funcional da release 0.1.1.65

- reformula visualmente Contratos, Categoria de Base, Departamento Médico, Estádio, Dia de Jogo e Finanças usando somente dados e ações já implementados;
- separa os novos painéis em componentes reutilizáveis, evitando concentrar centenas de linhas adicionais nas telas principais;
- deixa o Estádio mais vivo com cena noturna animada em `CustomPaint`, iluminação, arquibancadas, gramado e densidade visual vinculada aos níveis reais da infraestrutura, sem mover regras para a UI;
- corrige substituições ilimitadas: `LiveMatchController` impõe cinco trocas por partida e bloqueia o retorno de jogador já substituído; `MatchScreen` e o sheet exibem/antecipam o limite;
- preserva `CareerState` schema 11, IDs persistentes, saves, engines existentes e Flame apenas como representação da partida.

## Estado funcional da release 0.1.1.64

- corrige os três erros de análise estática do editor de escudos, disponibilizando `ClubIconValidator`, `base64Encode` e `base64Decode` para os arquivos `part` da Central de Edição;
- preserva integralmente o importador de packs, `iconBase64`, CareerState schema 11, IDs, saves, Match Engine e workflow.

## Estado funcional da release 0.1.1.63

- Home substitui os quatro indicadores esportivos por saldo, orçamento de transferências, receitas e despesas do mês usando os dados financeiros existentes;
- cabeçalho mantém apenas o e-mail ao lado do técnico; preparação passa para o card do próximo jogo e o botão externo fica somente como Avançar/Abrir partida;
- confiança usa informações reais do estádio no lugar da forma recente; classificação e artilheiros ficam compactos/lado a lado quando há largura; Notícias & Destaques ganha tela própria;
- pacote completo `.tmpack`/`.tmclubs` deixa explícita a importação conjunta de clubes, jogadores, técnicos e escudos por IDs permanentes; o pack somente de escudos continua disponível;
- áudio da partida encerra efeitos, ambiente e narração no fim/saída e `MatchScreen.dispose` não consulta mais `ref`, reduzindo risco de chiado residual;
- preserva CareerState schema 11, IDs, saves e Match Engine.

## Estado funcional da release 0.1.1.62

- adiciona pack separado de escudos `tatica-manager-logos` v1, importável em `.tmlogos`/JSON pela Central de Edição;
- cada escudo é associado exclusivamente ao `Club.id` permanente, com suporte a packs parciais e prévia antes da aplicação;
- reutiliza `ClubIconValidator` e altera somente `iconBase64`, preservando nomes, elencos, técnicos, estádio, uniformes, schema 11, saves e Match Engine.

## Estado funcional da release 0.1.1.61

- alinha três testes estruturais revelados pelo GitHub Actions ao estado funcional atual, sem alterar produção;
- criação do técnico valida `País`, Finanças valida `Salários`/`Patrocínios` e a Home valida avatares nos widgets modulares;
- preserva CareerState schema 11, saves, IDs, Match Engine e workflow sem alterações.

## Estado funcional da release 0.1.1.60

- corrige os dois warnings `unused_element_parameter` introduzidos pela Home premium, removendo parâmetros `padding` nunca utilizados em Notícias e Rankings;
- preserva exatamente o layout da Home 0.1.1.59, seus dados reais, atalhos e responsividade;
- mantém CareerState schema 11, saves, IDs, Match Engine e workflow sem alterações.

## Estado funcional da release 0.1.1.59

- remodela a Home seguindo a referência premium com cabeçalho de clube/técnico, quatro indicadores, próxima partida, confiança/forma, faixa de avanço, notícias, classificação e artilheiros;
- todos os cards usam dados reais já existentes na carreira e preservam atalhos/rotas anteriores;
- separa a nova composição em widgets de Home menores, sem controller novo ou regra de negócio paralela;
- mantém CareerState schema 11, saves, IDs, Match Engine e workflow.

## Estado funcional da release 0.1.1.58

- remove o import redundante de `dart:ui` em `diagnostic_service.dart` que fazia o `flutter analyze` falhar no GitHub Actions;
- preserva o funcionamento da Central de Diagnóstico, áudio, saves, schema 11, Match Engine e workflow.

## Estado funcional da release 0.1.1.57

- corrige o `argument_type_not_assignable` apontado pelo GitHub Actions em `AudioFileStore`, mantendo cópia sequencial em chunks e sem materializar músicas inteiras em memória;
- atualiza o repositório oficial em README, handoff, prompt de continuação, documentação histórica e metadados para `https://github.com/adriedsonlemoz/Tatica-Manager`;
- preserva `CareerState` schema 11, saves, IDs, Match Engine e workflow atual.

## Estado funcional da release 0.1.1.56

- remove feedback tátil de interface, navegação, cards e eventos normais; somente gol/contra pode vibrar, respeitando `GameSettings.haptics`;
- antecipa a leitura das preferências de áudio durante o splash e serializa o carregamento da playlist no `AudioManager` singleton;
- remodela Finanças com resumo, receitas/despesas, evolução do saldo e seções expansíveis usando os dados financeiros já persistidos;
- criação de carreira passa a começar por `Escolha seu técnico`, sem exigir cidade/estado;
- `ManagerProfile` ganha ID estável e campos profissionais, e `ClubIdentityPack` v3 passa a transportar técnicos no mesmo formato do editor;
- Central de Edição recebe Técnicos com criar/editar/importar/exportar/restaurar, reutilizando aparência e foto existentes;
- `CareerState` passa ao schema 11 e migra saves schema 10 gerando banco de técnicos sem trocar IDs de clube/jogador, sem alterar Match Engine.

## Estado funcional da release 0.1.1.54

- importação múltipla de músicas passa a copiar cada arquivo sequencialmente por stream, sem acumular bytes completos em memória;
- tela de áudio preserva o `GameController` enquanto montada e não usa `ref` durante `dispose`;
- adiciona Central de Diagnóstico persistente com erros Flutter/Dart, checkpoints, última saída Android, crash nativo e exportação TXT;
- mantém schema 10, IDs persistidos, saves, Match Engine e workflow de CI.

## Estado funcional da release 0.1.1.53

- atualiza somente dois testes antigos da Caixa de Entrada que ignoravam as propostas comerciais iniciais;
- idempotência e tombstone passam a localizar a mensagem testada por ID e preservam as três mensagens legítimas de patrocinadores;
- não altera código funcional, Match Engine, schema 10 ou saves da 0.1.1.52.

## Estado funcional da release 0.1.1.52

- corrige os dois erros `undefined_method` do GitHub Actions restaurando o import do `MatchPhasePanel` já existente;
- elimina o lint `prefer_if_null_operators` de `Stadium.copyWith` sem mudar resultado;
- preserva integralmente a transmissão, Match Engine, schema 10 e saves da 0.1.1.51.

## Estado funcional da release 0.1.1.51

- câmera 2D suave acompanha bola/timeline com recentralização gradual, zoom contextual e a mesma perspectiva em replay;
- campo e atores recebem profundidade leve, sombras, vinheta, pulso do protagonista e trajetórias discretas;
- controles principais são Pausar, Simular, Tática, Trocar e Áudio; duração visual pode ser 4, 6 ou 8 minutos;
- simulação apenas avança a timeline já calculada; outros jogos usam o Match Engine existente uma vez e acompanham o mesmo minuto;
- narração inicia filtrada em lances importantes e oferece Todos, Importantes e Meu time;
- áudio limpo, cooldown, ambiente baixo e ducking reduzem sobreposição; narração falada continua desligada por padrão;
- `CareerState` permanece no schema 10 e os novos campos possuem fallback retrocompatível.

## Estado funcional da release 0.1.1.50

- seis orçamentos departamentais persistidos, limitados pelo caixa e reiniciados ao trocar de clube/temporada;
- Estádio com nome/ingresso editáveis, demanda por preço, obras reais, negociação, arquibancadas e áreas desbloqueáveis;
- propostas comerciais com valor, duração, bônus, objetivo, condições, expiração, aceite, recusa e contraproposta;
- naming rights altera o nome visível sem perder o original; Caixa de Entrada abre Finanças;
- `CareerState` schema 10 lê saves schema 9 sem alterar IDs, transferências ou Match Engine.

## Estado funcional da release 0.1.1.49

- a playlist padrão atual usa 5 faixas OGG navegáveis no mesmo `AudioManager`; `somdenavegamenu.mp3` permanece como som de toque/navegação;
- novas preferências iniciam em 1x e com narração desligada; vibração reage na apresentação a eventos como trave, gol e cartões;
- aviso de validação da carreira é central/temático; bola possui quatro estilos e movimento ocioso discreto;
- editor do técnico mantém prévia fixa e aceita foto normalizada; Clubes usa País > Campeonato > Série > Clubes;
- Contratos mostra foto e oferece atalhos -10%, pedido, +10% e +20%; zonas da classificação ficam no rodapé;
- preserva schema 9, IDs, saves antigos, separação de controladores e Match Engine.

## Estado funcional da release 0.1.1.48

- atualiza `player_avatar_identity_test.dart` para validar a composição modular atual da Central de Mercado (`market_screen.dart` + `market_components.dart` + `PlayerAvatar`);
- atualiza `transfer_ui_structure_test.dart` para validar `showIncomingTransferOfferDialog` na Home e em Propostas recebidas, em vez de textos literais removidos pela modularização;
- não altera código funcional, UI, schema 9, saves, IDs, regras de transferência ou Match Engine.

## Estado funcional da release 0.1.1.47

- release corretiva do CI: escapa `R$` nas strings constantes dos filtros do Mercado;
- adiciona import explícito de `ManagerCareerHistoryEntry` no `ManagerCareerEngine`;
- normaliza a receita de hospitalidade do Estádio para `int`;
- preserva integralmente o schema 9, saves, IDs e todas as funcionalidades da 0.1.1.46.

## Estado funcional da release 0.1.1.46

- Central de Mercado com cinco áreas (Buscar, Observação, Negociações, Propostas recebidas e Histórico), scouting progressivo e negociação persistente por dias;
- parcelas de transferências negociadas comprometem o orçamento total, pagam entrada na assinatura e liquidam obrigações futuras pelo avanço da carreira;
- Categoria de Base persistente com promoção preservando `Player.id`; Departamento Médico usa lesão/condição/fadiga reais do jogador;
- Caixa de Entrada persistente deriva eventos da carreira sem duplicá-los e mantém referências acionáveis para jogador, clube, partida, proposta e negociação;
- Home, classificação, perfil de clube, calendário e estatísticas compartilham navegação e exibem informações mais completas;
- `CareerState` está no schema 9; campos novos possuem fallback vazio para saves schema 8, sem reescrever IDs persistidos;
- escudos personalizados são renderizados com proporção preservada e fundo neutro/transparente, sem aplicar a cor do clube atrás da imagem.

- preparação mostra os titulares antes dos indisponíveis e reutiliza `LineupEngine.autoSelect` para sugerir a melhor equipe;
- a Home possui transição curta ao avançar o dia e abre `MatchDayPresentationScreen` ao alcançar uma partida;
- `LeagueEngine` usa cadência configurável entre rodadas, com `competitionId` e horário persistidos no `MatchFixture`;
- Escalação usa campo mais alto, banco agrupado por setor e área separada de inelegíveis;
- substituição ao vivo mantém o relógio pausado até a escolha voltar da sheet e ser aplicada pelo `LiveMatchController`, que re-simula o restante pelo Match Engine;
- `CareerState.currentSchemaVersion = 8` e `ManagerCareerState` persiste passagens, emprego/desemprego e propostas com fallback para saves antigos;
- `ManagerCareerEngine` concentra reputação, vagas e mudanças de clube; `LeagueCatchUpEngine` resolve rodadas que ficaram no passado durante período sem clube.

## Regra número 1: não recomeçar nem converter novamente

Este projeto já foi refeito do zero em Flutter. Não voltar para React/Capacitor e não iniciar um novo projeto paralelo. Continue sobre a arquitetura existente.

Antes de alterar qualquer arquivo:

1. Leia este documento.
2. Leia `README.md`.
3. Leia `docs/PROMPT_CONTINUACAO_IA.md`.
4. Leia as documentações específicas em `docs/` relacionadas à área que será modificada.
5. Inspecione o código atual antes de propor refatoração.

## Arquitetura atual

A lógica do jogo é separada da interface. Flutter não deve conter regras de negócio importantes dentro das telas, e Flame não deve decidir o resultado da partida.

```text
lib/
├── app/
│   ├── state/
│   │   ├── career_controller.dart
│   │   ├── game_controller.dart
│   │   ├── live_match_controller.dart
│   │   ├── transfer_controller.dart
│   │   └── providers.dart
│   └── widgets/
├── core/
│   ├── database/
│   ├── platform/
│   ├── save/
│   ├── theme/
│   └── utils/
├── data/
├── domain/
├── features/
├── game/
│   ├── career/
│   ├── club/
│   ├── contract/
│   ├── cpu/
│   ├── finance/
│   ├── league/
│   ├── lineup/
│   ├── match/
│   ├── morale/
│   ├── player/
│   ├── season/
│   └── transfer/
└── main.dart
```

### Controladores

- `CareerController`: listar, criar, abrir e excluir carreiras/saves; carregar/salvar pacotes de identidade e coordenar migração de IDs legados ao acessar saves.
- `GameController`: sessão da carreira ativa, escalação, tática, persistência consolidada e virada de temporada.
- `LiveMatchController`: partida atual, alterações ao vivo, substituições, conclusão da rodada e consequências pós-jogo.
- `TransferController`: compra, venda, renovação e coordenação com finanças/contratos.

Evite transformar novamente `GameController` em um controlador gigante.

### Match Engine

O antigo motor monolítico já foi dividido. Preserve essa separação:

```text
lib/game/match/engine/
├── match_engine.dart
├── match_strength_calculator.dart
├── match_probability_calculator.dart
├── match_player_selector.dart
├── match_event_generator.dart
├── match_timeline_generator.dart
├── match_statistics_calculator.dart
└── match_trajectory_generator.dart
```

`match_engine.dart` deve permanecer principalmente como orquestrador.

## Fluxo de carreira atual

Fluxo desejado:

```text
Splash/Bootstrap
→ Central de Carreiras (editar/importar banco completo opcional)
→ Nova carreira
→ Perfil/origem do técnico
→ Competição e clube
→ Formação
→ Mentalidade, pressão e ritmo
→ Assinatura visual do contrato
→ Home da carreira
```

A Central de Carreiras suporta múltiplos saves. Não reintroduzir um único save global fixo. O banco padrão pode ser editado/importado antes de criar a carreira; cada save também possui edição isolada pelo menu **Editar banco da carreira**.

A criação usa quatro etapas: perfil/origem, competição/clube, formação/mentalidade e pressão/ritmo. Uniformes, estádio, escudo e jogadores são dados editáveis do banco e não devem carregar lógica da partida.

## Pontos já corrigidos recentemente

- `0.1.1.44`: corrige a expulsão por segundo amarelo dentro do Match Engine, impede participação/substituição posterior, substitui os principais sons e navegação, deixa música desligada por padrão e evolui Classificação, Finanças, patrocinadores e Estádio com campos retrocompatíveis.
- `0.1.1.43`: atualiza o teste de integração visual de avatares para a composição atual `SquadScreen → PlayerCard → PlayerAvatar`; a UI e a lógica permanecem inalteradas.
- `0.1.1.42`: corrige o import de `PlayerPositionX` em `lineup_pitch.dart`, removendo o bloqueio de `flutter analyze` da tela de Escalação sem mudança funcional.

Na linha `0.1.1.x` foram tratados:

- sobreposição do botão **Começar carreira** sobre o texto inferior;
- conteúdo coberto pela navegação inferior;
- tela visual de assinatura do contrato antes de entrar na carreira;
- reforço de fullscreen/immersive no Android;
- fluxo de negociação com valor mínimo e contraproposta;
- impacto financeiro de transferências e salário mensal;
- manifesto previsível para o AL Sistemas;
- versionamento sincronizado entre release, Android, ZIP e CI;
- modularização do `GameController` e do `MatchEngine`;
- calendário diário persistido no save e preparação pré-jogo;
- indisponibilidade por lesão, suspensão e baixa condição;
- primeiro tempo, intervalo, segundo tempo e resumo pós-jogo ampliado;
- Sobre / Novidades, contato e apoio via Pix nas Configurações.
- novo ícone oficial com Adaptive Icon Android e catálogo AppIcon iOS;
- correção do build release com Java/Kotlin alinhados em JVM 17;
- venda pelo Elenco refeita como proposta da CPU com confirmação e valores formatados;
- compra e renovação em diálogos centralizados, sem feedback preso ao rodapé;
- histórico de temporadas e revisão antes da virada de ano;
- GitHub Actions publica somente o APK versionado; `pubspec.lock` não é disponibilizado como Artifact.
- calendário mensal, notícias diárias, janelas de transferências, alertas de contratos e eventos de partida mais claros.
- ciclo de vida de contratos centralizado, com vencimento idempotente, jogadores livres sem duplicação e reconciliação ao abrir saves.
- clubes padrão fictícios com IDs neutros permanentes; editor completo de clube/estádio/uniformes/ícone/jogadores; importação comunitária v2.
- migração automática dos IDs legados de clubes em saves antigos, preservando IDs de jogadores e referências da carreira.
- banco comunitário v2 com estádio, três uniformes, ícone, elencos, jogadores livres e edição detalhada de atletas; `tatica-manager-players` v1 importa elencos isolados; estado transitório da carreira é preservado ao editar saves.
- criação de carreira reorganizada em componentes menores, com seleção em duas colunas no caminho Países > Brasil > Liga > Série A > Clubes; cards exibem escudo, nome, overall calculado sobre os 18 melhores atletas, estrelas e orçamento.
- perfil do técnico ampliado com apelido, idade inicial, nacionalidade e local de nascimento; `managerHistory` registra um retrato por temporada e a idade progride de forma derivada.
- importação de escudos reforçada com PNG/JPG/WebP, até 256 KiB, dimensões de 32 a 1024 px e proporção máxima 2:1; validação existe na UI e no engine.
- correção dos cinco lints que bloqueavam `flutter analyze` no CI da 0.1.1.14; parâmetros descartados usam wildcards e acesso nullable foi simplificado.
- correção dos seis erros de análise estática da 0.1.1.17 em `editor_experience_test.dart`: strings com `R$` usam raw string e ASCII usa `ascii.encode` de `dart:convert`.
- correção do lint restante da 0.1.1.18 em `editor_experience_test.dart`: removido import redundante de `dart:typed_data`, já coberto por `package:flutter/services.dart`.
- correção do único teste restante da 0.1.1.19: o diálogo de escudo volta a exibir explicitamente `32–1024 px`, alinhado ao validador e ao teste de UI.
- mercado CPU orientado por carências de posição, com agentes livres e transferências entre CPUs usando os mesmos TransferEngine/ContractEngine e sem movimentar automaticamente atletas do clube do usuário.
- mercado CPU ampliado com notícias em CareerEvent, venda estratégica, concorrência por alvos e proteção de caixa/folha sem alterar GameController ou schema do save.
- propostas recebidas da CPU pelo elenco do usuário são acionáveis no mesmo `CareerEvent`: aceitar, recusar e contrapropor; nenhuma venda do usuário ocorre sem aceite explícito.
- o mercado usa a lista de clubes da carreira e IDs opacos, sem depender de prefixo `br-club-*`, Série A ou quantidade fixa de 20 clubes; regras específicas de competição devem entrar pela camada de competições quando forem implementadas.
- correção dos três lints `unnecessary_non_null_assertion` apontados pelo GitHub Actions da 0.1.1.24 em `cpu_market_test.dart`, sem mudança na lógica do mercado.
- correção dos oito testes revelados após o analyzer da 0.1.1.26 passar: fixtures de propostas agora usam comprador compatível com o atleta, preservando o teto salarial; notícias priorizam contratação de destaque quando há overall elevado.
- identidade visual inicial dos jogadores com `PlayerAvatarIdentity` determinístico por `Player.id` e `PlayerAvatar` reutilizável; Elenco, Perfil, Mercado, negociações e notícias exibem rostos sem alterar saves, GameController, mercado ou Match Engine.
- partida ao vivo modernizada com HUD/placar compacto fora da rolagem, narração contínua e notificações para todos os `MatchEventType`, substituições com avatares, cinco ajustes táticos acessíveis e `MatchPitchGame` enfileirando/representando trajetórias sem conhecer o Match Engine ou usar `Random`.
- campo 2D horizontal em proporção 105:68 dentro do modo retrato; `MatchPitchGame` converte apenas a representação `x=1-y / y=x`, deixando coordenadas, timeline e regras do Match Engine intactas.
- a partida 2D avançada agora inclui mergulho visual do goleiro, comemorações em grupo, pênalti com preparação específica, bola na trave como evento real do Match Engine, replay de trave/pênalti defendido, transições de intervalo/fim e estádio/torcida animados; Flame continua apenas encenando a timeline.
- sistema de áudio modular em `app/audio` + `core/audio`, com 5 faixas OGG de menu, faixa atual/seleção/próxima música, efeitos de interface e partida, controles independentes, suporte a arquivos do aparelho e resolução de efeitos por `MatchEvent`; o Match Engine não conhece nem dispara áudio.
- narração falada opcional por TTS do aparelho em `MatchNarrationService`, com volume próprio e frases derivadas apenas dos eventos relevantes; posse/passes não são falados e o Match Engine permanece sem dependência de áudio/TTS.
- `GameSettings.sound` foi preservado como chave geral legada; as novas preferências ficam em `AudioSettings` com defaults compatíveis, sem exigir migração destrutiva do save.
- preferência de validação em aparelho: acumular mudanças e testar APKs em blocos maiores, evitando solicitar instalação a cada microrelease; CI e validações locais continuam obrigatórios quando disponíveis.
- Elenco e Escalação compartilham avaliação de posição/status: `starterIds` mantém a ordem dos slots, OVR efetivo vem do `LineupEngine`, cards exibem forma/condição/cartões e `PlayerAvatar` usa foto personalizada privada quando existir, com fallback procedural. Esses componentes são a base planejada para Categoria de Base, Centro Médico e Centro de Treino.

O CI da `0.1.1.28` foi confirmado verde em 25/08/2026, incluindo `flutter analyze`, testes e build release. A `0.1.1.29` não foi baixada/validada separadamente em aparelho; suas mudanças foram absorvidas pela linha 0.1.1.30+ e continuam presentes na 0.1.1.37. O GitHub Actions da `0.1.1.33` chegou ao `flutter analyze` e revelou cinco bloqueios: dois lints `prefer_initializing_formals` em `PlayerAvatar`, referência a `Club.city` inexistente, extensão `FormationType.label` sem import no pré-jogo e um import não utilizado em Configurações. A `0.1.1.35` corrigiu esses cinco pontos. A `0.1.1.36` adicionou o áudio base. A `0.1.1.37` acrescenta narração falada opcional por TTS e precisa de validação no próximo CI/aparelho porque o ambiente local desta entrega não possui Flutter. O CI da `0.1.1.7` também havia sido confirmado verde em 24/08/2026: 21 testes passaram e o APK release foi gerado. O log ainda exibiu avisos não fatais sobre Built-in Kotlin futuro e `Already watching path`; a `0.1.1.8` mantém o modo Kotlin já validado e reduz o file watching do Gradle no runner.

Esses pontos ainda devem ser validados no APK real em aparelho físico. Não assuma que uma correção visual está concluída sem testar o build.

## Persistência e saves

A persistência usa SQLite. O projeto já suporta múltiplas carreiras e possui migração da estrutura anterior.

Ao alterar entidades persistidas:

- preserve compatibilidade de saves sempre que possível;
- crie migração explícita quando a estrutura mudar;
- mantenha IDs de clubes estáveis;
- não dependa de nomes visíveis como chave persistente;
- adicione teste de serialização/save-load.

## Versionamento obrigatório

A fonte canônica da versão visível é `VERSION`.

Padrão de release solicitado pelo projeto:

```text
0.1.1.109
```

Não usar o antigo padrão visível `0.1.0+3`.

Arquivos relevantes:

- `VERSION` — fonte canônica da release visível;
- `app.json` — metadados externos e versão sincronizada;
- `pubspec.yaml` — versão SemVer compatível com Flutter e build inteiro crescente;
- Android — `versionName` igual à release visível e `versionCode` igual ao build do `pubspec.yaml`;
- iOS — versão/build sincronizados pelo utilitário quando a estrutura está presente;
- workflow — valida o APK antes de publicar o Artifact.

Para esta release:

```text
release/versionName: 0.1.1.131
versionCode:         132
pubspec:             0.1.1+132
```

A próxima alteração/entrega normalmente deve virar `0.1.1.132` e usar um `versionCode` maior que 132.

Nunca altere somente o nome do ZIP para simular uma versão nova.

Antes de empacotar qualquer nova release, confirme também que `flutter analyze` não possui lints; avisos tratados como erro no CI bloqueiam testes e build mesmo quando não afetam a lógica do jogo.

Para uma nova release, atualize `VERSION` e o build em `pubspec.yaml`, depois use:

```bash
python3 tool/versioning.py sync
python3 tool/versioning.py verify
```

O arquivo `al-sistemas.json` foi removido na 0.1.1.109 e **não deve ser recriado**. Ferramentas e automações do projeto devem usar `VERSION`, `app.json` e `pubspec.yaml`.

## CI obrigatório antes de considerar uma entrega pronta

O workflow deve executar:

```text
version verify
→ validação/configuração da plataforma Android versionada
→ restauração de caches Flutter/Pub/Gradle
→ flutter pub get (gera pubspec.lock quando ainda ausente)
→ flutter analyze
→ flutter test
→ flutter build apk --release
→ validação do versionName/versionCode do APK
→ upload somente do APK versionado como Artifact
```

Uma alteração não deve ser chamada de concluída se `analyze`, `test` ou `build apk` estiverem falhando.


### Lockfile

`flutter pub get` pode gerar/atualizar `pubspec.lock` dentro do workspace de build. Esse arquivo faz parte da resolução de dependências do projeto, mas **não deve ser publicado como Artifact**. O GitHub Actions publica somente o APK versionado para evitar que gerenciadores externos confundam lockfile/ZIP com o aplicativo.

## Testes existentes

Atualmente existem testes para:

- configuração da nova carreira;
- refatoração dos controladores;
- calendário diário, descanso mínimo e 38 rodadas;
- disponibilidade de jogadores;
- Match Engine modular;
- serialização/save-load;
- transferências, venda por proposta da CPU, renovação e finanças;
- histórico e virada de temporada;
- metadados de versionamento;
- recursos de ícone Android/iOS e integridade das artes-fonte.
- avanço diário/notícias e limite de crescimento do feed;
- janelas de transferências e bloqueio no controlador;
- calendário/classificação e navegação pré-jogo;
- apresentação de eventos com nomes completos;
- política de Artifact somente APK;
- desgaste pós-jogo baseado nos participantes reais.

Arquivos:

```text
test/career_setup_test.dart
test/career_creation_ui_test.dart
test/club_identity_test.dart
test/club_editor_ui_test.dart
test/controller_refactor_test.dart
test/league_schedule_test.dart
test/season_calendar_test.dart
test/multi_season_calendar_test.dart
test/player_availability_test.dart
test/match_engine_refactor_test.dart
test/serialization_smoke_test.dart
test/transfer_finance_test.dart
test/season_history_test.dart
test/transfer_ui_structure_test.dart
test/versioning_metadata_test.dart
test/android_ci_infrastructure_test.dart
test/app_icon_assets_test.dart
test/daily_career_events_test.dart
test/transfer_window_test.dart
test/calendar_and_standings_ui_test.dart
test/pre_match_navigation_test.dart
test/match_event_presentation_test.dart
test/match_participation_fatigue_test.dart
test/contracts_ui_test.dart
test/contract_lifecycle_test.dart
test/artifact_policy_test.dart
test/audio_system_test.dart
test/player_avatar_identity_test.dart
test/live_match_visual_experience_test.dart
```

Sempre adicione ou ajuste testes quando mudar regra de negócio.

## Próximas prioridades recomendadas

1. Validar a `0.1.1.110` no GitHub Actions com analyzer, testes e build release; o log anterior já confirmou analyzer limpo e 282/283 testes aprovados antes desta correção.
2. Em aparelho, gravar uma partida completa e validar aceleração/frenagem, pênaltis, retorno à formação e estabilidade dos nomes em 60 e 120 Hz.
3. Exercitar avanço diário, partida do usuário, jogos CPU, mercado e contratos para confirmar que a Série A atual continua no caminho completo do Match Engine.
4. Quando entrar uma segunda competição real, implementar estado competitivo por competição (calendário/classificação/rodada/estatísticas) antes de ativá-la como liga completa simultânea.
5. Manter a seleção de ligas imutável após o início do save até existir reconstrução segura de calendário, tabela, resultados e estatísticas.
6. Resolver posteriormente a keystore release persistente; até lá, preservar o fallback já documentado e o `applicationId`.

## Regras de manutenção

- Preferir arquivos pequenos e responsabilidade única.
- Não colocar regras de negócio em widgets.
- Não duplicar cálculos entre tela e engine.
- Não alterar IDs persistentes sem migração.
- Não atualizar dependências para beta/dev sem motivo.
- Usar versões estáveis compatíveis das dependências.
- Não criar imagens/ícones/splash sem solicitação explícita.
- Não apagar funcionalidades existentes para simplificar uma correção.
- Não declarar algo corrigido apenas porque o código parece correto; validar no CI e, para UI, no aparelho.

## Documentação histórica útil

- `docs/PROMPT_MESTRE.txt`
- `docs/ETAPA_1.md`
- `docs/CARREIRAS_E_ESTADO.md`
- `docs/REFATORACAO_CONTROLLERS.md`
- `docs/REFATORACAO_MATCH_ENGINE.md`
- `docs/CLUB_IDENTITIES.md`
- `docs/RELEASE_0.1.1.24.md`
- `docs/RELEASE_0.1.1.23.md`
- `docs/RELEASE_0.1.1.22.md`
- `docs/CPU_MARKET.md`
- `docs/RELEASE_0.1.1.21.md`
- `docs/RELEASE_0.1.1.18.md`
- `docs/RELEASE_0.1.1.17.md`
- `docs/RELEASE_0.1.1.16.md`
- `docs/RELEASE_0.1.1.15.md`
- `docs/RELEASE_0.1.1.14.md`
- `docs/RELEASE_0.1.1.13.md`
- `docs/RELEASE_0.1.1.8.md`
- `docs/RELEASE_0.1.1.7.md`
- `docs/RELEASE_0.1.1.6.md`
- `docs/RELEASE_0.1.1.5.md`
- `docs/RELEASE_0.1.1.4.md`
- `docs/RELEASE_0.1.1.3.md`

Use o histórico para entender decisões, não para restaurar arquitetura antiga que já foi substituída.
