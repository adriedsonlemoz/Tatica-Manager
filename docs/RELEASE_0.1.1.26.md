# Release 0.1.1.26

## Correção do GitHub Actions

O workflow da `0.1.1.25` voltou a parar em `flutter analyze --no-pub`, antes dos testes e do APK. A causa real foram acessos a propriedades de valores anuláveis em `test/cpu_market_test.dart` (`unchecked_use_of_nullable_value`).

Os testes já verificavam `isNotNull`, mas o matcher do pacote de testes não promove o tipo para o analyzer. A correção mantém as mesmas assertions e cria referências locais não anuláveis imediatamente depois delas, evitando tanto acessos anuláveis quanto operadores `!` redundantes espalhados.

## Escopo

- Nenhuma regra do mercado foi alterada.
- Nenhuma mudança em `GameController`, `LeagueEngine`, editor, criação de carreira ou Match Engine.
- Nenhuma mudança de schema SQLite ou IDs persistidos.
- Mantidas integralmente as funcionalidades da `0.1.1.24` e o hotfix anterior.

## Validação obrigatória

```bash
python3 tool/versioning.py sync
python3 tool/versioning.py verify
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

O GitHub Actions deve publicar somente `tatica-manager-0.1.1.26.apk` como Artifact, sem `pubspec.lock`.
