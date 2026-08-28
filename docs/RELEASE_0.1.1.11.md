# Release 0.1.1.11 — Estabilidade do versionamento e CI

## Objetivo

Corrigir as falhas de testes observadas no GitHub Actions da 0.1.1.10 sem alterar regras de jogo.

## Alterações

- Remove expectativas fixas de `0.1.1.9` e `versionCode 11` dos testes de metadados e infraestrutura.
- Faz os testes lerem `al-sistemas.json` como fonte canônica de versão.
- Mantém a validação de sincronismo entre `al-sistemas.json`, `VERSION`, `app.json`, `pubspec.yaml`, `AppInfo` e Android.
- Mantém o GitHub Actions com um único Artifact: o APK versionado.
- Não publica `pubspec.lock` nos Artifacts.
- Atualiza `Sobre / Novidades` para mostrar as três releases mais recentes.
- Não altera calendário, mercado, contratos, partidas, finanças ou persistência.

## Motivo

A 0.1.1.10 estava correta nos metadados, mas três testes ainda continham números de versão antigos escritos diretamente no código. Com esta correção, novos incrementos de versão não exigem alterar expectativas fixas nesses testes.
