# Carreiras e estado — arquitetura após a refatoração

Repositório oficial: `https://github.com/adriedsonlemoz/Tatica-Manager`

Esta refatoração separa o ciclo de vida dos saves das regras de jogo para impedir que `GameController` concentre responsabilidades demais.

## Fluxo de abertura

```text
Splash
  ↓
CareerController.bootstrap()
  ↓
Central de Carreiras
  ├── Continuar última carreira
  ├── Abrir uma carreira existente
  └── Nova carreira
          ↓
     Perfil/origem do técnico
          ↓
     País > Campeonato > Série > Clube
          ↓
     Formação + mentalidade
          ↓
     Pressão + ritmo
          ↓
     CareerFactory
          ↓
     Save SQLite
          ↓
     GameController.attachCareer()
          ↓
     GameShell
```

## Responsabilidades

### `CareerController`

Responsável somente pelo ciclo de vida de carreiras:

- listar saves;
- criar carreira;
- abrir carreira;
- guardar qual foi a última carreira usada;
- fechar a carreira ativa e voltar ao menu;
- apagar um save.

### `GameController`

Mantém a sessão da carreira já aberta e as ações de jogo. Ele não decide mais qual save deve ser exibido na abertura do aplicativo.

A divisão adicional já foi aplicada no build `0.1.0+3`: partida ao vivo fica em `LiveMatchController` e compras, vendas e renovações ficam em `TransferController`. O `GameController` permanece como sessão consolidada da carreira.

## Banco local

O banco atual está na versão 3. O modelo de múltiplos saves criado na v2 continua o mesmo; a v3 acrescenta somente metadados leves de listagem.

`career_saves` deixa de ter um único registro fixo e passa a aceitar vários IDs de carreira. Cada linha guarda metadados leves para a Central de Carreiras e o payload completo em JSON.

Metadados:

- ID permanente da carreira;
- nome da carreira;
- técnico;
- clube;
- temporada;
- rodada;
- versão do schema;
- data de criação;
- última atualização.

A tabela `app_meta` guarda o ID da última carreira aberta. Na v3, `career_saves` também persiste um resumo derivado (identidade visual mínima, colocação, próximo jogo e total de rodadas), permitindo listar carreiras sem selecionar o payload JSON completo.

## Compatibilidade

O `onUpgrade` migra o banco antigo de save único para o modelo de múltiplos saves. O JSON de `CareerState` também possui valores de fallback para abrir saves criados antes dos campos `careerId`, `careerName`, `manager`, `createdAt` e `currentDate`. A partir do schema 3, a data atual da carreira é persistida para permitir avanço dia a dia sem perder compatibilidade com saves antigos.

## Nova carreira

A criação atual possui seis etapas:

1. escolher usar um técnico existente ou criar um novo;
2. selecionar/preencher o perfil do técnico;
3. país, campeonato, série e clube;
4. selecionar a profundidade das ligas do save;
5. formação;
6. mentalidade, pressão, ritmo e duração da partida.

Os uniformes não bloqueiam a criação. A primeira carreira usa automaticamente a identidade visual do clube. Personalização de uniforme deve ser um recurso opcional futuro e não uma dependência do motor da carreira.

## Calendário diário

A carreira mantém `CareerState.currentDate`. Novas carreiras começam três dias antes da primeira partida da temporada. `CareerCalendarEngine` avança exatamente um dia por ação e bloqueia o avanço quando a data atual é a data de uma partida pendente do clube do usuário.

Lesões e suspensões continuam contadas por rodadas; a passagem de dias recupera condição/fadiga, mas não apaga indisponibilidades esportivas. A rodada de indisponibilidade é consumida somente depois de todos os jogos da rodada terem sido simulados, antes de aplicar novas ocorrências.

## Schema 4 — notícias e histórico de partidas da temporada

A partir da `0.1.1.9`, `CareerState.currentSchemaVersion` é 4 e o payload também guarda:

- `news`: acontecimentos persistentes do avanço diário e da disponibilidade do elenco;
- `matchHistory`: resultados completos da temporada atual, usados para abrir detalhes de partidas já disputadas no calendário;
- `seasonHistory`: continua acumulando os resumos de temporadas concluídas.

