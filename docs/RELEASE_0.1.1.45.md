# Release 0.1.1.45

## Escopo

Evolução do dia de jogo, preparação, calendário, escalação/substituições e carreira profissional do treinador, preservando Match Engine, IDs persistidos e compatibilidade dos saves existentes.

## Preparação e dia de jogo

- o pré-jogo passa a mostrar primeiro os 11 titulares realmente associados às posições da formação, com avatar, função e OVR efetivo;
- a própria preparação pode aplicar a melhor escalação disponível reutilizando `LineupEngine.autoSelect`, que já considera disponibilidade, posição, OVR efetivo, condição, fadiga, suspensão e lesão;
- indisponíveis permanecem em seção própria e com motivo explícito;
- ao chegar à data de uma partida pela Home, uma apresentação `HOJE É DIA DE JOGO` abre antes do pré-jogo;
- a apresentação destaca competição, mandante/visitante, escudos, estádio, data, horário, rodada e mando, com animação curta para não tornar a carreira lenta;
- o avanço diário recebe uma transição rápida entre a data anterior e a nova data e encaminha automaticamente para a apresentação especial ao alcançar um jogo.

## Calendário

- a geração da liga deixa de usar incremento fixo de sete dias e passa a usar uma cadência configurável por competição;
- as rodadas atuais alternam intervalos de 4 a 10 dias, sempre acima do mínimo de dois dias completos de descanso;
- a combinação produz jogos em diferentes dias da semana em vez de concentrá-los aos domingos;
- `MatchFixture` passa a persistir `competitionId`, hora e minuto do início com fallback para saves antigos;
- a tela de calendário mostra nome da competição e horário;
- o gerador aceita `competitionId` e padrão de intervalos próprios, preparando futuras ligas/copas sem codificar a Série A na regra de calendário.

## Escalação e banco

- o campo da Escalação fica mais alto em retrato e identifica visualmente a formação atual;
- o banco passa a ser agrupado em Goleiros, Defensores, Meio-campistas e Atacantes;
- atletas lesionados, suspensos ou com condição insuficiente ficam separados em `INELEGÍVEIS / INDISPONÍVEIS`;
- a troca de titulares continua priorizando candidatos por função e OVR efetivo, sem duplicar a regra do `LineupEngine`.

## Substituições ao vivo

- abrir a substituição pausa imediatamente a partida e zera o acumulador do relógio;
- a sheet apenas devolve a escolha `quem sai → quem entra`, sem alterar a partida por conta própria;
- `MatchScreen` aplica a escolha no `LiveMatchController` ainda com o relógio pausado;
- somente depois da confirmação/aplicação a partida volta a correr;
- o `LiveMatchController` continua re-simulando o restante da timeline pelo Match Engine com os novos titulares, portanto a alteração tem efeito real na partida;
- jogadores expulsos continuam fora das opções e protegidos também pelo controller.

## Carreira do treinador

- `CareerState` passa ao schema 8 com `ManagerCareerState` opcional/retrocompatível;
- a carreira registra passagens por clubes, data/temporada de início e fim e motivo da saída;
- a tela `Carreira do técnico` mostra reputação profissional, clubes comandados, temporadas, propostas e trajetória;
- o treinador pode pedir demissão, ficar sem clube, consultar vagas, candidatar-se e aceitar/recusar propostas;
- vagas e propostas usam reputação do clube, desempenho atual após partidas, histórico de temporadas e situação de emprego do treinador;
- enquanto o treinador está sem clube, a Home vira uma central do mercado de técnicos e permite avançar os dias;
- ao assumir outro clube, a escalação é recalculada para o novo elenco, o histórico da passagem anterior é preservado e o extrato financeiro/última partida do clube anterior não é apresentado como se fosse do novo clube;
- se o treinador permanecer desempregado além de rodadas já datadas, `LeagueCatchUpEngine` resolve pelo Match Engine os jogos que ficaram no passado e recompõe a tabela antes da contratação, evitando calendário travado ou retorno a datas antigas.

## Compatibilidade

- nenhum ID de clube/jogador foi alterado;
- não há migração destrutiva no SQLite;
- saves sem `managerCareer`, `competitionId` ou horário de partida recebem defaults seguros ao carregar;
- a migração de identidades de clubes também migra IDs de passagens/propostas do treinador e preserva os novos metadados de `MatchFixture`;
- `GameController` continua apenas coordenando persistência e ações; regras de vagas ficam no `ManagerCareerEngine` e a lógica da partida continua no Match Engine;
- Flame não ganhou decisão de substituição, calendário ou carreira.

## Testes adicionados/atualizados

- distribuição de rodadas entre diferentes dias da semana e descanso mínimo;
- configuração de `competitionId`/cadência para competição futura;
- save legado sem `managerCareer`;
- demissão, procura de vaga e contratação por outro clube;
- retomada da carreira após dias desempregado, incluindo catch-up de rodadas passadas;
- reputação sem bônus fictício antes da primeira partida;
- fluxo de substituição pausado até a aplicação;
- pré-jogo com titulares antes dos indisponíveis;
- agrupamento do banco e separação dos inelegíveis;
- teste existente da liga passa a exigir variedade de dias da semana.

## Validação local

O ambiente desta entrega não possui Flutter/Dart instalados. Foram executados `python3 tool/versioning.py sync` e `python3 tool/versioning.py verify`, além de inspeções estruturais/integração do pacote. `flutter pub get`, `flutter analyze`, `flutter test` e `flutter build apk --release` permanecem para o GitHub Actions.
