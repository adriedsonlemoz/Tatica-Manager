import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/core/utils/color_hex.dart';
import 'package:tatica_manager/core/utils/editor_input_formatters.dart';
import 'package:tatica_manager/core/utils/text_file_decoder.dart';
import 'package:tatica_manager/game/club/club_pack_importer.dart';
import 'package:tatica_manager/game/player/player_pack_importer.dart';

void main() {
  test('hex aceita # ou apenas seis dígitos e normaliza em maiúsculas', () {
    expect(ColorHex.format(ColorHex.parse('#1a2b3c')), '1A2B3C');
    expect(ColorHex.format(ColorHex.parse('1a2b3c')), '1A2B3C');
    expect(() => ColorHex.parse('12345'), throwsFormatException);
  });

  test('formatador hexadecimal remove # e caracteres inválidos', () {
    final formatter = HexColorInputFormatter();
    final result = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(
        text: '#a1-b2:c3',
        selection: TextSelection.collapsed(offset: 9),
      ),
    );
    expect(result.text, 'A1B2C3');
  });

  test('salário usa padrão monetário brasileiro durante edição', () {
    expect(formatEditableMoney(1234567), r'R$ 1.234.567');
    expect(parseEditableMoney(r'R$ 1.234.567'), 1234567);
    final formatter = BrazilianMoneyInputFormatter();
    final result = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(
        text: '1234567',
        selection: TextSelection.collapsed(offset: 7),
      ),
    );
    expect(result.text, r'R$ 1.234.567');
  });

  test('decoder preserva UTF-8 com acentos e símbolos especiais', () {
    final source = '<?xml version="1.0" encoding="UTF-8"?><x>São João ~ 10‰</x>';
    expect(TextFileDecoder.decode(Uint8List.fromList(utf8.encode(source))), source);
  });

  test('decoder reconhece Windows-1252 declarado no XML', () {
    final head = ascii.encode('<?xml version="1.0" encoding="windows-1252"?><x>S');
    final tail = ascii.encode('o ~ 10');
    final close = ascii.encode('</x>');
    final bytes = Uint8List.fromList([
      ...head,
      0xE3, // ã
      ...tail,
      0x89, // ‰ no Windows-1252
      ...close,
    ]);
    expect(TextFileDecoder.decode(bytes), contains('São ~ 10‰'));
  });

  test('importador XML de clubes preserva acentos e símbolos', () {
    final source = '''<?xml version="1.0" encoding="UTF-8"?>
<tatica-manager-clubs version="2" name="Teste São ~ ‰" author="QA">
  <clubs>
    <club id="br-club-001">
      <name>União São João</name>
      <nickname>União</nickname>
      <shortName>USJ</shortName>
    </club>
  </clubs>
</tatica-manager-clubs>''';
    final pack = ClubPackImporter.decodeBytes(
      Uint8List.fromList(utf8.encode(source)),
      fileName: 'clubes.xml',
    );
    expect(pack.name, 'Teste São ~ ‰');
    expect(pack.clubs.single.name, 'União São João');
  });

  test('importador XML separado de jogadores preserva caracteres', () {
    final source = '''<?xml version="1.0" encoding="UTF-8"?>
<tatica-manager-players version="1" name="Elenco São ~ ‰">
  <players>
    <player>
      <id>player-xml-1</id>
      <firstName>João</firstName>
      <lastName>Gonçalves</lastName>
      <displayName>João Gonçalves</displayName>
    </player>
  </players>
</tatica-manager-players>''';
    final pack = PlayerPackImporter.decodeBytes(
      Uint8List.fromList(utf8.encode(source)),
      fileName: 'jogadores.xml',
    );
    expect(pack.name, 'Elenco São ~ ‰');
    expect(pack.players.single.displayName, 'João Gonçalves');
  });

  test('editor usa navegação por competição e confirma salvamento em diálogo', () {
    final source = File('lib/features/career/club_editor_screen.dart').readAsStringSync();
    expect(source, contains('CompetitionBreadcrumb'));
    expect(source, contains('CompetitionCatalog.brazil'));
    expect(source, contains('CompetitionBrowserLevel.country'));
    expect(source, contains('CompetitionBrowserLevel.championship'));
    expect(source, contains('CompetitionBrowserLevel.series'));
    expect(source, contains('CompetitionBrowserLevel.clubs'));
    expect(source, contains('_showSaveConfirmation'));
    expect(source, contains("title: const Text('Alterações salvas')"));
  });

  test('seletor de escudo é apresentado em diálogo central', () {
    final source = File('lib/features/career/club_detail_editor_screen.dart').readAsStringSync();
    expect(source, contains("title: const Text('Ícone / escudo')"));
    expect(source, contains("label: const Text('Escolher imagem')"));
    expect(source, contains('showDialog<String>'));
    expect(source, isNot(contains('showModalBottomSheet')));
  });

  test('data de nascimento usa seletor e salário usa formatador monetário', () {
    final source = File('lib/features/career/player_database_editor_screen.dart').readAsStringSync();
    expect(source, contains('showDatePicker'));
    expect(source, contains('BrazilianMoneyInputFormatter'));
    expect(source, contains('parseEditableMoney'));
  });
}
