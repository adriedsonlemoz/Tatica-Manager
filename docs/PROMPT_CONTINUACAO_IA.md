# Prompt para continuar o Tática Manager 2 em outra IA

Copie o bloco abaixo e envie à IA junto com o ZIP/repositório mais recente do projeto.

```text
Você vai continuar o desenvolvimento do projeto Tática Manager 2.

REPOSITÓRIO OFICIAL
https://github.com/adriedsonlemoz/Tatica-Manager

STACK
Flutter + Dart, Riverpod, SQLite (sqflite) e Flame apenas para a representação visual 2D da partida.

VERSÃO ATUAL DESTE HANDOFF
Release visível: 0.1.1.105
Android versionCode: 106
pubspec: 0.1.1+106

Novidade desta base: sobre a seleção de ligas da 0.1.1.75, adiciona a fundação multi-competição do `CareerState` schema 13. Cada `competitionId` possui progresso, tabela, estatísticas e disciplina próprios; fixtures continuam num calendário global e carregam metadados de fase/grupo/confronto. O Match Engine permanece único e apenas produz `MatchResult`; a aplicação ao save fica fora dele. O catálogo também fica preparado para futuras competições internacionais sem associá-las artificialmente a um país.

ANTES DE ALTERAR QUALQUER CÓDIGO
1. Leia AI_HANDOFF.md.
2. Leia README.md.
3. Leia docs/PROMPT_MESTRE.txt.
4. Leia as documentações da pasta docs relacionadas à área que será modificada.
5. Inspecione a implementação atual. Não assuma que o projeto ainda está na arquitetura descrita em versões antigas dos documentos.

REGRA CENTRAL
Continue sobre o projeto Flutter existente. NÃO reconstrua o app novamente, NÃO converta de volta para React/Capacitor e NÃO crie uma segunda arquitetura paralela.

ARQUITETURA
Mantenha domínio, engines, persistência, estado e UI separados.

- lib/domain: modelos e regras fundamentais sem dependência de Flutter.
- lib/game: engines do jogo.
- lib/features: telas e widgets por funcionalidade.
- lib/app/state: controladores Riverpod.
- lib/core: banco, save, tema, plataforma e utilitários.
- Flame deve representar a partida, não decidir o resultado.

CONTROLADORES ATUAIS
- CareerController: múltiplos saves, criar/abrir/listar/excluir carreira.
- GameController: sessão da carreira ativa, escalação, tática, persistência e temporada.
- LiveMatchController: partida ao vivo, substituições, conclusão da rodada e efeitos pós-jogo.
- TransferController: compra, venda, renovação, contratos e integração financeira.

Não volte a concentrar tudo no GameController.

MATCH ENGINE
O Match Engine já foi modularizado. Preserve os módulos de força, probabilidade, seleção de jogadores, eventos, timeline, estatísticas e trajetória. match_engine.dart deve continuar principalmente como orquestrador.

FLUXO DE NOVA CARREIRA
Bootstrap → Central de Carreiras → Nova carreira → Escolha do técnico (existente ou criado) → Competição/clube → Seleção de ligas do save → Formação → Mentalidade/pressão/ritmo → Assinatura visual do contrato → Home.

A carreira suporta múltiplos saves. Não reintroduza save único global.

VERSIONAMENTO — OBRIGATÓRIO EM TODA ENTREGA
A fonte canônica é al-sistemas.json.
O padrão visível é A.B.C.D, por exemplo 0.1.1.4.
O pubspec usa uma representação SemVer compatível e o Android usa versionCode inteiro crescente.
Antes de qualquer nova entrega, incremente a versão. Partindo deste handoff, a próxima normalmente será 0.1.1.106 com versionCode > 106.


Depois de editar al-sistemas.json, execute:
python3 tool/versioning.py sync
python3 tool/versioning.py verify

Nunca deixe:
- al-sistemas.json com uma versão;
- pubspec com outra;
- Android/APK com versão antiga;
- ZIP com metadados divergentes.

AL SISTEMAS
O gerenciador AL Sistemas lê al-sistemas.json para detectar produto/versão. Preserve na raiz:
- al-sistemas.json
- VERSION
- app.json
- pubspec.yaml

Não crie um package.json falso para fazer o projeto Flutter parecer Node.js.

CI / CRITÉRIO DE CONCLUSÃO
Não considere a entrega pronta até passar:
- python3 tool/versioning.py verify
- flutter pub get
- flutter analyze
- flutter test
- flutter build apk --release

O workflow também deve validar o versionName/versionCode embutidos no APK e publicar o APK versionado como Artifact.

BUGS/ALTERAÇÕES RECENTES QUE DEVEM SER PRESERVADOS
- correção da sobreposição do botão Começar carreira;
- correção de conteúdo escondido pela navegação inferior;
- tela animada de assinatura do contrato ao iniciar carreira;
- fullscreen imersivo reforçado no Android;
- negociação com valor mínimo/contraproposta e valores formatados;
- taxa de transferência afeta orçamento e salário entra na folha mensal;
- múltiplas carreiras;
- controladores separados;
- Match Engine modular;
- manifesto/versionamento para AL Sistemas;
- calendário diário persistido no save;
- tela de preparação no dia da partida;
- lesões, suspensões e baixa condição bloqueiam escalação;
- partida dividida em primeiro tempo, intervalo e segundo tempo;
- resumo pós-jogo ampliado;
- Sobre / Novidades, contato e apoio por Pix.
- novo ícone oficial com Adaptive Icon Android e catálogo AppIcon iOS;
- build release alinhado em JVM 17 para Java e Kotlin;
- venda pelo Elenco por proposta da CPU com confirmação;
- compra e renovação em janelas centralizadas;
- histórico da carreira e revisão de fim de temporada;
- somente o APK versionado é publicado nos Artifacts; pubspec.lock não deve ser publicado.
- calendário mensal e partidas clicáveis;
- avanço diário com notícias, recuperação, propostas e alertas de contratos;
- janelas de transferências;
- narração e resumo com nomes completos dos clubes e tipos de eventos claros.
- áudio modular com 11 faixas OGG de menu, faixa atual/seleção/próxima música, efeitos de interface/partida, volumes separados e arquivos personalizados; o áudio reage aos MatchEvent somente na apresentação.
- narração falada opcional por TTS do aparelho, com liga/desliga e volume próprios; apenas lances relevantes são falados e replay não repete a voz.
- clubes padrão fictícios com IDs neutros permanentes `br-club-001` a `br-club-020`.
- editor de nome, apelido e sigla na Central de Carreiras, por padrão global ou por save.
- importação comunitária v2 para clube, estádio, uniformes, ícone e jogadores, com IDs persistentes protegidos e migração automática de IDs legados.
- mercado CPU com análise de carências por posição, contratação de agentes livres e transferências direcionadas entre clubes; o clube do usuário nunca é movimentado automaticamente.
- mercado CPU com venda estratégica, concorrência controlada por alvos, proteção financeira e notícias persistentes usando CareerEvent.
- propostas recebidas da CPU são negociáveis pelo usuário com aceitar, recusar e contrapropor; continuam persistidas no CareerEvent e nunca executam venda automática do clube do usuário.
- engines de mercado recebem o universo de clubes da carreira e tratam IDs como opacos, sem depender de Série A, prefixo brasileiro ou exatamente 20 clubes.
- mercado CPU mantém prioridade estável durante a janela, perfil financeiro e até três alvos alternativos, tentando substituto se o primeiro deixar de ser viável.
- Home possui classificação compacta com jogos, vitórias, empates, derrotas, saldo e pontos, além de painel informativo para avançar o dia.
- criação de carreira usa cards menores; Formação fica isolada e Mentalidade passa para a etapa visual de Pressão/Ritmo.
- calendário da liga mantém 12/04 como primeira referência, mas as rodadas usam cadência configurável com diferentes dias da semana e mínimo de descanso; preserve os testes de intervalo e a abertura por `competitionId` para futuras competições.
- jogadores possuem avatares 2D determinísticos por `Player.id` como fallback e podem receber foto personalizada normalizada no editor do banco; forma recente, condição, fadiga e cartões são expostos por componentes reutilizáveis de Elenco/Escalação sem duplicar regras do Match Engine.

Esses itens ainda precisam de validação no APK/aparelho quando aplicável. Se um problema continuar no dispositivo, corrija a causa sem desfazer a arquitetura.

PRÓXIMAS PRIORIDADES
1. Validar a 0.1.1.105 no GitHub Actions, incluindo `flutter analyze`, testes e build release.
2. Em aparelho, validar a nova etapa de seleção de ligas e confirmar que a Série A do clube permanece completa em todos os presets.
3. Testar abertura da Central de Carreiras com múltiplos saves antigos e novos após a migração SQLite v2 -> v3.
4. Exercitar avanço diário, jogos CPU, mercado e contratos para confirmar que a configuração persistida não altera a Série A atual.
5. A próxima expansão de dados pode adicionar a Série B real usando o estado por competição já existente; antes de estaduais/copas, implementar somente o regulamento/calendário específico de cada torneio.
6. Manter alteração de ligas após o início da carreira bloqueada até existir reconstrução segura de calendário, tabela, resultados e estatísticas.

```


