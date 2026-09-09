# Release 0.1.1.143 — Polimento visual orientado por vídeo

## Escopo

Esta release aplica apenas os ajustes visuais confirmados na gravação de uso. A Home sem rolagem e telas não demonstradas no vídeo permanecem fora desta etapa.

## Transmissão e encerramento da partida

- A composição passa a usar a altura disponível da tela. Em aparelhos baixos, o `FittedBox` continua reduzindo o conjunto proporcionalmente; em aparelhos altos, a área adicional é aproveitada pela narração.
- A narração mostra de dois a quatro lances importantes conforme a altura disponível.
- `FIM DE JOGO` agora tem prioridade no indicador de estado e não aparece junto de `PAUSADO`.
- Os cinco comandos da partida são removidos depois dos 90 minutos, quando já não podem executar ações.
- O encerramento preserva estatísticas e narração e oferece uma única ação clara para abrir o resumo.
- O cálculo de colisão das etiquetas ganhou uma margem visual maior, reduzindo nomes colados quando os atletas se concentram na mesma região.

## Perfil, Auxiliar técnico e Mais

- A seção de disciplina do jogador troca quatro métricas apertadas por quatro blocos em grade 2×2, mantendo os mesmos dados e regras.
- O card `PRIORIDADES DA COMISSÃO` passa a medir sua altura pelo conteúdo; o espaço flexível fica fora do card e mantém os botões no rodapé.
- A tela Mais reduz margens, ícones e espaçamento vertical dos atalhos, preservando uma linha de título, descrição e todos os destinos.

## Integridade preservada

Não foram modificados Match Engine, eventos gerados, placares, probabilidades, movimentação, recompensas, valores de PM, SQLite, saves, finanças ou orçamento dos clubes. A lógica da partida continua sendo decidida antes da apresentação em Flame.

## Validação

- teste estrutural dedicado aos estados de fim de jogo, uso responsivo de altura, distância entre etiquetas, disciplina 2×2, prioridades naturais e menu compacto;
- verificação de delimitadores Dart e dos contratos textuais existentes;
- sincronização obrigatória de `VERSION`, `pubspec.yaml`, Android, `app.json`, `AppInfo` e documentação.

O ambiente local desta entrega não inclui o SDK Flutter. `flutter analyze`, `flutter test` e a geração do APK devem ser confirmados pelo workflow do projeto.
