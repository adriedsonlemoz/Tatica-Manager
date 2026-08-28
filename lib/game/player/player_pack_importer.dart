import 'dart:convert';
import 'dart:typed_data';

import 'package:xml/xml.dart';

import '../../core/utils/text_file_decoder.dart';
import '../../domain/player/player_data_pack.dart';

abstract final class PlayerPackImporter {
  static PlayerDataPack decodeBytes(Uint8List bytes, {String? fileName}) {
    final source = TextFileDecoder.decode(bytes).trim();
    final extension = fileName?.split('.').last.toLowerCase();
    if (extension == 'xml' || source.startsWith('<')) {
      return PlayerDataPack.fromJson(_xmlToPack(source));
    }
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException('O arquivo precisa conter um objeto JSON.');
    }
    return PlayerDataPack.fromJson(Map<String, dynamic>.from(decoded));
  }

  static Map<String, dynamic> _xmlToPack(String source) {
    XmlDocument document;
    try {
      document = XmlDocument.parse(source);
    } catch (error) {
      throw FormatException('XML inválido: $error');
    }
    final root = document.rootElement;
    if (root.name.local != 'tatica-manager-players' &&
        root.name.local != 'taticaManagerPlayers') {
      throw const FormatException(
        'O XML precisa usar a raiz <tatica-manager-players>.',
      );
    }

    final version = int.tryParse(
          (root.getAttribute('version') ?? root.getElement('version')?.innerText ?? '')
              .trim(),
        ) ??
        PlayerDataPack.formatVersion;
    final name = (root.getAttribute('name') ??
            root.getElement('name')?.innerText ??
            'Pacote XML de jogadores')
        .trim();
    final author = (root.getAttribute('author') ??
            root.getElement('author')?.innerText)
        ?.trim();
    final playersContainer = root.getElement('players');
    final playerElements =
        playersContainer?.findElements('player') ?? root.findElements('player');

    return <String, dynamic>{
      'format': PlayerDataPack.format,
      'version': version,
      'name': name.isEmpty ? 'Pacote XML de jogadores' : name,
      if (author?.isNotEmpty == true) 'author': author,
      'players': playerElements.map(_elementMap).toList(growable: false),
    };
  }

  static Map<String, dynamic> _elementMap(XmlElement element) {
    final result = <String, dynamic>{};
    for (final attribute in element.attributes) {
      result[attribute.name.local] = _scalar(attribute.value);
    }
    final groups = <String, List<XmlElement>>{};
    for (final child in element.childElements) {
      groups.putIfAbsent(child.name.local, () => <XmlElement>[]).add(child);
    }
    for (final entry in groups.entries) {
      final elements = entry.value;
      if (elements.length > 1) {
        result[entry.key] = elements.map(_valueOf).toList(growable: false);
      } else {
        result[entry.key] = _valueOf(elements.single);
      }
    }
    return result;
  }

  static dynamic _valueOf(XmlElement element) {
    if (element.childElements.isEmpty && element.attributes.isEmpty) {
      return _scalar(element.innerText.trim());
    }
    return _elementMap(element);
  }

  static dynamic _scalar(String source) {
    final value = source.trim();
    if (value == 'true') return true;
    if (value == 'false') return false;
    if (value == 'null') return null;
    final integer = int.tryParse(value);
    if (integer != null) return integer;
    final decimal = double.tryParse(value.replaceAll(',', '.'));
    if (decimal != null) return decimal;
    return value;
  }
}
