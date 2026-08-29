# Release 0.1.1.107 — libGDX integrado ao campo da partida no Android

## Escopo

Esta release integra o libGDX como nova camada de renderização do campo da partida no Android, sem alterar o Match Engine, suas probabilidades, resultados, estatísticas ou coordenadas. O objetivo é testar uma superfície OpenGL dedicada mantendo toda a interface e as regras existentes em Flutter/Dart.

## Arquitetura adotada

- `MatchEngine` continua sendo a única fonte de eventos e coordenadas da partida;
- `MatchPitchController` define o contrato visual usado pela tela da partida;
- no Android, `LibGdxMatchPitchController` reproduz a fila de apresentação já existente e envia apenas eventos visuais para o renderer nativo;
- fora do Android, `MatchPitchGame` continua disponível como renderer Flame de fallback;
- `LiveMatchPitchPanel` continua sendo um widget Flutter e mantém sobre o campo os overlays de replay, eventos e transições;
- placar, timeline, áudio, simulação, táticas, substituições e finalização da partida permanecem nos módulos atuais.

## Integração Android

A `MainActivity` passa a usar `FlutterFragmentActivity` e registra um `PlatformView` específico para o campo. O Dart usa `PlatformViewLink` + `AndroidViewSurface`/`initSurfaceAndroidView` para forçar Hybrid Composition, adequada à superfície OpenGL do libGDX. O PlatformView hospeda um `AndroidFragmentApplication` por meio de `initializeForView()`, de modo que a superfície ocupa somente o retângulo do campo, em vez de abrir uma segunda Activity ou substituir a tela inteira.

Foi adotado libGDX `1.14.2`, estável, com OpenGL ES 2 por padrão para maior compatibilidade. Os natives Android são empacotados para `arm64-v8a`, `armeabi-v7a`, `x86` e `x86_64` durante o build.

## Renderer libGDX inicial

O primeiro renderer desenha proceduralmente:

- gramado horizontal com faixas e marcações;
- gols e malha das redes;
- jogadores com uniformes principal/reserva já resolvidos pelo Flutter;
- goleiros com kits próprios;
- nomes dos atletas;
- bola, sombra e arco visual básico;
- interpolação dos jogadores e da bola a partir dos `FieldPoint` enviados pela timeline;
- reação visual simples de torcida e replay.

Nenhuma imagem, modelo 3D ou asset externo foi adicionado nesta etapa.

## Compatibilidade e riscos controlados

- `CareerState` permanece no schema 13;
- nenhum ID persistido foi alterado;
- saves antigos continuam compatíveis;
- não existe chamada ao `MatchEngine` no código Kotlin/libGDX;
- nenhuma regra de substituição, cartão, placar ou resultado foi duplicada no renderer;
- o Flame continua presente como fallback, deixando a integração reversível.

O principal ponto que ainda precisa de validação em aparelho é o ciclo de vida do `PlatformView`/Fragment ao entrar, sair, minimizar e retornar à partida, além da fluidez em aparelhos Android de diferentes GPUs.

## Testes

Adicionado `test/libgdx_match_renderer_integration_test.dart`, verificando estruturalmente:

- seleção do renderer libGDX somente no Android;
- preservação do fallback Flame;
- uso de Hybrid Composition no `PlatformView`, `AndroidFragmentApplication` e `initializeForView()`;
- uso do libGDX 1.14.2 e natives Android;
- ausência de `MatchEngine` e aleatoriedade no renderer Kotlin.

## Validação

`python3 tool/versioning.py verify` deve permanecer verde após a sincronização da versão.

Neste ambiente não há Flutter/Dart instalados, portanto `flutter pub get`, `flutter analyze`, `flutter test` e `flutter build apk --release` não puderam ser executados localmente e dependem do GitHub Actions.
