# Release 0.1.1.107 — movimentação visual natural

## Escopo

Esta release altera somente a forma como o renderer Flame apresenta coordenadas e eventos já produzidos. Nenhuma regra, probabilidade, decisão, placar, resultado ou trajetória do Match Engine foi modificada.

## Movimento dos jogadores

- cada atleta mantém um estado visual independente de velocidade;
- deslocamentos ganham aceleração e frenagem, eliminando partidas e paradas instantâneas;
- pequenas curvas determinísticas quebram o aspecto de movimento em linha reta sem introduzir aleatoriedade de gameplay;
- atrasos curtos por jogador e setor evitam que todos comecem a correr no mesmo frame;
- a passada, a inclinação e a sombra agora respondem à velocidade real do boneco, e não apenas à distância restante para o alvo;
- o atleta associado ao lance acompanha o `event.start` fornecido pela timeline.

## Pênaltis e retorno à formação

- o pênalti reposiciona o cobrador e o goleiro;
- somente jogadores dentro da zona próxima à área são afastados para a espera da cobrança;
- atletas que já estão fora da área preservam suas posições, evitando a coluna vertical observada na gravação;
- depois do lance, defesa, meio, ataque e goleiros retornam à formação com atrasos diferentes.

## Nomes e estabilidade visual

- a posição escolhida para cada nome é lembrada entre frames;
- uma etiqueta só troca de âncora quando a anterior deixa de caber ou entra em conflito relevante;
- a respiração em repouso foi reduzida e separada do deslocamento do boneco.

## Integridade

- Match Engine e `lib/game/match/engine/` permanecem byte a byte inalterados;
- `CareerState` permanece no schema 13;
- saves, IDs, eventos, coordenadas, replay, HUD, uniformes e multi-competição continuam compatíveis;
- nenhuma imagem ou mockup foi criado, alterado ou adicionado nesta release.

## Validação esperada

O CI deve executar `flutter analyze`, `flutter test` e `flutter build apk --release`. Em aparelho, validar uma partida completa, especialmente cobrança de pênalti, sequência passe/chute/gol, retorno à formação e estabilidade dos nomes em telas estreitas.
