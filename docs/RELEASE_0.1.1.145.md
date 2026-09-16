# Release 0.1.1.145 — Áudio de partida renovado

## Escopo

Esta release substitui apenas a camada sonora da partida onde os clipes enviados pelo usuário ficaram tecnicamente aproveitáveis. Não altera probabilidades, resultados, eventos, animações, regras de carreira ou persistência.

## Ambiente de estádio

- `stadium_ambience_field.wav` substitui o ambiente reproduzido em loop durante a partida.
- O material foi extraído do clipe fornecido pelo usuário em 48 kHz estéreo, com corte de extremos de frequência e costura de 500 ms entre fim e início para reduzir emenda perceptível.
- WAV é usado para evitar novo estágio de compressão com perdas no loop contínuo.
- O ganho do ambiente no mixer cai de 18% para 16% do volume efetivo de partida; efeitos e narração continuam por cima com ducking temporário.

## Efeitos integrados

Os trechos novos foram ligados aos mesmos eventos já existentes no catálogo:

- `shot_field.wav` — finalização;
- `woodwork_field.wav` — bola na trave;
- `save_field.wav` — defesa do goleiro;
- `goal_field.wav` — gol;
- `penalty_saved_field.wav` — pênalti defendido.

Os clipes foram recortados nos impactos mais claros, receberam fades curtos para evitar cliques e filtragem leve para remover extremos desnecessários. Os demais eventos mantêm os assets anteriores porque o material novo não ofereceu separação suficientemente confiável para substituição automática.

## Compatibilidade

- `MatchEventType` e Match Engine não foram modificados.
- Sons personalizados por evento continuam tendo prioridade sobre os assets padrão.
- `cleanAudio`, volumes, TTS e músicas de menu continuam com o mesmo comportamento.
- Os assets antigos permanecem no pacote como base histórica/fallback, mas os cinco eventos acima e o ambiente passam a usar os novos arquivos `*_field.wav`.

## Validação

- catálogo aponta para arquivos existentes e isolados dos assets regeneráveis pelo utilitário de áudio;
- teste estrutural confirma os novos caminhos e o ganho de ambiente de 16%;
- metadados de versão sincronizados para 0.1.1.145 / Android versionCode 146;
- Match Engine permanece sem dependências da camada de áudio.
