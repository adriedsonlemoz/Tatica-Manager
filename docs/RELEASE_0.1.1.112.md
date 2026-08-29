# Release 0.1.1.112 — correção da compilação Kotlin do renderer libGDX

## Causa real do erro

O GitHub Actions da 0.1.1.111 avançou além das etapas anteriores:

- `flutter analyze`: sem problemas;
- `flutter test`: **282 testes aprovados**;
- `flutter build apk --release`: chegou a `:app:compileReleaseKotlin`.

A compilação falhou em `LibGdxPitchPainter.kt:126` com `Unresolved reference 'crowdPulse'`.

Na refatoração visual da 0.1.1.110, `LibGdxPitchPainter.draw()` passou a receber `crowdPulse`, mas `drawCrowd()` continuou usando o identificador sem recebê-lo como parâmetro. Como `drawCrowd()` é um método separado, a variável não estava em seu escopo Kotlin.

## Correção

O valor agora percorre explicitamente apenas a camada visual:

```text
LibGdxMatchRenderer.crowdPulse
        ↓
LibGdxPitchPainter.draw(crowdPulse)
        ↓
drawStadiumBase(crowdPulse)
        ↓
drawCrowd(crowdPulse)
```

Nenhum estado novo foi criado e nenhum valor é calculado no Match Engine. O pulso continua derivado apenas do tipo de evento já apresentado pelo renderer.

## Regressão atualizada

`test/libgdx_match_renderer_integration_test.dart` passa a verificar que `crowdPulse` aparece nas assinaturas necessárias e é repassado explicitamente entre os métodos. Isso cobre exatamente o contrato perdido pela refatoração.

## Arquitetura preservada

A correção não altera:

- Match Engine, probabilidades, placar, eventos ou coordenadas;
- `SurfaceView` e Hybrid Composition;
- tamanho explícito 105:68 do campo;
- `FitViewport` 1050×680;
- Flame fallback fora do Android;
- `CareerState` schema 13, saves, IDs ou multi-competição.

## Validação

O log anterior confirma 282 testes aprovados e analyzer sem problemas antes da falha Kotlin. Nesta release, o versionamento canônico deve passar em `python3 tool/versioning.py verify`. `flutter analyze`, `flutter test` e `flutter build apk --release` ainda precisam ser executados em ambiente com Flutter/GitHub Actions.
