# Release 0.1.1.141 — Polimento visual e avisos globais

## Notificações e recompensas

- `GlobalNoticeHost` foi posicionado acima do `Navigator`, portanto avisos permanecem disponíveis em qualquer tela.
- Recompensas têm prioridade: interrompem temporariamente um aviso comum, entram pelo topo e o aviso anterior retorna para a fila.
- O aviso mostra título, descrição e confirmação sonora; tocar no card o dispensa.
- O antigo aviso fixo no rodapé da Home foi removido para não cobrir Notícias e Destaques.
- Cálculo, valores, persistência e proteção idempotente dos PM permanecem inalterados.

## Tipografia

- `AppTheme` agora define explicitamente a hierarquia de displays, cabeçalhos, títulos, corpos, rótulos, botões e navegação.
- Textos estáticos abaixo de 10 px foram eliminados.
- Cards de jogadores, status, painéis, recompensas e informações secundárias receberam ajustes locais de legibilidade.

## Avançar Dia

- A ação fica bloqueada enquanto o processamento está em andamento, impedindo avanços simultâneos por toque repetido.
- A transição permanece visível por pelo menos 1,5 segundo, incluindo o tempo real de processamento.
- O observador que tocava som em toda mudança de rota foi removido porque o toque físico já é tratado pela camada global; isso elimina o barulho duplicado percebido ao avançar.

## Dia de Jogo

- A tela usa composição vertical fixa e responsiva, sem `ListView` no corpo.
- Em alturas menores, cabeçalho, confronto, grade e preparação entram em modo compacto, mantendo todas as ações necessárias visíveis.
- A grade interna permanece sem rolagem.

## Notícias

- `CareerEvent` persiste o campo `read` e `GameController.markNewsRead` grava a transição uma única vez no save.
- Notícias novas recebem selo `NOVA`, borda mais forte e maior contraste; notícias lidas usam aparência neutra.
- O cabeçalho da Home indica quando existem notícias não lidas.
- Notícias de saves anteriores à criação do campo são consideradas lidas para evitar pendências artificiais em massa.

## Primeira entrada da carreira

- A apresentação foi reconstruída no tema azul-grafite do aplicativo.
- Escudo, clube, competição, técnico e texto ficam centralizados em uma única composição consistente.
- O escudo aparece antes do técnico e o mecanismo existente continua garantindo exibição somente na primeira entrada da carreira.

## Escopo preservado

Não foram alterados Match Engine, resultados, probabilidades, calendário competitivo, valores de PM, carteira, finanças, salários ou orçamento de transferências.

## Validação local

O ambiente local não possui Flutter/Dart. Foram executadas verificações estruturais, de serialização, referências, versionamento e conteúdo do pacote. O workflow do repositório deverá executar `flutter analyze`, `flutter test` e gerar o APK versionado.
