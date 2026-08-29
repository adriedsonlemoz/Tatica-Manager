# Release 0.1.1.115 — Correção da Home/tema no analyzer

## Escopo

Esta release corrige exclusivamente os nove erros de análise estática revelados pelo GitHub Actions da 0.1.1.114. Não altera o layout aprovado da Home, a preferência claro/escuro, o Match Engine, a movimentação ou o renderer libGDX.

## Correções

- restaura o import de `AppColors` em `lib/features/match/match_screen.dart`, necessário para o gradiente adaptativo da transmissão;
- remove `const` de dois subtrees do pré-jogo que usam `AppColors.textPrimary`, agora um getter adaptativo e portanto não constante em tempo de compilação;
- transforma em strings raw seis expectativas de `test/calendar_and_standings_ui_test.dart`, fazendo o teste procurar literalmente `${s?...}` no código da Home em vez de tentar avaliar `s` dentro do próprio teste.

## Compatibilidade

Permanecem preservados:

- Home clara e estrutura responsiva da 0.1.1.114;
- modo escuro persistente;
- renderer Android libGDX e Flame fallback;
- movimentação integrada da 0.1.1.113;
- Match Engine e coordenadas/eventos da partida;
- `CareerState` schema 13;
- saves existentes, IDs persistidos e fundação multi-competição.

## Validação

O log do GitHub Actions da 0.1.1.114 parou em `flutter analyze --no-pub` com nove erros, antes de executar testes e build. Nesta entrega, `python3 tool/versioning.py verify` deve validar o versionamento. `flutter analyze`, `flutter test` e `flutter build apk --release` dependem do GitHub Actions ou de um ambiente com Flutter instalado.
