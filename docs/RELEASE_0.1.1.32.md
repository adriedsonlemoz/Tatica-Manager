# Release 0.1.1.32 — Replay e transmissão da partida

## Resumo

A `0.1.1.32` inicia uma nova camada de apresentação para a partida ao vivo. O objetivo é aproximar o Tática Manager de uma transmissão interativa, mantendo o Match Engine como fonte absoluta de resultado, eventos e trajetórias.

## Arquitetura preservada

Nenhuma jogada é recalculada no Flame. O fluxo continua:

```text
Match Engine
→ MatchEvent / start / end
→ LiveMatchController
→ MatchPresentationDirector
→ MatchPitchGame / widgets de transmissão
```

`MatchPresentationDirector` interpreta apenas como um evento já existente deve ser encenado. Ele não usa `Random`, não escolhe finalizador, não altera placar e não interfere nas probabilidades.

## Replay de gol

Quando a timeline do mesmo minuto contém uma sequência de gol, a apresentação reaproveita os últimos eventos relevantes já produzidos pelo motor, normalmente:

```text
passe → finalização → gol
```

Essa sequência é reproduzida mais lentamente com:

- indicação `REPLAY`;
- câmera aproximada na região da jogada;
- bola refazendo a trajetória já calculada;
- jogador ativo destacado;
- corridas simples de apoio e fechamento;
- botão `Pular`;
- relógio visual temporariamente bloqueado para não avançar enquanto o replay está sendo exibido.

O replay não é uma nova simulação.

## Campo e jogadores

A representação do campo recebeu:

- câmera/zoom interpolado sem alterar as coordenadas do Match Engine;
- pequenos elementos de arquibancada/torcida no enquadramento;
- jogadores desenhados com corpo, cabeça e pernas mais legíveis;
- corridas de apoio em passes;
- aproximação de atacantes em finalizações;
- fechamento de defensores e reação do goleiro;
- deslocamento simples de comemoração após gols.

A orientação horizontal 105:68 permanece intacta.

## Overlays de transmissão

Foi criado um widget independente para os principais acontecimentos dentro do próprio campo:

- gol;
- cartão amarelo;
- cartão vermelho;
- pênalti;
- pênalti defendido;
- lesão;
- substituição;
- replay.

Quando existe jogador relacionado ao evento, o overlay usa o avatar já existente. Gols também podem mostrar a assistência quando ela estiver registrada no `MatchEvent`.

## Placar

O cronômetro recebeu transição animada entre minutos e destaque visual em 45' e 90'. O placar continua com a animação já existente quando o resultado muda, e os contadores de cartões passam a atualizar de forma animada.

## Organização dos arquivos

Para evitar crescimento excessivo do renderer, a apresentação foi separada em:

- `match_presentation_director.dart` — cria cues visuais e sequência de replay;
- `match_player_motion.dart` — deslocamentos visuais dos jogadores;
- `match_pitch_visuals.dart` — desenho do gramado, marcações, jogadores e bola;
- `match_pitch_game.dart` — coordenação do renderer Flame;
- `live_match_broadcast_overlay.dart` — overlays Flutter sobre o campo.

## Compatibilidade

- não altera schema de save;
- não altera IDs;
- não altera `MatchEngine`;
- não altera probabilidades ou estatísticas;
- não altera regras de mercado;
- não move lógica da partida para Flame.

## Testes

Foi adicionado `test/match_presentation_director_test.dart`, cobrindo:

- replay criado apenas a partir de eventos de gol existentes;
- preservação da ordem passe → chute → gol;
- ausência de replay automático em cartão amarelo.

`live_match_visual_experience_test.dart` também foi atualizado para validar a nova camada de apresentação, bloqueio visual do relógio e separação dos componentes.

## Validação executada

Foram executados:

```bash
python3 tool/versioning.py sync
python3 tool/versioning.py verify
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Resultados locais desta entrega:

- `python3 tool/versioning.py sync` — **passou**;
- `python3 tool/versioning.py verify` — **passou**;
- `python3 tool/verify_app_icons.py` — **passou**;
- `flutter pub get` — executado, retornou `flutter: command not found` (exit 127);
- `flutter analyze` — executado, retornou `flutter: command not found` (exit 127);
- `flutter test` — executado, retornou `flutter: command not found` (exit 127);
- `flutter build apk --release` — executado, retornou `flutter: command not found` (exit 127).

Também foi conferido que `match_engine.dart`, `live_match_controller.dart`, `game_controller.dart` e o workflow do GitHub Actions permanecem byte a byte inalterados em relação à 0.1.1.31. O workflow continua publicando somente o APK versionado.

Como a 0.1.1.31 ainda não havia sido compilada pelo usuário, esta release também corrige uma conversão de `clamp` em `ManagerAppearance` para garantir tipos `int` explícitos antes da próxima validação Flutter.
