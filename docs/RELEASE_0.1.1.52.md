# Release 0.1.1.52 — Correção do build da transmissão

**Android versionCode:** 54  
**pubspec:** `0.1.1+54`  
**CareerState schema:** 10

## Correções

- Restaura em `match_screen.dart` o import de `live_match_event_widgets.dart`, onde o componente reutilizado `MatchPhasePanel` já estava implementado.
- Corrige os dois erros `undefined_method` exibidos pelo GitHub Actions nas áreas de intervalo e fim de jogo.
- Simplifica `baseName ?? (name != null ? name : this.baseName)` para a expressão equivalente `baseName ?? name ?? this.baseName`, eliminando o lint `prefer_if_null_operators` restante.
- Adiciona regressão estrutural para impedir que o import do painel seja removido novamente.

## Compatibilidade

Esta é uma microrelease corretiva. Não altera UI, Match Engine, câmera, timeline, placares da rodada, áudio, schema, IDs ou dados persistidos da 0.1.1.51.

## Validação

O log `Flutter-Analisar-Testar-e-Gerar-APK-4-logs.zip` mostrou exatamente três apontamentos no `flutter analyze`: dois erros de `MatchPhasePanel` ausente e um lint no estádio. Os três foram corrigidos. O ambiente local não possui Flutter/Dart, portanto a confirmação final de `flutter analyze`, testes e build continua no GitHub Actions. Nenhum APK foi gerado nesta entrega.
