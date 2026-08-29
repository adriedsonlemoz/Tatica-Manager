# Release 0.1.1.109 — compatibilidade dos natives libGDX com AGP 9

## Causa real do CI

O GitHub Actions da 0.1.1.108 concluiu `flutter pub get`, `flutter analyze` e os testes e chegou ao `flutter build apk --release`. O Gradle falhou em `android/app/build.gradle.kts` porque o Android Gradle Plugin 9.1 não permite passar uma instância de `Provider` para o `AndroidSourceSet` de `jniLibs`.

A linha problemática registrava o diretório `layout.buildDirectory.dir(...)` diretamente com `sourceSets.getByName("main").jniLibs.srcDir(...)`. No AGP 9, `android.sourceset.disallowProvider` é habilitado por padrão e diretórios gerados devem ser conectados pela Variant Sources API.

## Correção

- a extração dos quatro classifiers nativos do libGDX passa a usar `ExtractGdxNativesTask`, com `ConfigurableFileCollection` como entrada e `DirectoryProperty` como saída;
- `androidComponents.onVariants` registra essa saída em `variant.sources.jniLibs?.addGeneratedSourceDirectory(...)`;
- o próprio AGP passa a conhecer a dependência entre o diretório JNI gerado e a tarefa que o produz;
- os `dependsOn` manuais de `preBuild`/`merge*JniLibFolders` deixam de ser necessários;
- não é usado o opt-out `android.sourceset.disallowProvider=false`.

## Testes

`test/libgdx_match_renderer_integration_test.dart` foi atualizado para exigir a Variant Sources API e rejeitar tanto o registro antigo via `jniLibs.srcDir(generatedGdxNatives)` quanto o opt-out do AGP.

## Compatibilidade

- libGDX permanece em 1.14.2;
- Match Engine permanece integralmente em Dart;
- Flame permanece como fallback fora do Android;
- `CareerState` permanece no schema 13;
- saves e IDs persistidos não foram alterados.

## Validação

`python3 tool/versioning.py verify` deve passar nesta entrega. `flutter pub get`, `flutter analyze`, `flutter test` e `flutter build apk --release` dependem do ambiente Flutter/GitHub Actions.
