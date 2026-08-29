# Release 0.1.1.108 — correção do analyzer da integração libGDX

## Causa real do CI

O GitHub Actions da 0.1.1.107 concluiu `flutter pub get`, mas interrompeu a execução em `flutter analyze --no-pub` com oito issues de nível `info`. O workflow trata qualquer issue do analyzer como falha, portanto a compilação Kotlin/libGDX ainda não chegou a ser executada.

Os apontamentos eram:

- um import redundante de `package:flutter/material.dart` em `libgdx_match_pitch_controller.dart`;
- ausência de `@override` em sete membros de `MatchPitchGame` que implementam o contrato `MatchPitchController`.

## Correção

- o bridge libGDX remove o import redundante de `package:flutter/material.dart` e mantém `flutter/services.dart`, que já fornece os símbolos utilizados nesse arquivo;
- `isReplayActive`, `blocksClock`, `playEvent`, `updateLineups`, `playEvents`, `skipReplay` e `clearPresentationQueue` de `MatchPitchGame` recebem `@override`;
- nenhuma lógica, duração de evento, coordenada, regra, dependência ou configuração Android foi modificada.

## Compatibilidade

- Match Engine continua integralmente em Dart;
- libGDX continua apenas como renderer Android;
- Flame continua como fallback;
- `CareerState` permanece no schema 13;
- saves e IDs persistidos não foram alterados.

## Validação

- `python3 tool/versioning.py sync` e `python3 tool/versioning.py verify` devem permanecer verdes;
- o log recebido confirma que `flutter pub get` passou na 0.1.1.107;
- `flutter analyze`, `flutter test` e `flutter build apk --release` precisam ser confirmados pelo próximo GitHub Actions, pois Flutter/Dart não estão instalados neste ambiente.
