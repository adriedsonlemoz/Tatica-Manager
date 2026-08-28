# Release 0.1.1.68

## Escopo

Release corretiva baseada no log real do GitHub Actions da 0.1.1.67. O CI chegou ao `flutter analyze` e parou por um único lint `use_null_aware_elements` em um widget compartilhado dos novos painéis.

## Causa real

`DashboardSectionHeader` ainda usava `if (trailing != null) trailing!` dentro da coleção de widgets. Com o Dart/Flutter atual do CI, o analyzer exige o elemento null-aware da coleção.

Além disso, ao revisar a etapa seguinte do pipeline, foi encontrada uma regressão já presente em `AppInfo`: `recentReleases` continha quatro itens, enquanto `app_info_test.dart` protege explicitamente o limite histórico de três. Corrigir somente o lint faria o CI avançar e falhar logo depois nos testes.

## Correções

- substitui a condição manual do `trailing` por `?trailing` no `DashboardSectionHeader`;
- mantém `AppInfo.recentReleases` com exatamente três releases: 0.1.1.68, 0.1.1.67 e 0.1.1.66;
- não altera composição visual, navegação, regras da partida ou dados persistidos.

## Arquitetura e compatibilidade

- Match Engine inalterado;
- Flame inalterado;
- `CareerState` permanece no schema 11;
- saves e IDs persistentes permanecem compatíveis.

## Validação

- correção comparada diretamente com o único diagnóstico do `flutter analyze` do GitHub Actions;
- revisão preventiva de `app_info_test.dart` confirma a exigência de exatamente três releases;
- `python3 tool/versioning.py verify` permanece obrigatório;
- `flutter analyze`, `flutter test` e `flutter build apk --release` dependem de ambiente com Flutter SDK ou do GitHub Actions.
