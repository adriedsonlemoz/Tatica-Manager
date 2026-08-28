# Release 0.1.1.57

## Correção do GitHub Actions

O log da 0.1.1.56 falhou em `flutter analyze` com `argument_type_not_assignable` em `lib/core/audio/audio_file_store.dart:58`: `IOSink` não podia ser usado diretamente como `StreamConsumer<Uint8List>` no `pipe` produzido por `XFile.openRead()` com Flutter 3.47.1.

A cópia continua sem carregar o arquivo inteiro na memória. Cada música é processada sequencialmente e cada chunk do stream é escrito no `IOSink`, com `flush` e `close` garantidos antes da renomeação do arquivo temporário.

## Repositório oficial

Todas as referências mantidas pelo projeto foram migradas do repositório anterior para:

`https://github.com/adriedsonlemoz/Tatica-Manager`

A mudança inclui README, AI handoff, prompt de continuação, documentos técnicos/históricos e metadados (`al-sistemas.json`, `app.json` e `pubspec.yaml`).

## Compatibilidade

- `CareerState` permanece no schema 11.
- Saves e IDs persistidos não mudam.
- Match Engine não foi alterado.
- GitHub Actions não foi alterado.
- O Artifact continua sendo somente o APK versionado.
