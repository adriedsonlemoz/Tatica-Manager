# Release 0.1.1.31

## Resumo

A `0.1.1.31` consolida uma rodada maior de evolução visual e de fluxo no Tática Manager 2, focada principalmente em **criação de carreira**, **preparação da partida**, **pós-jogo**, **ajustes ao vivo** e **mensagens de avanço diário**.

A intenção desta release foi melhorar a sensação de acabamento sem criar sistemas paralelos e sem mexer na lógica central do Match Engine além do necessário para persistência e atualização do perfil do treinador.

## Principais entregas

### Criação de carreira
- seleção de formações agora usa **três cards por linha**;
- mini-campos das formações receberam **animação leve** para transmitir melhor o posicionamento;
- seleção de **nacionalidade** e **país de origem** agora mostra **bandeiras reais**;
- o técnico ganhou **avatar visual próprio**, com visual alinhado à estrutura usada nos jogadores;
- foi adicionada a ação **Editar aparência**;
- a aparência do treinador agora é **persistida no save**.

### Perfil do treinador
- adicionada a estrutura `ManagerAppearance`;
- o treinador passou a ter visual próprio persistente;
- a tela de configurações agora permite abrir novamente o editor de aparência;
- a exibição de origem/nacionalidade foi ajustada para evitar repetição desnecessária do país.

### Assinatura do contrato
- a animação de assinatura passou a usar o **nome do treinador** com aparência mais próxima de escrita manual.

### Home / avanço diário
- a mensagem simples no rodapé foi substituída por uma **mensagem integrada ao layout**, exibida no topo da shell com animação e fechamento automático;
- isso evita o aviso parcialmente escondido sobre a Home.

### Preparação da partida
- a tela foi reorganizada para destacar melhor:
  - adversário;
  - data;
  - estádio;
  - situação da escalação;
  - formação;
  - força da equipe;
  - jogadores indisponíveis;
  - acessos à escalação e tática.

### Pós-jogo
- a tela foi dividida em **duas etapas visuais**:
  1. resultado e principais momentos;
  2. estatísticas e situação do elenco.
- os principais acontecimentos agora exibem **avatar/rosto do jogador** quando aplicável;
- substituições receberam apresentação compacta com jogadores de entrada e saída.

### Ajustes ao vivo
- a tela foi refeita para ficar mais visual e contextual;
- cada grupo tático agora apresenta descrição curta do impacto esperado;
- a UI deixa explícito que a alteração afeta **somente o restante da partida**;
- a base do comportamento continua usando `LiveMatchController.changeTactic`, que recalcula a partir do snapshot atual do jogo.

## Estrutura / manutenção
- foi adicionada a modelagem `ManagerAppearance`;
- `ManagerProfile` passou a serializar a aparência;
- `CareerState.currentSchemaVersion` foi elevado para `7`;
- o `GameController` recebeu atualização controlada do perfil do treinador;
- a documentação e os metadados de versão foram sincronizados para `0.1.1.31` / `0.1.1+33` / `versionCode 33`.

## Arquivos de versão atualizados
- `al-sistemas.json`
- `VERSION`
- `app.json`
- `pubspec.yaml`
- `android/app/build.gradle.kts`
- `lib/core/config/app_info.dart`
- `README.md`
- `AI_HANDOFF.md`
- `docs/PROMPT_CONTINUACAO_IA.md`

## Observações
- neste ambiente, **`dart` e `flutter` não estavam instalados**, então não foi possível executar `flutter analyze`, `flutter test` ou o build localmente;
- por isso, a próxima validação obrigatória deve acontecer no CI/GitHub Actions e, idealmente, em aparelho.
