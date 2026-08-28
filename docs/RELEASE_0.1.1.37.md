# Release 0.1.1.37 — Narração falada opcional

## Objetivo

Adicionar uma primeira camada de narração falada à partida sem alterar o Match Engine, sem usar arquivos de voz gravados e sem aumentar significativamente o APK.

## Implementação

- Adicionado `flutter_tts 4.2.5` para usar a voz disponível no próprio aparelho.
- Criado `MatchNarrationService` em `lib/app/audio`, isolando integração com TTS.
- Criado `MatchNarrationFormatter` em `lib/core/audio`, responsável apenas por selecionar e formatar frases derivadas de `MatchEvent`.
- A voz cobre início, finalizações, defesas, trave, gols, faltas, cartões, pênaltis, substituições, lesões, intervalo e fim de jogo.
- Posse e passes não são falados para evitar uma narração excessivamente contínua.
- O segundo tempo possui anúncio explícito na camada de apresentação.
- Replay continua sem disparar novamente os eventos da apresentação, evitando repetição de efeitos e narração.

## Configurações e saves

`AudioSettings` ganhou:

- `narrationEnabled`;
- `narrationVolume`.

Os campos possuem fallback ao carregar saves anteriores, portanto não há migração destrutiva nem mudança de IDs persistentes.

A narração também respeita a chave geral `GameSettings.sound` e o volume mestre.

## Android

O manifesto declara `android.intent.action.TTS_SERVICE` em `<queries>`, conforme exigido para descoberta de mecanismos TTS em Android 11+.

A voz e a qualidade final dependem do mecanismo TTS/idioma instalado no aparelho. Falhas ou ausência de voz nunca interrompem a partida.

## Arquitetura

O fluxo permanece:

```text
Match Engine
→ MatchEvent / timeline
→ apresentação da partida
→ AudioManager
   ├─ efeitos just_audio
   └─ MatchNarrationService / TTS
```

O Match Engine não importa `flutter_tts`, `just_audio` ou qualquer classe da camada de áudio.

## Validação prevista

```text
python3 tool/versioning.py sync
python3 tool/versioning.py verify
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Os comandos Flutter só podem ser marcados como aprovados quando efetivamente executados em ambiente com Flutter.
