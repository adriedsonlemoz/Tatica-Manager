# Release 0.1.1.111 — correção da regressão de layout da partida

## Causa da falha

O GitHub Actions da 0.1.1.110 passou pelo `flutter analyze` sem problemas e executou 282 testes. Desses, 281 passaram. A única falha estava em `live_match_visual_experience_test.dart`.

O teste ainda exigia encontrar `AspectRatio(` e `aspectRatio: 105 / 68` em `live_match_pitch_panel.dart`, embora a 0.1.1.110 tenha substituído deliberadamente esse widget por dimensões explícitas:

- `pitchAspectRatio = 105 / 68`;
- `height = width / pitchAspectRatio`;
- `SizedBox(width: width, height: height)`;
- `Clip.hardEdge`.

Essa troca faz parte da contenção do `SurfaceView` nativo do libGDX e está documentada na release anterior.

## Correção

A regressão estrutural passa a validar a implementação real em uso, verificando:

- a constante de proporção `105 / 68`;
- o cálculo explícito da altura a partir da largura;
- o `SizedBox` que fornece dimensões limitadas ao renderer;
- o clipping rígido do painel.

Não foi reintroduzido `AspectRatio` somente para satisfazer uma expectativa antiga.

## Arquitetura preservada

Nenhum código funcional do renderer, Match Engine, bridge Dart/Kotlin, Gradle, saves ou persistência foi alterado.

Continuam preservados:

- Hybrid Composition real com `initExpensiveAndroidView`;
- `SurfaceView` contido pelo host nativo;
- `FitViewport` 1050×680;
- libGDX como renderer Android;
- Flame como fallback;
- Match Engine como única fonte de regras, eventos, resultados e coordenadas;
- `CareerState` schema 13, IDs e saves existentes.

## Validação

O log da 0.1.1.110 confirmou antes desta correção:

- `flutter analyze`: sem problemas;
- 281 testes aprovados;
- 1 teste estrutural falhou por expectativa obsoleta.

Nesta entrega, a correção foi aplicada ao teste e o versionamento canônico deve ser verificado com `python3 tool/versioning.py verify`. Os comandos Flutter ainda precisam ser executados pelo GitHub Actions/ambiente com Flutter instalado.
