# Locução da partida

A release 0.1.1.146 usa 15 clipes de voz fornecidos pelo usuário e armazenados em `assets/audio/voice/`.

| Asset | Evento | Fala |
|---|---|---|
| `kickoff.wav` | início | Começa o jogo! |
| `yellow_card.wav` | amarelo | Cartão amarelo! |
| `red_card.wav` | vermelho | Cartão vermelho! Está expulso! |
| `foul.wav` | falta | Falta marcada! |
| `penalty.wav` | pênalti | Pênalti! |
| `penalty_saved.wav` | pênalti defendido | Pênalti defendido! |
| `save.wav` | grande defesa | Grande defesa! |
| `woodwork.wav` | trave | Na trave! |
| `substitution.wav` | substituição | Substituição! |
| `injury.wav` | lesão | Jogador lesionado! |
| `goal_home.wav` | gol mandante | Gol do time da casa! |
| `goal_away.wav` | gol visitante | Gol do time visitante! |
| `halftime.wav` | intervalo | Fim do primeiro tempo! |
| `second_half.wav` | segundo tempo | Começa o segundo tempo! |
| `fulltime.wav` | fim | Fim de jogo! |

## Tratamento

- WAV PCM 16-bit;
- mono;
- 24 kHz;
- silêncio excedente aparado;
- fades curtos nas bordas;
- ganho normalizado para manter as falas próximas entre si sem clipping.

## Runtime

`MatchNarrationService` tenta primeiro o asset de `MatchVoiceCue`. O TTS do Android só é acionado como fallback caso o asset não possa ser reproduzido ou quando uma mensagem dinâmica não possuir gravação dedicada.

Gol do mandante e visitante são escolhidos pela camada de áudio a partir do clube associado ao evento, sem alterar o Match Engine.
