# Release 0.1.1.21

## Mercado CPU

- Adiciona análise de carências de elenco por posição em `CpuSquadNeedsEngine`.
- Adiciona escolha direcionada de agentes livres e jogadores de outros clubes em `CpuRecruitmentEngine`.
- Substitui a transferência aleatória periódica da CPU por decisões baseadas em necessidade, qualidade e orçamento.
- Limita o mercado a no máximo dois negócios CPU por rodada e impede que o mesmo jogador seja negociado duas vezes na mesma execução.
- Protege integralmente o clube do usuário contra movimentações automáticas da CPU.
- Renovações CPU passam a reutilizar `ContractEngine.negotiate`, evitando regra paralela de contrato.
- Mantém `TransferEngine` como executor central de compras e vendas.
- Adiciona `test/cpu_market_test.dart` cobrindo carência, agente livre, transferência, duplicação, proteção do usuário, janela e limite de negócios.

## Arquitetura

Nenhuma mudança foi necessária no `GameController`, no schema do save ou no Match Engine.

## Validação

Executar antes da publicação:

```bash
python3 tool/versioning.py sync
python3 tool/versioning.py verify
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```
