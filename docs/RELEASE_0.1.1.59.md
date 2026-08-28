# Release 0.1.1.59

## Nova Home premium

- Remodela a Home seguindo a referência visual fornecida, mantendo a tela totalmente dinâmica e ligada aos dados reais da carreira.
- Novo cabeçalho com escudo, nome do clube, temporada/competição, próximo jogo, caixa de entrada e acesso ao perfil do técnico.
- Adiciona quatro cards compactos para posição/pontos, próximo jogo, competição e desempenho recente.
- Próxima partida ganha composição de transmissão com escudos, estádio, horário e competição, sem alterar calendário ou Match Engine.
- Forma recente e a reputação calculada pelo sistema de carreira são apresentadas em um painel de confiança/momento, apenas como leitura visual.
- Avanço diário/dia de jogo recebe faixa verde destacada preservando o mesmo `GameController` e o fluxo de apresentação existente.
- Notícias passam a aparecer em cards horizontais com avatar quando houver jogador relacionado.
- Classificação compacta e os três artilheiros ficam integrados à Home com navegação para tabela, clube, jogador e Estatísticas.
- Atalhos de Táticas, Calendário, Finanças, Base e Departamento Médico continuam disponíveis.
- Barra inferior recebe contorno/sombra compatíveis com o novo padrão sem alterar seus destinos.

## Arquitetura e compatibilidade

- Não altera `CareerState` schema 11.
- Não altera saves, IDs persistidos, clubes, jogadores, técnicos ou import/export.
- Não altera nenhum arquivo ou regra do Match Engine.
- Não cria controller ou sistema de dados paralelo; a Home apenas reorganiza e apresenta informações já existentes.

## Testes

- Atualiza o teste estrutural da Home para validar os novos componentes e preservar a classificação compacta e o avanço diário contextual.
- `AppInfo.recentReleases` permanece no limite histórico de três releases esperado pelos testes do projeto.

## Versionamento

- Release visível: `0.1.1.59`
- pubspec: `0.1.1+61`
- Android versionName: `0.1.1.59`
- Android versionCode: `61`
