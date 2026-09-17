# Release 0.1.1.146 — Locução oficial da partida

**Android versionCode:** `147`

## Escopo

Esta release substitui a narração principal do Android por um conjunto de falas pré-gravadas fornecidas pelo usuário. A alteração permanece restrita à camada de áudio e apresentação: não modifica Match Engine, probabilidades, placares, disciplina, substituições, saves ou regras de carreira.

## Pacote de voz

Foram integrados 15 clipes WAV em `assets/audio/voice/`:

- `kickoff.wav` — “Começa o jogo!”;
- `yellow_card.wav` — “Cartão amarelo!”;
- `red_card.wav` — “Cartão vermelho! Está expulso!”;
- `foul.wav` — “Falta marcada!”;
- `penalty.wav` — “Pênalti!”;
- `penalty_saved.wav` — “Pênalti defendido!”;
- `save.wav` — “Grande defesa!”;
- `woodwork.wav` — “Na trave!”;
- `substitution.wav` — “Substituição!”;
- `injury.wav` — “Jogador lesionado!”;
- `goal_home.wav` — “Gol do time da casa!”;
- `goal_away.wav` — “Gol do time visitante!”;
- `halftime.wav` — “Fim do primeiro tempo!”;
- `second_half.wav` — “Começa o segundo tempo!”;
- `fulltime.wav` — “Fim de jogo!”.

Os clipes foram recortados, normalizados, convertidos para PCM 16-bit mono em 24 kHz e receberam fades curtos nas bordas. Isso evita cliques e reduz diferenças de ganho entre eventos.

## Runtime

- `MatchNarrationService` agora possui um player `just_audio` dedicado para a voz.
- A locução pode tocar simultaneamente com efeitos de campo e ambiente, sem reutilizar o mesmo player dos efeitos.
- `AudioCatalog` mantém um catálogo separado de `MatchVoiceCue` e seus assets.
- O gol usa `goal_home.wav` ou `goal_away.wav` de acordo com o lado real do clube associado ao evento.
- A fala do segundo tempo usa o novo asset dedicado.
- A finalização comum não recebe uma fala pré-gravada; o efeito de chute continua suficiente e evita misturar a voz antiga do TTS com a nova identidade sonora.
- O TTS do Android permanece como fallback somente se a reprodução de um asset de voz falhar ou quando houver uma mensagem dinâmica sem gravação dedicada.

## Mixagem

O ambiente tratado introduzido na 0.1.1.145 é preservado. O ducking da torcida foi ampliado nos eventos com falas mais longas, principalmente gol, expulsão e pênalti defendido, para a locução permanecer inteligível até o fim.

## Compatibilidade

- configuração de volume da narração continua válida;
- opção de ativar/desativar narração continua válida;
- sons personalizados de evento continuam tendo prioridade sobre os efeitos padrão;
- áudio limpo e playlist de menu não foram alterados;
- Match Engine continua sem dependência de `just_audio`, TTS ou catálogo de áudio.

## Validação

- 15 assets de voz presentes no pacote;
- catálogo de voz aponta apenas para arquivos existentes;
- gol de mandante/visitante é resolvido fora do Match Engine;
- metadados sincronizados para `0.1.1.146` / Android `versionCode 147`;
- `python3 tool/versioning.py verify` deve passar localmente;
- este ambiente de empacotamento não possui Flutter/Dart, portanto `flutter analyze`, `flutter test` e `flutter build apk --release` dependem do GitHub Actions.
