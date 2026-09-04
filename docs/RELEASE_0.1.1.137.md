# Release 0.1.1.137 — Correção dos rótulos do auxiliar

## Erro do workflow 90

O analyzer parava com quatro erros `undefined_getter` na tela do Auxiliar técnico. Os tipos estavam corretos, mas as extensões que fornecem os textos `label` não ficam disponíveis por importação transitiva em Dart.

## Correção aplicada

- `technical_assistant_screen.dart` importa diretamente `formation.dart` para usar `FormationTypeX`.
- A tela importa diretamente `tactic.dart` para usar `MentalityX`, `PressingX` e `MatchTempoX`.
- Formação, mentalidade, pressão e ritmo continuam exibidos com os mesmos rótulos em português definidos pelo domínio.

## Escopo preservado

Não houve mudança na recomendação da IA, no plano diário de treinamento, na escalação, na tática persistida, nas probabilidades ou nos resultados do Match Engine.

O workflow 90 não chegou aos testes ou à geração do APK porque a etapa de análise estática encerrou o job. A próxima execução deve validar também essas etapas.
