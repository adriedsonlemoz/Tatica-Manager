# Prompt para continuar o Tática Manager 2 em outra IA

Copie o bloco abaixo e envie à IA junto com o ZIP/repositório mais recente do projeto.

```text
Você vai continuar o desenvolvimento do projeto Tática Manager 2.

REPOSITÓRIO OFICIAL
https://github.com/adriedsonlemoz/Tatica-Manager

STACK
Flutter + Dart, Riverpod, SQLite (sqflite) e Flame apenas para a representação visual 2D da partida.

VERSÃO ATUAL DESTE HANDOFF
Release visível: 0.1.1.58
Android versionCode: 60
pubspec: 0.1.1+60
Release atual: correção do import redundante de `dart:ui` na Central de Diagnóstico apontado pelo `flutter analyze`, preservando diagnóstico, áudio, `CareerState` schema 11, IDs, saves, Match Engine e workflow.

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
Bootstrap → Central de Carreiras → Nova carreira → Perfil/origem do técnico → Competição/clube → Formação → Mentalidade/pressão/ritmo → Assinatura visual do contrato → Home.

A carreira suporta múltiplos saves. Não reintroduza save único global.

VERSIONAMENTO — OBRIGATÓRIO EM TODA ENTREGA
A fonte canônica é al-sistemas.json.
O padrão visível é A.B.C.D, por exemplo 0.1.1.4.
O pubspec usa uma representação SemVer compatível e o Android usa versionCode inteiro crescente.

Antes de qualquer nova entrega, incremente a versão. Partindo deste handoff, a próxima normalmente será 0.1.1.59 com versionCode > 60.

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
- áudio modular com cinco músicas originais, efeitos de interface/partida, volumes separados e arquivos personalizados; o áudio reage aos MatchEvent somente na apresentação.
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
1. Validar a 0.1.1.48 no GitHub Actions; o analyzer da 0.1.1.47 já passou e os dois testes estruturais de UI foram alinhados à modularização atual.
2. Em aparelho, testar em bloco: avanço diário, HOJE É DIA DE JOGO, pré-jogo, calendário em dias variados, Escalação e pausa de substituição.
3. Testar save/load depois de deixar o clube, receber proposta e assumir outro, inclusive após avançar dias desempregado.
4. Preservar o calendário configurável por `competitionId` quando novas ligas/copas forem adicionadas.
5. Resolver a assinatura persistente do APK quando conveniente, mantendo o fallback atual até os Secrets serem configurados.
6. Categorias de base, centro médico e treino podem evoluir depois sem criar controllers vazios ou arquitetura paralela.

```
