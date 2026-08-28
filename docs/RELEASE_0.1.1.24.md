# Release 0.1.1.24

## Mercado CPU — planejamento da janela

- Adiciona `CpuMarketStrategyEngine` para manter uma prioridade coerente por clube durante a mesma janela sem criar novo campo persistido no save.
- Diferencia perfis **oportunista**, **equilibrado** e **ambicioso** conforme pressão financeira, reputação, caixa, orçamento e folha.
- `CpuRecruitmentEngine` passa a montar uma lista curta de até três alvos para a prioridade atual.
- Se o alvo principal for contratado por outro clube, desaparecer ou deixar de ser viável financeiramente antes da execução, a CPU tenta a alternativa seguinte.
- `CpuUserOfferEngine` passa a alinhar propostas pelo elenco do usuário à prioridade estratégica atual do comprador.
- A concorrência continua com aleatoriedade controlada, mas prioridade/lista-base ficam estáveis na mesma janela.
- O limite de no máximo dois negócios por rodada, proteção do clube do usuário, `TransferEngine`, `ContractEngine` e limites financeiros existentes permanecem preservados.

## Classificação na Home

- A classificação compacta passa a exibir posição, clube, **J**, **V**, **E**, **D**, **SG** e **PTS**.
- Mantém apenas os líderes e, quando necessário, inclui o clube do usuário em uma linha destacada sem transformar a Home na tabela completa.
- O total de rodadas exibido no cabeçalho é derivado dos fixtures da carreira em vez de usar `/38` fixo, preparando a interface para competições com tamanhos diferentes.

## Avançar dia

- Substitui o botão genérico por um painel **Preparação diária**.
- A interface informa a próxima data, quantos dias restarão até a partida e que o avanço processa recuperação, contratos, mercado, notícias e preparação da carreira.
- A ação continua chamando o fluxo existente de `GameController.advanceDay`; nenhuma nova regra de avanço foi criada na UI.

## Criação de carreira

- Reduz `mainAxisExtent` dos cards de clube para 108 px, mantendo duas colunas, escudo, nome, overall/estrelas e orçamento.
- A etapa **Formação** passa a conter somente seleção da formação e sua representação no mini-campo.
- **Mentalidade** foi movida para a etapa seguinte, junto de **Pressão** e **Ritmo**.
- Mentalidade passa a usar o mesmo padrão de cards visuais das outras opções de estilo.
- O objeto tático persistido continua usando os mesmos enums/campos; não houve migração de save.

## Consulta do calendário — regra não alterada

O calendário atual da liga é gerado por `LeagueEngine` com `firstMatchDate(season) = DateTime(season, 4, 12)` e `fixtureGapDays = 7`. Em 2026, **12/04/2026 é domingo**. Como cada rodada soma exatamente sete dias, todas as rodadas permanecem no domingo. O segundo turno segue o mesmo espaçamento.

`LeagueEngine.validateSchedule` atualmente exige apenas que o intervalo entre partidas do mesmo clube seja maior que `minimumRestDays = 2`; ele não distribui rodadas por dia da semana. `CareerCalendarEngine` apenas avança/exibe a data da carreira e não escolhe as datas dos fixtures.

Para permitir quarta, quinta, sábado e domingo de forma segura em uma etapa futura, será necessário separar **geração dos pareamentos** da **alocação das datas**, introduzir uma política/calendário da competição com dias permitidos e validar por clube: descanso mínimo, conflito de partidas e, quando existirem múltiplas competições, choque entre competições. Os testes deverão deixar de exigir incremento fixo de sete dias e passar a validar regras de descanso/dias permitidos/conflitos.

**Nenhuma regra de data das partidas foi alterada nesta release.**

## Testes adicionados/atualizados

- prioridade estratégica estável dentro da mesma janela;
- variação controlada entre carreiras;
- perfil oportunista versus ambicioso;
- tentativa de alvo alternativo quando o principal é perdido;
- lista curta e sem duplicação de alvos;
- criação de carreira com Formação isolada e Mentalidade na etapa visual seguinte;
- cards de clube com nova altura;
- classificação compacta com J/V/E/D/SG/PTS;
- painel informativo de avanço diário e total de rodadas não hardcoded.

## Arquitetura e persistência

- `GameController` não recebeu nova responsabilidade de mercado nem lógica de classificação.
- `CpuManagerEngine` continua orquestrando; necessidade, recrutamento, finanças, vendas e estratégia permanecem em engines especializados.
- `TransferEngine` continua executando transferências e `ContractEngine` centralizando contratos.
- Match Engine e Flame não foram alterados.
- `CareerState.currentSchemaVersion` permanece inalterado.
- Não houve alteração de schema SQLite nem IDs persistentes obrigatórios.
- A regra de calendário de partidas foi apenas analisada/documentada.

## Validação obrigatória

```bash
python3 tool/versioning.py sync
python3 tool/versioning.py verify
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

O GitHub Actions deve continuar publicando somente `tatica-manager-0.1.1.24.apk` como Artifact, sem `pubspec.lock`.

## Estado da validação local

- `python3 tool/versioning.py sync`: executado com sucesso.
- `python3 tool/versioning.py verify`: executado com sucesso.
- `python3 tool/verify_app_icons.py`: executado com sucesso.
- `al-sistemas.json` e `app.json`: JSON validado localmente.
- workflow revisado: publica somente o APK versionado; não há `pubspec.lock` nos Artifacts.
- auditoria contra a `0.1.1.23`: `GameController` e `LeagueEngine` permanecem sem alterações; schema do save continua em 6.
- `flutter pub get`: tentado neste ambiente e retornou `flutter: command not found` (código 127).
- `flutter analyze`: tentado neste ambiente e retornou `flutter: command not found` (código 127).
- `flutter test`: tentado neste ambiente e retornou `flutter: command not found` (código 127).
- `flutter build apk --release`: tentado neste ambiente e retornou `flutter: command not found` (código 127).

A análise estática, a suíte Flutter e o APK da `0.1.1.24` ainda precisam ser confirmados pelo GitHub Actions ou por um ambiente com Flutter instalado.