Saves anteriores recebem listas vazias para os novos campos ao serem lidos. Na virada de temporada, `matchHistory` é limpo para limitar o crescimento do save, enquanto `seasonHistory` e notícias relevantes permanecem.

`DailyCareerEngine` coordena eventos do dia sem deslocar regra de negócio para a Home. `CareerCalendarEngine` continua responsável apenas pela progressão da data e recuperação diária básica do estado dos clubes.

## Contratos e jogadores livres — 0.1.1.12

O ciclo de vida dos contratos usa `ContractLifecycleEngine` como regra única. Um vínculo é considerado vencido quando `endSeason < season`; por isso a virada de temporada incrementa primeiro a temporada e depois executa a mesma reconciliação usada pelo avanço diário e pela abertura de saves.

A reconciliação é idempotente: remove atletas vencidos dos clubes, preserva seus IDs/atributos/histórico, limpa `clubId`, adiciona uma única ocorrência em `freeAgents` e corrige a escalação do usuário quando necessário. Não houve alteração do schema do save nem do banco SQLite.


## Identidade de clubes e pacotes comunitários — 0.1.1.13

Os clubes base passaram a usar IDs neutros e imutáveis no formato `br-club-001` até `br-club-020`. Nome, apelido e sigla são identidade editável e nunca devem ser usados como chave persistente.

`ClubIdentityEngine` concentra validação, aplicação e migração de identidade. A Central de Carreiras permite editar o pacote padrão para novas carreiras ou a identidade de um save específico. Um save editado não altera os demais.

Saves anteriores com IDs vinculados aos nomes antigos são migrados de forma idempotente ao listar/abrir/editar a carreira. A migração atualiza referências de clube em elenco, calendário, classificação, histórico de temporada, notícias e histórico de partidas, sem trocar `Player.id`, resultados, dinheiro ou atributos. O campo `Club.nickname` possui fallback para `name`, portanto não exige mudança de schema do `CareerState` nem do SQLite.

Pacotes comunitários usam o formato JSON documentado em `docs/CLUB_IDENTITIES.md`. A versão 2 aceita identidade, estádio, uniformes, ícone, elencos e jogadores livres, sempre preservando os IDs permanentes e sem abrir caminho para alterar reputação, dinheiro, calendário ou resultados. O pacote padrão personalizado fica armazenado em `app_meta`, sem mudança de versão do banco.


## Editor completo do banco — 0.1.1.14

O pacote comunitário evoluiu para `tatica-manager-clubs` v2. O `ClubIdentityEngine` continua concentrando normalização/aplicação e passou a validar também estádio, três uniformes, ícone Base64, elencos e jogadores livres.

O editor padrão pode alterar a estrutura dos elencos antes de criar uma carreira, mantendo `Club.id` e `Player.id` como chaves permanentes. Clubes precisam manter de 20 a 30 atletas para respeitar os limites já usados pelo mercado/CPU.

Em uma carreira existente, a edição/importação preserva o conjunto global de IDs de jogadores e mantém estado transitório do save (lesão, disciplina, condição, fadiga, moral, estatísticas e histórico). Isso permite corrigir identidade, número, overall, atributos, contrato e apresentação sem apagar acontecimentos já ocorridos.

`ClubKit` persiste uniforme 1/2/3 em dados estruturados, e `Club.iconBase64` guarda o escudo/ícone local. A UI não decide regras de consistência: validação e aplicação permanecem no engine.

## Criação de carreira e perfil do técnico — 0.1.1.15

Na 0.1.1.15 a criação ainda usava três etapas, mas a UI foi dividida em componentes específicos (`ManagerProfileStep`, `ClubSelectionStep` e `CareerSetupStep`) para evitar concentração no fluxo principal. A seleção apresenta a hierarquia **Países > Brasil > Liga > Série A > Clubes** e usa grade de duas colunas. Cada card mostra `ClubBadge`, nome, orçamento e overall calculado sobre os 18 jogadores de maior overall do elenco carregado; a reputação do seed é apenas fallback quando não existe elenco.

