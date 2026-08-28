# Release 0.1.1.4 — Handoff de desenvolvimento

Esta release é focada em continuidade e documentação técnica.

## Alterações

- Adiciona `AI_HANDOFF.md` na raiz como porta de entrada para outra IA ou desenvolvedor.
- Adiciona `docs/PROMPT_CONTINUACAO_IA.md` com um prompt completo e pronto para copiar.
- Registra arquitetura atual, controladores, Match Engine modular, fluxo de carreira, persistência, CI e regras de manutenção.
- Registra a política obrigatória de versionamento e a integração com o AL Sistemas.
- Atualiza a release visível para `0.1.1.4`.
- Atualiza Android `versionCode` para `6`.
- Atualiza o `pubspec.yaml` para `0.1.1+6`.

## Continuidade

A próxima alteração/entrega deve atualizar novamente a versão. Na linha atual, o próximo valor esperado normalmente é `0.1.1.5`, com Android `versionCode` maior que 6.

## Validação

Executar antes de publicar:

```bash
python3 tool/versioning.py verify
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```
