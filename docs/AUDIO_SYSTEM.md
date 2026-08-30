# Sistema de áudio — Tática Manager 2

## Objetivo

A camada de áudio foi adicionada sem mover nenhuma regra de partida para Flutter/Flame. O fluxo continua:

```text
Match Engine
→ MatchEvent / timeline
→ LiveMatchController
→ apresentação da partida
→ AudioManager + Flame/overlays
```

O Match Engine não importa `just_audio`, não conhece arquivos sonoros e não decide quando um efeito deve ser reproduzido. O áudio apenas reage aos eventos já calculados.

## Organização

```text
lib/app/audio/
├── audio_manager.dart
├── audio_providers.dart
└── match_narration_service.dart

lib/core/audio/
├── audio_catalog.dart
├── audio_file_store.dart
└── match_narration_formatter.dart

lib/domain/settings/
└── audio_settings.dart

lib/features/settings/
├── audio_settings_screen.dart
└── menu_music_player_card.dart
```

### AudioManager

Responsável por:

- player de música;
- player de interface;
- player de efeitos da partida;
- volumes por categoria;
- pausa da música durante partidas;
- retomada da música ao sair da partida;
- fallback para assets padrão;
- substituição por arquivos personalizados quando configurados;
- tratamento tolerante a falhas: erro de áudio nunca pode interromper save, navegação ou partida.

### AudioCatalog

Centraliza a relação entre:

- `UiAudioCue` e assets da interface;
- `MatchAudioCue` e assets da partida;
- `MatchEventType` e o efeito correspondente;
- cinco músicas padrão dos menus.

Eventos de posse continuam silenciosos. A partir da 0.1.1.44, passes usam o efeito enviado para esta release; chute, defesa, gol, falta, cartões, pênalti, trave, lesão e substituição continuam com cues próprias. Os arquivos de escanteio, impedimento e tiro de meta também ficam catalogados e prontos para uso quando esses acontecimentos passarem a existir como `MatchEventType` reais, sem inventar eventos apenas na camada de áudio.

### AudioFileStore

Usa o seletor nativo de arquivos já existente no projeto e copia os arquivos escolhidos para a área privada do aplicativo. Isso evita depender de um caminho temporário retornado pelo seletor do Android/iOS.

Formatos aceitos inicialmente:

- MP3;
- M4A;
- AAC;
- WAV;
- OGG;
- FLAC.

Nenhuma permissão ampla de armazenamento é solicitada: a escolha passa pelo seletor do sistema.

## Persistência e compatibilidade

`GameSettings.sound` foi mantido como chave geral para compatibilidade com saves antigos.

As novas opções ficam em `AudioSettings`:

- música ligada/desligada;
- interface ligada/desligada;
- partida ligada/desligada;
- narração ligada/desligada;
- volume geral;
- volume da música;
- volume da interface;
- volume da partida;
- volume da narração;
- uso de playlist personalizada;
- caminhos das músicas personalizadas;
- overrides de sons por evento.

Saves anteriores, que não possuem o bloco `audio`, recebem defaults automaticamente. Não há alteração de IDs de jogador/clube e não há migração destrutiva.

Se um save contendo caminhos de áudio personalizados for movido para outro aparelho, arquivos inexistentes são ignorados e o jogo volta aos sons/músicas padrão.

## Assets incluídos e licença

Na 0.1.1.109, a playlist padrão foi reduzida para somente as 5 faixas OGG selecionadas e fornecidas em `musicasmenu.zip`. As outras seis faixas OGG foram removidas dos assets e do catálogo. Os arquivos não possuem metadados embutidos; a interface exibe nomes legíveis derivados dos próprios nomes dos arquivos.

Os efeitos de interface e partida continuam podendo ser regenerados por:

```bash
python3 tool/generate_audio_assets.py
```

Esse utilitário não gera mais músicas de menu, evitando que a playlist antiga volte ao projeto. As 5 faixas OGG atuais são assets versionados e devem ser mantidas diretamente em `assets/audio/menu/`.

## Música de menu

A música de fundo inicia **desativada por padrão** em novas configurações/saves sem preferência explícita. Quando o jogador a ativa, o player escolhe uma faixa inicial variável e mantém shuffle + loop da playlist. Ao entrar em uma partida, a música é pausada. Ao sair da partida, a mesma camada de áudio retoma a reprodução.

O player expõe a faixa atual, permite selecionar qualquer música da lista ativa e avançar manualmente para a próxima, mantendo shuffle e loop no mesmo `AudioManager`. Quando o usuário ativa uma playlist personalizada e existem arquivos válidos, ela substitui a lista padrão. Desativar a opção volta às 5 faixas OGG incluídas no jogo sem apagar os arquivos importados.

## Playlist reduzida — 0.1.1.109

A lista padrão passa a conter exatamente cinco faixas: Jim Yosef — Lights, Disfigure — Blank, DEAF KEV — Invincible, Cormak — Flavors e David Bulla — Unexpected. O player, shuffle, loop, seleção manual, próxima faixa e playlist personalizada continuam usando o mesmo `AudioManager`; somente o catálogo padrão e os assets incluídos foram reduzidos.

## Sons da interface

A aplicação possui uma camada central de interação para toques curtos e um `NavigatorObserver` para transições de tela. Mensagens globais/confirmatórias usam cue própria. Chamadas não são espalhadas por cada botão do projeto.

