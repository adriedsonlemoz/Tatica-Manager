# Fundação multi-competição

## Objetivo

Permitir que uma carreira possua várias competições simultâneas sem duplicar clubes, atletas, contratos, CPU ou Match Engine. A fundação serve primeiro à futura Série B e aos estaduais, mas não contém IDs ou regras específicas que obriguem o modelo a ser brasileiro.

## Estado do mundo e estado da competição

`CareerState` continua sendo o mundo da carreira: clubes carregados, jogadores, técnicos, mercado, contratos, finanças, data e calendário global.

`CompetitionSeasonState` contém somente o que precisa ser independente por torneio:

- `competitionId`;
- participantes;
- progresso/rodada;
- classificação;
- estatísticas de jogadores;
- disciplina/suspensões;
- fases/grupos;
- conclusão.

O mesmo `Club` e o mesmo `Player` são referenciados por ID em várias competições. Não há cópia de elenco para estadual, liga ou copa.

## Calendário global

Os fixtures de todos os torneios permanecem em `CareerState.fixtures`. Cada fixture possui `competitionId` e pode possuir `stageId`, `groupId`, `tieId` e `leg`.

Essa decisão permite detectar conflitos quando um mesmo clube participa de mais de um torneio. `CompetitionCalendarEngine` concilia as datas carregadas antes que o calendário seja usado pela carreira. Regras específicas de cada campeonato devem continuar no seu gerador/regulamento, não na UI e não no Match Engine.

## Formatos

`CompetitionFormat` diferencia liga em dois turnos, liga em turno único, mata-mata, grupos + mata-mata e jogo único. Somente formatos de liga possuem geração automática nesta release. Formatos de copa são representáveis no domínio, mas o sistema lança erro explícito se alguém tentar ativá-los antes de existir o regulamento real.

Isso é intencional: Copa do Brasil, Libertadores, estaduais e Mundial não devem receber um gerador fictício genérico que produza regulamentos incorretos.

## Catálogo doméstico e internacional

Competições domésticas continuam organizadas em `CompetitionCatalog.countries`. `CompetitionCatalog.internationalCompetitions` é uma coleção separada para torneios supranacionais. Ela fica vazia enquanto não houver dados reais.

Assim, no futuro, Libertadores/Sul-Americana/Mundial não precisarão ser cadastradas como se pertencessem ao Brasil. `CompetitionCatalog.allCompetitions` é a visão única usada pela configuração do save.

## Match Engine

`MatchEngine.simulate` já possui o isolamento desejado: recebe uma partida e devolve `MatchResult`. Ele não deve receber `CareerState`, não atualiza classificação e não persiste save.

`MatchCareerImpactEngine` aplica o resultado ao mundo da carreira. Efeitos físicos permanecem no jogador global; estatísticas e disciplina competitivas são gravadas no `CompetitionSeasonState` correto.

`CompetitionSimulationEngine` escolhe quando jogos CPU devem ser resolvidos. O custo da resolução continua vindo de `CareerLeagueSetup`: `full` usa o Match Engine; `background` pode usar o resolvedor estatístico leve.

## Compatibilidade

O schema 13 preserva os campos legados `standings` e `roundIndex` como espelho da `primaryCompetitionId`. Isso evita uma migração abrupta de todas as telas e mantém compatibilidade de leitura.

Saves schema 12 que ainda tinham apenas uma classificação são promovidos para um `CompetitionSeasonState` da competição principal. IDs históricos da Série A não são alterados.

Migrações de identidade também percorrem participantes e tabelas persistidas dentro das fases/grupos.

## Limites intencionais antes de injetar novos torneios

A fundação permite cadastrar uma Série B real depois do design sem refazer o save. Para ativar estaduais/copas, ainda será necessário cadastrar seus participantes e implementar os regulamentos/calendários específicos. Promoção/rebaixamento, classificação continental e critérios próprios de desempate devem ser engines/regras da competição, não condicionais espalhados pelo `GameController`.

Alterar uma competição de `unloaded` para carregada no meio da temporada continua bloqueado, porque exigiria reconstruir retrospectivamente calendário e resultados. A seleção permanece definida no início da carreira.
