# Release 0.1.1.109 — playlist reduzida e versionamento simplificado

**Android versionCode:** `110`  
**pubspec:** `0.1.1+110`

## Alterações

- remove `al-sistemas.json` da raiz do projeto;
- elimina a dependência desse arquivo em `tool/versioning.py`, GitHub Actions e testes;
- define `VERSION` como fonte canônica da versão visível e usa o build do `pubspec.yaml` como `versionCode` Android;
- substitui a playlist padrão do menu pela lista reduzida enviada em `musicasmenu.zip`;
- mantém exatamente cinco faixas: Jim Yosef — Lights, Disfigure — Blank, DEAF KEV — Invincible, Cormak — Flavors e David Bulla — Unexpected;
- remove as outras seis faixas OGG da pasta `assets/audio/menu/` e do `AudioCatalog`;
- atualiza testes de áudio para exigir exatamente essas cinco faixas;
- atualiza README, handoff, prompt de continuação e documentação do sistema de áudio.

## Preservado

- Match Engine e resultados das partidas;
- saves, schemas, IDs e regras de carreira;
- efeitos de interface e partida;
- playlist personalizada do usuário, shuffle, loop, seleção manual e próxima faixa;
- estrutura Android e workflow de geração do APK.

## Validação local disponível

- `python3 tool/versioning.py sync`;
- `python3 tool/versioning.py verify`;
- conferência de integridade do ZIP e dos cinco assets OGG.

Flutter/Dart não estão disponíveis no ambiente de empacotamento atual; `flutter analyze`, `flutter test` e `flutter build apk --release` continuam sendo executados pelo GitHub Actions.
