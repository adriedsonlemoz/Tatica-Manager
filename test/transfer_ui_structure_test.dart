import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mercado centraliza propostas sem concluir acordos nas telas antigas', () {
    final profile =
        File('lib/features/player/player_profile_screen.dart').readAsStringSync();
    final playerDialogs =
        File('lib/features/player/player_market_dialogs.dart').readAsStringSync();
    final incomingOfferDialog = File(
      'lib/features/market/incoming_transfer_offer_dialog.dart',
    ).readAsStringSync();
    final negotiation =
        File('lib/features/negotiation/negotiation_screen.dart').readAsStringSync();

    expect(profile, isNot(contains('showModalBottomSheet')));
    expect(profile, isNot(contains('ScaffoldMessenger.of')));
    expect(playerDialogs, contains('showDialog<void>'));
    expect(playerDialogs, contains('showDialog<bool>'));
    expect(playerDialogs, contains('maxWidth: 440'));
    expect(incomingOfferDialog, contains('showIncomingTransferOfferDialog'));
    expect(incomingOfferDialog, contains('acceptIncomingOffer'));
    expect(incomingOfferDialog, contains('rejectIncomingOffer'));
    expect(incomingOfferDialog, contains('counterIncomingOffer'));
    expect(incomingOfferDialog, contains('maxWidth: 440'));
    final home = File('lib/features/home/home_screen.dart').readAsStringSync();
    final market = File('lib/features/market/market_screen.dart').readAsStringSync();
    final marketComponents = File(
      'lib/features/market/market_components.dart',
    ).readAsStringSync();
    expect(home, contains('initialSection: MarketSection.negotiations'));
    expect(market, contains("Tab(text: 'Mercado')"));
    expect(market, contains("Tab(text: 'Observados')"));
    expect(market, contains("Tab(text: 'Negociações')"));
    expect(marketComponents, contains('TransferNegotiationStatus.received'));
    expect(marketComponents, contains('completeMarketNegotiation'));
    expect(marketComponents, contains('TransferNegotiationKind.loan'));
    expect(incomingOfferDialog, contains("Text('Contrapropor')"));
    expect(negotiation, contains('showDialog<bool>'));
    expect(negotiation, contains('maxWidth: 460'));
  });
}
