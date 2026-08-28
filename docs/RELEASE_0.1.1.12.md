# Release 0.1.1.12 — Contratos e jogadores livres

## Objetivo

Fortalecer a lógica de contratos sem alterar o schema dos saves, mantendo `TransferController` responsável por negociação e usando um engine dedicado para o ciclo de vida dos vínculos.

## Decisões importantes

- `PlayerContract.endSeason` continua sendo o campo persistido; não foi criada uma segunda data de vencimento.
- A regra canônica é única: um contrato está vencido quando `endSeason < season`.
- A tela de contratos apenas consulta o `ContractLifecycleEngine` para classificar vínculos; não mantém regra própria de vencimento.
- `ContractLifecycleEngine.reconcile` é idempotente e é usado no avanço diário, na virada de temporada e ao abrir uma carreira.
- Jogadores liberados preservam ID, atributos e histórico, recebem `clubId = null` e entram uma única vez em `freeAgents`.
- Recém-liberados ficam protegidos do preenchimento automático de elencos na mesma virada, evitando que deixem de ser agentes livres imediatamente.
- Quando o preenchimento já existente usa um agente livre antigo, ele recebe um contrato válido antes de entrar no novo clube.
- A renovação passou a considerar também duração de forma explícita, incluindo possibilidade de recusa para vínculos excessivamente longos de veteranos e contraproposta salarial.
- Não houve alteração do banco SQLite nem incremento do schema do save.

## Testes adicionados ou ampliados

- alerta de contrato próximo do vencimento;
- vencimento no avanço diário;
- renovação aceita, recusada e com contraproposta;
- impacto financeiro da renovação;
- transformação em agente livre preservando ID/histórico;
- remoção do clube e ausência de duplicação;
- idempotência do processamento;
- save/load após vínculo vencido;
- reconciliação ao abrir carreira;
- virada de temporada;
- várias temporadas consecutivas sem contratos vencidos em elencos nem IDs simultâneos em clube e livres;
- compatibilidade com saves anteriores.

## CI

O workflow permanece inalterado na política de Artifact: publica somente `tatica-manager-<versão>.apk` e não publica `pubspec.lock`.
