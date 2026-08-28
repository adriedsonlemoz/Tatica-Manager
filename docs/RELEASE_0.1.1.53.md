# Release 0.1.1.53 — Regressões da Caixa de Entrada

**Android versionCode:** 55  
**pubspec:** `0.1.1+55`  
**CareerState schema:** 10

## Correções

- Atualiza os dois testes restantes de `market_career_system_test.dart` que esperavam incorretamente que a Caixa de Entrada completa tivesse somente uma mensagem.
- A idempotência agora conta exclusivamente `inbox-fixture-alert` e confirma que o mesmo evento continua gerando uma única mensagem acionável.
- O teste de exclusão agora procura exclusivamente `inbox-persisted-news` e confirma que seu tombstone continua único, lido e excluído após nova tentativa de inclusão.
- Os dois testes também confirmam que as três mensagens de propostas comerciais inicializadas pela carreira continuam presentes e não são confundidas com duplicação.

## Compatibilidade

Esta release altera somente testes e metadados de versão. Não modifica código funcional, Match Engine, Caixa de Entrada, patrocinadores, schema, IDs ou saves da 0.1.1.52.

## Evidência do CI

Na execução recebida, o `flutter analyze` passou e 212 testes foram aprovados. Os dois únicos testes com falha encontraram quatro mensagens em vez de uma: a mensagem criada pelo próprio teste e três propostas comerciais legítimas já adicionadas por `CareerFactory.create()`.

O ambiente local não possui Flutter/Dart, portanto a confirmação final dos 214 testes e do build deve ocorrer no GitHub Actions. Nenhum APK foi gerado nesta entrega.
