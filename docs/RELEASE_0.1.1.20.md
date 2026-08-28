# Release 0.1.1.20 — Correção do teste de escudo

## Causa real

O GitHub Actions da `0.1.1.19` passou integralmente pelo `flutter analyze --no-pub` com **No issues found**.

Na etapa `flutter test`, 97 testes passaram e 1 falhou:

- `test/club_editor_ui_test.dart`: o teste esperava que o editor exibisse `32–1024 px`;
- o diálogo real exibia a mesma regra como `entre 32 e 1024 px`.

A validação funcional de imagem já estava correta. O erro era apenas divergência entre a apresentação textual da regra e a expectativa do teste.

## Correção

O diálogo central de **Ícone / escudo** agora exibe explicitamente:

`32–1024 px`

A validação continua usando `ClubIconValidator.validateBytes`, sem alterar formatos, tamanho máximo, proporção ou regras do banco.

Também foram corrigidas referências antigas de versão que ainda permaneciam no topo do `README.md`, e `tool/versioning.py` foi reforçado para validar essas linhas canônicas.

## Arquitetura

Não houve alteração em `GameController`, Match Engine, calendário, mercado, contratos ou lógica esportiva.

## Versão

- release/versionName: `0.1.1.20`;
- pubspec: `0.1.1+22`;
- Android versionCode: `22`.

## CI

O log da `0.1.1.19` confirma:
- `flutter analyze`: aprovado, sem issues;
- `flutter test`: 97 aprovados, 1 falhou pela divergência textual acima.

O próximo GitHub Actions deve confirmar o conjunto completo de testes e então avançar para o build do APK.


## Validação local

Foram executados com sucesso:

- `python3 tool/versioning.py sync`;
- `python3 tool/versioning.py verify`;
- `python3 tool/verify_app_icons.py`;
- parsing estrutural dos arquivos JSON, YAML e XML;
- conferência do workflow de Artifact.

Os comandos Flutter também foram realmente tentados neste ambiente, mas o executável não está instalado:

- `flutter pub get` → `127` (`flutter: command not found`);
- `flutter analyze` → `127`;
- `flutter test` → `127`;
- `flutter build apk --release` → `127`.

Portanto o GitHub Actions continua sendo a validação obrigatória para analyzer, testes e APK desta release.

## Artifact

O workflow permanece configurado para publicar somente o APK versionado. `pubspec.lock` não é publicado como Artifact.