`ManagerProfile` passa a persistir `displayName`, `nickname`, `nationality`, `ageAtStart`, `careerStartSeason` e `birthPlace`. A idade atual é derivada por temporada, sem mutação diária. `CareerState.managerHistory` guarda um snapshot do técnico por temporada (`ManagerCareerHistoryEntry`), permitindo exibir a trajetória no Histórico da carreira. O schema do payload da carreira passa para 5; o SQLite continua na mesma versão porque o perfil completo permanece dentro do JSON do save.

A preparação inicial reutiliza `ClubIdentityEngine.applyIdentityToClub`, garantindo que nome, estádio, escudo e três uniformes vistos no editor sejam os mesmos aplicados ao iniciar a carreira.


## Editor e criação visual — 0.1.1.17

A navegação de competição foi centralizada em `CompetitionCatalog` e reaproveitada pelo editor e pela criação: **País > Campeonato > Série > Clubes**. A criação passa a quatro etapas para separar formação/mentalidade de pressão/ritmo. `FormationMiniPitch` apenas visualiza os slots do `FormationCatalog`; não cria uma segunda regra de formação.

A origem do técnico passa a persistir `birthCountry`, `birthState` e `birthCity`, além do texto derivado `birthPlace`. O payload passa ao schema 6 e mantém fallback para saves sem os novos campos. Estados/cidades do Brasil ficam fora dos widgets em `assets/data/brazil_locations.json`, preparados para expansão por país. O catálogo inicial traz os 27 estados e 346 cidades selecionadas; a UI oferece entrada manual de município quando ele ainda não estiver na lista.

## Finanças, patrocínios e estádio — 0.1.1.44

A evolução financeira da 0.1.1.44 preserva o save atual e não cria um controlador paralelo. `FinanceEngine` continua responsável pela liquidação da rodada do clube do usuário e passa a delegar cálculos específicos para módulos menores:

- `SponsorshipEngine`: contratos ativos, valores anuais, duração, bônus de desempenho e receita por rodada;
- `StadiumEngine`: público projetado, bilheteria, camarotes/hospitalidade, lojas, alimentação, publicidade e custo operacional;
- `FinanceTransaction`: mantém lançamentos persistidos com categorias identificáveis para histórico e balanço.

`Club.sponsorships` e os níveis comerciais de `Stadium` são campos opcionais na serialização. Saves antigos recebem lista vazia/defaults de nível 1 e continuam carregando sem migração destrutiva ou alteração de IDs. Quando não há contrato persistido, `SponsorshipEngine` fornece contratos determinísticos padrão; negociações futuras podem persistir contratos reais na mesma estrutura.

O módulo visual de Estádio é próprio, mas não decide regras de partida. Ele representa a infraestrutura 2D e projeções financeiras. A arrecadação real continua sendo lançada pelo `FinanceEngine` no fechamento da rodada, evitando duplicar receitas ao abrir a tela.

## Carreira profissional do treinador — schema 8 (0.1.1.45)

`CareerState.managerCareer` persiste o vínculo profissional separadamente do histórico anual antigo. Ele registra passagens (`ManagerClubTenure`), estado empregado/desempregado e propostas (`ManagerJobOffer`). Saves anteriores que não possuem o campo recebem automaticamente uma passagem ativa pelo `userClubId` já persistido, sem migração destrutiva do SQLite.

As decisões de reputação, vagas, demissão, contratação e propostas ficam em `game/career/manager_career_engine.dart`; `GameController` somente coordena persistência e mensagens. Quando o técnico fica sem clube, `LeagueCatchUpEngine` pode resolver pelo Match Engine partidas cuja data ficou no passado antes de uma nova contratação, preservando a progressão da tabela sem mover lógica para widgets ou Flame.

`MatchFixture` também passa a persistir `competitionId`, `kickoffHour` e `kickoffMinute`, todos com fallback seguro para saves antigos.



## Mercado, Base e Caixa de Entrada — schema 9 (0.1.1.46)

A `0.1.1.46` amplia `CareerState` sem alterar IDs persistidos existentes. Os novos campos são opcionais na desserialização e recebem listas vazias quando ausentes, permitindo abrir diretamente saves do schema 8:

