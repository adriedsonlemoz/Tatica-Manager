# Release 0.1.1.108 — Home alinhada ao mockup e correção do analyzer

## Escopo

Esta release conclui o realinhamento da Home ao mockup aprovado iniciado na entrega anterior e corrige a única falha reportada pelo GitHub Actions da 0.1.1.107. Nenhuma regra, probabilidade, decisão, placar, resultado ou trajetória do Match Engine foi modificada.

## Home

- cabeçalho do clube passa a exibir o saldo (`club.money`) no lugar da linha de próxima partida, que agora tem card próprio;
- adiciona o botão de ação principal "JOGAR PARTIDA" / "AVANÇAR DIA", cheio, verde, com ícone de destaque à direita;
- atalhos rápidos passam a ser Elenco, Táticas, Transferências, Finanças, Calendário e Base, em uma única fileira de tiles planos;
- o card "Próxima Partida" mostra os dois escudos, o "X" central e uma coluna com competição, data/hora e estádio;
- adiciona o bloco "Resumo da Temporada" com jogos, vitórias, empates, derrotas, gols marcados e gols sofridos, calculados a partir da classificação real do clube do usuário;
- os cards de classificação e artilharia passam a usar o mesmo acento verde e os títulos "CLASSIFICAÇÃO"/"ARTILHARIA", com a tabela compacta mostrando apenas J e PTS;
- renomeia a seção de notícias para "NOTÍCIAS E DESTAQUES".

## Identidade visual

- `ClubBadge` deixa de desenhar uma caixa clara fixa (`#F4F4F4`) atrás de escudos customizados; o fundo passa a ser transparente, preservando o esquema escuro do aplicativo em qualquer tela que use o widget.

## Correção do GitHub Actions

- remove o parâmetro `icon` de `_DashboardSectionHeader` (`lib/features/home/home_dashboard_rankings.dart`), que ficou sem nenhum chamador depois da reorganização da Home e era sinalizado pelo `flutter analyze` como `unused_element_parameter`.

## Integridade

- Match Engine e `lib/game/match/engine/` permanecem inalterados;
- `CareerState` permanece no schema 13;
- saves, IDs, eventos, coordenadas, replay, HUD, uniformes e multi-competição continuam compatíveis;
- nenhum dado foi inventado: todos os valores exibidos na Home vêm de dados já existentes na carreira (clube, standings, fixtures, notícias).

## Validação esperada

O CI deve executar `flutter analyze`, `flutter test` e `flutter build apk --release` sem nenhum problema. Em aparelho, validar a Home completa (saldo, botão de avanço/partida, atalhos, próxima partida, resumo da temporada, classificação/artilharia e notícias) e conferir que os escudos customizados aparecem sem caixa clara ao fundo.
