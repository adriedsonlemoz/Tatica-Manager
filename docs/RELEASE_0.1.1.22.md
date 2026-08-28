# Release 0.1.1.22

## Mercado CPU

- Usa `CpuMarketResult.moves` para gerar notícias persistentes com `CareerEvent`, sem estrutura paralela de notícias.
- Adiciona `CpuSellingEngine` para avaliar venda estratégica por profundidade, substitutos, importância, overall, salário, contrato, idade, potencial, valor e pressão financeira.
- Adiciona `CpuFinancialEngine` para preservar caixa, limitar gasto por operação e considerar a folha salarial projetada.
- Permite que mais de um clube registre interesse no mesmo jogador por meio de `CpuMarketResult.interests`.
- Usa aleatoriedade controlada por seed estável da carreira/temporada/rodada/clube para variar necessidades próximas, alvos e desempates sem tornar a simulação imprevisível.
- Mantém o máximo de dois negócios por rodada e impede movimentação duplicada do mesmo jogador.
- Mantém `TransferEngine` como executor de transferências e `ContractEngine` como regra central de contratos.
- Mantém o clube do usuário fora das movimentações automáticas.

## Testes

`test/cpu_market_test.dart` foi ampliado para cobrir:

- carência e ausência de carência;
- agente livre;
- compra CPU para CPU;
- titular importante e jogador excedente;
- profundidade mínima do vendedor;
- contrato próximo do fim e salário elevado na decisão de venda;
- falta de dinheiro e preservação de caixa;
- elenco cheio;
- contraproposta de renovação;
- múltiplos clubes interessados no mesmo jogador;
- limite de negócios e janela fechada;
- várias rodadas e temporadas sem duplicação de IDs;
- save/load depois das transferências e persistência das notícias.

## Arquitetura e persistência

- `GameController` não foi alterado.
- Match Engine, editor e criação de carreira não foram alterados.
- Nenhuma mudança de schema SQLite ou `CareerState.currentSchemaVersion` foi necessária.
- Notícias continuam usando `CareerEvent` e o limite existente de notícias persistidas.

## Validação obrigatória

Executar antes da publicação:

```bash
python3 tool/versioning.py sync
python3 tool/versioning.py verify
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

O GitHub Actions deve continuar publicando somente `tatica-manager-0.1.1.22.apk` como Artifact.

## Estado da validação local

- `python3 tool/versioning.py sync`: executado com sucesso.
- `python3 tool/versioning.py verify`: executado com sucesso.
- `flutter pub get`: não executável neste ambiente (`flutter: command not found`, código 127).
- `flutter analyze`: não executável neste ambiente (`flutter: command not found`, código 127).
- `flutter test`: não executável neste ambiente (`flutter: command not found`, código 127).
- `flutter build apk --release`: não executável neste ambiente (`flutter: command not found`, código 127).

A análise estática, a suíte Flutter e o APK ainda precisam ser confirmados pelo GitHub Actions ou por um ambiente com Flutter instalado.
