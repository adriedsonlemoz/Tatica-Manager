# Carregamento de ligas por carreira

## Objetivo

A seleção de ligas pertence ao **save**, não ao banco instalado. O catálogo de competições continua sendo a fonte do mundo disponível e nenhuma liga é apagada da instalação quando fica fora de uma carreira.

A primeira implementação usa somente as competições reais já cadastradas em `CompetitionCatalog`. Nesta release o catálogo contém apenas o Brasil / Liga Nacional / Série A; nenhuma liga fictícia foi criada para demonstrar a interface.

## Análise da arquitetura anterior

Antes da 0.1.1.75, a criação assumia implicitamente um único campeonato completo:

- `CareerFactory` materializava todos os `clubSeeds` no `CareerState`;
- `CareerState` possuía um único conjunto de `fixtures`, `standings` e `roundIndex` e partes da aplicação ainda assumiam 38 rodadas;
- o pacote de identidade já carregado pela tela de criação era lido novamente no `CareerController.createCareer`;
- `CareerCalendarEngine.advanceDay` recuperava os jogadores de todos os clubes existentes no save;
- `CpuManagerEngine.runRound` processava todos os clubes do save no ciclo de contratos/mercado;
- os outros jogos da rodada eram resolvidos com `MatchEngine.simulate`, mesmo quando eram CPU x CPU;
- `SqliteCareerRepository.listSaves()` lia e desserializava o payload JSON completo de todos os saves para obter escudo, colocação e próximo jogo.

Com uma única Série A esses custos são aceitáveis, mas cresceriam diretamente quando o catálogo recebesse novos países e divisões.

## Modelo persistido — CareerState schema 12

`CareerState.leagueSetup` guarda um `CareerLeagueSetup` com:

- `preset`: `fast`, `balanced`, `broad` ou `custom`;
- mapa `competitionId -> LeagueLoadLevel`;
- níveis `full`, `background` e `unloaded`.

Regras:

1. a competição que contém o clube do usuário é sempre normalizada para `full`;
2. IDs de clubes e competições não são renomeados;
3. clubes de competições `unloaded` não são materializados no novo save;
4. ligas fora do save continuam intactas no catálogo/banco de instalação;
5. saves schema 11 ou anteriores, que não possuem `leagueSetup`, são lidos como legado e suas competições já existentes ficam `full`.

A seleção não pode ser alterada depois que a carreira começa nesta etapa. Adicionar ou remover competições no meio do save exigiria definir reconstrução de calendário, rodadas, resultados, tabela, estatísticas e histórico. Isso deve ser projetado separadamente antes de ser liberado.

## Presets na criação

`CareerLeaguePlanner` gera e normaliza os presets usando exclusivamente `CompetitionCatalog`:

- **Rápido**: mantém a liga do clube do usuário completa e prioriza o menor mundo ativo;
- **Equilibrado**: reserva espaço para combinação de ligas completas e segundo plano;
- **Mundo amplo**: marca como completas as competições realmente disponíveis;
- **Personalizado**: permite escolher manualmente os níveis, exceto descarregar a liga do usuário.

A UI mostra apenas `Desempenho estimado: Rápido / Normal / Pesado`. RAM, threads e números internos não são expostos ao jogador.

Com o catálogo atual de uma única liga, os presets naturalmente resultam no mesmo mundo efetivo: a Série A completa. Quando novas competições reais forem adicionadas ao catálogo, elas passam a aparecer automaticamente na etapa sem precisar criar dados de demonstração.

## Partidas CPU e Match Engine

Não existe segundo Match Engine.

`CpuFixtureResolver` apenas decide **qual resolução já permitida deve ser usada** conforme o nível persistido da competição:

- `full` -> continua chamando `MatchEngine.simulate`;
- `background` -> usa `BackgroundFixtureResolver`, que gera placar e estatísticas agregadas determinísticas sem timeline visual;
- a partida do jogador continua no fluxo do Match Engine atual.

`BackgroundFixtureResolver` não usa Flame, não produz animação e não toma responsabilidade pela partida do jogador. Flame continua somente como representação visual da timeline calculada pelo Match Engine.

Nesta release não existem fixtures reais de uma segunda competição no catálogo, portanto o caminho de segundo plano fica preparado e testado sem alterar os resultados atuais da Série A.

## Temporada, tabela e número de rodadas

`CareerState` passa a derivar:

- `primaryCompetitionId`;
- clubes/fixtures da competição principal;
- `totalUserRounds` a partir do calendário real.

A conclusão da temporada, `currentRound`, a geração da temporada seguinte e o rateio de patrocínio do usuário deixam de depender diretamente do número 38. Para a Série A atual o resultado continua sendo 38 rodadas.

O estado ainda mantém uma única classificação principal. Quando uma segunda liga real for adicionada, a próxima evolução deverá persistir estado competitivo por competição (classificação/estatísticas/calendário) sem duplicar controllers ou Match Engine. A estrutura de seleção e filtragem criada aqui é a base para essa extensão.

## CPU, mercado, contratos e avanço diário

Somente clubes de competições carregadas entram em `CareerState.clubs` nas novas carreiras. Por consequência, os loops existentes de:

- recuperação diária;
- contratos;
- mercado CPU;
- desenvolvimento;
- gerenciamento de elenco;

não percorrem clubes de ligas `unloaded`.

Clubes de ligas `background`, quando existirem no catálogo real e forem selecionados, continuam no save e podem participar do mercado/contratos. A resolução de suas partidas pode usar o caminho estatístico mais barato.

## SQLite v3 e listagem dos saves

O payload JSON integral continua em `career_saves.payload` e continua sendo a fonte da carreira aberta.

SQLite v3 acrescenta somente metadados derivados para a Central de Carreiras: identidade visual mínima do clube do usuário, colocação, próximo adversário/data/local e total de rodadas. A migração v2 -> v3 calcula esse resumo uma única vez para saves existentes.

`listSaves()` consulta apenas essas colunas e não seleciona `payload`. Assim, abrir a Central de Carreiras deixa de transferir/desserializar todos os jogadores, fixtures, técnicos, mercado e histórico de cada save apenas para montar cards.

## Gargalos que permanecem preparados para evolução futura

- O payload de uma carreira aberta continua sendo um JSON único no SQLite. Com muitas ligas completas, o tamanho do save ainda crescerá conforme os clubes efetivamente carregados.
- A classificação persistida ainda representa a competição principal; múltiplas tabelas reais devem ser adicionadas quando houver uma segunda liga real para validar o fluxo.
- O `CpuManagerEngine` continua executando mercado/contratos sobre todos os clubes carregados, como desejado para ligas completas e de segundo plano. Se o mundo crescer muito, frequência e profundidade da CPU de background podem ser reduzidas em uma etapa específica, sem mover essa lógica para `GameController`.
- Não é seguro habilitar troca de ligas após a criação até existir política explícita para calendário, resultados e estatísticas já disputados.
