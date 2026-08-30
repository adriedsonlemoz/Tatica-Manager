# Release 0.1.1.119 — Finanças conectadas à carreira

**pubspec:** `0.1.1+120`  
**Android versionCode:** `120`

## Objetivo

Refazer a tela de Finanças segundo a referência aprovada, sem criar números,
categorias ou um sistema financeiro paralelo. A fonte de verdade continua
sendo `CareerState.finances`, junto ao caixa, orçamento de transferências e
folha do clube persistidos na carreira.

## Nova interface

- Cabeçalho do clube com escudo, temporada, reputação, caixa e orçamento de
  reforços reais.
- Abas `Resumo`, `Receitas`, `Despesas` e `Salários`.
- Gráfico de saldo com seleção de últimos 3, 6 ou 12 meses.
- Cards de receita, despesa e resultado do mês.
- Distribuição percentual apenas das despesas efetivamente registradas.
- Filtros por categoria nas abas de receitas e despesas.
- Lista de salários atual derivada do elenco e links para os contratos e
  perfis dos jogadores.
- Atalhos operacionais para Estádio, Mercado, Contratos e Orçamentos.

## Dados e integração

`FinanceDashboardEngine` reconstrói o saldo de cada mês usando o caixa atual
e os lançamentos posteriores. Assim não foi necessário adicionar snapshots ou
uma estrutura financeira duplicada aos saves existentes.

| Origem | Informação exibida |
| --- | --- |
| Estádio | Bilheteria, camarotes, lojas, alimentação, publicidade e obras |
| Mercado | Compras, vendas, parcelas e orçamento de transferências |
| Contratos | Folha atual, renovações e luvas |
| Patrocínios | Contratos ativos, propostas e receitas por rodada |
| Administração | Orçamentos departamentais e saldo disponível |

A previsão usa a média de até três meses fechados que já possuem lançamentos.
Se a carreira ainda não tiver essa base, a tela informa que a previsão ainda
não está disponível.

## Correção de linha do tempo

Compra, venda, renovação e bônus de assinatura passaram a criar
`FinanceTransaction` usando `career.currentDate`. A tela também limita apenas
para visualização dados antigos gravados com data incompatível com a temporada,
sem alterar o save original.

## Escopo preservado

- Não foram criados custos fictícios para Categoria de Base, Comissão técnica,
  dívidas, impostos ou moedas secundárias.
- Não altera Match Engine, resultados, probabilidades ou fluxo pós-jogo.
- Não altera schema, IDs, persistência, Estádio ou regras de transferências.
