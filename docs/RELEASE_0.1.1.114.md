# Release 0.1.1.114 — Home alinhada à referência

## Causa

A comparação entre o print real da Home e a referência aprovada mostrou que a implementação havia se afastado visualmente: o verde estava dominando o botão e os cards de Classificação/Artilharia, os atalhos tinham ícones pequenos, o cabeçalho estava compacto demais e a barra inferior usava um grande indicador verde. O log 65 também mostrou uma falha independente em `player_avatar_identity_test.dart`, que ainda esperava `PlayerCard` no Elenco mesmo após a tela ter sido redesenhada.

## Home

- restaura a barra superior com menu, nome do jogo, notificações e caixa de entrada;
- aumenta o cabeçalho do clube e mantém somente informações reais já existentes;
- usa verde escuro no botão `AVANÇAR DIA` / `JOGAR PARTIDA`, com texto branco e ação presa ao extremo direito;
- aumenta os ícones dos seis atalhos e mantém os cards em azul-grafite;
- amplia escudos da Próxima Partida, usa nomes completos e aumenta o espaçamento dos dados do jogo;
- mantém os seis indicadores do Resumo da Temporada em uma única linha e adiciona divisores verticais;
- remove o fundo verde dominante de Classificação e Artilharia, divide os dois cards igualmente e restaura rodapés discretos;
- reduz Notícias e Destaques na Home para três linhas compactas;
- simplifica visualmente a barra inferior, removendo a cápsula verde de seleção.

## Teste corrigido

`player_avatar_identity_test.dart` passa a validar `_SquadTable`, `_SquadPlayerRow` e `PlayerAvatar` na tela Elenco atual. Nenhum `PlayerCard` antigo é recriado apenas para satisfazer o teste.

## Integridade

- Match Engine não alterado;
- saves, schema, IDs, regras e resultados preservados;
- cinco músicas otimizadas preservadas;
- `al-sistemas.json` continua ausente;
- documentação obrigatória atualizada nesta entrega.

## Versionamento

- release visível: `0.1.1.114`;
- pubspec: `0.1.1+115`;
- Android versionName: `0.1.1.114`;
- Android versionCode: `115`.
