import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/domain/career/manager_profile.dart';
import 'package:tatica_manager/domain/club/club_identity.dart';
import 'package:tatica_manager/domain/formation/formation.dart';
import 'package:tatica_manager/domain/season/career_state.dart';
import 'package:tatica_manager/domain/tactic/tactic.dart';
import 'package:tatica_manager/game/club/club_identity_engine.dart';

void main() {
  test('perfil completo do técnico mantém dados profissionais no JSON', () {
    final original = ManagerProfile.normalized(
      id: 'manager-test',
      displayName: 'Técnico Teste',
      nationality: 'Brasil',
      ageAtStart: 44,
      careerStartSeason: 2026,
      birthDate: DateTime(1982, 5, 10),
      currentClubId: 'br-club-001',
      contractUntilSeason: 2028,
      reputation: 78,
      style: 'Posse',
      preferredFormation: FormationType.f4231,
      preferredMentality: Mentality.attacking,
      experienceYears: 14,
      overall: 76,
      userCreated: true,
    );

    final restored = ManagerProfile.fromJson(original.toJson());
    expect(restored.id, 'manager-test');
    expect(restored.birthDate, DateTime(1982, 5, 10));
    expect(restored.currentClubId, 'br-club-001');
    expect(restored.contractUntilSeason, 2028);
    expect(restored.reputation, 78);
    expect(restored.style, 'Posse');
    expect(restored.preferredFormation, FormationType.f4231);
    expect(restored.preferredMentality, Mentality.attacking);
    expect(restored.experienceYears, 14);
    expect(restored.overall, 76);
    expect(restored.userCreated, isTrue);
  });

  test('pacote único do editor exporta e reimporta técnicos sem formato paralelo', () {
    final base = ClubIdentityEngine.defaultPack();
    final encoded = base.encode();
    final restored = ClubIdentityPack.decode(encoded);

    expect(ClubIdentityPack.formatVersion, 3);
    expect(restored.managers, isNotNull);
    expect(restored.managers, hasLength(base.clubs.length));
    expect(restored.managers!.map((m) => m.id).toSet().length,
        restored.managers!.length);
  });

  test('pacote completo também aceita coaches como alias de managers', () {
    final base = ClubIdentityEngine.defaultPack();
    final json = base.toJson();
    json['coaches'] = json.remove('managers');
    final restored = ClubIdentityPack.fromJson(json);

    expect(restored.managers, isNotNull);
    expect(restored.managers, hasLength(base.managers!.length));
    expect(restored.managers!.first.id, base.managers!.first.id);
  });

  test('schema de carreira inclui banco de técnicos e migração legada', () {
    final source = File('lib/domain/season/career_state.dart').readAsStringSync();
    expect(CareerState.currentSchemaVersion, 11);
    expect(source, contains("'managers': managers.map"));
    expect(source, contains('_legacyManagerDatabase('));
    expect(source, contains("'manager-\${club.id}'"));
  });

  test('Central de Edição oferece técnicos, importação, exportação e restauração', () {
    final central = File('lib/features/career/club_editor_screen.dart').readAsStringSync();
    final editor = File('lib/features/career/manager_database_editor_screen.dart')
        .readAsStringSync();
    expect(central, contains("title: const Text('Técnicos'"));
    expect(editor, contains('Criar técnico'));
    expect(editor, contains('Importar'));
    expect(editor, contains('Exportar selecionados'));
    expect(editor, contains('Restaurar técnicos originais'));
    expect(editor, contains('Aparência / foto'));
    expect(editor, contains('Data de nascimento'));
    expect(editor, contains('Contrato até a temporada'));
    expect(editor, contains('exportTextFile'));
    expect(editor, contains('tatica-manager-tecnicos.json'));

    final appearance = File('lib/features/career/manager_appearance_editor.dart')
        .readAsStringSync();
    final photoStore = File('lib/core/media/player_photo_store.dart')
        .readAsStringSync();
    expect(appearance, contains("title: 'TRAÇOS DO ROSTO'"));
    expect(appearance, contains("label: 'Olhos'"));
    expect(appearance, contains("label: 'Sobrancelhas'"));
    expect(appearance, contains("label: 'Horizontal'"));
    expect(appearance, contains('cropZoom'));
    expect(photoStore, contains('cropAlignmentX'));
    expect(photoStore, contains('cropAlignmentY'));
    expect(photoStore, contains('cropZoom'));
  });

  test('Finanças usa resumo, gráficos e seções expansíveis', () {
    final source = [
      File('lib/features/finances/finances_screen.dart').readAsStringSync(),
      File('lib/features/finances/finances_dashboard_components.dart').readAsStringSync(),
    ].join('\n');
    expect(source, contains('_FinanceHero('));
    expect(source, contains('Receitas x despesas'));
    expect(source, contains('EVOLUÇÃO DO SALDO'));
    expect(source, contains('ExpansionTile('));
    expect(source, contains("title: 'Patrocínios'"));
    expect(source, contains("title: 'Estádio'"));
    expect(source, contains("title: 'Histórico'"));
  });
}
