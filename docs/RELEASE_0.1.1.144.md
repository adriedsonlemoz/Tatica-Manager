# Release 0.1.1.144 — Elenco organizado e menu ajustado

## Escopo

Esta release reorganiza a leitura do Elenco e corrige o espaço visual abaixo do último item da tela Mais. Não adiciona opções, abas, dados ou regras de jogo.

## Elenco

- A lista mantém uma única tela rolável e passa a separar os atletas em Goleiros, Defensores, Meio-campistas e Atacantes.
- Busca e filtro são aplicados antes do agrupamento; grupos sem resultado ficam ocultos e o perfil completo continua abrindo ao tocar na linha.
- A posição deixa de ser repetida abaixo do nome e permanece na coluna POS.
- A segunda linha mostra `idade • situação`, usando `Player.age` e os dados já persistidos de lesão, suspensão, condição, fadiga e moral.
- Lesão e suspensão têm prioridade na situação apresentada e recebem fundo, contorno e texto de atenção. O detalhe real permanece acessível por tooltip e a coluna Cartões continua exibindo a disciplina da competição atual.
- As linhas preservam avatar, padding e altura anteriores; as colunas POS, GER e Cartões continuam alinhadas.
- O resumo superior do clube reduz escudo, margens e espaçamentos sem remover nome, temporada, reputação, saldo ou orçamento de transferências.

## Menu Mais

- O padding inferior após Configurações cai de 96 para 20 pixels lógicos.
- Os destinos, descrições, ordem, altura e área de toque dos cards permanecem iguais; nenhuma opção foi criada para preencher a tela.

## Integridade preservada

Não foram modificados modelos de jogador, serialização, regras de disponibilidade, disciplina, Match Engine, escalação, perfil do jogador, recompensas, valores de PM, SQLite, saves ou finanças do clube.

## Validação

- teste estrutural dedicado ao agrupamento, idade real, estados prioritários, manutenção das colunas e compactação do cabeçalho;
- atualização do teste do menu Mais para impedir o retorno da reserva inferior de 96 pixels;
- verificação de delimitadores Dart, contratos textuais, metadados de versão, ícones e conteúdo do pacote final.

O ambiente local desta entrega não inclui o SDK Flutter. `flutter analyze`, `flutter test` e a geração do APK devem ser confirmados pelo workflow do projeto.
