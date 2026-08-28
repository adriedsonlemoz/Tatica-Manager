# Release 0.1.1.48 — Testes alinhados à Central de Mercado

**Android versionCode:** 50  
**pubspec:** `0.1.1+50`  
**CareerState schema:** 9

## Causa do CI

O GitHub Actions da `0.1.1.47` concluiu `flutter analyze --no-pub` com **No issues found** e executou 201 testes. Foram 199 aprovados e 2 reprovados. Os dois testes eram verificações estruturais por leitura de arquivos que ainda procuravam detalhes da UI anterior à modularização da Central de Mercado.

## Correções

- `player_avatar_identity_test.dart` passa a seguir a composição real `market_screen.dart` → `market_components.dart` → `PlayerAvatar`, preservando também a garantia de que `TransferEngine.buy` não foi movido para a UI.
- `transfer_ui_structure_test.dart` passa a validar a abertura real de `showIncomingTransferOfferDialog` na Home e na aba **Propostas recebidas**, além das ações centralizadas de aceitar, recusar e contrapropor.
- Não foram reintroduzidos textos, flags ou caminhos obsoletos apenas para satisfazer os testes.

## Compatibilidade

Não há alteração funcional no jogo, nem mudança de schema, saves, IDs persistidos, regras financeiras, transferências ou Match Engine. O `CareerState` permanece no schema 9.

## Validação

- causa confirmada a partir do log do GitHub Actions da 0.1.1.47;
- os asserts atualizados foram conferidos contra a árvore real da release;
- `python3 tool/versioning.py verify` deve permanecer obrigatório;
- `flutter analyze`, `flutter test` e `flutter build apk --release` devem ser repetidos pelo GitHub Actions, pois o SDK Flutter não está disponível no ambiente local desta correção.
