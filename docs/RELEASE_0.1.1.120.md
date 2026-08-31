# Release 0.1.1.120 — Transferências centralizadas e Finanças compactas

**pubspec:** `0.1.1+121`  
**Android versionCode:** `121`

## Objetivo

Concluir o fluxo de transferências sem sistemas paralelos e manter Finanças
fiel aos dados já persistidos na carreira. A referência visual foi adaptada ao
layout mobile existente, sem criar imagens, clubes, jogadores, valores ou
categorias financeiras fictícias.

## Central de Negociações

- A tela de Transferências mantém `Mercado`, `Observados` e adiciona a aba
  `Negociações` para compras, vendas, renovações e empréstimos.
- Toda proposta entra primeiro na Central com estado persistido: recebida, em
  análise, contraproposta, acordo possível, recusada, concluída ou encerrada.
- Aceitar bases não conclui a operação. A conclusão continua sendo uma ação
  separada, validada novamente contra os dados atuais da carreira.
- Busca, filtros avançados, observação gradual, perfil do jogador e as opções
  antigas de venda permanecem acessíveis no novo desenho.

## Integração de dados

| Sistema | Integração efetiva |
| --- | --- |
| Elenco e jogadores | Compra/venda move o atleta somente na conclusão; empréstimo muda o elenco temporariamente e retorna automaticamente no prazo. |
| Contratos | Renovação vira negociação persistida; o clube de origem continua podendo renovar atleta emprestado. |
| Salários | A folha é sempre derivada do elenco atual; no empréstimo, ela acompanha o clube receptor durante o prazo. |
| Orçamento | Propostas abertas reservam taxa, entrada e luvas para não comprometer acima do orçamento/caixa real. |
| Finanças | Compra, venda, luvas, renovação e parcelas usam `FinanceTransaction` com a data da carreira. |

Parcelas de venda também entram como receita financeira do usuário quando são
liquidadas. Se o comprador não tiver caixa, a parcela permanece pendente e é
notificada sem gerar saldo negativo artificial.

## Finanças sem rolagem principal

O `Resumo` passa a se adaptar à altura disponível. Saldo, métricas e atalhos
permanecem fixos e compactos; gráficos completos, distribuição, histórico,
previsão, patrocínios e orçamento ficam no painel de detalhes rolável. As
abas de Receitas, Despesas e Salários preservam seus próprios detalhes sem
forçar a página principal a rolar.

## Compatibilidade e escopo preservado

- Schema 14 adiciona os campos de empréstimo e tipos de negociação com leitura
  compatível para saves que ainda não possuem esses dados.
- Não foram adicionados dados decorativos, orçamento salarial fictício, taxa de
  empréstimo inventada, categorias financeiras novas sem fluxo ou uma segunda
  lista de lançamentos.
- Match Engine, calendário, resultados, IDs, Estádio e regras de partida não
  foram alterados.
