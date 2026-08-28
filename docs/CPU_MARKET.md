# Mercado controlado pela CPU

A partir da 0.1.1.21, os clubes controlados pela CPU avaliam o próprio elenco antes de contratar. A 0.1.1.22 aprofunda essa base com venda estratégica, concorrência por jogadores, proteção financeira e notícias de mercado. A 0.1.1.24 fecha a primeira fase com planejamento estratégico estável por janela e lista curta de alternativas.

## Responsabilidades

- `CpuSquadNeedsEngine`: mede profundidade e qualidade por posição e informa prioridades de contratação.
- `CpuRecruitmentEngine`: escolhe agentes livres ou alvos em outros clubes considerando posição, overall, potencial, idade, utilidade para o elenco e custo; também monta uma lista curta de alternativas para a prioridade atual.
- `CpuMarketStrategyEngine`: deriva a prioridade e o perfil de mercado do clube durante a janela, com seed estável por carreira/temporada/período e sem adicionar estado persistente ao save.
- `CpuSellingEngine`: decide se um atleta da CPU é negociável considerando profundidade, substitutos, importância, idade, salário, contrato, valor de mercado e situação financeira.
- `CpuFinancialEngine`: limita gasto por operação, preserva reserva de caixa e verifica o impacto da nova folha antes de uma tentativa de contratação.
- `CpuManagerEngine`: orquestra renovações, planejamento dos interesses concorrentes, tentativa de alternativas e no máximo dois negócios por rodada de mercado.
- `CpuMarketNewsEngine`: transforma negócios concluídos em `CareerEvent`, sem criar um segundo sistema de notícias.
- `TransferEngine`: continua sendo o único executor de compra/venda e aplica orçamento, tamanho de elenco, salário e contrato.
- `ContractEngine`: continua sendo a regra central para renovação salarial e duração de contratos.

## Planejamento estratégico por janela

Na `0.1.1.24`, cada clube CPU passa a manter uma prioridade coerente durante a mesma janela de transferências em vez de sortear novamente toda a estratégia a cada rodada. O planejamento é derivado dos dados da carreira e não cria novo campo de save.

- carências emergenciais continuam tendo prioridade absoluta;
- quando existem necessidades próximas, a escolha usa seed estável da carreira, temporada, janela e clube;
- o clube recebe um perfil **oportunista**, **equilibrado** ou **ambicioso** conforme pressão financeira, reputação e margem de caixa/orçamento;
- clubes pressionados favorecem agentes livres e preservação de caixa;
- clubes com maior capacidade financeira podem valorizar mais qualidade/potencial, sem ignorar reserva financeira;
- `CpuRecruitmentEngine` mantém até três alvos para a prioridade;
- se o primeiro alvo for contratado por outro clube, ficar indisponível ou deixar de ser financeiramente viável antes da execução, a CPU pode tentar a alternativa seguinte;
- o limite global de no máximo dois negócios concluídos por rodada continua preservado.

A concorrência pode variar entre rodadas, mas a prioridade e a lista-base do clube permanecem coerentes na mesma janela. Carreiras diferentes podem produzir estratégias diferentes sem tornar o comportamento aleatório ou impossível de reproduzir.

## Venda estratégica

A CPU não disponibiliza automaticamente qualquer jogador que tenha mercado. Antes de uma transferência, o vendedor avalia:

- profundidade mínima da posição;
- existência e qualidade de substitutos;
- importância do jogador no núcleo principal;
- diferença de overall para o nível do clube;
- salário em relação à folha média;
- contrato terminando na temporada atual ou seguinte;
- idade e potencial;
- valor de mercado;
- pressão financeira;
- marcação manual como negociável.

Jogadores-chave sem substituto equivalente ficam protegidos. Excedentes, atletas caros, veteranos e vínculos próximos do fim recebem maior propensão de venda, desde que a profundidade mínima seja preservada.

## Concorrência e aleatoriedade controlada

Os clubes montam seus interesses antes da execução dos negócios. Assim, mais de um clube pode demonstrar interesse no mesmo jogador na mesma rodada, mas o atleta continua podendo ser movimentado apenas uma vez.

A seleção da prioridade e da lista-base de alvos usa seed estável derivada da carreira, temporada, janela e clube. A ordem de disputa entre clubes pode incorporar a rodada, permitindo concorrência diferente sem trocar toda a estratégia do clube. Isso mantém o comportamento reproduzível dentro da mesma carreira, mas evita sequências obrigatoriamente idênticas em carreiras diferentes.

`CpuMarketResult.interests` expõe os interesses planejados e `CpuMarketResult.moves` continua registrando somente os negócios realmente concluídos.

## Comportamento financeiro

Antes de tentar uma contratação, a CPU verifica:

- dinheiro e orçamento de transferências;
- parcela máxima do orçamento que pode ser usada em um único reforço;
- reserva mínima de caixa;
- folha salarial projetada após a contratação;
- urgência real da posição;
- melhoria de qualidade em relação ao elenco atual.

Uma carência emergencial permite maior flexibilidade, mas não autoriza gastar todo o caixa ou assumir salário incompatível com o clube.

## Notícias de mercado

