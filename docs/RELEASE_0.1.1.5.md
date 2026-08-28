# Release 0.1.1.5 — Infraestrutura Android e CI

## Objetivo

Estabilizar a base de build antes de avançar temporada, calendário e simulações de longo prazo. Não há mudança intencional de regra de gameplay nesta release.

## Alterações

- plataforma `android/` passa a fazer parte do repositório;
- CI deixa de executar `flutter create` e `flutter clean`;
- Flutter fixado em `3.47.1` (stable);
- Gradle `9.3.1`, Android Gradle Plugin `9.1.0` e Kotlin Gradle Plugin `2.4.0`;
- `actions/checkout@v7.0.1`, `actions/setup-java@v5.6.0`, `subosito/flutter-action@v2.23.0` e `actions/upload-artifact@v7.0.1`;
- cache Gradle habilitado, além dos caches Flutter/Pub;
- o `pubspec.lock` resolvido pelo Flutter 3.47.1 é publicado como Artifact separado para ser incorporado ao repositório sem fabricação manual;
- versão avançada para `0.1.1.5`, `pubspec 0.1.1+7` e Android `versionCode 7`;
- novo teste `android_ci_infrastructure_test.dart` protege a estrutura e o workflow contra regressões.

## Dependências Dart/Flutter

As dependências diretas permanecem nas versões estáveis atuais: `cupertino_icons 1.0.9`, `flame 1.38.0`, `flutter_riverpod 3.4.2`, `sqflite 2.4.3` e `flutter_lints 6.0.0`. Pacotes transitivos não são forçados além das restrições do Flutter/Dart.

## Lockfile

O ZIP de origem não continha `pubspec.lock` e o ambiente local desta entrega não possui Flutter/Dart para resolver o grafo com segurança. O CI executa `flutter pub get` com Flutter 3.47.1 e publica o `pubspec.lock` resultante como Artifact `tatica-manager-0.1.1.5-pubspec-lock`. Esse arquivo deve ser incorporado ao repositório após a primeira execução verde.

## Observação sobre assinatura

O build release do CI continua usando a chave de debug para permitir geração automática do APK sem segredos. Antes de publicar na Google Play, configurar assinatura de produção/Play App Signing em uma etapa própria.

## Próxima frente

Após a validação desta infraestrutura no GitHub Actions, a prioridade funcional é temporada/calendário: rodada 1–38, virada de temporada, save/load e simulação de múltiplos anos.
