# Release 0.1.1.131 — Correção do analyzer no cartão amarelo

**Release visível:** `0.1.1.131`  
**Android versionCode:** `132`  
**pubspec:** `0.1.1+132`

## Correção do log 84

- Corrige os três avisos fatais de análise estática em `match_event_generator.dart`.
- O jogador já havia sido validado como não nulo no ramo do cartão amarelo; por isso, o acesso passa a usar `player.id` e `player.displayName` diretamente.
- A mudança não altera probabilidade, motivo, minuto, equipe ou atleta escolhidos para o cartão.

## Análise visual separada

O vídeo recebido revelou oportunidades no campo ao vivo — formação visual fixa em 4-3-3, posse baseada em poucos eventos e leitura apertada dos nomes —, mas nenhuma mudança visual foi incluída nesta microcorreção. A próxima intervenção no campo deve ser validada como um conjunto de design e comportamento, preservando a tela fixa em modo retrato.
