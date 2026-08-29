# Release 0.1.1.110 — campo libGDX contido e visual refinado

## Causa do problema visual

O campo libGDX aparecia no topo da partida, mas a superfície nativa ocupava uma área muito maior do que o retângulo visível do gramado. O Flutter criava o PlatformView com `initSurfaceAndroidView`, que tenta usar Texture Layer Hybrid Composition quando possível. O `GLSurfaceView` do libGDX, porém, só era adicionado depois, quando o `AndroidFragmentApplication` entrava no `FrameLayout`.

Esse ciclo é especialmente inadequado para um `SurfaceView` acrescentado depois da criação do PlatformView: a composição pode ser escolhida antes de a superfície existir e o resultado pode ficar com tamanho/posição incorretos.

## Correção do encaixe

- o Dart passa a usar `PlatformViewsService.initExpensiveAndroidView`, forçando Hybrid Composition real desde a criação;
- `LiveMatchPitchPanel` calcula explicitamente a altura a partir da largura usando a proporção `105 / 68` e entrega ao renderer um `SizedBox` com dimensões limitadas;
- o painel e a View libGDX recebem `Clip.hardEdge`/`ClipRect` para reforçar os limites visuais;
- o host Android e o Fragment usam `FrameLayout` com clipping e o `GLSurfaceView` recebe `MATCH_PARENT` em largura e altura;
- o renderer usa mundo virtual `1050 x 680` com `FitViewport`, atualiza o viewport em `resize()` e reaplica o `glViewport` antes de cada frame.

## Refinamento visual do renderer

- jogadores ficam maiores e mais legíveis, com corpo, shorts, meias, cabeça, braços, sombra de contato e padrões de uniforme;
- goleiros mantêm kits próprios e passam a ter mangas/luvas mais evidentes;
- o atleta envolvido no lance recebe destaque visual sem alterar a posição decidida pelo motor;
- nomes passam a ter escala maior, fundo escuro, faixa de cor do time/goleiro e escolha entre quatro posições para reduzir colisões;
- quando o bitmap font não possui algum glifo Unicode do nome, o renderer translitera somente esse caractere para evitar quadrados/vazios em nomes acentuados;
- todos os jogadores visíveis continuam elegíveis para rótulo; quando não existe posição sem colisão, o renderer escolhe a alternativa com menor área de sobreposição;
- bola ganha contorno, sombra, arco visual e rastro discreto;
- gols usam dimensões mais próximas do campo real, profundidade, fundo de rede e malha refinada;
- gramado recebe faixas mais naturais, marcações proporcionais, pontos central/de pênalti e melhor separação do entorno;
- a interpolação visual dos jogadores passa a usar suavização independente da taxa de quadros.

## Arquitetura

O Match Engine não foi alterado. Resultados, probabilidades, placar, cartões, substituições, estatísticas, jogadores dos eventos e coordenadas continuam sendo produzidos em Dart. O Kotlin/libGDX apenas recebe a timeline pronta e a representa visualmente.

O renderer nativo foi dividido em responsabilidades menores:

- `LibGdxMatchRenderer.kt`: bridge de comandos, estado e interpolação;
- `LibGdxPitchPainter.kt`: campo, gols, jogadores e bola;
- `LibGdxPlayerLabelPainter.kt`: nomes e redução de colisões;
- `LibGdxMatchVisualModels.kt`: modelos e geometria visual compartilhados.

Flame permanece como fallback fora do Android. `CareerState` continua no schema 13; saves e IDs persistidos não mudam.

## Testes

`test/libgdx_match_renderer_integration_test.dart` passa a verificar estruturalmente:

- uso obrigatório de `initExpensiveAndroidView` e ausência do caminho adaptativo anterior;
- tamanho explícito `105 / 68` no Flutter e clipping do host nativo;
- `MATCH_PARENT` do `GLSurfaceView` dentro do Fragment;
- `FitViewport`, `viewport.update()` e `viewport.apply()` no renderer;
- existência dos módulos visuais de jogadores/gols/rótulos;
- manutenção da fronteira que impede `MatchEngine` no Kotlin/libGDX.

## Validação necessária

Além do CI, esta release precisa ser testada em aparelho Android verificando principalmente:

1. ausência do grande espaço vazio entre campo e timeline;
2. campo totalmente contido no card;
3. nomes legíveis e sem sobreposição excessiva;
4. entrada/saída/minimização da partida sem crash;
5. overlays Flutter continuando acima do renderer;
6. fluidez da partida em aparelho real.
