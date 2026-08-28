# Release 0.1.1.33 — Partida 2D avançada

## Resumo

A `0.1.1.33` aprofunda a camada de apresentação da partida iniciada na `0.1.1.32`. O foco desta release é tornar os grandes momentos mais vivos sem transformar Flame em simulador de regras.

O fluxo continua:

```text
Match Engine
→ MatchEvent / trajetórias
→ LiveMatchController
→ MatchPresentationDirector
→ Flame / overlays de transmissão
```

## Mergulho do goleiro

A representação do goleiro agora possui pose específica de mergulho em:

- finalizações;
- defesas;
- gols;
- pênaltis defendidos;
- bolas na trave.

A direção visual do mergulho deriva da trajetória já registrada no evento.

## Pênaltis

O pênalti ganhou uma apresentação própria:

- cobrador posicionado no ponto da cobrança;
- demais jogadores aguardam fora da região da cobrança;
- goleiro fica preparado sobre a linha;
- câmera aproxima a área;
- a bola só parte para o gol no evento de resultado (`goal` ou `penaltySaved`), evitando antecipar visualmente o desfecho.

Quando o pênalti é defendido, o evento passa também a registrar o `playerId` do goleiro e o cobrador em `secondaryPlayerId`, enriquecendo a apresentação sem adicionar sorteio novo.

## Bola na trave

Foi adicionado `MatchEventType.woodwork`.

A bola na trave:

- nasce no **Match Engine**, não no renderer;
- usa o mesmo sorteio já feito para o desfecho de uma finalização aberta;
- não altera o placar;
- continua contando a finalização normal já registrada;
- produz trajetória até o poste e rebote para dentro do campo;
- recebe overlay `NA TRAVE!` e replay curto.

A distribuição preserva a chance anterior de defesa do goleiro; o evento de trave ocupa parte das finalizações que antes terminavam sem outro evento destacado.

## Comemorações

Gols agora geram uma pequena comemoração coletiva:

- artilheiro corre para uma região próxima ao ataque;
- companheiros próximos se agrupam;
- a pose visual usa braços erguidos e movimento vertical discreto;
- o efeito é puramente visual e não interfere na formação usada pelo motor.

## Estádio e torcida

A área Flame foi reorganizada para separar campo e ambientação. Foram adicionados:

- arquibancadas superiores, inferiores e laterais;
- pontos de torcida com cores dos clubes;
- reação visual da torcida proporcional à importância do lance;
- placas/LED animadas;
- bancos de reservas;
- iluminação discreta nos cantos;
- campo agora desenhado dentro de uma área própria, preservando a proporção horizontal 105:68 do painel.

A ambientação ficou em `match_stadium_visuals.dart`, evitando inflar o renderer principal.

## Overlays de transmissão

Os overlays foram separados em componentes reutilizáveis e agora tratam de forma específica:

- gol;
- bola na trave;
- pênalti defendido;
- cartão amarelo;
- cartão vermelho;
- substituição;
- replay.

Cartões usam uma representação visual de cartão e substituições exibem entrada/saída com avatares e setas.

## Replay

Além de gols, a apresentação agora pode reproduzir:

- bola na trave;
- pênalti defendido.

Os replays continuam consumindo somente os `MatchEvent` já existentes. Nenhuma jogada é recalculada durante o replay.

## Intervalo e fim de jogo

Foi criado um overlay de transição específico para:

- `INTERVALO`;
- `FIM DE JOGO`.

A transição mostra o placar atual e desaparece automaticamente, mantendo os painéis de ação já existentes logo depois.

## Organização dos arquivos

A nova camada foi dividida em componentes pequenos:

```text
lib/game/match/renderer/
├── match_pitch_game.dart
├── match_pitch_moment_state.dart
├── match_pitch_visuals.dart
├── match_player_motion.dart
├── match_player_visuals.dart
├── match_presentation_director.dart
└── match_stadium_visuals.dart

lib/features/match/widgets/
├── live_match_broadcast_overlay.dart
├── live_match_event_hero.dart
├── live_match_phase_transition_overlay.dart
└── live_match_pitch_panel.dart
```

## Compatibilidade

- não altera IDs persistidos;
- não altera schema de save;
- o novo enum de evento é serializado pelo nome, mantendo compatibilidade com saves anteriores;
- `GameController` não recebe nova responsabilidade;
- Flame continua sem escolher gols, cartões, finalizadores ou resultados;
- a única regra nova do motor é o evento raro de bola na trave, que não altera placar.

## Testes adicionados/atualizados

- `match_presentation_director_test.dart`: replay de gol, trave e pênalti defendido;
- `match_woodwork_test.dart`: trajetória de poste/rebote e confirmação de que o evento nasce no Match Engine;
- `live_match_visual_experience_test.dart`: cobertura da nova ambientação, goleiro e transição de fases;
- `match_event_presentation_test.dart`: novo rótulo `Na trave`.

## Versionamento

- release/versionName: `0.1.1.33`;
- pubspec: `0.1.1+35`;
- Android versionCode: `35`.

## Validação executada

- `python3 tool/versioning.py sync` — executado com sucesso após a atualização dos metadados e documentos da release;
- `python3 tool/versioning.py verify` — executado com sucesso em `0.1.1.33 / versionCode 35`;
- `python3 tool/verify_app_icons.py` — executado com sucesso;
- `flutter pub get` — executado, mas o ambiente retornou `flutter: command not found` (código 127);
- `flutter analyze` — executado, mas o ambiente retornou `flutter: command not found` (código 127);
- `flutter test` — executado, mas o ambiente retornou `flutter: command not found` (código 127);
- `flutter build apk --release` — executado, mas o ambiente retornou `flutter: command not found` (código 127).

Portanto, análise estática, testes Flutter e build release ainda dependem do GitHub Actions. O workflow permanece configurado para publicar somente o APK versionado.