Cada negócio concluído pode gerar no máximo uma notícia persistente no sistema existente de `CareerEvent`. O texto diferencia agente livre, transferência comum, contratação de destaque e jovem de alto potencial. Quando um atleta atende simultaneamente aos critérios de destaque e promessa, overall elevado tem prioridade no título da notícia. Transferências entre clubes mencionam origem, destino e valor, evitando duplicar uma notícia de chegada e outra de saída para a mesma operação.

## Proteções preservadas

- A CPU não compra nem vende automaticamente jogadores do clube controlado pelo usuário.
- Nenhum jogador pode ser movimentado duas vezes na mesma rodada do mercado.
- O vendedor precisa manter `TransferEngine.minimumSquadSize` atletas e a profundidade mínima da posição principal negociada.
- Contratações só ocorrem com a janela aberta.
- Clubes próximos do limite mínimo de elenco continuam recebendo prioridade por meio dos limites centralizados no `TransferEngine`.
- Operações regulares continuam espaçadas para evitar excesso de transferências.
- Não houve mudança de schema do save nem criação de IDs persistidos novos para o mercado CPU.

## Propostas da CPU pelo elenco do usuário

A partir da `0.1.1.23`, o interesse da CPU pelo elenco do usuário deixa de ser apenas informativo e passa a gerar uma negociação real, sem permitir venda automática.

- `CpuUserOfferEngine` escolhe comprador e atleta usando `CpuMarketStrategyEngine`, `CpuSquadNeedsEngine`, `CpuRecruitmentEngine` e `CpuFinancialEngine`, mantendo a proposta alinhada à prioridade atual do comprador.
- A CPU só envia proposta quando a posição é realmente útil para o comprador e a operação respeita caixa, orçamento, folha projetada e teto estratégico.
- Existe no máximo uma proposta recebida ativa por vez, com validade de cinco dias e cooldown para evitar insistência excessiva no mesmo atleta.
- A proposta continua persistida como `CareerEventType.transferOffer`; não foi criada tabela, entidade de save ou estrutura de notícias paralela.
- `TransferController` coordena as ações **Aceitar**, **Recusar** e **Contrapropor**.
- A transferência só é executada por `TransferEngine` depois de aceite explícito do usuário.
- Antes de abrir ou concluir a negociação, a proposta é revalidada contra a situação atual do comprador. Se necessidade, elenco ou finanças mudarem, ela deixa de ser acionável.
- Uma contraproposta dentro do teto pode ser aceita imediatamente. Acima do teto, a CPU pode informar seu valor final; esse valor pode ser aceito ou recusado, sem ciclo infinito de barganha.

A tela **Mercado** e a lista **Notícias e Eventos** apontam para o mesmo evento persistido e abrem o mesmo diálogo de negociação.

## Preparação para futuras ligas

O mercado não deve precisar ser refeito quando novas ligas forem cadastradas. Na `0.1.1.23`, os engines envolvidos nas decisões de mercado trabalham sobre a lista de clubes presente na carreira e tratam `Club.id` como identificador opaco.

Isso significa que a lógica de mercado não depende de:

- prefixo `br-club-*`;
- Série A;
- país Brasil;
- exatamente 20 clubes no universo analisado.

Os limites globais atuais de elenco foram centralizados em `TransferEngine.minimumSquadSize` e `TransferEngine.maximumSquadSize`, e os gatilhos de elenco curto derivam desses valores.

Esta preparação **não significa que regras específicas de cada liga já estejam implementadas**. Quando novas competições entrarem, janelas locais, inscrição, estrangeiros ou outras regras esportivas devem ser fornecidas pelas estruturas de competição e consumidas pelo mercado existente, sem criar engines paralelos por país.


## Encerramento da primeira fase

Com a `0.1.1.24`, a primeira fase do mercado CPU fica coberta por: necessidades, recrutamento de livres, compras entre CPUs, venda estratégica, concorrência, proteção financeira, notícias, propostas negociáveis ao usuário e planejamento por janela com alternativas. Próximos ajustes nesta área devem ser orientados por testes de temporadas longas ou por regras reais das novas competições, evitando adicionar lógica paralela sem evidência.


## Central de Mercado do usuário — 0.1.1.46

A Central de Mercado adicionada na `0.1.1.46` não substitui os engines do mercado CPU. A interface do usuário mantém scouting e estado de negociação em `CareerState`, enquanto a aceitação/execução final continua passando por `TransferEngine`. Dessa forma, limites de elenco, orçamento, contrato e movimentação do jogador continuam centralizados.

O fluxo do usuário possui cinco áreas: **Buscar**, **Observação**, **Negociações**, **Propostas recebidas** e **Histórico**. `PlayerScoutingReport` libera dados gradualmente; `TransferNegotiation` persiste proposta, contraproposta, salário, duração, bônus, parcelas e clubes concorrentes; `TransferInstallmentPayment` registra somente obrigações futuras de acordos parcelados. Agentes livres não geram taxa de transferência nem parcelamento de passe.

Propostas recebidas da CPU continuam usando `CpuUserOfferEngine` e exigem aceite explícito. Não existe venda automática do elenco controlado pelo usuário.
