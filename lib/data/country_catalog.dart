class CountryOption {
  const CountryOption({
    required this.code,
    required this.name,
    required this.flag,
  });

  final String code;
  final String name;
  final String flag;

  String get label => '$flag $name';
}

abstract final class CountryCatalog {
  static const List<CountryOption> all = [
    CountryOption(code: 'BR', name: 'Brasil', flag: '🇧🇷'),
    CountryOption(code: 'AR', name: 'Argentina', flag: '🇦🇷'),
    CountryOption(code: 'UY', name: 'Uruguai', flag: '🇺🇾'),
    CountryOption(code: 'PY', name: 'Paraguai', flag: '🇵🇾'),
    CountryOption(code: 'CL', name: 'Chile', flag: '🇨🇱'),
    CountryOption(code: 'BO', name: 'Bolívia', flag: '🇧🇴'),
    CountryOption(code: 'PE', name: 'Peru', flag: '🇵🇪'),
    CountryOption(code: 'CO', name: 'Colômbia', flag: '🇨🇴'),
    CountryOption(code: 'EC', name: 'Equador', flag: '🇪🇨'),
    CountryOption(code: 'VE', name: 'Venezuela', flag: '🇻🇪'),
    CountryOption(code: 'MX', name: 'México', flag: '🇲🇽'),
    CountryOption(code: 'US', name: 'Estados Unidos', flag: '🇺🇸'),
    CountryOption(code: 'PT', name: 'Portugal', flag: '🇵🇹'),
    CountryOption(code: 'ES', name: 'Espanha', flag: '🇪🇸'),
    CountryOption(code: 'IT', name: 'Itália', flag: '🇮🇹'),
    CountryOption(code: 'FR', name: 'França', flag: '🇫🇷'),
    CountryOption(code: 'DE', name: 'Alemanha', flag: '🇩🇪'),
    CountryOption(code: 'NL', name: 'Holanda', flag: '🇳🇱'),
    CountryOption(code: 'GB', name: 'Inglaterra', flag: '🇬🇧'),
  ];

  static CountryOption? byName(String value) {
    final normalized = value.trim().toLowerCase();
    for (final item in all) {
      if (item.name.toLowerCase() == normalized) return item;
    }
    return null;
  }

  static String flagOf(String value) => byName(value)?.flag ?? '🌍';

  static String labelOf(String value) => byName(value)?.label ?? '🌍 $value';
}
