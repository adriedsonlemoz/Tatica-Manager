# Release 0.1.1.113 — movimentação natural integrada ao libGDX

## Escopo

Esta release usa a 0.1.1.112 libGDX como base e incorpora as melhorias de movimentação produzidas separadamente no Work 0.1.1.107. O merge foi feito por responsabilidade: nenhuma versão antiga substituiu a integração Android/libGDX atual e nenhum arquivo do Match Engine foi alterado.

## Movimento no libGDX

- cada atleta possui estado visual independente de velocidade X/Y, atraso, alvo anterior, início da transição e força de curva;
- o deslocamento usa aceleração e frenagem em vez de `Vector2.lerp` uniforme;
- trajetórias recebem curvas pequenas e determinísticas, sem `Random` e sem alterar o destino entregue pela timeline;
- saídas recebem atrasos curtos por atleta/setor, eliminando o efeito de todos iniciarem no mesmo frame;
- goleiros usam velocidade máxima ligeiramente menor e transições específicas em defesa/pênalti;
- a posição final continua exatamente o alvo produzido pela apresentação dos eventos do Match Engine.

## Pênaltis e retorno à formação

- o cobrador vai ao ponto da cobrança e o goleiro defensor assume a linha visual apropriada;
- somente jogadores dentro da aproximação da área são movidos para posições de espera;
- atletas já fora da zona preservam sua posição, evitando a antiga coluna/efeito de ímã;
- defesa, meio, ataque e goleiros retornam à formação com atrasos diferentes e curvas discretas.

## Animação e nomes

- passada, braços, inclinação, balanço vertical e sombra respondem à velocidade real do estado visual;
- jogador parado deixa de receber deslocamento ambiente do corpo inteiro;
- o painter de nomes mantém a âncora anterior enquanto ela continua utilizável;
- a prioridade dos nomes fica estável por jogador, com atleta ativo e goleiros à frente;
- em aglomerações, etiquetas secundárias podem ser omitidas temporariamente em vez de trocar de lado a cada frame;
- nomes acentuados continuam usando o fallback de glifos já existente no libGDX.

## Flame fallback

Os quatro arquivos modificados pelo Work (`match_pitch_game.dart`, `match_player_motion.dart`, `match_player_labels.dart` e `match_player_visuals.dart`) foram integrados também ao fallback Flame por merge de três vias, preservando `MatchPitchController` e a arquitetura libGDX adicionada depois da base 0.1.1.106.

## Integridade

- `lib/game/match/engine/` não foi modificado;
- libGDX continua somente como renderer/apresentação visual;
- não há `Random` nem decisão de gameplay no Kotlin;
- `CareerState` permanece no schema 13;
- saves e IDs persistidos não mudam;
- Hybrid Composition, SurfaceView 105:68, FitViewport, bridge Dart/Kotlin, uniformes, goleiros, bola, redes, replay, substituições, timeline e narração são preservados.

## Testes

- mantém `match_player_motion_visual_test.dart` vindo do Work para o fallback Flame;
- amplia `libgdx_match_renderer_integration_test.dart` para exigir aceleração/frenagem, curvas, pênalti seletivo, retorno escalonado, animação por velocidade e estabilidade de nomes no renderer nativo;
- atualiza `live_match_visual_experience_test.dart` preservando simultaneamente a regressão do layout libGDX e a regressão de movimento do Work.

## Validação necessária

Executar no CI:

```text
python3 tool/versioning.py verify
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Em aparelho, validar principalmente pênalti, passe seguido de chute, gol/comemoração, retorno à formação, estabilidade dos nomes e sensação de aceleração/frenagem.
