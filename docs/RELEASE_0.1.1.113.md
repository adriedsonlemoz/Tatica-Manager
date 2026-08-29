# Release 0.1.1.113 — reintegração da qualidade visual da 0.1.1.107 ao renderer libGDX

## Contexto

A 0.1.1.107 existiu como dois pacotes divergentes a partir do mesmo ponto de partida:

- um pacote aprimorou somente a apresentação do renderer Flame (`movimentação visual natural`): aceleração/frenagem real dos jogadores, curvas determinísticas de deslocamento, atrasos escalonados no retorno à formação, cobrança de pênalti que não puxa os 22 atletas para uma coluna, e memória de âncora dos rótulos de nome entre frames;
- o outro pacote partiu do mesmo ponto, mas seguiu para a integração do libGDX como renderer nativo Android (`libGDX integrado ao campo da partida`), evoluindo até a 0.1.1.112 através das correções de CI documentadas em `RELEASE_0.1.1.108.md` a `RELEASE_0.1.1.112.md`.

Como os dois pacotes divergiram do mesmo commit, a integração libGDX nunca recebeu as melhorias de movimento/rótulos, e o pacote de movimento nunca recebeu a integração libGDX. Esta release une os dois.

## O que foi reintegrado

Do pacote de movimento (0.1.1.107), para dentro da base com libGDX (0.1.1.112):

- `lib/game/match/renderer/match_player_motion.dart`: `MatchPlayerMotionState` (velocidade, atraso preparado, curva de trajetória) e as funções `moveTeam`, `preparePenaltyTransitions`, `prepareFormationReturn`, `clearPreparedTransitions`, `_beginTransition`, `_advancePlayer`, `_approach`;
- `lib/game/match/renderer/match_player_labels.dart`: `MatchPlayerLabelPlacement` e a preferência de âncora (`preferredAnchor`) em `_place`, que evita que um rótulo troque de posição a cada frame sem necessidade;
- `lib/game/match/renderer/match_player_visuals.dart`: taxa de passada/balanço refinada e `idleBreath` separado do deslocamento do boneco;
- `lib/game/match/renderer/match_pitch_game.dart`: reconstruído a partir da versão da 0.1.1.107 (que já contém `_homeMotionStates`/`_awayMotionStates`, `_labelPlacements`, `_eventUsesStartPosition` e o uso de `preparePenaltyTransitions`/`prepareFormationReturn`), com a interface `MatchPitchController` (introduzida pela integração libGDX) reaplicada por cima: `implements MatchPitchController`, `@override` em `isReplayActive`, `blocksClock`, `playEvent`, `updateLineups`, `playEvents`, `skipReplay`, `clearPresentationQueue`, e `disposeController()`.

Do pacote libGDX (0.1.1.112), preservado integralmente:

- `MatchPitchController` (contrato), `LibGdxMatchPitchController`, `libgdx_match_pitch_view.dart`;
- `MainActivity`, o módulo Kotlin `matchgdx` e o pipeline Gradle (`ExtractGdxNativesTask`, Variant Sources API, natives arm64-v8a/armeabi-v7a/x86/x86_64);
- a seleção de renderer por plataforma em `match_screen.dart` (`LibGdxMatchPitchController` no Android, `MatchPitchGame`/Flame fora dele);
- o encaixe visual do `SurfaceView` em `live_match_pitch_panel.dart` (`SizedBox` explícito 105:68, `Clip.hardEdge`, `initExpensiveAndroidView`).

O `MatchPitchGame` (Flame) passa a ser, ao mesmo tempo, o renderer de fallback fora do Android **e** a base funcional de onde a integração libGDX herdou seu contrato — mas o Kotlin/libGDX continua fazendo sua própria interpolação nativa (`FitViewport`, `LibGdxMatchRenderer`), sem chamar nada deste arquivo Dart.

## Testes

- `test/match_player_motion_visual_test.dart` (existia somente na 0.1.1.107) volta a fazer parte da suíte, cobrindo `penaltySetup`, aceleração/frenagem até o alvo exato e atraso preparado;
- `test/live_match_visual_experience_test.dart` recupera o teste "renderer mantém estado visual de movimento e de posição dos nomes" removido pela integração libGDX, validando `_eventUsesStartPosition`, `preparePenaltyTransitions`, `prepareFormationReturn` e `placementStates: _labelPlacements` em `match_pitch_game.dart`;
- as ~80 asserções de conteúdo desse arquivo de teste foram conferidas programaticamente contra o código mesclado (sem executor Flutter neste ambiente) e todas batem;
- `test/libgdx_match_renderer_integration_test.dart` (0.1.1.107 a 0.1.1.112) não foi alterado e continua validando exclusivamente o lado Kotlin/Gradle/PlatformView, que não foi tocado por esta release.

## Compatibilidade

- Match Engine e `lib/game/match/engine/` continuam intocados;
- `CareerState` permanece no schema 13; saves e IDs persistidos não mudam;
- Flame continua como fallback fora do Android; libGDX continua como renderer Android;
- nenhuma regra de jogo, probabilidade, placar ou resultado foi alterada — apenas a apresentação visual do campo.

## Validação necessária

Este ambiente não tem Flutter/Dart instalado, então `flutter pub get`, `flutter analyze`, `flutter test` e `flutter build apk --release` precisam ser confirmados pelo GitHub Actions ou localmente. Recomenda-se rodar a suíte completa (com atenção aos dois testes reintegrados) e validar em aparelho Android real que a partida ainda usa o renderer libGDX com o movimento/rótulos agora mais estáveis herdados da 0.1.1.107.
