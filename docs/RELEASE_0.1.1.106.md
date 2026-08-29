# Release 0.1.1.106 — campo legível e uniformes seguros

## Escopo

Esta release altera exclusivamente a apresentação visual da partida e o passo pré-jogo de escolha de uniforme. O Match Engine não foi modificado: resultados, probabilidades, eventos, trajetória, coordenadas e regras continuam sendo produzidos pela implementação existente.

## Uniformes

- o usuário escolhe entre uniforme principal, reserva e terceiro antes de iniciar a transmissão;
- o adversário recebe automaticamente a combinação disponível com maior contraste perceptivo;
- quando todos os uniformes cadastrados são semelhantes, um kit visual de segurança é gerado somente para a partida, sem alterar dados ou saves;
- goleiros usam cores próprias, calculadas contra ambos os times e o gramado, além de mangas longas, luvas e detalhes específicos.

## Jogadores e nomes

- os nomes exibidos são compactados de acordo com o espaço disponível;
- tamanho, largura e distância do rótulo acompanham a escala do campo;
- o posicionamento tenta âncoras alternativas para reduzir colisões, priorizando goleiros e o atleta da jogada;
- jogadores, bola e sombras recebem escala e contato com o gramado mais consistentes, enquanto a interpolação visual de movimento fica mais suave sem alterar posições do motor.

## Campo e gols

- redes ganham fundo, laterais, malha e reação ao gol com sensação de profundidade;
- traves são redesenhadas em primeiro plano para integrar jogadores e bola ao gol;
- gramado recebe textura procedural discreta, listras, marcações adaptativas, arcos e cantos refinados;
- a bola, seu rastro e sua sombra passam a responder melhor à escala da tela.

## Compatibilidade e integridade

- nenhuma imagem ou mockup foi criado ou adicionado;
- `CareerState` permanece no schema 13;
- saves, IDs, HUD, replay, timeline, narração, estatísticas, substituições e multi-competição permanecem compatíveis;
- novos testes cobrem resolução de conflitos de uniforme e contratos estruturais do renderer/pré-jogo.

## Validação esperada

O CI deve executar `flutter analyze`, `flutter test` e `flutter build apk --release`. Em aparelho, validar principalmente nomes em telas estreitas, as três opções de uniforme, confrontos entre clubes de cores próximas e a proporção das redes durante gols.
