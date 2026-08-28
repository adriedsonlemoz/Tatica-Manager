# Release 0.1.1.63

## Home

- mantém somente o atalho de e-mail ao lado do técnico;
- substitui posição/próximo jogo/competição/desempenho por saldo, orçamento de transferências, receitas e despesas mensais reais;
- move preparação para dentro do card da próxima partida e simplifica a ação externa para Avançar/Abrir partida;
- troca forma recente por informações do estádio no painel lateral;
- compacta classificação e artilheiros lado a lado quando houver largura;
- adiciona fundos/accent colors discretos e uma tela própria de Notícias & Destaques.

## Pacotes e técnicos

- a Central de Edição passa a chamar o `tatica-manager-clubs` v3 de pacote completo e aceita também a extensão `.tmpack`;
- a confirmação mostra contagem de clubes, jogadores, técnicos e escudos antes de carregar;
- técnicos usam a coleção existente `managers`/`coaches`; escudos permanecem ligados por `Club.id`/`iconBase64`;
- o importador separado `tatica-manager-logos` continua disponível para alterar somente escudos.

## Áudio pós-partida

- `MatchScreen` guarda o `AudioManager` antes do descarte e não usa `ref` no `dispose`;
- no fim da partida, ambiente em loop e narração são encerrados; na saída, o player de efeitos também é parado;
- a saída é idempotente e a música de menu volta pelo mesmo `AudioManager` singleton.

## Compatibilidade

- `CareerState` permanece schema 11;
- nenhum ID persistente é alterado;
- Match Engine não é modificado;
- workflow de CI não precisa ser alterado.
