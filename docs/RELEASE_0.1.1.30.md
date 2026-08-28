# Release 0.1.1.30 — Campo horizontal na partida ao vivo

## Objetivo

Esta release incorpora a modernização da partida da 0.1.1.29 e transforma o campo 2D em orientação horizontal, mantendo o aplicativo em modo retrato. A mudança prepara a base visual para passes, chutes, movimentação lateral, câmera e animações futuras sem alterar o Match Engine.

## Campo 2D

- O viewport do Flame passa a usar proporção `105:68`, próxima à proporção de um campo real.
- Gols passam a ficar à esquerda e à direita.
- Linha do meio, círculo central, grandes áreas, pequenas áreas, marcas de pênalti, redes e faixas do gramado foram reorganizados para a nova orientação.
- O time da casa parte do lado esquerdo e ataca para a direita; o visitante faz o sentido oposto.
- A altura do campo deixa de depender de uma fração da altura do aparelho, reduzindo rolagem vertical e liberando espaço para lance atual, comandos e narração.

## Coordenadas e arquitetura

O Match Engine continua usando exatamente as mesmas coordenadas normalizadas e a mesma convenção de profundidade no eixo Y. `MatchPitchGame` aplica somente no momento de renderizar a transformação:

```text
x visual = 1 - y do motor
y visual = x do motor
```

Com isso:

- nenhuma trajetória é recalculada;
- nenhum evento é reescrito;
- passes, chutes e gols continuam vindo da timeline do Match Engine;
- o Flame não recebe lógica de probabilidade ou resultado;
- saves e IDs persistidos não mudam.

## Escopo preservado da 0.1.1.29

Continuam presentes o placar compacto fora da rolagem, narração contínua, notificações de eventos, substituição visual com avatares, ajustes táticos e fila de animações do renderer.

## Testes

`test/live_match_visual_experience_test.dart` foi ampliado para verificar:

- proporção horizontal `105:68` na tela;
- transformação do goleiro da casa para o lado esquerdo;
- transformação do goleiro visitante para o lado direito;
- finalização da casa terminando no gol direito;
- renderer ainda consumindo `event.start/end` sem `MatchEngine` ou `Random`.

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
- `python3 tool/versioning.py verify` — executado com sucesso em `0.1.1.30 / versionCode 32`;
- `python3 tool/verify_app_icons.py` — executado com sucesso;
- `flutter pub get` — executado, mas o ambiente retornou `flutter: command not found`;
- `flutter analyze` — executado, mas o ambiente retornou `flutter: command not found`;
- `flutter test` — executado, mas o ambiente retornou `flutter: command not found`;
- `flutter build apk --release` — executado, mas o ambiente retornou `flutter: command not found`.

Assim, análise, testes Flutter e build dependem do GitHub Actions. Em aparelho, conferir principalmente legibilidade dos jogadores no campo mais baixo, trajetória da bola nos dois sentidos, gols nas duas metas, placar fixo e quantidade de conteúdo visível sem rolagem.
