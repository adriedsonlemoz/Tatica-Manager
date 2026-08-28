# Release 0.1.1.73

## Escopo

Correção estritamente focada no único teste que ainda falhou no GitHub Actions da 0.1.1.72.

## Causa real

O `flutter analyze` da 0.1.1.72 passou e 245 testes também passaram. A única falha estava em `editor_experience_test.dart`.

Na 0.1.1.71/72, o salvamento da Central de Edição foi modularizado: a navegação e o `State` principal permanecem em `club_editor_screen.dart`, as ações de salvar/importar ficam em `club_editor_import_actions.dart` e o feedback central reutilizável fica em `editor_feedback_dialog.dart`.

O teste antigo ainda lia somente `club_editor_screen.dart` e procurava `_showSaveConfirmation` e a construção antiga `title: const Text('Alterações salvas')`, símbolos que deixaram de existir depois da refatoração legítima.

## Correção

- o teste continua validando a navegação `País > Campeonato > Série > Clubes` no arquivo principal;
- passa a validar `_save`, `showEditorNotice` e `title: 'Alterações salvas'` no arquivo de ações;
- passa a validar `showDialog<void>` e `AlertDialog` no componente de feedback central;
- não reintroduz método antigo apenas para satisfazer o teste.

## Compatibilidade

- nenhuma mudança em código funcional ou visual;
- `CareerState` permanece no schema 11;
- SQLite permanece v2;
- IDs e saves permanecem inalterados;
- Match Engine e Flame não foram alterados.

## Validação obrigatória

```bash
python3 tool/versioning.py verify
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Somente etapas realmente executadas devem ser reportadas como aprovadas.
