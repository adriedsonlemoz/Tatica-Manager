# Release 0.1.1.15 — Criação de carreira e robustez do editor

## Principais alterações

- seleção de clubes reorganizada no caminho **Países > Brasil > Liga > Série A > Clubes**;
- cards em duas colunas com escudo, nome, overall, estrelas e orçamento;
- overall de apresentação calculado sobre os 18 melhores jogadores do banco carregado;
- perfil do técnico ampliado com nome, apelido, idade inicial, nacionalidade e local de nascimento;
- histórico do técnico persistido por temporada em `CareerState.managerHistory`;
- criação dividida em componentes menores para reduzir responsabilidade de `new_career_flow_screen.dart`;
- migração histórica de clubes separada de `ClubIdentityEngine`;
- tela do editor de clubes dividida em arquivos de detalhe e widgets;
- importação de escudos reforçada: PNG/JPG/WebP, até 256 KiB, 32–1024 px e proporção máxima 2:1;
- remoção explícita de ícone preservada no JSON;
- preparação da carreira reutiliza a função central de identidade, evitando divergência de estádio/escudo/uniformes.

## Persistência

O payload de `CareerState` passa ao schema 5 para incluir `managerHistory`. Não há nova tabela nem aumento da versão do SQLite; o perfil/histórico permanece no JSON da carreira. IDs de clubes e jogadores continuam estáveis.

## Testes adicionados/atualizados

Cobertura foi ampliada para criação do perfil, serialização, histórico do técnico, múltiplas temporadas até 2040, cálculo de overall/estrelas, estrutura da seleção de clubes e regras de escudos personalizados/importação.

## Validação local

Passaram localmente `python3 tool/versioning.py sync`, `python3 tool/versioning.py verify`, `python3 tool/verify_app_icons.py`, parsing de JSON/YAML/XML, verificação de imports/parts relativos, balanceamento de delimitadores Dart, IDs permanentes, pacote comunitário de teste e política do Artifact.

Os quatro comandos Flutter foram tentados após as alterações finais, mas este ambiente não possui o executável `flutter`: `flutter pub get`, `flutter analyze`, `flutter test` e `flutter build apk --release` retornaram código 127 (`flutter: command not found`). Portanto analyze/test/build permanecem obrigatórios no GitHub Actions e a UI ainda precisa de validação em aparelho, especialmente em larguras pequenas e no seletor de escudos.
