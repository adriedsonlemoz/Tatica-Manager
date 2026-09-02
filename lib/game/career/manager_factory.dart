import '../../domain/career/manager_profile.dart';
import '../../domain/formation/formation.dart';
import '../../domain/tactic/tactic.dart';

/// Cria perfis fictícios, porém verossímeis e estáveis, para o banco padrão.
/// O mesmo clube sempre recebe o mesmo técnico, sem usar nomes de pessoas reais.
abstract final class ManagerFactory {
  static const _names = <String>[
    'Rafael Moreira',
    'Eduardo Nogueira',
    'Caio Menezes',
    'Gabriel Siqueira',
    'Paulo Varela',
    'Marcos Tavares',
    'Vinícius Falcão',
    'André Pimentel',
    'Diego Valente',
    'Luís Barreto',
    'Fábio Azevedo',
    'Renato Mota',
    'Bruno Queiroz',
    'Leandro Sampaio',
    'Thiago Paes',
    'Rodrigo Faria',
    'Carlos Dantas',
    'Márcio Gouveia',
    'Daniel Vilela',
    'Gustavo Lacerda',
  ];

  static const _birthplaces = <(String city, String state)>[
    ('São Paulo', 'SP'),
    ('Rio de Janeiro', 'RJ'),
    ('Belo Horizonte', 'MG'),
    ('Porto Alegre', 'RS'),
    ('Curitiba', 'PR'),
    ('Recife', 'PE'),
    ('Salvador', 'BA'),
    ('Fortaleza', 'CE'),
    ('Goiânia', 'GO'),
    ('Campinas', 'SP'),
    ('Florianópolis', 'SC'),
    ('Natal', 'RN'),
  ];

  static const _styles = <String>[
    'Equilibrado',
    'Ofensivo',
    'Posse',
    'Transição',
    'Defensivo',
  ];

  static const _formations = <FormationType>[
    FormationType.f433,
    FormationType.f442,
    FormationType.f4231,
    FormationType.f352,
    FormationType.f451,
  ];

  static const _mentalities = <Mentality>[
    Mentality.balanced,
    Mentality.attacking,
    Mentality.defensive,
  ];

  static ManagerProfile forClub({
    required String clubId,
    required int clubReputation,
    required int season,
  }) {
    final index = _stableIndex(clubId);
    final birthplace = _birthplaces[index % _birthplaces.length];
    final age = 36 + (index % 22);
    return ManagerProfile(
      id: 'manager-$clubId',
      displayName: _names[index % _names.length],
      nationality: 'Brasil',
      ageAtStart: age,
      careerStartSeason: season,
      birthCity: birthplace.$1,
      birthState: birthplace.$2,
      birthCountry: 'Brasil',
      birthPlace: '${birthplace.$1}, ${birthplace.$2}, Brasil',
      currentClubId: clubId,
      contractUntilSeason: season + 1 + (index % 3),
      reputation: (clubReputation + 5).clamp(35, 95).toInt(),
      overall: clubReputation.clamp(45, 90).toInt(),
      experienceYears: 7 + (index % 18),
      style: _styles[index % _styles.length],
      preferredFormation: _formations[index % _formations.length],
      preferredMentality: _mentalities[index % _mentalities.length],
    );
  }

  static bool isLegacyPlaceholder(ManagerProfile manager) =>
      manager.displayName.trim() == 'Técnico CPU';

  static int _stableIndex(String source) {
    final numericSuffix = RegExp(r'(\d+)$').firstMatch(source)?.group(1);
    if (numericSuffix != null) {
      return int.parse(numericSuffix) - 1;
    }
    var hash = 17;
    for (final code in source.codeUnits) {
      hash = (hash * 31 + code) & 0x7fffffff;
    }
    return hash;
  }
}
