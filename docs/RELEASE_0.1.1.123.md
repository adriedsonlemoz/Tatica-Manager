# Release 0.1.1.123 — Correção dos testes de Finanças e Transferências

**pubspec:** `0.1.1+124`  
**Android versionCode:** `124`

## Diagnóstico do log 77

A análise estática já passou sem qualquer issue. A suíte avançou até os testes e
encerrou com **291 testes aprovados e 3 falhas**. As três falhas estavam ligadas
às alterações recentes de Finanças e Transferências.

## Correções

- Restaura `_FinanceExpansion` como componente realmente utilizado, em vez de
  apenas reintroduzir código morto.
- A área de detalhes financeiros volta a expor **Estádio** e **Patrocínios** em
  seções expansíveis, preservando o pedido de manter a tela principal de
  Finanças compacta e sem rolagem.
- A seção de Estádio abre a gestão real já existente; a seção de Patrocínios
  reutiliza contratos e propostas persistidos da carreira.
- A renovação contratual passa a adicionar o lançamento financeiro depois de
  formar o estado `next`, usando `createdAt: next.currentDate`. Assim o
  livro-caixa usa explicitamente a mesma data do estado que será persistido.

## Escopo preservado

- Nenhum teste foi removido ou relaxado.
- Não foram criados modelos financeiros, de estádio ou patrocínio paralelos.
- Compra, venda, renovação e empréstimo continuam centralizados em Negociações.
- Elenco, contratos, salários, orçamento, saves, calendário e Match Engine não
  tiveram suas regras alteradas.
