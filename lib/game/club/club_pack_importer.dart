import 'dart:typed_data';

import 'package:xml/xml.dart';

import '../../core/utils/text_file_decoder.dart';
import '../../domain/club/club_identity.dart';

abstract final class ClubPackImporter {
  static ClubIdentityPack decodeBytes(Uint8List bytes, {String? fileName}) {
    final source = TextFileDecoder.decode(bytes).trim();
    final extension = fileName?.split('.').last.toLowerCase();
    if (extension == 'xml' || source.startsWith('<')) {
      return ClubIdentityPack.fromJson(_xmlToPack(source));
    }
    return ClubIdentityPack.decode(source);
  }

  static Map<String, dynamic> _xmlToPack(String source) {
    XmlDocument document;
    try {
      document = XmlDocument.parse(source);
    } catch (error) {
      throw FormatException('XML inválido: $error');
    }
    final root = document.rootElement;
    if (root.name.local != 'tatica-manager-clubs' && root.name.local != 'taticaManagerClubs') {
      throw const FormatException('O XML precisa usar a raiz <tatica-manager-clubs>.');
    }
    final map = <String, dynamic>{
      'format': ClubIdentityPack.format,
      'version': _intValue(root.getAttribute('version') ?? _childText(root, 'version')) ?? 2,
      'name': root.getAttribute('name') ?? _childText(root, 'name') ?? 'Pacote XML',
      if ((root.getAttribute('author') ?? _childText(root, 'author'))?.trim().isNotEmpty == true)
        'author': (root.getAttribute('author') ?? _childText(root, 'author'))!.trim(),
      'clubs': <dynamic>[],
    };

    final clubsContainer = root.getElement('clubs');
    final clubElements = clubsContainer?.findElements('club') ?? root.findElements('club');
    map['clubs'] = clubElements.map(_clubMap).toList(growable: false);

    final freeAgents = root.getElement('freeAgents');
    if (freeAgents != null) {
      map['freeAgents'] = freeAgents.findElements('player').map(_elementMap).toList(growable: false);
    }
    final managers = root.getElement('managers') ?? root.getElement('coaches');
    if (managers != null) {
      map['managers'] = [
        ...managers.findElements('manager'),
        ...managers.findElements('coach'),
      ].map(_elementMap).toList(growable: false);
    }
    return map;
  }

  static Map<String, dynamic> _clubMap(XmlElement club) {
    final map = _elementMap(club);
    map['id'] ??= club.getAttribute('id');
    return map;
  }

  static Map<String, dynamic> _elementMap(XmlElement element) {
    final result = <String, dynamic>{};
    for (final attribute in element.attributes) {
      result[attribute.name.local] = _scalar(attribute.value);
    }
    final children = element.childElements.toList(growable: false);
    if (children.isEmpty) return result;
    final groups = <String, List<XmlElement>>{};
    for (final child in children) {
      groups.putIfAbsent(child.name.local, () => <XmlElement>[]).add(child);
    }
    for (final entry in groups.entries) {
      final name = entry.key;
      final elements = entry.value;
      if ((name == 'players' || name == 'freeAgents') && elements.length == 1) {
        result[name] = elements.single.findElements('player').map(_elementMap).toList(growable: false);
        continue;
      }
      if (elements.length > 1) {
        result[name] = elements.map(_valueOf).toList(growable: false);
      } else {
        result[name] = _valueOf(elements.single);
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

  static int? _intValue(String? value) => value == null ? null : int.tryParse(value.trim());

  static String? _childText(XmlElement element, String name) => element.getElement(name)?.innerText;
}