## Seleção de ligas por carreira — 0.1.1.75

A criação possui uma etapa de configuração do mundo do save baseada em `CompetitionCatalog`. Não criar ligas fictícias: apenas competições reais cadastradas podem aparecer. A liga do clube do usuário deve permanecer `full`.

`CareerState` schema 12 persiste `CareerLeagueSetup`. Ligas `unloaded` não entram no estado de novas carreiras; `background` permanece preparada para mercado/contratos e resolução estatística CPU; `full` continua no Match Engine. Não criar segundo Match Engine e não mover lógica para Flame.

SQLite v3 mantém o payload integral, mas a Central de Carreiras usa colunas de resumo e não seleciona `payload` em `listSaves()`. Preservar essa otimização e a migração v2 -> v3.

A troca de ligas após o início do save continua desabilitada até haver regras explícitas para reconstrução de calendário, classificação, resultados e estatísticas. Consulte `docs/LEAGUE_LOADING.md`.


## Fundação multi-competição — 0.1.1.76 / schema 13

A carreira agora possui estado competitivo independente por `competitionId` através de `CompetitionSeasonState`, incluindo participantes, progresso, classificação, estatísticas, disciplina e fases. `CareerState.fixtures` continua sendo o calendário global, e `primaryCompetitionId` define qual torneio alimenta os espelhos legados `standings`/`roundIndex` e as telas que ainda trabalham com uma competição principal.

