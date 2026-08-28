# Release 0.1.1.51 — Transmissão de partida

**Android versionCode:** 53  
**pubspec:** `0.1.1+53`  
**CareerState schema:** 10

## Alterações

- A câmera 2D acompanha a bola com atraso leve, recentralização gradual e limites que evitam grandes áreas vazias.
- Ataques e lances importantes recebem aproximação curta; replay e transmissão normal compartilham o mesmo diretor de câmera.
- Campo, jogadores, bola e linhas permanecem no mesmo mundo visual do Flame, com vinheta, perspectiva discreta, sombras, pulso do protagonista e trajetória curta para passes e finalizações.
- O controle principal passa a oferecer Pausar, Simular, Tática, Trocar e Áudio. As velocidades legadas continuam apenas no JSON para compatibilidade.
- A duração visual pode ser Rápida (4 min), Normal (6 min) ou Completa (8 min), sem alterar os 90 minutos, probabilidades ou estatísticas do Match Engine.
- Simular permite avançar ao próximo lance importante, dez minutos, intervalo ou fim. A opção até o fim exige confirmação e percorre a timeline já calculada.
- Os outros jogos da rodada são preparados uma única vez pelo Match Engine existente, revelados conforme o minuto e reutilizados ao concluir a rodada.
- A faixa Rodada apresenta alertas temporários de gols e abre todos os placares ao vivo sem cobrir o campo ou pausar automaticamente a partida.
- O card intermediário duplicado foi removido; o overlay fica restrito a lances relevantes e a narração inicia em Importantes, com filtros Todos, Importantes e Meu time.
- Áudio limpo é ativado por padrão, aplica cooldown nos efeitos, impede sobreposição de cues, mantém ambiente original de estádio em volume baixo e reduz esse ambiente durante acontecimentos importantes.
- Narração falada permanece desligada por padrão; o botão de áudio da partida silencia e restaura rapidamente a configuração existente.

## Arquitetura e compatibilidade

- Nenhum arquivo em `lib/game/match/engine/` foi alterado.
- `MatchEngine.simulate(...)` permanece a única fonte de timeline, placar e estatísticas.
- Flame continua apenas representando `MatchEvent.start`, `MatchEvent.end` e os atores já definidos na timeline.
- `matchDurationMinutes` e `cleanAudio` são opcionais no JSON, com defaults retrocompatíveis de 6 minutos e áudio limpo.
- `matchSpeed` foi preservado para leitura de saves existentes, embora não controle mais a transmissão.
- O schema permanece 10; não há migração destrutiva nem alteração de IDs persistidos.

## Validações desta entrega

- verificação canônica de versão e metadados Android/iOS;
- comparação estrutural com a 0.1.1.50 para confirmar que o Match Engine não mudou;
- validação de JSON, YAML, plist, imports locais e balanceamento estrutural dos Dart alterados;
- regressões adicionadas para câmera, avanço da timeline, placares da rodada, filtros de narração, duração e áudio;
- validação por `ffprobe` do ambiente de estádio original de 12 segundos;
- integridade do pacote ZIP e ausência de APK.

O ambiente usado para empacotamento não possui Flutter/Dart. Por isso, `flutter analyze` e `flutter test` devem ser executados pelo GitHub Actions e câmera, vibração, mixagem de áudio e desempenho precisam da validação final em aparelho.
