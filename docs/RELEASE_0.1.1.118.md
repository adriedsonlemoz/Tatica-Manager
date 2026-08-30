# Release 0.1.1.118 — Pré-jogo alinhado à referência

**pubspec:** `0.1.1+119`  
**Android versionCode:** `119`

## Objetivo

Aplicar ao jogo o design de Pré-jogo aprovado pelo usuário sem inventar informações que o domínio ainda não possui. Por isso técnico, clima e árbitro não foram adicionados.

## Novo layout do Pré-jogo

A tela passa a ser organizada em:

1. card principal com competição, escudos, clubes, `VS`, data/hora, estádio e forma recente;
2. `CONFRONTO TÁTICO` com formação, mentalidade e comparação de Ataque / Meio-campo / Defesa;
3. `ESCALAÇÃO PROVÁVEL` em duas colunas;
4. `DESFALQUES` dos dois clubes;
5. cards `ESCALAÇÃO`, `TÁTICA` e `UNIFORMES`;
6. ações `JOGAR PARTIDA` e `SIMULAR`.

A duração da transmissão não é mais exibida no Pré-jogo. A configuração existente continua disponível nas Configurações do jogo.

## Dados reais, sem conteúdo decorativo

- a forma recente usa os últimos cinco `MatchFixture` já disputados por cada clube;
- o rival usa `LiveRoundSimulator.formationFor(opponent)` e `LiveRoundSimulator.tacticFor(opponent)`, exatamente a derivação usada ao preparar a partida;
- os titulares do rival vêm de `LineupEngine.autoSelect` com as suspensões da competição;
- Ataque, Meio-campo e Defesa usam `MatchStrengthCalculator.calculate` para os dois lados;
- os desfalques incluem lesão, suspensão específica da competição e condição física inferior a 35%;
- o estádio exibido é `home.stadium.name`.

## Uniformes

O seletor existente deixa de ocupar permanentemente a tela e passa a abrir em `showDialog`. `PreMatchKitSelector` e `MatchKitResolver` foram mantidos, portanto o usuário continua escolhendo seu uniforme e o rival continua sendo ajustado automaticamente para evitar conflito de cores.

## Simulação direta

`SIMULAR` não cria uma engine paralela. O fluxo é:

```text
LiveMatchController.prepareMatch()
→ Match Engine existente
→ LiveMatchController.finishMatch()
→ ResultScreen
```

Assim gols, cartões, lesões, estatísticas, classificação, finanças, mercado da CPU, notícias e demais efeitos pós-jogo continuam passando pelo mesmo pipeline da partida assistida.

## Escopo preservado

- Match Engine não alterado;
- regras e probabilidades de resultados não alteradas;
- Estádio e os três sistemas da 0.1.1.116/117 não alterados;
- músicas não alteradas;
- saves/schema/IDs não alterados;
- `al-sistemas.json` continua ausente.
