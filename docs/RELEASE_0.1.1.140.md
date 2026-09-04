# Release 0.1.1.140 — Correção do teste de recompensas

## Diagnóstico do workflow 93

O workflow concluiu o `flutter analyze` sem problemas e executou a suíte de testes. Houve uma única falha em `reward_system_test.dart`: o teste esperava 5 PM na derrota, mas recebeu 30 PM.

O resultado adicional de 25 PM não era uma falha do calculador. O segundo cálculo reutilizava o progresso global de 10 partidas produzido pelo primeiro, mas passava uma coleção vazia de transações existentes. Nesse estado artificial, o calculador identificava corretamente o marco de 10 partidas como ainda não pago e concedia os 25 PM correspondentes.

## Correção

O cenário da derrota agora inclui `matches-global:10` entre os IDs permanentes já registrados. Isso reproduz o estado que existe em produção após o commit atômico do cálculo anterior.

Assim, o teste continua verificando as duas regras pretendidas:

- derrota encerra a sequência de vitórias;
- uma partida perdida concluída concede somente os 5 PM de base quando nenhum novo marco é alcançado.

## Escopo preservado

Não houve alteração em código de produção, valores de PM, IDs, persistência SQLite, carteira, histórico, notificações, partidas, temporadas, objetivos, Match Engine, interface ou finanças.

O ambiente local desta correção não possui Flutter/Dart. A próxima execução do workflow deve confirmar a suíte completa e gerar o APK versionado.