- `scoutingReports`: progresso de observação por `playerId`;
- `transferNegotiations`: propostas do usuário com valores, salário, duração, bônus, parcelas, resposta e interesse concorrente;
- `transferInstallments`: obrigações futuras de transferências parceladas;
- `inbox`: mensagens persistentes derivadas de `CareerEvent`, com flags de lida/importante/arquivada e referências acionáveis;
- `youthAcademy`: atletas da base com `Player.id` próprio e persistente; ao promover, o mesmo ID é movido para o elenco profissional.

O SQLite continua armazenando o payload JSON da carreira; não é criada arquitetura paralela. `CareerState.fromJson` normaliza o payload antigo para `currentSchemaVersion = 9`, e `CareerController.openCareer` completa somente estruturas deriváveis (como a base inicial e a caixa a partir de notícias existentes) antes de salvar novamente.

Parcelamentos novos comprometem o valor total no `transferBudget` no fechamento para impedir reutilização do orçamento, mas movimentam o `money` por entrada e parcelas mensais persistidas. Compras diretas antigas continuam à vista, preservando o comportamento anterior.

## Administração do clube — schema 10 (0.1.1.50)

`CareerState.clubAdministration` guarda o plano orçamentário do clube atual e as propostas de patrocínio. O campo é opcional na leitura: saves schema 9 recebem um plano derivado do caixa/orçamento existente e mantêm todos os IDs persistidos.

O plano separa transferências, salários, estrutura, categoria de base, estádio e outros departamentos. Transferências continuam usando `Club.transferBudget`; os demais valores são administrados pelo mesmo estado e investimentos no Estádio geram `FinanceTransaction` real.

Contratos aceitos permanecem em `Club.sponsorships`. Propostas pendentes, contrapropostas e decisões ficam no estado administrativo, chegam à Caixa de Entrada e expiram pelo avanço diário. Ao trocar de clube ou temporada, o engine prepara um plano compatível para o empregador atual sem transportar orçamento do clube anterior.


## Banco de técnicos — schema 11 (0.1.1.56)

`CareerState.managers` passa a persistir a base de técnicos da carreira usando o próprio `ManagerProfile`, sem criar controller ou armazenamento paralelo. Cada técnico possui ID estável independente do nome exibido e pode estar associado a um clube, livre ou ser o personagem controlado pelo usuário.

`ManagerProfile` mantém todos os campos antigos e acrescenta, com fallback, `id`, `birthDate`, `currentClubId`, `contractUntilSeason`, `reputation`, `style`, `preferredFormation`, `preferredMentality`, `experienceYears`, `overall` e `userCreated`. O técnico do usuário continua em `CareerState.manager`; a lista `managers` é o banco completo e mantém a mesma instância lógica por ID, evitando duplicação durante a criação da carreira.

Saves schema 10 ou anteriores sem `managers` são normalizados em memória: o técnico do usuário é preservado e recebe ID estável quando necessário; os demais clubes recebem referências derivadas de seus IDs e do `managerName` já persistido. Nenhum `Club.id`, `Player.id`, fixture, resultado, negociação ou regra do Match Engine é recalculado pela migração. Na próxima persistência normal do save, o banco já é gravado no schema 11.


## Seleção de ligas — schema 12 e SQLite v3 (0.1.1.75)

`CareerState.leagueSetup` passa a persistir a profundidade das competições do save com `LeagueLoadLevel.full`, `background` e `unloaded`. A configuração pertence à carreira; não remove nem altera dados do catálogo instalado. Saves schema 11 ou anteriores sem o campo são normalizados para schema 12, mantendo completas as competições que já existiam em seus fixtures e preservando IDs.

`CareerLeaguePlanner` usa somente `CompetitionCatalog` para os presets Rápido, Equilibrado, Mundo amplo e Personalizado. A série que contém `userClubId` é sempre forçada como completa. `CareerFactory` materializa em `CareerState.clubs` somente clubes de competições carregadas, de forma que os loops existentes de recuperação diária, contratos e CPU não percorrem ligas `unloaded` quando o catálogo crescer.

