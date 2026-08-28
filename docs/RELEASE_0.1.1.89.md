# Release 0.1.1.89 — Home mais legível e informativa

## Escopo

Ajuste fino da Home compacta. A prioridade é recuperar legibilidade e presença visual sem voltar ao layout esticado das primeiras versões da revisão. Nenhum módulo de gameplay é criado ou alterado.

## Alterações visuais

- aumenta a fonte de Próximo jogo no cabeçalho e os títulos dos quatro cards financeiros;
- aumenta levemente a altura da Próxima Partida e amplia os escudos dos dois clubes;
- aumenta data/hora, informações do estádio e a faixa Dia de jogo/Preparação;
- aumenta ícones e textos dos cinco atalhos mantendo a mesma linha compacta;
- aumenta tipografia de Notícias, classificação e artilheiros;
- remove os rodapés redundantes Ver tabela e Ver ranking; os cards de classificação e artilharia passam a abrir diretamente suas telas completas;
- aumenta de três para quatro a quantidade máxima de notícias mostradas na Home;
- quando existem partidas disputadas e a tela possui altura suficiente, usa o espaço inferior para mostrar até cinco Últimas Partidas com adversário, placar e resultado, usando `matchHistory` já persistido.

## Pontos de atenção nos atalhos

Os atalhos passam a suportar um ponto visual apenas quando existe um estado real correspondente:

- Táticas: escalação atual inválida para a próxima competição;
- Calendário: dia de jogo;
- Finanças: proposta de patrocínio ainda aguardando resposta;
- Departamento Médico: jogador lesionado;
- Base: permanece sem indicador porque não existe hoje uma condição equivalente de pendência obrigatória.

## Compatibilidade

Permanecem preservados `CareerState` schema 13, saves, IDs persistentes, calendário e fundação multi-competição, CPU, mercado, contratos, finanças e Match Engine. Flame continua somente como camada visual da partida.

## Validação

O preflight estrutural dos Dart alterados deve ser executado junto com `python3 tool/versioning.py verify`. O ambiente desta entrega não possui Flutter/Dart, portanto `flutter pub get`, `flutter analyze`, `flutter test` e `flutter build apk --release` continuam dependendo do GitHub Actions.
