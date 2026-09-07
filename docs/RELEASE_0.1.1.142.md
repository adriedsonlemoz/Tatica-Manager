# Release 0.1.1.142 — Correção do analyzer do polimento

## Diagnóstico do workflow 95

O workflow validou a versão `0.1.1.141`, preparou o Flutter 3.47.1 e resolveu as dependências. O processo parou no `flutter analyze` antes dos testes e do APK.

Foram identificadas três causas independentes:

- `StateProvider` não estava disponível pelo import principal do Flutter Riverpod 3.4.3;
- `showGameNotice` era chamado pela Home sem o import do arquivo que o declara;
- o teste da apresentação inicial continha um parêntese excedente, provocando erros de sintaxe em cascata.

## Correções

- `home_screen.dart` substitui o estado temporário por um `NotifierProvider`, mantendo a implementação na API atual do Riverpod e alinhada aos demais controladores do projeto.
- `home_screen.dart` importa explicitamente `game_notice_dialog.dart`.
- `career_onboarding_ui_test.dart` usa uma chamada `expect` multilinha com os delimitadores corretos.

## Escopo preservado

Não houve alteração em interface, duração do Avançar Dia, notícias, apresentação da carreira, Match Engine, regras de PM, persistência, valores, finanças ou saves. A release apenas libera a análise estática dos recursos da 0.1.1.141.

O próximo workflow deverá confirmar `flutter analyze`, executar a suíte de testes e gerar o APK versionado.
