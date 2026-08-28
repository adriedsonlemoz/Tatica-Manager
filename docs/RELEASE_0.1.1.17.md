# Release 0.1.1.17 — Editor e criação de carreira

## Editor do banco

- navegação compartilhada por **País > Campeonato > Série > Clubes**;
- edição de uniformes com seletor visual RGB e entrada hexadecimal sem exigir `#`;
- data de nascimento do jogador via calendário;
- salário formatado automaticamente em reais durante a digitação;
- seleção/remoção de escudo iniciada por diálogo central;
- confirmação de salvamento em diálogo central;
- importação de banco completo e pacote de jogadores também em XML;
- decodificação com BOM, UTF-8 estrito, UTF-16 e fallback Windows-1252/Latin-1 para preservar acentos e símbolos como `‰` e `~`.

## Criação de carreira

A criação passa a ter quatro etapas:

1. perfil do técnico e origem;
2. país/campeonato/série/clube;
3. formação com mini campo + mentalidade;
4. pressão + ritmo em seleção visual dedicada.

O local de nascimento usa dados externos ao código em `assets/data/brazil_locations.json`. A estrutura é extensível para novos países. O catálogo local desta release contém os 27 estados e um conjunto inicial de 346 cidades brasileiras; quando um município ainda não estiver no catálogo, a UI permite digitá-lo manualmente sem perder país/estado. A fonte de dados fica isolada para expansão futura sem aumentar widgets/controladores.

Os cards de clube continuam em duas colunas, mas usam altura fixa reduzida e preservam escudo, nome, overall/estrelas e orçamento.

## Persistência

`ManagerProfile` passa a persistir `birthCountry`, `birthState` e `birthCity` além de `birthPlace`. O `CareerState` passa ao schema 6. O SQLite não muda de versão porque os novos campos permanecem no payload JSON da carreira.

## Testes adicionados/atualizados

- hierarquia de competição compartilhada;
- cards compactos e quatro etapas da criação;
- catálogo geográfico separado;
- mini campo das formações;
- hex com/sem `#`;
- formatação monetária;
- UTF-8 e Windows-1252 com caracteres especiais;
- importação XML de clubes e jogadores;
- diálogo central de escudo e de confirmação de salvamento;
- data de nascimento por seletor.

## Versão

- release/versionName: `0.1.1.17`;
- pubspec: `0.1.1+19`;
- Android versionCode: `19`.

## Arquitetura e validação final

- `GameController` não recebeu alterações nesta release; editor, importação e criação de carreira permanecem fora da responsabilidade de sessão/temporada.
- `tool/versioning.py verify` também confere o `versionCode` exibido no bloco-resumo do `AI_HANDOFF.md`, evitando divergência documental silenciosa.
- A auditoria local confirmou JSON/YAML/XML válidos, referências Dart relativas existentes, delimitadores estruturais balanceados e ausência dos padrões de lint que bloquearam a 0.1.1.14.
- O ambiente local não possui o executável Flutter. `flutter pub get`, `flutter analyze`, `flutter test` e `flutter build apk --release` foram tentados e retornaram código 127; a validação Flutter final depende do GitHub Actions.
