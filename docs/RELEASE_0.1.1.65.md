# Release 0.1.1.65

## Escopo

Esta release aplica a reformulação visual dos mockups enviados a seis módulos existentes e corrige o limite de substituições da partida ao vivo, sem criar sistemas paralelos nem alterar o schema dos saves.

## Alterações

- **Contratos:** resumo do elenco, filtros e cards de contrato passam a destacar vencimentos, folha e valor do elenco com dados do sistema atual.
- **Categoria de Base:** academia, destaque e lista de jovens usam jogadores e estimativas de potencial já persistidos, mantendo a promoção existente.
- **Departamento Médico:** condição, risco de reincidência, lesões e retornos são reorganizados em um painel de monitoramento derivado de `MedicalEngine`.
- **Estádio:** nova cena noturna animada em `CustomPaint`, resumo de público/receita e grade das instalações já suportadas por `StadiumEngine`; upgrades, orçamento, ingresso e naming rights continuam usando as ações existentes.
- **Dia de Jogo:** confronto, competição, horário, estádio, classificação, forma, moral, condição, pressão, formação e preparação são apresentados de forma mais viva, sem clima ou outros dados inexistentes.
- **Finanças:** caixa, receitas/despesas mensais, evolução do saldo, categorias e indicadores visuais reaproveitam as transações atuais e preservam salários, patrocínios, estádio, orçamentos e histórico.
- **Partida ao vivo:** `LiveMatchController` limita o clube do usuário a cinco substituições por partida e impede o retorno de jogador que já saiu. A tela mostra a contagem e bloqueia a abertura do seletor ao atingir o limite.

## Arquitetura e compatibilidade

- Novos painéis foram separados em arquivos de componentes para evitar telas monolíticas.
- Nenhuma regra da partida foi movida para Flame.
- Nenhum novo controller, schema ou sistema de save foi criado.
- `CareerState` permanece no schema 11; IDs persistentes e saves existentes são preservados.

## Testes e validação

- Testes estruturais de Contratos, Finanças/Estádio e substituição foram atualizados para acompanhar a modularização.
- Foi adicionado `test/live_substitution_limit_test.dart` como regressão para o limite de cinco trocas e o bloqueio de retorno do substituído.
- A validação Flutter local depende da disponibilidade do SDK no ambiente de entrega.
