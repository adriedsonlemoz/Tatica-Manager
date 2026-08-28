# Release 0.1.1.72

## Escopo

Correção estritamente focada no bloqueio de `flutter analyze` mostrado pelo GitHub Actions da 0.1.1.71.

## Causa real

A refatoração anterior separou importação, restauração e salvamento da Central de Edição para `club_editor_import_actions.dart` usando uma `extension` sobre `_ClubEditorScreenState`.

O comportamento em runtime permanecia equivalente, porém a extension chamava diretamente o método protegido `State.setState`. No Dart/Flutter atual, isso gera `invalid_use_of_protected_member` porque a chamada não ocorre dentro de um membro de uma subclasse de `State`.

O CI encontrou nove ocorrências nas linhas correspondentes às operações de pacote completo, pack de escudos, restauração e salvamento.

## Correção

- as nove chamadas diretas a `setState` foram substituídas por `_updateEditorState`;
- `_updateEditorState` pertence a `_ClubEditorScreenState` e é o único ponto novo que chama `setState` para essas ações extraídas;
- `club_editor_import_actions.dart` continua separado, evitando devolver centenas de linhas ao arquivo principal;
- nenhuma lógica de importação, validação, confirmação, diagnóstico, restauração ou persistência foi removida.

## Compatibilidade

- `CareerState` permanece no schema 11;
- SQLite permanece v2;
- IDs persistentes e saves permanecem inalterados;
- nenhuma alteração no Match Engine ou no renderer Flame;
- nenhuma mudança visual nesta release.

## Testes

`club_editor_ui_test.dart` passa a proteger a refatoração verificando que o arquivo de ações não volte a chamar `setState` diretamente e que o wrapper permaneça no `State` principal.

## Validação obrigatória

```bash
python3 tool/versioning.py verify
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Só registrar como aprovadas as etapas realmente executadas.
