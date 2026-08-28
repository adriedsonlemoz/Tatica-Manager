# Tática Manager 2

Reconstrução do Tática Manager em Flutter + Dart, com foco mobile-first, modo retrato, interface esportiva premium e partida 2D com Flame.

Repositório oficial: https://github.com/adriedsonlemoz/TaticaManager2

**Release atual:** `0.1.1.56`
**Android versionCode:** `58`

## Fonte oficial de versão

A versão visível da release é definida em `al-sistemas.json`. O arquivo `tool/versioning.py` mantém os demais metadados sincronizados e o CI falha quando encontra divergência.

Arquivos de identificação/versionamento incluídos no projeto:

- `al-sistemas.json` — manifesto canônico para ferramentas externas e AL Sistemas;
- `VERSION` — versão visível simples (`0.1.1.56`);
- `app.json` — identidade externa do aplicativo;
- `pubspec.yaml` — manifesto Flutter, com versão SemVer compatível (`0.1.1+58`);
- Android — plataforma versionada no repositório, com `versionName 0.1.1.56` e `versionCode 58`;
- iOS — catálogo `AppIcon.appiconset` com todos os tamanhos já versionado; a estrutura Xcode completa será sincronizada quando a plataforma iOS for adicionada;
- GitHub Actions — valida a versão embutida no APK antes de publicar o Artifact.

> O Flutter/Dart usa SemVer no `pubspec.yaml`, por isso a release de quatro partes `0.1.1.56` é representada internamente como `0.1.1+58`. A versão visível do aplicativo/Android continua sendo `0.1.1.56`.

## Política obrigatória de release

Toda correção, alteração, refatoração ou entrega deve atualizar a versão antes de ser publicada. O padrão visível é `A.B.C.D`; para esta linha, a próxima entrega normalmente será `0.1.1.57`, salvo quando houver um incremento funcional maior.

Antes de publicar:

```bash
python3 tool/versioning.py sync
python3 tool/versioning.py verify
```

O workflow usa a plataforma Android versionada, cache de Flutter/Pub/Gradle e executa `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --release`, além de conferir o `versionName`/`versionCode` do APK. Não recria `android/` e não executa `flutter clean` em runner novo. O `flutter pub get` resolve as dependências no workspace, mas o CI publica **somente o APK versionado** como Artifact. O `pubspec.lock` não é disponibilizado nos Artifacts.

## Etapa atual

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

Consulte também `docs/RELEASE_0.1.1.37.md`, `docs/RELEASE_0.1.1.36.md`, `docs/AUDIO_SYSTEM.md`, `docs/RELEASE_0.1.1.35.md`, `docs/RELEASE_0.1.1.34.md`, `docs/RELEASE_0.1.1.33.md`, `docs/RELEASE_0.1.1.32.md`, `docs/RELEASE_0.1.1.31.md`, `docs/RELEASE_0.1.1.30.md`, `docs/RELEASE_0.1.1.29.md`, `docs/RELEASE_0.1.1.28.md`, `docs/RELEASE_0.1.1.27.md`, `docs/RELEASE_0.1.1.26.md`, `docs/RELEASE_0.1.1.25.md`, `docs/RELEASE_0.1.1.24.md`, `docs/RELEASE_0.1.1.23.md`, `docs/RELEASE_0.1.1.22.md`, `docs/RELEASE_0.1.1.21.md`, `docs/CPU_MARKET.md`, `docs/RELEASE_0.1.1.20.md`, `docs/RELEASE_0.1.1.19.md`, `docs/RELEASE_0.1.1.18.md`, `docs/RELEASE_0.1.1.17.md`, `docs/RELEASE_0.1.1.16.md`, `docs/RELEASE_0.1.1.15.md`, `docs/RELEASE_0.1.1.14.md`, `docs/RELEASE_0.1.1.13.md`, `docs/CLUB_IDENTITIES.md`, `docs/RELEASE_0.1.1.12.md`, `docs/RELEASE_0.1.1.11.md`, `docs/RELEASE_0.1.1.10.md`, `docs/RELEASE_0.1.1.9.md`, `docs/RELEASE_0.1.1.8.md`, `docs/RELEASE_0.1.1.7.md`, `docs/RELEASE_0.1.1.6.md`, `docs/RELEASE_0.1.1.5.md`, `docs/RELEASE_0.1.1.4.md`, `docs/RELEASE_0.1.1.3.md`, `docs/AL_SISTEMAS_FLUTTER.md`, `docs/ETAPA_1.md`, `docs/CARREIRAS_E_ESTADO.md`, `docs/REFATORACAO_CONTROLLERS.md` e `docs/REFATORACAO_MATCH_ENGINE.md`.


### Narração falada opcional

A release 0.1.1.37 usa TTS do próprio aparelho para narrar lances importantes. O recurso pode ser ligado/desligado e possui volume próprio em Configurações → Áudio. Posse e passes não são falados, e o Match Engine continua independente da camada de áudio.