O Match Engine não foi duplicado. `CpuFixtureResolver` roteia competições completas ao `MatchEngine.simulate` existente; apenas partidas CPU de uma competição explicitamente `background` podem usar `BackgroundFixtureResolver`, que retorna placar e estatísticas agregadas sem timeline. Flame permanece exclusivamente visual. Como o catálogo da 0.1.1.75 ainda contém apenas a Série A, todos os jogos reais atuais continuam no caminho completo.

A competição principal passa a derivar seus clubes, fixtures e quantidade total de rodadas. `seasonComplete`, `currentRound`, a temporada seguinte e o rateio de patrocínio deixam de assumir funcionalmente 38 rodadas, embora a Série A atual continue gerando 38.

SQLite v3 mantém `payload` como fonte integral do save, mas adiciona colunas de resumo para a Central de Carreiras. A migração v2 -> v3 lê cada save existente uma única vez para preencher o resumo; depois disso, `listSaves()` não seleciona o payload completo. Isso reduz leitura, alocação e desserialização ao abrir a Central de Carreiras sem transformar o estado da carreira em tabelas paralelas.

A seleção fica imutável depois da criação nesta etapa. Ativar/desativar ligas no meio de uma carreira continua considerado inseguro enquanto não houver política explícita para calendário, classificação, resultados, estatísticas e histórico já disputados. A análise completa está em `docs/LEAGUE_LOADING.md`.

## Fundação multi-competição — schema 13 (0.1.1.76)

`CareerState` passa a persistir `primaryCompetitionId` e um `CompetitionSeasonState` independente por `competitionId`. Cada estado competitivo mantém participantes, progresso/rodada, classificação, estatísticas de jogadores, disciplina e fases da competição. Os campos legados `standings` e `roundIndex` continuam como espelho da competição principal para preservar telas e saves existentes durante a transição.

`fixtures` permanece como calendário global da carreira. Essa decisão permite que um mesmo clube dispute mais de um torneio na mesma temporada sem criar calendários paralelos que desconhecem conflitos de data. `CompetitionCalendarEngine` reconcilia os fixtures das competições carregadas e pode deslocar partidas de menor precedência quando o mesmo clube teria jogos incompatíveis na mesma janela.

`MatchFixture` passa a suportar, de forma opcional e retrocompatível, `stageId`, `groupId`, `tieId` e `leg`. A Série A conserva os IDs históricos de fixture; novas competições usam `competitionId` no prefixo para evitar colisões entre rodadas equivalentes de torneios diferentes.

Estatísticas e disciplina competitivas são armazenadas por torneio. Lesão, condição, fadiga, moral e os totais globais da temporada continuam pertencendo ao `Player`, enquanto gols/cartões/suspensões de uma competição são atualizados no respectivo `CompetitionSeasonState`. O espelho disciplinar antigo do jogador é mantido para a competição principal.

O Match Engine existente não foi substituído nem reescrito: ele continua recebendo os dados da partida e devolvendo `MatchResult`. `MatchCareerImpactEngine` aplica esse resultado ao estado correto da carreira, e `CompetitionSimulationEngine` coordena partidas exclusivamente CPU por data. Competições `full` continuam usando o Match Engine; somente competições explicitamente `background` podem usar a resolução estatística leve já existente. Flame continua exclusivamente visual.

O catálogo distingue escopo (`nationalLeague`, `regionalLeague`, `domesticCup`, `continental`, `world`) e formato (`leagueDoubleRoundRobin`, `leagueSingleRoundRobin`, `knockout`, `groupAndKnockout`, `singleMatch`). Nenhuma competição fictícia é cadastrada nesta fundação. Regulamentos de mata-mata/grupos que ainda não existem no jogo permanecem explicitamente sem gerador, evitando criar calendários incorretos por suposição.

Saves schema 12 são normalizados para schema 13 preservando IDs de clubes e fixtures, transformando a competição principal existente no primeiro estado competitivo. A migração de identidade também percorre participantes, classificações e tabelas internas de fases/grupos para impedir referências antigas quando um pack renomeia/remapeia clubes.
