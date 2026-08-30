# Release 0.1.1.110 — teste da Home sincronizado

**Android versionCode:** `111`  
**pubspec:** `0.1.1+111`

## Erro corrigido

O GitHub Actions da 0.1.1.109 concluiu `flutter analyze --no-pub` sem problemas e executou 283 testes. Desses, 282 passaram e apenas `calendar_and_standings_ui_test.dart` falhou.

A falha não estava na Home em execução. O teste ainda procurava nomes e detalhes de componentes de layouts anteriores, começando por `HomeFinanceGrid`. Outras expectativas do mesmo teste também estavam obsoletas e causariam novas falhas em sequência.

## Correção aplicada

- atualiza o teste para validar a estrutura realmente usada pela Home atual;
- cobre `HomePrimaryActionButton`, `HomeQuickAccess`, `HomeNextMatchCard`, `HomeSeasonSummaryRow`, `HomeLeagueAndScorers` e `HomeNewsHighlights`;
- confirma a distribuição dos seis indicadores do Resumo da Temporada;
- mantém verificações de responsividade dos atalhos, dados da próxima partida, classificação, artilharia, notícias e escudos;
- preserva a proteção introduzida na 0.1.1.108 contra o parâmetro de ícone não utilizado no cabeçalho de rankings.

## Preservado

- nenhum componente antigo foi recolocado apenas para satisfazer o teste;
- nenhuma alteração visual foi feita na Home;
- `al-sistemas.json` continua removido;
- playlist padrão continua com cinco faixas;
- Match Engine, saves, IDs, regras, resultados e assets permanecem inalterados.

## Validação esperada

O CI deve passar por `flutter analyze --no-pub`, `flutter test` e então seguir para `flutter build apk --release`.
