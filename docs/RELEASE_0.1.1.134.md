# Release 0.1.1.134 — Correção do analyzer do campo dinâmico

**Release visível:** `0.1.1.134`  
**Android versionCode:** `135`  
**pubspec:** `0.1.1+135`

## Correção

- Corrige o único aviso fatal reportado pelo `flutter analyze` no log 87.
- O parâmetro anulável `inPossession` recebe diretamente `_possessionHome`, removendo uma comparação nula redundante.
- Nenhuma regra, probabilidade, formação, animação ou resultado de partida foi alterado.

## Escopo preservado

- Formações reais no campo.
- Posse ao vivo estabilizada.
- Movimentação coletiva por fases.
- Etiquetas menores e priorizadas.
- Bola, áreas, gols e aproximações mais legíveis.

O log 87 parou antes dos testes e da geração do APK; esta microcorreção existe exclusivamente para liberar essas etapas no próximo workflow.
