# Release 0.1.1.14 — Editor completo do banco

## Escopo

A `0.1.1.14` transforma o editor de identidade da versão anterior em um editor de banco completo, mantendo a lógica de jogo desacoplada da apresentação e dos arquivos comunitários.

## Alterações

- mantém IDs internos neutros `br-club-001` a `br-club-020`;
- adiciona `shirtNumber` persistente ao jogador;
- adiciona estádio editável, incluindo nome, capacidade e preço do ingresso;
- adiciona `ClubKit` para uniforme 1, 2 e 3, com cinco cores e padrão visual;
- adiciona ícone/escudo local em Base64 com limite de 256 KiB;
- adiciona editor completo de jogadores: identidade, posições, pé, dimensões físicas, camisa, overall, potencial, mercado, contrato, atributos e perfil visual;
- adiciona edição/importação dos jogadores livres;
- permite alterar estrutura de elencos no banco padrão antes de criar uma carreira;
- preserva IDs e estado transitório quando a edição ocorre em uma carreira existente;
- amplia o formato comunitário `tatica-manager-clubs` para versão 2;
- adiciona `tatica-manager-players` v1 para importar somente um elenco/lista de atletas;
- mantém leitura dos pacotes v1 como pacotes mínimos com fallback;
- limita elencos a 20–30 atletas para respeitar as regras já existentes de transferências/CPU;
- adiciona `docs/BANCO_TESTE_NOMES_REAIS.json` para testes locais, sem incorporar esses nomes à base distribuída.

## Arquitetura

`ClubIdentityEngine` permanece responsável por normalizar, validar e aplicar o banco. As telas apenas coletam dados. `CareerController` continua responsável por persistência de carreiras/pacote padrão. Match Engine, TransferController e LiveMatchController não receberam nova responsabilidade.

## Compatibilidade e integridade

Embora o jogo ainda não tenha sido lançado, a mudança mantém fallback de serialização para não tornar testes e saves de desenvolvimento desnecessariamente frágeis. `Club.id` e `Player.id` continuam imutáveis em carreiras existentes.

Ao aplicar um pacote em um save, lesão, cartões, condição, fadiga, moral, estatísticas e histórico atuais são preservados. Em novas carreiras, o banco padrão pode definir a estrutura completa dos elencos e jogadores livres.

## Validação pendente

É obrigatório executar `flutter pub get`, `flutter analyze`, `flutter test` e `flutter build apk --release` no CI caso o ambiente local não possua Flutter, além de validar seletor de arquivos, ícones e os formulários em aparelho Android.
