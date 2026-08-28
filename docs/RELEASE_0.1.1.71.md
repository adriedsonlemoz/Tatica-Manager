# Release 0.1.1.71

## Escopo

Acabamento da Central de Carreiras, da Central de Edição, dos técnicos, da personalização visual da bola e da Central de Diagnóstico. A release trabalha sobre o fluxo existente, sem criar arquitetura paralela e sem mover regras de partida para Flame.

## Central de Carreiras

- remove o botão separado **Continuar**; tocar no card do save passa a ser a ação de carregamento;
- remove a edição de carreira existente a partir desta tela;
- cada card passa a usar o escudo real do clube e dados derivados do payload do próprio save: colocação atual e próximo adversário/data;
- substitui o menu de três pontos por lixeira direta, verticalmente centralizada, com confirmação personalizada e aviso de exclusão definitiva;
- arredonda a logo da marca, troca `Suas carreiras` por `Carregar jogo salvo` e adiciona `Tática Manager Beta 2.0 • v<versão>` no rodapé;
- tocar na versão abre a Central de Diagnóstico já existente.

## Técnicos

- `ManagerAppearance` identifica perfis sem aparência personalizada e gera traços determinísticos a partir do seed estável do técnico;
- o seed passa a incluir também o ID permanente, reduzindo colisões entre perfis com nomes/dados semelhantes;
- nenhuma nova coluna, campo obrigatório de save ou alteração de ID foi criada;
- aparências efetivamente personalizadas continuam usando os valores editados como fonte autoritativa.

## Editar dados do jogo

- o atalho `Edição` passa a se chamar **Editar dados do jogo**;
- a listagem de clubes continua abrindo cada clube em uma tela própria, sem expandir o formulário no meio da rolagem;
- adiciona tutorial interno cobrindo navegação, IDs permanentes, pacotes completos, escudos, técnicos, restauração padrão e salvamento;
- compacta as ações principais para **Pacote**, **Padrão** e **Escudos**;
- **Padrão** sempre exige confirmação antes de substituir os dados preparados;
- confirmação de pacote usa margem lateral de 8 dp e resume clubes, jogadores, técnicos e escudos;
- feedback de pacote, escudos, restauração e salvamento usa diálogo central personalizado em vez do snackbar claro no rodapé;
- o arquivo principal do editor foi reduzido e operações de importação/salvamento foram separadas em `club_editor_import_actions.dart`.

## Edição de técnicos

- reorganiza o cabeçalho e compacta a lista;
- coloca **Exportar dados** e **Padrão** lado a lado;
- restauração padrão sempre pede confirmação;
- o formulário individual do técnico foi separado em `manager_editor_screen.dart` para reduzir o arquivo principal;
- mensagens de importação/restauração/exportação passam a usar feedback central.

## Bola da partida

- remove a seleção por dropdown e exibe quatro bolas visualmente: Clássica, Verde, Amarela e Retrô;
- a prévia e o campo compartilham `drawMatchBallGraphic`, evitando divergência entre a opção mostrada em Configurações e a bola renderizada na partida;
- `MatchScreen` continua encaminhando `career.settings.matchBallStyle` ao `MatchPitchGame`; a mudança permanece somente visual.

## Diagnóstico

- registros passam a guardar contexto/origem além de mensagem e stack trace;
- erros Flutter usam `FlutterErrorDetails` para registrar exceção, library/context e stack;
- a tela passa a mostrar métricas, registros recentes, contexto/origem e stack em cards expansíveis, mantendo o relatório técnico completo e exportação TXT;
- `CareerController` registra falhas capturadas ao listar, abrir, criar e excluir carreiras;
- a Central de Edição registra falhas de carregamento, importação, restauração e salvamento, permitindo diagnosticar erros que antes eram apenas tratados pela UI.

## Compatibilidade

- `CareerState` permanece no schema 11;
- SQLite permanece na versão 2;
- IDs de clubes, jogadores, técnicos, fixtures e saves permanecem inalterados;
- a Central de Carreiras continua listando metadados SQL mesmo quando um payload não pode ser decodificado;
- Match Engine não foi alterado; Flame segue somente como representação visual.

## Testes adicionados/atualizados

- `career_hub_upgrade_test.dart`: cards dos saves, dados enriquecidos, ausência de edição/Continuar, logo, subtítulo e acesso ao diagnóstico;
- `club_editor_ui_test.dart`: novo nome do editor, ausência de edição por save no hub, tutorial, confirmação, feedback central e tela própria do clube;
- `manager_system_upgrade_test.dart`: ações atuais do editor, confirmação de Padrão, part do formulário e identidades visuais distintas/estáveis;
- `match_ball_picker_test.dart`: seleção visual e ligação entre `GameSettings` e renderer da partida;
- `diagnostic_system_test.dart`: contexto de FlutterError, acesso pelo rodapé e captura de falhas de carreira;
- `career_onboarding_ui_test.dart`: nome atualizado **Editar dados do jogo**.

## Validação obrigatória

```bash
python3 tool/versioning.py verify
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Somente etapas realmente executadas devem ser reportadas como aprovadas. A validação visual final dos cards, diálogos e bolas também deve ser feita em aparelho.
