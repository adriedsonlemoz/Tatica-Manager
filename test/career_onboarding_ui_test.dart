import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tema usa azul-grafite e mantém verde como destaque', () {
    final source = File('lib/core/theme/app_colors.dart').readAsStringSync();

    expect(source, contains('0xFF101820'));
    expect(source, contains('0xFF162229'));
    expect(source, contains('0xFF1C2B32'));
    expect(source, contains('0xFF76D91B'));
    expect(source, contains('0xFFD6B65D'));
  });

  test('primeira abertura exige aceite e mantém termos e privacidade internos', () {
    final bootstrap =
        File('lib/features/bootstrap/bootstrap_screen.dart').readAsStringSync();
    final terms =
        File('lib/features/legal/first_run_terms_gate.dart').readAsStringSync();
    final information =
        File('lib/features/legal/game_information_screen.dart').readAsStringSync();

    expect(bootstrap, contains('AppPreferences.termsAcceptedKey'));
    expect(bootstrap, contains('FirstRunTermsGate'));
    expect(terms, contains('Aceitar e continuar'));
    expect(terms, contains('GameInformationPage.terms'));
    expect(terms, contains('GameInformationPage.privacy'));
    expect(information, contains("title: 'Termos de Uso'"));
    expect(information, contains("title: 'Privacidade'"));
    expect(information, contains("title: 'Sobre o jogo'"));
    expect(information, contains("title: 'Como funciona'"));
  });

  test('hub inicial expõe links discretos para informações e opções', () {
    final hub = File('lib/features/career/career_hub_screen.dart')
        .readAsStringSync();
    final links = File('lib/features/career/career_hub_info_links.dart')
        .readAsStringSync();

    expect(hub, contains('CareerHubInfoLinks('));
    for (final label in [
      'Sobre o jogo',
      'Como funciona',
      'Termos de Uso',
      'Privacidade',
      'Editar dados do jogo',
      'Configurações',
    ]) {
      expect(links, contains(label));
    }
  });

  test('nova carreira marca apresentação e bootstrap a consome uma vez', () {
    final controller =
        File('lib/app/state/career_controller.dart').readAsStringSync();
    final bootstrap =
        File('lib/features/bootstrap/bootstrap_screen.dart').readAsStringSync();
    final arrival =
        File('lib/features/career/career_arrival_screen.dart').readAsStringSync();

    expect(controller, contains('AppPreferences.careerIntroPendingKey(careerId)'));
    expect(controller, contains("'true'"));
    expect(bootstrap, contains('careerIntroPendingKey(widget.career.careerId)'));
    expect(bootstrap, contains('CareerArrivalScreen('));
    expect(bootstrap, contains('saveAppValue('));
    expect(arrival, contains('ManagerAvatar('));
    expect(arrival, contains('ClubBadge('));
    expect(arrival, contains('CompetitionCatalog.primarySeriesForClub'));
    expect(arrival, contains('APRESENTAÇÃO OFICIAL'));
    expect(arrival, contains(r'EDIÇÃO\nESPECIAL'));
    expect(arrival, contains('NOVO DESAFIO'));
    expect(arrival, contains('Começar carreira'));
    expect(arrival, contains('A partir daqui, a temporada começa oficialmente.'));
    expect(arrival, isNot(contains('Icons.menu_rounded')));
  });

  test('duração nova usa 1 2 e 3 minutos por tempo sem mover regra para Flame', () {
    final preset = File('lib/domain/settings/match_presentation_settings.dart')
        .readAsStringSync();
    final match =
        File('lib/features/match/match_screen.dart').readAsStringSync();
    final flow =
        File('lib/features/career/new_career_flow_screen.dart').readAsStringSync();

    expect(preset, contains("quick(1, 'Rápida', '1 min/tempo')"));
    expect(preset, contains("normal(2, 'Normal', '2 min/tempo')"));
    expect(preset, contains("complete(3, 'Completa', '3 min/tempo')"));
    expect(match, contains('minutesPerHalf * 2'));
    expect(flow, contains('matchDuration: _matchDuration'));
    expect(flow, contains('onMatchDuration:'));
  });
}
