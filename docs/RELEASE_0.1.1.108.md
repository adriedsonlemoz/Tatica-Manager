# Release 0.1.1.108 — correção do analyzer da Home

## Correção

O log do GitHub Actions da release 0.1.1.107 apontou um único problema em `lib/features/home/home_dashboard_rankings.dart`: o parâmetro opcional `icon` de `_DashboardSectionHeader` nunca era fornecido por nenhuma chamada, gerando `unused_element_parameter` e fazendo `flutter analyze` encerrar com código 1.

A release remove somente esse parâmetro, o campo associado e o bloco condicional que jamais era renderizado.

## Integridade

- a aparência atual dos cards de Classificação e Artilharia permanece igual;
- nenhuma regra ou resultado do Match Engine foi alterado;
- saves, IDs, `CareerState` e multi-competição permanecem compatíveis;
- nenhuma imagem, mockup ou asset foi criado ou alterado.

## Validação esperada

O CI deve voltar a ultrapassar a etapa `flutter analyze --no-pub` e seguir para `flutter test` e `flutter build apk --release`.
