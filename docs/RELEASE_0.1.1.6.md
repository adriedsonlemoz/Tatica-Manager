# Release 0.1.1.6 — Temporadas, calendário e fluxo de partida

## Objetivo

Introduzir o avanço diário da carreira e tornar o dia da partida um fluxo completo: preparação da equipe, primeiro tempo, intervalo, segundo tempo e resumo final.

## Alterações

- `CareerState` passa a persistir `currentDate` (schema 3), mantendo fallback para saves antigos.
- Novas temporadas começam três dias antes da primeira rodada e a Home avança exatamente um dia por toque em **Avançar dia**.
- No dia do jogo, o avanço fica bloqueado e a Home abre **Preparar partida**.
- A tela pré-jogo mostra formação, titulares, força, lesionados, suspensos e jogadores afastados por baixa condição, com acesso a Escalação/Tática e ajuste automático.
- Lesões e suspensões existentes são respeitadas durante a rodada e só então têm sua duração consumida; novas ocorrências permanecem ativas para a rodada seguinte.
- A passagem de dias recupera condição e fadiga, sem reduzir lesões/suspensões por rodada.
- O calendário da liga mantém 38 rodadas e passa a validar explicitamente pelo menos dois dias completos de descanso entre partidas de um mesmo clube.
- A partida ao vivo para aos 45 minutos, exibe **Intervalo**, permite ajustes e exige ação para começar o segundo tempo; aos 90 minutos exibe **Fim de jogo**.
- O resumo final mostra placar do intervalo/final, resultado para o usuário, principais eventos, estatísticas, posição na liga e situação do elenco.
- Configurações recebe **Sobre / Novidades** com as três versões mais recentes recolhidas/expansíveis, contato e apoio via Pix.
- Contato e chave Pix: `adriedson@outlook.com`.
- `tool/versioning.py` também sincroniza/valida `AppInfo.version`.

## Versionamento

- Release visível / Android `versionName`: `0.1.1.6`
- `pubspec.yaml`: `0.1.1+8`
- Android `versionCode`: `8`

## Testes adicionados/ajustados

- avanço diário e bloqueio no dia da partida;
- persistência e fallback de `currentDate`;
- descanso mínimo do calendário;
- estados de indisponibilidade e exclusão da escalação automática;
- duração por rodada de lesão/suspensão;
- evento de intervalo aos 45' e fim de jogo aos 90';
- viradas consecutivas de temporada e validade do calendário até 2040;
- metadados da release, três entradas de Novidades e infraestrutura Android.

## Validação necessária no CI/aparelho

Antes de considerar esta release pronta, executar:

```text
python3 tool/versioning.py verify
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

No aparelho, validar especialmente o avanço diário, a tela pré-jogo, alterações táticas/substituições no intervalo, retorno do resumo final e a janela Sobre / Novidades.
