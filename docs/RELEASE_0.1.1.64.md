# Tática Manager 0.1.1.64

Release corretiva do GitHub Actions sobre a 0.1.1.63.

## Correção

O `flutter analyze` apontou três símbolos indisponíveis nos arquivos `part` do editor de clubes:

- `ClubIconValidator` em `club_detail_editor_screen.dart`;
- `base64Encode` em `club_detail_editor_screen.dart`;
- `base64Decode` em `club_editor_widgets.dart`.

A biblioteca principal `club_editor_screen.dart` agora importa explicitamente `dart:convert` para as funções Base64 e `club_icon_validator.dart`, tornando esses símbolos disponíveis para todos os arquivos `part`.

## Regressão

O teste estrutural do editor passa a verificar que esses imports continuam presentes, além da chamada de validação já existente.

Não houve alteração no formato de packs, `iconBase64`, CareerState schema 11, IDs persistidos, saves, Match Engine ou GitHub Actions.
