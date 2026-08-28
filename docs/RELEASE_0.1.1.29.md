# Release 0.1.1.29 — Partida ao vivo modernizada

## Objetivo

Esta release inicia a modernização visual da partida ao vivo sem transferir regras para o Flutter ou para o Flame. O Match Engine continua responsável por resultado, eventos, jogadores envolvidos e trajetórias; a interface e o renderer apenas apresentam a timeline já calculada.

## Placar e hierarquia da tela

- O placar foi reconstruído em formato compacto e fica fora da área rolável, permanecendo visível durante toda a partida.
- Minuto, etapa, pausa, escudos, nomes, placar, cartões e finalizações ficam concentrados no mesmo HUD.
- O campo sobe na hierarquia e os comandos deixam de ficar depois da lista de eventos.
- Intervalo e fim de jogo usam painéis compactos com ação explícita, sem empurrar o placar para fora da tela.

## Narração e notificações

- A narração ao vivo passa a exibir também posse, construção, passes e faltas, além dos acontecimentos principais.
- `MatchEventPresentation` ordena apenas eventos já ocorridos e fornece headlines para todos os tipos existentes de `MatchEventType`.
- Gols, gol contra, cartões, pênaltis, pênalti defendido, lesões, substituições, intervalo e fim de jogo recebem destaque visual específico.
- O lance atual usa `AnimatedSwitcher`, avatar quando existe `playerId` e transições curtas para não interromper o ritmo.
- Textos genéricos de posse/passe recebem variação determinística pela sequência do evento, sem consumir `Random` e sem alterar o resultado da simulação.

## Substituições e tática ao vivo

- A antiga troca por dois dropdowns foi substituída por seleção visual dos titulares e reservas.
- Os cards mostram avatar, nome, posição, overall e condição.
- Reservas da mesma posição recebem destaque e a confirmação mostra uma prévia `SAI → ENTRA`.
- Jogadores já substituídos para fora deixam de ser oferecidos novamente como entrada pela interface.
- A folha de tática ao vivo agora expõe mentalidade, pressão, ritmo, linha defensiva e construção, reutilizando o `Tactic` e o `LiveMatchController` existentes.

## Flame / campo 2D

`MatchPitchGame` continua sem conhecer `MatchEngine` ou decidir ações. A evolução visual inclui:

- campo com acabamento mais profundo, áreas, pequenas áreas e redes;
- jogadores com silhueta mais legível que os círculos simples anteriores;
- reação visual de jogadores próximos a `MatchEvent.start/end`;
- trilha curta da bola;
- fila de eventos para que sequências no mesmo minuto, como passe → chute → gol, possam ser reproduzidas em ordem;
- retorno gradual das peças à base após o lance.

Nenhum `Random` foi adicionado ao renderer e nenhuma probabilidade/regra da partida foi movida para Flame.

## Arquitetura e saves

Não houve alteração em:

- `GameController`;
- `LiveMatchController` como contrato/regra pública de resultado;
- módulos do Match Engine;
- schema SQLite;
- `CareerState`/schema de save;
- IDs persistidos;
- regras de mercado, contratos, calendário ou finanças.

A UI foi dividida em componentes próprios para evitar crescimento excessivo de `match_screen.dart`.

## Testes

Foi adicionado `test/live_match_visual_experience_test.dart`, cobrindo:

- headline para todos os tipos de evento;
- ordem da narração e bloqueio de eventos futuros;
- variação de narração genérica sem alterar a timeline;
- presença do placar separado da rolagem;
- substituição visual sem `DropdownButtonFormField`;
- fila/uso de `start/end` no renderer e ausência de `MatchEngine`/`Random` no Flame.

## Validação obrigatória

```bash
python3 tool/versioning.py sync
python3 tool/versioning.py verify
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Resultado no ambiente local desta entrega:

- `python3 tool/versioning.py sync` — executado com sucesso;
- `python3 tool/versioning.py verify` — executado com sucesso em `0.1.1.29 / versionCode 31`;
- `flutter pub get` — executado, mas o ambiente retornou `flutter: command not found`;
- `flutter analyze` — executado, mas o ambiente retornou `flutter: command not found`;
- `flutter test` — executado, mas o ambiente retornou `flutter: command not found`;
- `flutter build apk --release` — executado, mas o ambiente retornou `flutter: command not found`.

Assim, análise, testes Flutter e build desta release dependem do GitHub Actions.

No aparelho, validar especialmente tamanhos do HUD em telas estreitas, altura do campo, legibilidade da narração em 1x/2x/4x, animação de gols/cartões e o fluxo completo de várias substituições no primeiro tempo e intervalo.
