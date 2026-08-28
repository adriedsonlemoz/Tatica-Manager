# Release 0.1.1.27

## Correção dos testes do mercado

O GitHub Actions da `0.1.1.26` passou pelo `flutter analyze --no-pub` sem issues e falhou em `flutter test`: 128 testes passaram e 8 falharam.

As falhas tinham duas causas reais:

- fixtures de propostas usavam o clube mais fraco da liga para comprar goleiros do clube mais forte; mesmo com caixa artificial alto, o teto salarial da CPU corretamente rejeitava a operação;
- uma contratação com overall 85 também atendia ao critério de jovem promessa, e a notícia priorizava promessa antes de destaque.

## Correções

- Os testes de oferta/aceite/recusa/contraproposta passam a usar comprador de reputação compatível com o clube do usuário.
- Foi adicionado teste garantindo que caixa elevado não ignora o teto salarial de um clube financeiramente incompatível.
- `CpuMarketNewsEngine` prioriza `Contratação de destaque` para overall >= 82 antes de classificar o atleta como jovem promessa.
- Nenhuma proteção financeira foi removida ou relaxada.
- Nenhuma mudança em `GameController`, `LeagueEngine`, Match Engine, editor, criação de carreira ou schema dos saves.

## Validação obrigatória

```bash
python3 tool/versioning.py sync
python3 tool/versioning.py verify
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

O GitHub Actions deve publicar somente `tatica-manager-0.1.1.27.apk` como Artifact, sem `pubspec.lock`.
