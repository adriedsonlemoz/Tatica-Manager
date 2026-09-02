# Release 0.1.1.129 — Confiabilidade da carreira, diretoria e CPU

**Release visível:** `0.1.1.129`  
**Android versionCode:** `130`

## Alterações

- O estado ativo da carreira só é atualizado depois que o SQLite confirma a gravação. Falhas são registradas no diagnóstico e não deixam alterações apenas aparentes.
- A migração do banco executa cada etapa necessária e mantém payloads V1 inválidos em uma tabela de recuperação, em vez de descartá-los sem registro.
- A diretoria passa a ter meta de posição e confiança persistentes, avaliadas por tabela e caixa. A Home exibe a meta e há uma avaliação semanal baseada somente nos dados da carreira.
- Formação e estilo do `ManagerProfile` dos clubes CPU agora chegam às simulações de partidas e competições.
- O feed recente guarda 120 notícias; as mais antigas são retidas em arquivo persistente de até 400 eventos e continuam acessíveis na tela de notícias.
- O calendário passou a informar claramente por que copas, grupos e partidas únicas ainda não podem ser ativados, evitando a criação de tabelas ou chaves fictícias.

## Preservado

- Match Engine, resultados, IDs de clube, regras de mercado, jogadores, contratos e o catálogo atual de competições não foram alterados.
- Não foram adicionados clubes, copas ou dados fictícios novos.
