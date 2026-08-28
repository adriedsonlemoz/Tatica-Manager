# Prompt — Próximo chat: contratos e jogadores livres

Você vai continuar o desenvolvimento do Tática Manager 2 a partir da versão 0.1.1.11.

Antes de alterar qualquer código, leia `AI_HANDOFF.md`, `README.md`, `docs/PROMPT_MESTRE.txt` e as documentações relacionadas. Inspecione a implementação atual e não reconstrua o projeto nem crie uma arquitetura paralela.

Neste chat, trabalhe somente na lógica de **contratos e jogadores livres**. Não implemente mercado completo da CPU, evolução de jogadores, categorias de base ou evolução visual 2D nesta etapa, exceto mudanças mínimas indispensáveis para os contratos funcionarem corretamente.

Objetivos:
- fazer contratos realmente vencerem conforme o calendário;
- gerar alertas antes do vencimento;
- permitir renovação antes do fim do vínculo;
- permitir que o jogador recuse ou faça contraproposta de renovação com regras coerentes;
- quando o contrato terminar sem renovação, retirar o jogador do clube e colocá-lo como jogador livre;
- impedir que jogadores com contrato vencido permaneçam indefinidamente no elenco;
- preservar IDs e compatibilidade de saves antigos, adicionando migração/default quando necessário;
- manter salário, duração e impacto financeiro consistentes;
- garantir que a virada de temporada e o avanço diário não processem o mesmo vencimento duas vezes;
- adicionar testes para vencimento, renovação, recusa, jogador livre, save/load e múltiplas temporadas.

Regras importantes:
- `CareerController`, `GameController`, `LiveMatchController` e `TransferController` já têm responsabilidades separadas; não volte a concentrar tudo no `GameController`;
- lógica de negócio não deve ficar nas telas;
- preserve o Match Engine e o Flame; esta tarefa não é visual;
- o GitHub Actions deve continuar publicando somente o APK nos Artifacts; nunca publique `pubspec.lock`;
- antes da entrega, incremente a versão a partir de 0.1.1.11, sincronize `al-sistemas.json`, `VERSION`, `app.json`, `pubspec.yaml` e Android, e execute/verifique `python3 tool/versioning.py verify`, `flutter pub get`, `flutter analyze`, `flutter test` e `flutter build apk --release` quando o ambiente permitir;
- não remova recursos funcionais apenas para fazer os testes passarem.

Antes de implementar, faça uma análise curta de como contratos são armazenados e processados hoje, identifique riscos de duplicação ou regressão e diga quais arquivos serão alterados. Depois implemente a menor mudança coerente, atualize os testes e documente somente decisões relevantes.