## Sons da partida

A tela da partida envia apenas o `MatchEvent` que começou a ser apresentado ao `AudioManager`. Replays não disparam o efeito novamente porque `MatchPitchGame.onEventStarted` não é chamado para cues marcadas como replay.

O início do segundo tempo é um cue de apresentação explícito porque a timeline atual possui evento de intervalo e não possui um segundo `kickoff` aos 46 minutos.



## Assets de eventos da 0.1.1.44

Mapeamentos efetivamente acionados por `MatchEvent` nesta release:

- início da partida e início do segundo tempo;
- intervalo e fim de jogo;
- passe;
- finalização;
- defesa do goleiro;
- gol;
- falta;
- cartão amarelo;
- cartão vermelho;
- navegação de menu/interface.

Os arquivos de **escanteio**, **impedimento** e **tiro de meta** estão incluídos e registrados no `AudioCatalog`, porém não são disparados artificialmente: o Match Engine atual ainda não possui esses três tipos na timeline. Quando forem implementados como eventos reais, a apresentação poderá reutilizar os assets já preparados.

## Narração por voz

A release 0.1.1.37 implementa a primeira narração falada por **TTS do aparelho**, sem tocar no Match Engine.

Organização:

- `MatchNarrationService`: integração com `flutter_tts`, volume, cancelamento e tolerância a falhas;
- `MatchNarrationFormatter`: seleciona e formata frases a partir de `MatchEvent`;
- `AudioManager`: coordena efeito e voz apenas na camada de apresentação.

A narração possui liga/desliga e volume próprios. Ela fala apenas lances relevantes; posse e passes ficam silenciosos para evitar fala contínua. A voz usa `pt-BR` quando disponível e a qualidade final depende do mecanismo TTS instalado no aparelho.

Nenhum arquivo de locução gravada foi incluído no APK. Uma camada futura pode permitir seleção de voz/velocidade ou pacotes de locução, mas isso deve continuar fora do Match Engine e do Flame.

## Mixagem limpa da partida — 0.1.1.51

A transmissão passa a ter a opção persistente `AudioSettings.cleanAudio`, ativada por padrão. Quando ligada, posse, passes e outros cues comuns não chegam ao player de efeitos; permanecem os apitos e acontecimentos relevantes, como gol, chance, defesa, trave, cartões, pênalti, lesão e substituição.

O `AudioManager` também passa a:

- aplicar cooldown por tipo de cue;
- interromper o efeito anterior antes de iniciar outro, evitando sobreposição;
- manter `stadium_ambience.m4a` em loop separado e volume baixo durante a partida;
- reduzir temporariamente o ambiente quando toca um efeito importante;
- pausar música de menu durante a partida e ambiente ao sair, silenciar ou suspender o aplicativo;
- preservar o mute rápido por `GameSettings.sound` sem apagar volumes e categorias.

O ambiente original pode ser regenerado de modo determinístico com:

```bash
python3 tool/generate_stadium_ambience.py
```

Narração TTS continua desligada por padrão. O replay não repete cues porque apenas a apresentação ao vivo chama `onEventStarted`.


## Inicialização e feedback tátil — 0.1.1.56

O `AudioManager` permanece singleton e passa a ser preparado durante o splash. `TaticaManagerApp` consulta a última carreira para aplicar suas preferências antes da primeira tela útil, sem bloquear a construção da interface. O carregamento da playlist é serializado por uma única tarefa interna e protegido por geração de configuração, evitando duas preparações concorrentes do mesmo `AudioPlayer` quando o estado da carreira chega durante a inicialização.

A política tátil também fica centralizada: `interfaceTap` não produz vibração e `matchEvent` só solicita `mediumImpact` para `goal`/`ownGoal`, sempre condicionado a `GameSettings.haptics`. Cartões, faltas, trave, substituições, replay, navegação, botões, cards e demais eventos permanecem sem feedback háptico. A regra é de apresentação e não altera a timeline ou o Match Engine.


## Encerramento limpo da partida — 0.1.1.63

O `MatchScreen` guarda a referência do `AudioManager` enquanto ainda está montado e não usa `ref.read` durante `dispose`. Ao atingir o fim da partida, `finishMatchPresentation()` encerra o ambiente em loop e a narração; ao sair da tela, `exitMatch()` também para explicitamente o player de efeitos antes de retomar a música de menu. A saída é idempotente para evitar execução dupla entre conclusão e `dispose`.

A mudança atua apenas na apresentação de áudio. A timeline, os eventos e o resultado continuam sendo produzidos pelo Match Engine sem dependência do player.


## Playlist navegável e apresentação inicial — 0.1.1.74

A playlist padrão passa a usar exclusivamente 11 faixas OGG otimizadas. `AudioManager` continua sendo o único player de música e passa a publicar `MenuPlaybackState`, permitindo que Configurações mostre a faixa atual, ofereça seleção manual e execute `Próxima música` sem criar um serviço paralelo. A playlist personalizada do aparelho continua compatível e usa nomes derivados dos arquivos locais.

A apresentação da primeira entrada da carreira também foi reorganizada visualmente: o conteúdo editorial continua usando apenas técnico, avatar, clube, escudo, competição, temporada e data reais do save, mas o botão deixa de ficar isolado por um grande vazio vertical e a matéria fica melhor integrada à base azul-grafite. A flag que limita a apresentação à primeira entrada do save permanece inalterada.
