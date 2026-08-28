# Release 0.1.1.36 — Sistema completo de áudio

## Escopo

Esta release adiciona a primeira camada completa de som ao Tática Manager, mantendo a arquitetura existente e sem alterar o resultado das partidas.

## Música dos menus

Foram adicionadas cinco músicas leves e originais, produzidas especificamente para esta distribuição e armazenadas em `assets/audio/menu/`.

- faixa inicial variável;
- reprodução em shuffle;
- loop contínuo;
- volume independente;
- música pausa durante a partida e volta ao sair dela.

## Sons da interface

Foram adicionados efeitos discretos para:

- toque/interação;
- navegação entre telas;
- confirmação/mensagem global.

A captura de toques fica centralizada em `AudioInteractionLayer` e a navegação em `AudioNavigationObserver`, evitando espalhar reprodução manual por todas as telas.

## Sons da partida

O catálogo cobre:

- início da partida;
- intervalo;
- início do segundo tempo;
- fim de jogo;
- chute;
- defesa;
- gol/gol contra;
- falta;
- amarelo;
- vermelho;
- substituição;
- bola na trave;
- pênalti;
- pênalti defendido;
- lesão.

`MatchAudioCue` é resolvido a partir de `MatchEventType` somente na camada de apresentação. Replays não repetem o som do evento.

## Configurações

A tela **Configurações > Áudio** agora controla separadamente:

- áudio geral;
- música;
- interface;
- partida;
- volume geral;
- volume de música;
- volume de interface;
- volume de partida.

## Arquivos personalizados

O jogador pode:

- selecionar várias músicas do aparelho;
- usar a seleção como playlist de menu;
- voltar às músicas originais sem apagar a playlist;
- substituir individualmente qualquer som de evento da partida;
- ouvir/testar cada efeito;
- restaurar um evento ou todos os eventos ao padrão.

Os arquivos selecionados são copiados para a área privada do aplicativo usando `file_selector` + `path_provider`. Se um caminho salvo deixar de existir, o sistema faz fallback para o áudio padrão.

## Compatibilidade de save

- `GameSettings.sound` continua existindo como chave geral legada;
- `AudioSettings` usa defaults quando o bloco novo estiver ausente;
- schema/IDs persistentes não foram alterados;
- saves antigos continuam carregáveis;
- nenhum caminho de áudio é necessário para a carreira funcionar.

## Dependências

- `just_audio ^0.10.6` para assets, arquivos locais, playlists, shuffle e múltiplos players;
- `path_provider ^2.1.6` para armazenamento privado dos arquivos escolhidos;
- `file_selector` existente continua sendo o seletor nativo.

## Licença dos áudios padrão

Nenhum áudio externo foi baixado. As músicas e os efeitos incluídos foram gerados especificamente para o projeto por `tool/generate_audio_assets.py`, evitando dependência de bibliotecas sonoras de terceiros.

## Narração por voz

Não foi ativada nesta release. A arquitetura ficou preparada para adicionar futuramente um `MatchNarrationService`, preferencialmente usando TTS opcional sobre os mesmos `MatchEvent`, sem mover responsabilidade para o Match Engine.

## Assinatura do APK enquanto os Secrets não estão configurados

O suporte à assinatura persistente foi preservado. Como a keystore ainda pode não estar configurada, o workflow agora:

- usa assinatura release persistente quando os quatro Secrets estão presentes;
- rejeita configuração parcial dos Secrets;
- usa temporariamente a chave debug do runner quando nenhum Secret estiver configurado.

Isso permite continuar testando releases agora. Até a assinatura persistente ser configurada, ainda pode ser necessário desinstalar a versão anterior para instalar um novo APK.

## Testes adicionados

`test/audio_system_test.dart` cobre:

- compatibilidade de `GameSettings` legado sem o bloco de áudio;
- serialização das novas preferências;
- mapeamento `MatchEventType -> MatchAudioCue`;
- existência das cinco músicas e de todos os assets padrão.

## Versionamento

- release/versionName: `0.1.1.36`;
- pubspec: `0.1.1+38`;
- Android versionCode: `38`.

## Validação

Os comandos de versionamento são executados localmente. O ambiente atual não possui Flutter/Dart, portanto `flutter pub get`, `flutter analyze`, `flutter test` e `flutter build apk --release` precisam ser confirmados pelo GitHub Actions.
