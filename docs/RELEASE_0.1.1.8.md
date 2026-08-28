# Release 0.1.1.8 — Mercado, histórico da carreira e CI

Esta entrega mantém a arquitetura Flutter existente e concentra mudanças em transferências, renovação, continuidade de temporadas e distribuição dos artifacts do CI.

## Mercado e elenco

- A venda pelo perfil do jogador deixa de tentar negociar contra o próprio clube do usuário.
- O mercado calcula uma proposta de compra da CPU e mostra clube comprador, valor de mercado e valor ofertado antes da confirmação.
- A operação é revalidada no momento da aceitação para impedir venda com orçamento/elenco do comprador já alterados.
- Ao vender um titular, a escalação é refeita automaticamente para não manter um ID inexistente entre os onze iniciais.
- Compra, venda e renovação retornam feedback dentro das próprias janelas, evitando mensagens soltas na parte inferior da tela.
- Contrapropostas de compra e renovação usam valores monetários formatados.

## Interface das negociações

- Compra e renovação usam diálogos centralizados, responsivos e roláveis.
- A negociação de compra mantém taxa, salário, duração, contraproposta e impacto financeiro na mesma janela.
- A renovação mostra salário atual, expectativa, luvas estimadas e ajusta a proposta para a contraproposta quando necessário.
- A venda exige confirmação explícita antes de mover o jogador e creditar a receita.

## Temporadas

- Adiciona tela **Histórico da carreira** em Mais.
- Cada temporada concluída registra posição, pontos, vitórias, empates e derrotas.
- O fim da temporada agora abre uma revisão central antes da virada de ano, deixando claro o que será processado ao iniciar a próxima temporada.
- O teste de múltiplas temporadas continua cobrindo calendário e virada até 2040 e agora também valida o crescimento do histórico.

## GitHub Actions

- `flutter pub get` permanece a etapa única de resolução de dependências; analyze, test e build usam `--no-pub`.
- APK e `pubspec.lock` são copiados para nomes versionados em `dist/`.
- `actions/upload-artifact@v7` usa `archive: false` para arquivos individuais, evitando downloads como `tatica-manager-...-pubspec-lock.zip`.
- O build release desativa o watcher VFS do Gradle no runner efêmero para reduzir trabalho desnecessário. O aviso `Already watching path` é originado pelo tooling Flutter e deve ser reavaliado no próximo log; ele não impediu o APK 0.1.1.7 de ser gerado.
- A migração para Built-in Kotlin permanece adiada até que app e plugins possam ser validados juntos; o build atual continua usando o modo de compatibilidade que passou no CI.

## Versão

- Release visível / Android `versionName`: `0.1.1.8`
- `pubspec.yaml`: `0.1.1+10`
- Android `versionCode`: `10`
