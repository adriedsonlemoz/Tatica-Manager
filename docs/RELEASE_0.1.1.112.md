# Release 0.1.1.112 — correção de Sobre / Novidades

**Android versionCode:** `113`  
**pubspec:** `0.1.1+113`

## Erro corrigido

O GitHub Actions da 0.1.1.111 passou no `flutter analyze`, mas encerrou nos testes com **282 testes aprovados e 1 falha**. O teste `test/app_info_test.dart` exige que `AppInfo.recentReleases` mantenha exatamente três releases, enquanto a lista havia acumulado mais entradas.

## Alteração aplicada

- mantém `AppInfo.recentReleases` com exatamente três itens;
- adiciona a 0.1.1.112 como release atual e mantém 0.1.1.111 e 0.1.1.110 como as duas anteriores;
- remove da lista exibida no aplicativo as releases mais antigas, sem apagar seus arquivos `docs/RELEASE_*.md`;
- não modifica o teste para aceitar um estado incorreto: preserva a regra original de três novidades recentes.

## Preservado

- as cinco músicas otimizadas da 0.1.1.111, byte a byte;
- playlist, player e efeitos de áudio;
- Match Engine;
- saves, IDs, regras e resultados;
- `al-sistemas.json` continua removido.
