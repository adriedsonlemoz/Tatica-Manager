# Release 0.1.1.136 — Auxiliar técnico e treino assistido

## Correção do workflow 89

O workflow confirmou `flutter analyze` sem problemas e aprovou 314 testes. A única falha era estrutural: `pre_match_and_lineup_ui_test.dart` ainda exigia o título “INELEGÍVEIS / INDISPONÍVEIS”, removido quando o banco da Escalação passou a adaptar as opções disponíveis e exibir o motivo em cada jogador.

O teste agora protege o comportamento atual: jogadores indisponíveis continuam no banco paginado, são identificados por `availableIds` e recebem o texto produzido por `playerAvailabilityReason`.

## Auxiliar técnico

- Novo módulo acessível em Mais e pela ação da tela de Táticas.
- Interface fixa e responsiva no padrão azul-grafite, sem imagens novas.
- Indicador de prontidão baseado em condição, fadiga e disponibilidade real.
- Alertas de lesão, baixa condição, suspensão, cartões acumulados, improvisação, fadiga e potencial de evolução.
- Cada alerta associado a atleta abre o perfil correspondente.
- As recomendações só mudam a carreira depois do botão “Aplicar recomendações”.

## IA local

`TechnicalAssistantEngine` é determinístico e funciona completamente no aparelho. Ele não envia dados para serviços externos e não inventa jogadores ou adversários.

A análise reutiliza:

- `LineupEngine` para disponibilidade, compatibilidade posicional e titulares;
- `MatchStrengthCalculator` para comparar ataque, meio-campo, defesa e goleiro;
- `LiveRoundSimulator` para formação, tática e técnico do adversário;
- disciplina da competição da próxima partida;
- condição, fadiga, moral, lesões, potencial e calendário persistidos.

O assistente pode recomendar uma das oito formações existentes e somente os cinco controles já suportados por `Tactic`: mentalidade, pressão, ritmo, linha defensiva e construção.

## Sistema de treino

- `TrainingPlan` persiste foco, intensidade e modo de gestão.
- Focos disponíveis: recuperação, equilibrado, tático, físico e técnico.
- Intensidades: leve, normal e alta.
- No modo automático, `TrainingEngine.recommend` recalcula o plano a cada avanço diário conforme proximidade da partida e estado físico.
- No modo manual, a seleção permanece até nova alteração do usuário.
- A carga diária usa a recuperação já existente e aplica ajustes moderados de condição, fadiga e moral; lesionados não recebem carga adicional.
- O resumo diário informa foco, intensidade e variação da condição média.

## Persistência e compatibilidade

- `CareerState.currentSchemaVersion` passa de 15 para 16.
- `trainingPlan` é serializado no mesmo payload da carreira.
- Saves antigos sem o campo recebem plano equilibrado, intensidade normal e gestão automática.
- SQLite e IDs existentes não mudam.
- Nenhuma probabilidade, placar ou resultado do Match Engine é decidido pela IA.

## Testes adicionados

- round-trip e fallback do plano de treino;
- recomendação conforme distância da partida;
- efeito da recuperação assistida;
- aplicação automática no avanço diário;
- relatório com escalação válida e adversário real;
- integração da tela sem HTTP ou Match Engine paralelo.
