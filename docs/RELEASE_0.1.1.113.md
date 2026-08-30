# Release 0.1.1.113 — Elenco em lista compacta

**Android versionCode:** `114`  
**pubspec:** `0.1.1+114`

## Alteração aplicada

A tela **Elenco** foi redesenhada seguindo a referência visual fornecida pelo usuário, sem adicionar módulos ou dados novos ao jogo.

- cabeçalho com escudo, nome do clube, temporada, reputação, saldo e orçamento de transferências já existentes no save;
- lista única de jogadores com número, avatar, nome, posição, GER e moral;
- linhas compactas em cards, sem agrupamentos por setor;
- resumo no final com total de jogadores, brasileiros e estrangeiros;
- busca e os filtros já existentes foram preservados nos ícones do topo;
- a faixa de abas `Jogadores / Funções / Status` não existe nesta implementação;
- o acesso ao Elenco pela Home passa a exibir retorno, sem alterar a aba principal do GameShell.

## Preservado

- Match Engine e renderer da partida;
- saves, schema, IDs, regras e resultados;
- cinco músicas otimizadas do menu e demais assets;
- `al-sistemas.json` continua removido;
- nenhuma imagem/mockup foi adicionada ao projeto: a imagem fornecida foi usada apenas como referência de layout.
