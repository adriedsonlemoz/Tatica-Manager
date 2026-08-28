# Release 0.1.1.46 — Mercado e carreira conectada

**Android versionCode:** 48
**pubspec:** `0.1.1+48`
**CareerState schema:** 9

## Alterações principais

- Central de Mercado em cinco áreas: Buscar, Observação, Negociações, Propostas recebidas e Histórico.
- Filtros por nome, nacionalidade, clube, liga, posição, idade, overall, potencial, valor, salário, contrato e agentes livres.
- Scouting progressivo persistente: relatório inicial, observado e relatório completo.
- Negociações persistentes por dias, com contraproposta, salário, duração, bônus, até quatro parcelas e interesse concorrente.
- Parcelamento financeiro real: orçamento total comprometido no fechamento; entrada e obrigações futuras movimentam o caixa nas datas de vencimento.
- Categoria de Base persistente, potencial estimado e promoção preservando `Player.id`.
- Departamento Médico usando lesão, condição e fadiga já existentes; atletas e perfis são clicáveis.
- Caixa de Entrada com Entrada, Não lidas, Importantes e Arquivadas, reutilizando eventos da carreira e mantendo referências acionáveis; exclusões persistem como tombstones para não recriar mensagens antigas.
- Home e avanço diário conectados a treino, recuperação, contratos, scouting, negociações, propostas e preparação de partida.
- Perfil de clube compartilhado com classificação, forma recente, próximo jogo e elenco clicável.
- Calendário/pós-jogo ampliado com estatísticas e eventos identificados por jogador/assistência.
- Estatísticas com Classificação, Jogos, Artilheiros, Assistências, Disciplina e ranking dinâmico de Técnicos.
- Escudos personalizados preservam proporção/transparência e não recebem a cor do clube atrás da imagem.

## Persistência e compatibilidade

O schema passa de 8 para 9. `scoutingReports`, `transferNegotiations`, `transferInstallments`, `inbox` e `youthAcademy` são opcionais na leitura; saves antigos recebem fallback seguro. IDs existentes de clubes, jogadores e partidas não são reescritos. Ao promover um atleta da base, o `Player.id` é mantido.

## Arquitetura

- `TransferEngine` continua responsável pela validação e execução de transferências.
- O mercado CPU continua usando seus engines estratégicos existentes; nenhuma segunda execução de transferências foi criada.
- `DailyCareerEngine` coordena os acontecimentos do avanço diário e alimenta a caixa sem duplicar mensagens.
- Departamento Médico apenas representa dados persistidos/regras já existentes de disponibilidade física.
- O Match Engine não foi alterado para estas funcionalidades; Flame continua somente na representação visual da partida.

## Testes adicionados/atualizados

`test/market_career_system_test.dart` cobre criação/promoção da base com preservação de ID, scouting progressivo e idempotente no mesmo dia, negociação persistente, caixa idempotente com exclusão persistente, migração do schema 8 e parcelamento futuro, além da presença do técnico do usuário no ranking.

A execução de Flutter analyzer/test/build depende de um ambiente com Flutter SDK. Consulte o resultado efetivamente registrado na entrega; não considerar esta documentação como evidência de CI aprovado.
