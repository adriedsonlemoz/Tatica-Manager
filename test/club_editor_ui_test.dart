import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Central de Carreiras expõe apenas o editor padrão do jogo', () {
    final hub = File('lib/features/career/career_hub_screen.dart').readAsStringSync();
    final links = File('lib/features/career/career_hub_info_links.dart').readAsStringSync();
    final editor = File('lib/features/career/club_editor_screen.dart').readAsStringSync();

    expect(links, contains("label: 'Editar dados do jogo'"));
    expect(hub, contains('onEditor:'));
    expect(hub, contains('const ClubEditorScreen()'));
    expect(hub, isNot(contains("value: 'edit-clubs'")));
    expect(hub, isNot(contains('Editar banco da carreira')));
    expect(editor, contains("'Editar dados do jogo'"));
  });

  test('editor expõe clube, estádio, uniformes, ícone e jogadores', () {
    final source = [
      'lib/features/career/club_editor_screen.dart',
      'lib/features/career/club_detail_editor_screen.dart',
      'lib/features/career/club_editor_widgets.dart',
      'lib/features/career/club_editor_import_actions.dart',
      'lib/features/career/game_data_editor_tutorial_screen.dart',
    ].map((path) => File(path).readAsStringSync()).join('\n');

    expect(source, contains('Importar pacote completo'));
    expect(source, contains("extensions: ['json', 'tmclubs', 'tmpack', 'xml']"));
    expect(source, contains('Importar somente escudos'));
    expect(source, contains('Técnicos'));
    expect(source, contains('_confirmFullPackImport'));
    expect(source, contains(r"label: 'Técnicos', value: '$managerCount'"));
    expect(source, contains('ClubLogoPackImporter.decodeBytes'));
    expect(source, contains('ClubLogoPackEngine.applyToIdentityPack'));
    expect(source, contains('A associação é feita pelo ID permanente'));
    expect(source, contains('ClubPackImporter.decodeBytes'));
    expect(source, contains('ClubIdentityEngine.normalizeAndValidatePack'));
    expect(source, contains('ID permanente:'));
    expect(source, contains('Nome e apelido'));
    expect(source, contains('Estádio'));
    expect(source, contains('Uniformes'));
    expect(source, contains('Ícone / escudo'));
    expect(source, contains('32–1024 px'));
    expect(source, contains('ClubIconValidator.validateBytes'));
    final librarySource = File('lib/features/career/club_editor_screen.dart').readAsStringSync();
    expect(librarySource, contains("import 'dart:convert' show base64Decode, base64Encode;"));
    expect(librarySource, contains("import '../../game/club/club_icon_validator.dart';"));
    expect(source, contains('Jogadores'));
    expect(source, contains('Jogadores livres'));
    expect(source, contains('Como editar os dados'));
    expect(source, contains('Tutorial de edição'));
    expect(source, contains('Restaurar dados padrão?'));
    expect(source, contains('insetPadding: const EdgeInsets.symmetric(horizontal: 8'));
    expect(source, contains('showEditorNotice('));
    expect(source, contains('Navigator.of(context).push<ClubIdentity>'));
    expect(source, contains('_ClubDetailEditorScreen('));
  });

  test('ações extraídas do editor atualizam estado pelo State principal', () {
    final screen = File('lib/features/career/club_editor_screen.dart').readAsStringSync();
    final actions = File('lib/features/career/club_editor_import_actions.dart').readAsStringSync();

    expect(screen, contains('void _updateEditorState(VoidCallback update) => setState(update);'));
    expect(actions, contains('_updateEditorState('));
    expect(actions, isNot(contains('setState(')));
  });

  test('editor de jogadores expõe dados-base e atributos avançados', () {
    final source = File('lib/features/career/player_database_editor_screen.dart').readAsStringSync();

    expect(source, contains('Número da camisa'));
    expect(source, contains('Overall'));
    expect(source, contains('Potencial'));
    expect(source, contains('Valor de mercado'));
    expect(source, contains('Salário mensal'));
    expect(source, contains('Atributos técnicos'));
    expect(source, contains('Atributos físicos'));
    expect(source, contains('Atributos mentais'));
    expect(source, contains('Recalcular overall pelos atributos'));
  });

  test('editor de elenco aceita pacote completo ou pacote separado de jogadores', () {
    final source = File('lib/features/career/roster_editor_screen.dart').readAsStringSync();

    expect(source, contains('ClubPackImporter.decodeBytes'));
    expect(source, contains('PlayerPackImporter.decodeBytes'));
    expect(source, contains('tatica-manager-players'));
  });

  test('banco local de nomes originais usa formato v2 sem trocar IDs neutros', () {
    final data = jsonDecode(File('docs/BANCO_TESTE_NOMES_REAIS.json').readAsStringSync()) as Map<String, dynamic>;
    final clubs = data['clubs'] as List<dynamic>;

    expect(data['format'], 'tatica-manager-clubs');
    expect(data['version'], 2);
    expect(clubs, hasLength(20));
    for (var index = 0; index < clubs.length; index++) {
      final club = clubs[index] as Map<String, dynamic>;
      expect(club['id'], 'br-club-${(index + 1).toString().padLeft(3, '0')}');
    }
  });

  test('editor de uniformes possui três kits e padrões', () {
    final source = File('lib/features/career/kit_editor_screen.dart').readAsStringSync();

    expect(source, contains('Uniforme 1'));
    expect(source, contains('Uniforme 2'));
    expect(source, contains('Uniforme 3'));
    expect(source, contains('ClubKitPattern.values'));
    expect(source, contains('ColorPickerField'));
  });
}
