# Release 0.1.1.147 — Correção do Build 100

**Android versionCode:** `148`

## Motivo

O workflow **Flutter — Analisar, Testar e Gerar APK #100** concluiu as etapas de checkout, validação de versão, Java, Flutter, plataforma Android, ícones, dependências e análise estática. Na suíte de testes, **344 testes passaram e 1 falhou**.

A única falha foi:

`test/app_info_test.dart: Sobre / Novidades mantém três releases e canais de apoio`

O teste esperava `AppInfo.recentReleases` com exatamente três entradas, enquanto a 0.1.1.146 havia deixado quatro entradas no histórico recente.

## Correção

- `AppInfo.recentReleases` voltou a conter exatamente três releases;
- a nova 0.1.1.147 aparece em primeiro lugar;
- 0.1.1.146 e 0.1.1.145 continuam visíveis como histórico recente;
- a 0.1.1.144 permanece documentada no repositório, apenas deixa de ocupar a lista curta da tela Sobre / Novidades.

## Áudio preservado

A correção não altera a atualização sonora anterior. Permanecem:

- 15 locuções WAV para eventos importantes;
- distinção de gol do mandante e do visitante;
- TTS apenas como fallback;
- novo ambiente de estádio sem o chiado anterior;
- novos efeitos de chute, trave, defesa, gol e pênalti defendido;
- mixagem e ducking introduzidos nas releases 0.1.1.145 e 0.1.1.146.

## Versionamento

- release / Android `versionName`: `0.1.1.147`;
- Flutter: `0.1.1+148`;
- Android `versionCode`: `148`.

## Validação

- causa do workflow 100 reproduzida a partir do log enviado pelo usuário;
- contrato do teste (`hasLength(3)`) reconciliado com `AppInfo.recentReleases`;
- `python3 tool/versioning.py verify` deve validar metadados e documentação;
- Flutter não está instalado no ambiente de empacotamento, portanto o novo `flutter test` e o APK devem ser executados pelo GitHub Actions.