Preserve `CompetitionCalendarEngine`, `CompetitionStateEngine`, `CompetitionSimulationEngine` e `MatchCareerImpactEngine`. Não mova essas responsabilidades para `GameController` e não crie um novo Match Engine. O Match Engine atual deve continuar simulando a partida e retornando `MatchResult`; o impacto competitivo é aplicado depois no estado correspondente.

O mesmo clube pode participar de vários torneios carregados. Estatísticas e suspensões são por competição; lesões, condição, fadiga e moral continuam globais. Fixtures novos podem persistir `stageId`, `groupId`, `tieId` e `leg`; a Série A deve conservar seus IDs históricos e novas competições devem usar IDs que incluam `competitionId`.

O catálogo já diferencia ligas nacionais/regionais, copas nacionais, torneios continentais e mundiais, mas a 0.1.1.76 não adiciona dados fictícios. Ao inserir Série B, estaduais, Copa do Brasil, Libertadores ou outras competições, cadastre somente dados/regras reais e implemente o gerador do formato específico quando necessário. Não use um gerador genérico inventado de mata-mata/grupos.

Saves schema 12 devem migrar para schema 13 sem alterar IDs persistentes. Alterar o conjunto de ligas carregadas depois que a carreira começou continua bloqueado; mudança de emprego só pode tornar principal/promover uma competição que já fazia parte do save.
