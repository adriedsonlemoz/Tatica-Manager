# Release 0.1.1.7 — Ícone oficial e correção do build Android

## Objetivo

Oficializar o novo ícone do Tática Manager nas plataformas móveis e corrigir a falha do GitHub Actions que impedia o APK release de compilar.

## Ícone

- A arte completa enviada pelo projeto foi preservada em `assets/brand/launcher/icon-full.png` e também passa a ser a identidade visual usada dentro do app.
- Android legado recebe `ic_launcher` e `ic_launcher_round` em mdpi, hdpi, xhdpi, xxhdpi e xxxhdpi.
- Android 8+ recebe Adaptive Icon com `foreground` transparente e `background` separados.
- O foreground foi dimensionado para permanecer dentro da zona segura central de 66/108 do canvas adaptativo; a arte não foi recortada nem redesenhada.
- O iOS recebe `AppIcon.appiconset` completo para iPhone, iPad e App Store, incluindo 1024×1024, sempre a partir da arte completa e sem cantos arredondados gravados.
- As três artes-fonte originais permanecem no projeto com hashes SHA-256 registrados em `assets/brand/launcher/source-hashes.json`.

## Correção do log de erro

O Workflow anterior passou por `flutter analyze` e pelos 18 testes, mas falhou em `:app:compileReleaseKotlin` porque Java compilava para JVM 17 e Kotlin para JVM 21.

A correção desta release:

- aplica explicitamente o Kotlin Gradle Plugin no caminho de compatibilidade usado pelo Flutter com `android.builtInKotlin=false`;
- fixa `kotlin.compilerOptions.jvmTarget` em JVM 17;
- mantém `compileOptions` Java em 17;
- executa o GitHub Actions com Java 17;
- adiciona `tool/verify_app_icons.py` ao CI antes de resolver dependências.

O aviso `gradle cache is not found` observado no primeiro build não é erro; significa apenas que ainda não havia cache salvo para aquela chave.

## Versionamento

- Release visível / Android `versionName`: `0.1.1.7`
- `pubspec.yaml`: `0.1.1+9`
- Android `versionCode`: `9`

## Testes/validações

- `test/app_icon_assets_test.dart` valida tamanhos de launcher legacy, Adaptive Icon e AppIcon iOS;
- `test/android_ci_infrastructure_test.dart` protege JVM 17 e a etapa de validação de ícones;
- `tool/verify_app_icons.py` valida PNGs, transparência esperada, manifesto Android, XML adaptativo, catálogo iOS e integridade das artes-fonte usando apenas a biblioteca padrão do Python.

## Validação ainda necessária

O ambiente de empacotamento desta entrega não possui Flutter/Android SDK. O GitHub Actions deve confirmar `flutter analyze`, `flutter test` e `flutter build apk --release`. Em aparelho, conferir especialmente o recorte do Adaptive Icon em launcher circular e squircle.
