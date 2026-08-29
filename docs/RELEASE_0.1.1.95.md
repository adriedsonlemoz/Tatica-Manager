# Release 0.1.1.95 — Campo da partida redesenhado

## Escopo

Esta release refaz o gramado e o entorno visual da partida ao vivo para tentar voltar ao caminho do mockup aprovado. O objetivo foi redesenhar o campo praticamente do zero, sem tocar em regras, resultados, eventos ou probabilidades do Match Engine.

## Campo e estádio

- redesenha a geometria do gramado com perspectiva mais equilibrada e enquadramento mais limpo;
- refaz as faixas do corte da grama, sombreado, vinheta, marcações, área central, grandes áreas, pequenas áreas e semicírculos;
- redesenha os gols e a moldura visual do estádio ao redor do campo;
- mantém a torcida WebP integrada ao fundo, com fallback em Canvas quando necessário.

## Jogadores e profundidade

- reduz novamente a escala visual dos jogadores para o campo respirar melhor;
- passa a desenhar os atletas respeitando profundidade, diminuindo sobreposição estranha entre mandante e visitante;
- preserva uniformes reais, goleiros diferenciados, animações dos lances e bola.

## Integridade da simulação

Nada muda na lógica. Match Engine, timeline, estatísticas baseadas em eventos já exibidos, cartões, substituições, replay e resultado permanecem iguais. Flame continua somente como camada visual.

## Compatibilidade

- `CareerState` schema 13 preservado;
- saves e IDs persistentes preservados;
- multi-competição preservada.

## Validação

O ambiente desta entrega não possui Flutter/Dart. `python3 tool/versioning.py verify` e preflight estrutural local devem ser executados aqui; `flutter analyze`, `flutter test` e `flutter build apk --release` dependem do GitHub Actions.
