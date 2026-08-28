# Release 0.1.1.70

## Escopo

Correção dos dois testes estruturais que bloquearam o GitHub Actions da 0.1.1.69. O log mostra que `flutter analyze` passou e que 238 testes foram concluídos com sucesso antes das duas falhas; portanto a correção foi feita nos testes desatualizados, sem desfazer a reformulação visual nem alterar código funcional.

## Causa real

1. `manager_system_upgrade_test.dart` ainda procurava os antigos grupos `OLHOS` e `SOBRANCELHAS`. Na 0.1.1.69 esses controles continuam existentes, mas foram compactados dentro do grupo `TRAÇOS DO ROSTO`.
2. `club_editor_ui_test.dart` lia apenas `career_hub_screen.dart` e esperava textos antigos como `Abrir editor`. O acesso padrão à Central de Edição foi extraído para `career_hub_info_links.dart`, enquanto o editor por save continua no menu de cada carreira e `ClubEditorScreen` continua distinguindo `Editor do banco` de `Editor da carreira`.

## Correções

- o teste do editor de aparência agora valida `TRAÇOS DO ROSTO`, `Olhos`, `Sobrancelhas`, controle `Horizontal` e `cropZoom`;
- o teste da Central de Carreiras passa a compor `career_hub_screen.dart`, `career_hub_info_links.dart` e `club_editor_screen.dart`;
- a regressão continua protegendo o link `Edição`, o callback do editor padrão, o menu `edit-clubs`, `Editar banco da carreira` e `ClubEditorScreen`;
- não foram reintroduzidos textos ou estruturas obsoletas apenas para satisfazer os testes.

## Compatibilidade

- nenhuma alteração de produção;
- `CareerState` permanece no schema 11;
- banco SQLite permanece na versão 2;
- IDs e saves existentes permanecem inalterados;
- controllers, Match Engine e Flame não foram modificados.

## Validação esperada

O fluxo obrigatório continua sendo:

```bash
python3 tool/versioning.py verify
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Somente etapas realmente executadas devem ser reportadas como aprovadas.
