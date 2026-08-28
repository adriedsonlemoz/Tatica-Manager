# Release 0.1.1.88 — Home compacta mais legível

## Escopo

Esta release refina a revisão visual compacta da Home. A intenção é manter a densidade conquistada nas versões anteriores, mas devolver legibilidade e presença visual aos textos e cards que haviam sido comprimidos demais.

## Alterações visuais

- o botão Avançar/Jogar deixa o cabeçalho da Próxima Partida e passa a ocupar a coluna central da faixa de informações, exatamente no lugar do horário duplicado;
- data e horário continuam disponíveis no cabeçalho do card, evitando repetição;
- aumenta a tipografia do próximo jogo no cabeçalho da Home;
- aumenta ícones e textos dos cinco atalhos sem restaurar as alturas antigas;
- aumenta tipografia de Notícias & Destaques, eventos, Série A e Artilheiros;
- a tabela ultracompacta deixa de renderizar escudos, liberando espaço para nome, jogos e pontos;
- tabela e artilheiros recebem proporções mais equilibradas;
- Notícias, classificação e artilheiros passam a compartilhar melhor a altura da mesma linha em telas compatíveis.

## Compatibilidade

Não há alteração de schema ou de regras do jogo. Permanecem preservados:

- `CareerState` schema 13;
- saves e IDs persistentes;
- fundação multi-competição;
- calendário, CPU, mercado, contratos e finanças;
- Match Engine como responsável pela lógica da partida;
- Flame somente como representação visual.

## Validação

- versionamento sincronizado por `tool/versioning.py`;
- testes estruturais da Home atualizados para proteger a nova posição do botão Avançar e a remoção do horário duplicado;
- `flutter analyze`, `flutter test` e `flutter build apk --release` ainda dependem do GitHub Actions porque Flutter/Dart não estão disponíveis neste ambiente.
