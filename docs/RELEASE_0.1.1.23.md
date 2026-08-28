# Release 0.1.1.23

## Propostas recebidas da CPU

- Adiciona `CpuUserOfferEngine` para clubes da CPU avaliarem jogadores do elenco do usuário com base em carência, qualidade, custo e capacidade financeira.
- Mantém a proteção do clube do usuário: nenhum atleta é vendido automaticamente.
- Torna `CareerEventType.transferOffer` acionável sem criar novo schema de save ou uma segunda estrutura de notícias.
- Permite aceitar, recusar e contrapropor ofertas da CPU pelo `TransferController`.
- Revalida necessidade, limite de elenco, caixa, orçamento, salário projetado e teto estratégico antes de considerar uma oferta ativa.
- Propostas expiram após cinco dias e há cooldown para reduzir repetição sobre o mesmo jogador.
- Quando a contraproposta ultrapassa o teto, a CPU pode apresentar seu valor final; o fluxo não permite barganha infinita.
- A transferência efetiva continua exclusivamente no `TransferEngine`.

## Preparação do mercado para futuras ligas

- O mercado recebe o universo de clubes da carreira e trata IDs como opacos, sem depender de `br-club-*`, Série A ou exatamente 20 clubes.
- Limites globais de elenco foram centralizados em `TransferEngine.minimumSquadSize` e `TransferEngine.maximumSquadSize`.
- `CpuManagerEngine`, `CpuSquadNeedsEngine`, `CpuSellingEngine` e `TransferController` passam a derivar seus limites desses valores quando aplicável.
- Foi adicionado cenário automatizado com 24 clubes e IDs de outra estrutura para proteger essa característica.
- Regras específicas futuras de competição, como janela, inscrição ou estrangeiros, **não** foram inventadas nesta release; deverão ser conectadas às estruturas de competição existentes quando novas ligas forem adicionadas.

## Interface

- Notícias e Eventos exibem **NEGOCIAR** em propostas válidas.
- Mercado destaca proposta recebida e abre negociação centralizada.
- O novo diálogo de oferta fica em `features/market/incoming_transfer_offer_dialog.dart`, evitando concentrar mais responsabilidade em `player_market_dialogs.dart`.
- Quando a CPU informa seu teto, a interface identifica o valor como final e mantém apenas as decisões de aceitar ou recusar.

## Testes adicionados/atualizados

- geração somente com necessidade real;
- comprador sem capacidade financeira;
- persistência de oferta via `CareerEvent` e save/load sem mudança de schema;
- contraproposta dentro e acima do teto;
- encerramento após valor final;
- expiração de proposta;
- aceite explícito transfere uma única vez e registra a venda;
- recusa preserva o atleta;
- universo com mais de 20 clubes e IDs fora do padrão brasileiro;
- limites de elenco centralizados;
- estrutura das telas de negociação.

## Arquitetura e persistência

- `GameController` não foi alterado.
- Match Engine, editor e criação de carreira não foram alterados.
- `CareerState.currentSchemaVersion` permanece inalterado.
- Não houve alteração de schema SQLite nem criação de novos IDs persistentes obrigatórios.
- `TransferEngine` continua executando transferências e `ContractEngine` continua centralizando contratos.

## Validação obrigatória

```bash
python3 tool/versioning.py sync
python3 tool/versioning.py verify
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

O GitHub Actions deve continuar publicando somente `tatica-manager-0.1.1.23.apk` como Artifact, sem `pubspec.lock`.

## Estado da validação local

- `python3 tool/versioning.py sync`: executado com sucesso.
- `python3 tool/versioning.py verify`: executado com sucesso.
- `python3 tool/verify_app_icons.py`: executado com sucesso.
- `al-sistemas.json` e `app.json`: JSON validado localmente.
- workflow revisado: publica somente o APK versionado; não há `pubspec.lock` nos Artifacts.
- `flutter pub get`: tentado neste ambiente e retornou `flutter: command not found` (código 127).
- `flutter analyze`: tentado neste ambiente e retornou `flutter: command not found` (código 127).
- `flutter test`: tentado neste ambiente e retornou `flutter: command not found` (código 127).
- `flutter build apk --release`: tentado neste ambiente e retornou `flutter: command not found` (código 127).

A análise estática, a suíte Flutter e o APK da `0.1.1.23` ainda precisam ser confirmados pelo GitHub Actions ou por um ambiente com Flutter instalado.
