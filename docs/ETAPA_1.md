# Etapa 1 — Fundação compilável

Repositório oficial desta reconstrução: `https://github.com/adriedsonlemoz/TaticaManager2`

Objetivo: transformar a nova base do Tática Manager em um projeto Flutter verificável e capaz de gerar APK.

## Padrão de ferramentas

- Flutter 3.47.0 stable
- Dart fornecido pelo Flutter 3.47.0
- Java 21 no CI
- Android + iOS gerados a partir do template oficial do Flutter

## Configuração de plataforma

`tool/bootstrap_flutter.sh` cria as pastas nativas usando `flutter create` e aplica as regras do Tática Manager.

`tool/configure_platforms.py` força:

- orientação portrait no Android;
- orientação portrait no iPhone/iPad;
- nome exibido "Tática Manager";
- barras Android transparentes compatíveis com o modo edge-to-edge usado em `lib/main.dart`.

## Validação obrigatória

Execute:

```bash
./tool/bootstrap_flutter.sh
./tool/verify_stage1.sh
```

A verificação executa, nessa ordem:

1. `flutter pub get`
2. `flutter analyze`
3. `flutter test`
4. `flutter build apk --release`

O APK esperado fica em:

`build/app/outputs/flutter-apk/app-release.apk`

O mesmo fluxo é executado pelo GitHub Actions em `.github/workflows/flutter-ci.yml`.

## Correções após a primeira execução do CI

O primeiro workflow de 24/08/2026 chegou corretamente até `flutter analyze`, que detectou 35 apontamentos. A revisão seguinte corrigiu:

- ícones Material inexistentes (`strategy_*` e `contract_rounded`);
- chamadas do calendário para usar o parâmetro nomeado `season:`;
- teste padrão `MyApp` criado automaticamente por `flutter create`;
- `super.render(canvas)` obrigatório do Flame;
- imports/variáveis sem uso e regras de lint;
- uso de `BuildContext` após operação assíncrona;
- avisos de ações antigas no GitHub Actions (`checkout@v5` e `setup-java@v5`).

A etapa continua considerada em andamento até `flutter analyze`, `flutter test` e `flutter build apk --release` passarem no GitHub Actions e o Artifact do APK existir.

## Correções após a segunda execução do CI

A segunda execução de 24/08/2026 confirmou que o projeto passou completamente no `flutter analyze` com **No issues found**. O pipeline avançou para `flutter test` e os dois testes falharam pelo mesmo motivo: ainda usavam o identificador antigo e fictício `aurora`, que não existe mais na base atual de 20 clubes brasileiros.

Correção aplicada:

- `league_schedule_test.dart` agora usa `clubSeeds.first.id`, garantindo que o teste crie a carreira com um clube realmente existente na seed atual;
- `serialization_smoke_test.dart` recebeu a mesma correção;
- o teste continua validando a criação da carreira, calendário de 38 rodadas e round-trip JSON, sem depender de um identificador legado.

Com isso, o próximo CI deve ultrapassar a etapa de testes e chegar ao `flutter build apk --release`, caso não exista outro erro funcional oculto.


## Refatoração de carreiras — build 0.1.0+2

Antes de ampliar novas mecânicas, o fluxo inicial foi reorganizado para não acoplar a criação/abertura de saves ao `GameController`.

Mudanças principais:

- `CareerController` dedicado a listar, abrir, criar e apagar carreiras;
- SQLite schema v2 com múltiplos saves;
- migração do antigo save único;
- Central de Carreiras como primeira tela após a Splash;
- assistente de nova carreira em três etapas;
- perfil do técnico salvo por carreira;
- formação e tática definidas antes do início;
- botão para voltar da carreira ativa à Central sem apagar o save;
- proteção adicional de `SafeArea` nas novas telas;
- `cupertino_icons` atualizado para `^1.0.9`;
- novos testes de metadados, compatibilidade de serialização e configuração inicial.

A validação da Etapa 1 continua sendo feita pelo GitHub Actions e só termina quando análise, testes e build do APK passarem.


## Refatoração de controladores — build 0.1.0+3

O controlador principal foi reduzido antes da próxima expansão funcional:

- `LiveMatchSession` e o fluxo da partida foram movidos para `LiveMatchController`;
- compras, vendas e renovações foram movidas para `TransferController`;
- `GameController` permanece responsável pela carreira ativa, escalação, tática, configurações, persistência consolidada e avanço de temporada;
- abrir/criar/fechar/excluir uma carreira agora limpa explicitamente qualquer sessão de partida ao vivo;
- telas de partida e mercado passaram a consumir os controladores especializados;
- `controller_refactor_test.dart` protege a separação de estado e o fluxo de contratação;
- versão incrementada para `0.1.0+3`.

A próxima divisão arquitetural, depois de validar este build no CI, será o `MatchEngine`.


## Refatoração do Match Engine — build 0.1.0+4

O motor de partida foi dividido sem alterar a API pública `MatchEngine.simulate(...)`:

- `match_engine.dart` virou fachada/orquestrador e caiu de 543 para cerca de 110 linhas;
- força por setor e modificadores táticos foram movidos para `MatchStrengthCalculator`;
- ameaça, posse e probabilidades por minuto foram movidas para `MatchProbabilityCalculator`;
- seleção de finalizador, assistente e goleiro foi movida para `MatchPlayerSelector`;
- criação dos acontecimentos estruturados foi movida para `MatchEventGenerator`;
- o relógio e a timeline ficaram em `MatchTimelineGenerator`;
- estatísticas finais ficaram em `MatchStatisticsCalculator`;
- trajetórias da bola ficaram em `MatchTrajectoryGenerator`;
- a ordem do `Random`, a seed, os eventos, o suporte a re-simulação e o balanceamento existente foram preservados;
- `match_engine_refactor_test.dart` adiciona regressão de determinismo e teste de força tática;
- versão incrementada para `0.1.0+4`.

A próxima prioridade, após o CI validar este build, passa a ser testar o ciclo de temporada de ponta a ponta antes de adicionar novas mecânicas.
