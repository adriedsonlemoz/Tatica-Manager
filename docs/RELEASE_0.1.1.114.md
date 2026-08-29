# Release 0.1.1.114 — Home clara e tema global

## Escopo

Esta release reformula a Home e introduz tema claro/escuro global sem alterar regras de carreira, Match Engine ou renderer da partida. A referência visual enviada foi usada apenas como direção de composição; todos os dados exibidos continuam vindo do save atual.

## Home

- substitui a composição escura anterior por uma estrutura mais simples e previsível em cards claros;
- adiciona barra superior compacta com acesso funcional a menu, notícias e caixa de entrada;
- valoriza escudo, nome, temporada, reputação, saldo e orçamento de transferências do clube;
- mantém ação principal contextual para `JOGAR PARTIDA`, `AVANÇAR DIA` ou revisão de temporada;
- apresenta seis atalhos responsivos: Elenco, Táticas, Transferências, Finanças, Calendário e Base;
- reorganiza Próxima Partida com escudos, competição, data/horário e estádio reais;
- adiciona Resumo da Temporada usando a classificação real do clube: jogos, vitórias, empates, derrotas, gols marcados e sofridos;
- mantém classificação e artilharia lado a lado em larguras de telefone compatíveis e notícias em lista compacta;
- não cria estatísticas, moedas, competições ou informações inexistentes no save.

## Tema claro e escuro

- modo claro passa a ser o padrão do aplicativo;
- modo escuro permanece disponível em Configurações e nas preferências antes da carreira;
- a escolha é persistida como preferência global do aplicativo, fora do schema do save;
- `AppColors` passa a fornecer uma única paleta neutra adaptativa para fundo, superfícies, navegação, bordas e textos secundários;
- `AppTheme` passa a expor `light` e `dark`, com `ThemeMode` controlado por Riverpod;
- barras do sistema ajustam o brilho dos ícones de acordo com o tema ativo;
- pré-jogo e chrome da transmissão também usam superfícies adaptativas; o gramado, estádio e demais elementos gráficos da partida preservam suas cores próprias;
- não foi criado um segundo sistema de tema paralelo.

## Compatibilidade

Permanecem preservados:

- renderer Android libGDX e Flame fallback;
- melhorias de movimentação da 0.1.1.113;
- Match Engine e coordenadas/eventos da partida;
- `CareerState` schema 13;
- saves existentes e IDs persistidos;
- fundação multi-competição;
- áudio, replay, substituições e demais sistemas de partida.

## Testes

- atualiza a regressão estrutural da Home para o novo layout;
- adiciona `light_dark_theme_test.dart` para validar modo claro padrão, persistência do modo escuro e paleta adaptativa;
- atualiza a regressão de contraste/navegação para os dois `ThemeData`;
- preserva as demais suítes do projeto.

## Validação

`python3 tool/versioning.py verify` deve validar a sincronização da release. Este ambiente não possui Flutter/Dart instalado; `flutter pub get`, `flutter analyze`, `flutter test` e `flutter build apk --release` dependem do GitHub Actions ou de outro ambiente Flutter.
