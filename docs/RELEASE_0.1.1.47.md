# Release 0.1.1.47 — Correções do CI do Mercado

**Android versionCode:** 49
**pubspec:** `0.1.1+49`
**CareerState schema:** 9

## Correções

- Escapa o caractere `$` nas opções monetárias dos filtros avançados de `market_dialogs.dart`, removendo os erros de parser/constantes inválidas reportados pelo `flutter analyze`.
- Adiciona o import explícito de `manager_profile.dart` em `manager_career_engine.dart`, permitindo resolver `ManagerCareerHistoryEntry`.
- Converte explicitamente a receita de hospitalidade do Estádio para `int`, respeitando o contrato de `StadiumMatchdayRevenue`.

## Compatibilidade

Não há mudança de schema, IDs persistidos, regras de mercado, lógica financeira ou Match Engine. A release mantém o schema 9 e toda a funcionalidade da 0.1.1.46.

## Validação

A causa foi identificada a partir do log do GitHub Actions da 0.1.1.46, que parou em `flutter analyze`. A validação completa de analyzer, testes e APK deve ser repetida no GitHub Actions para esta release.
