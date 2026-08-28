# Release 0.1.1.75

## Seleção e profundidade de ligas por carreira

- adiciona uma etapa própria na criação de carreira com os presets **Rápido**, **Equilibrado**, **Mundo amplo** e **Personalizado**;
- usa somente países, campeonatos e divisões existentes em `CompetitionCatalog`; nenhuma liga fictícia foi adicionada;
- persiste no save os níveis `full`, `background` e `unloaded` pelo novo `CareerLeagueSetup`;
- a liga/divisão do clube controlado é sempre forçada como completa;
- clubes de competições não carregadas deixam de entrar no `CareerState` de novas carreiras, preparando a base para expansão real do catálogo;
- a seleção fica definida na criação; alteração pós-início continua desabilitada por exigir regras seguras para calendário, tabela, resultados e estatísticas.

## Partidas e processamento

- ligas completas continuam usando o **Match Engine existente**;
- `CpuFixtureResolver` permite que partidas exclusivamente CPU de ligas em segundo plano usem `BackgroundFixtureResolver`, com placar/estatísticas agregadas e sem timeline visual;
- não foi criado outro Match Engine e Flame permanece somente como camada visual;
- a Série A atual continua no caminho completo, portanto o comportamento das partidas existentes não é rebaixado para a simulação leve;
- número de rodadas da competição principal passa a ser derivado dos fixtures, removendo dependência funcional fixa de 38 rodadas na conclusão da temporada e no rateio de patrocínios.

## Criação e carregamento de saves

- o pacote de clubes já carregado no fluxo de criação é reutilizado ao confirmar a carreira, evitando uma nova leitura do banco/pacote padrão;
- `CareerState.currentSchemaVersion` passa de 11 para 12; saves antigos sem `leagueSetup` são promovidos em memória e suas competições existentes permanecem completas;
- SQLite passa de v2 para **v3** com migração que adiciona um resumo leve para os cards da Central de Carreiras;
- `listSaves()` não seleciona mais o `payload` completo, evitando desserializar todos os clubes, jogadores, técnicos, fixtures e históricos de cada carreira apenas para listar os saves;
- `Club.id`, `Player.id`, `ManagerProfile.id`, `MatchFixture.id` e os payloads existentes são preservados.

## Validação

Foram adicionados/ajustados testes de estrutura e regressão para seleção de ligas, migração do schema 11, obrigatoriedade da liga do usuário, ausência de ligas fictícias, resolução estatística de background, roteamento para o Match Engine existente, fluxo de seis etapas e resumo SQLite sem leitura do payload na listagem.
