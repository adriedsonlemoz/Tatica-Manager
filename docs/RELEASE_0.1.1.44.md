# Release 0.1.1.44

## Escopo

Evolução integrada de áudio, classificação, finanças/patrocínios, primeira versão do módulo de Estádio e correção crítica de disciplina durante a partida.

## Partida e cartões

- o Match Engine passa a manter disciplina por jogador durante a própria timeline;
- o segundo cartão amarelo preserva o segundo amarelo e gera automaticamente um `MatchEventType.red` com motivo `secondYellow`;
- o atleta expulso deixa imediatamente as assignments ativas e não pode voltar a ser escolhido para passe, chute, gol, assistência ou outros eventos posteriores;
- vermelho direto também passa a carregar posição visual para que o renderer possa retirar o atleta do campo 2D;
- Flame apenas representa a expulsão, removendo visualmente o boneco correspondente; a decisão continua no Match Engine;
- substituições ao vivo não oferecem jogador expulso e o `LiveMatchController` também bloqueia a operação como segunda barreira;
- minutos jogados passam a considerar o minuto da expulsão;
- evento, narração, estatísticas e resumo final recebem amarelos/vermelho normalmente.

## Áudio

- substituídos pelos arquivos enviados os efeitos de gol, falta, cartões, chute, defesa, início, intervalo e fim de jogo;
- substituído o som de navegação da interface;
- passe passa a possuir cue própria;
- escanteio, impedimento e tiro de meta ficam catalogados como assets preparados para futuros `MatchEventType` reais;
- música de fundo passa a iniciar desativada por padrão, mantendo a opção manual em Configurações;
- Match Engine continua sem dependência de áudio.

## Classificação

- topo mostra `Campeonato Brasileiro Série A` sem renomear IDs/nomenclaturas internas usadas pelo banco;
- cada posição mostra subida, queda ou estabilidade comparando com a rodada anterior;
- zonas passam a identificar Libertadores, Sul-Americana e Rebaixamento de forma mais clara;
- a tela possui fundação para seletor de competição e exibe o seletor quando mais de uma série estiver disponível.

## Finanças e patrocinadores

- tela financeira reorganizada em saldo, entradas, saídas, balanço, orçamento, folha, categorias e histórico;
- categorias incluem estádio, comercial, salários, transferências, premiações e operações;
- adicionada área de patrocinadores com tipo, valor anual e duração;
- contratos de patrocínio possuem estrutura persistível para valor, duração, bônus, tipo e futura negociação;
- adicionada lista dos maiores salários com navegação direta para o perfil do jogador.

## Estádio

- criado módulo próprio com representação 2D;
- receitas de mando passam a ser separadas em bilheteria, camarotes/hospitalidade, lojas, alimentação e publicidade;
- níveis comerciais do estádio são persistidos com defaults retrocompatíveis;
- receitas são liquidadas pelo `FinanceEngine`, sem duplicação ao visitar a tela.

## Compatibilidade

- nenhum ID persistido foi alterado;
- não há migração destrutiva de SQLite;
- novos campos de clube/estádio/evento são opcionais e possuem fallback para saves anteriores;
- `GameController` não recebeu nova concentração de responsabilidades;
- Flame continua sem decidir resultado ou disciplina.

## Testes adicionados/atualizados

- segundo amarelo → vermelho e remoção das assignments;
- atleta expulso não participa de eventos posteriores do Match Engine;
- serialização do motivo `secondYellow`;
- proteção de substituição para expulsos;
- receitas de estádio e patrocínio;
- persistência retrocompatível do estádio e contratos de patrocinador;
- crescimento da receita comercial com infraestrutura;
- movimento de posição entre rodadas;
- classificação visual e novo nome da competição;
- áudio com música desligada por padrão, novo som de navegação e passe mapeado.

## Validação local

O ambiente desta entrega não possui Flutter/Dart instalados. A validação local fica limitada ao versionamento canônico, inspeções estruturais e integridade do pacote. `flutter analyze`, `flutter test` e `flutter build apk --release` devem ser executados pelo GitHub Actions.
