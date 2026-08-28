# Release 0.1.1.60

## Objetivo

Corrigir os dois bloqueios de análise estática revelados pelo GitHub Actions após a remodelação da Home na 0.1.1.59.

## Correções

- remove o parâmetro opcional `padding` nunca utilizado de `_DashboardCard` em `home_dashboard_news.dart`;
- remove o mesmo parâmetro morto de `_DashboardCard` em `home_dashboard_rankings.dart`;
- mantém `padding: EdgeInsets.all(12)` como comportamento fixo nesses dois componentes, preservando o layout da 0.1.1.59;
- adiciona regressão estrutural para impedir a reintrodução desses parâmetros mortos nos dois arquivos.

## Compatibilidade

- CareerState continua no schema 11;
- saves e IDs persistidos não mudam;
- Match Engine não foi alterado;
- GitHub Actions não foi alterado;
- nenhuma funcionalidade da nova Home foi removida.

## Validação

A causa foi obtida diretamente do log do GitHub Actions: `flutter analyze --no-pub` encontrou somente dois `unused_element_parameter` nos arquivos da Home. O verificador canônico de versão deve ser executado antes da entrega.
