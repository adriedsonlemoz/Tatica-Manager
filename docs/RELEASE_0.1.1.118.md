# Release 0.1.1.118 — Elenco e Classificação conforme os mockups

## Escopo

Esta release aplica os dois mockups aprovados às telas de Elenco e Classificação, mantendo os dados reais da carreira, a navegação existente e a preferência persistente de tema.

## Elenco

- adiciona cabeçalho compacto com escudo, clube, temporada, reputação, caixa e orçamento;
- substitui os cards verticais pela tabela com número, avatar, jogador, posição, geral e moral;
- mantém busca e filtros em ações discretas no topo;
- torna Jogadores, Funções e Status abas funcionais de ordenação;
- adiciona resumo de total de jogadores, brasileiros e estrangeiros;
- mantém o acesso ao perfil ao tocar em qualquer atleta.

## Classificação

- remove a rolagem horizontal da tabela;
- apresenta as colunas Time, J, V, E, D, GP e PTS dentro da largura do telefone;
- preserva destaque do clube do usuário, zonas e movimento entre rodadas;
- adiciona abas funcionais para Tabela, Jogos e Artilheiros;
- adiciona informações reais do campeonato e critérios de desempate;
- mantém troca de competição quando houver mais de uma liga carregada.

## Tema e compatibilidade

- todas as novas superfícies usam `AppColors.background`, `surface`, `surfaceRaised`, `border`, `textPrimary` e `muted`;
- o seletor já existente em Configurações continua alternando entre os modos claro e escuro;
- não altera Match Engine, renderer libGDX/Flame, `CareerState` schema 13, persistência, saves ou IDs;
- adiciona regressões estruturais específicas para as duas telas e atualiza expectativas obsoletas.

## Versionamento

- release visível: `0.1.1.118`;
- Android `versionCode`: `119`;
- pubspec: `0.1.1+119`.
