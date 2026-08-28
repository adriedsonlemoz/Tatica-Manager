import 'dart:convert';

import 'package:flutter/services.dart';

class BrazilStateLocations {
  const BrazilStateLocations({
    required this.code,
    required this.name,
    required this.cities,
  });

  final String code;
  final String name;
  final List<String> cities;
}

class BrazilLocationCatalog {
  const BrazilLocationCatalog({required this.states});

  final List<BrazilStateLocations> states;

  static Future<BrazilLocationCatalog> load() async {
    final source = await rootBundle.loadString('assets/data/brazil_locations.json');
    final decoded = jsonDecode(source) as Map<String, dynamic>;
    final countries = decoded['countries'] as List? ?? const [];
    final brazil = countries
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .firstWhere(
          (item) => item['code'] == 'BR',
          orElse: () => const <String, dynamic>{},
        );
    final states = (brazil['states'] as List? ?? const [])
        .whereType<Map>()
        .map((item) {
          final map = Map<String, dynamic>.from(item);
          return BrazilStateLocations(
            code: map['code'] as String? ?? '',
            name: map['name'] as String? ?? '',
            cities: (map['cities'] as List? ?? const [])
                .map((city) => city.toString())
                .where((city) => city.isNotEmpty)
                .toList(growable: false),
          );
        })
        .where((state) => state.code.isNotEmpty && state.name.isNotEmpty)
        .toList(growable: false);
    return BrazilLocationCatalog(states: states);
  }

  BrazilStateLocations? stateByCode(String? code) {
    if (code == null || code.isEmpty) return null;
    for (final state in states) {
      if (state.code == code) return state;
    }
    return null;
  }
}
