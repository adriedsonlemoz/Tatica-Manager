import 'package:flutter_test/flutter_test.dart';
import 'package:tatica_manager/data/club_seed.dart';
import 'package:tatica_manager/domain/club/club.dart';
import 'package:tatica_manager/game/match/renderer/match_kit_resolver.dart';

void main() {
  test('uniformes visualmente iguais são tratados como conflito', () {
    final first = _kit(0xFF202020, 0xFFF5F5F5);
    final second = _kit(0xFF202020, 0xFFF5F5F5);

    expect(MatchKitResolver.kitsConflict(first, second), isTrue);
    expect(MatchKitResolver.contrastScore(first, second), lessThan(38));
  });

  test('resolver preserva escolha do usuário e troca o uniforme rival', () {
    final home = _club(
      id: 'home',
      home: _kit(0xFFCC2028, 0xFF202020),
      away: _kit(0xFFF4F4F4, 0xFFCC2028),
      third: _kit(0xFF151515, 0xFFF4F4F4),
    );
    final away = _club(
      id: 'away',
      home: _kit(0xFFC92028, 0xFFFFFFFF),
      away: _kit(0xFFF2F2F2, 0xFF202020),
      third: _kit(0xFF2465C7, 0xFFFFFFFF),
    );

    final selection = MatchKitResolver.resolve(
      home: home,
      away: away,
      userClubId: home.id,
      userSlot: MatchKitSlot.primary,
    );

    expect(selection.homeKit.primaryHex, home.homeKit.primaryHex);
    expect(selection.awaySlot, MatchKitSlot.third);
    expect(selection.awayKit.primaryHex, away.thirdKit.primaryHex);
    expect(selection.contrastScore, greaterThanOrEqualTo(38));
    expect(selection.safetyFallbackUsed, isFalse);
  });

  test('fallback visual garante contraste quando todos os kits conflitam', () {
    final repeated = _kit(0xFFEEEEEE, 0xFFFFFFFF);
    final home = _club(
      id: 'home',
      home: repeated,
      away: repeated,
      third: repeated,
    );
    final away = _club(
      id: 'away',
      home: repeated,
      away: repeated,
      third: repeated,
    );

    final selection = MatchKitResolver.resolve(
      home: home,
      away: away,
      userClubId: home.id,
      userSlot: MatchKitSlot.primary,
    );

    expect(selection.safetyFallbackUsed, isTrue);
    expect(selection.adjustedClubId, away.id);
    expect(
      MatchKitResolver.kitsConflict(selection.homeKit, selection.awayKit),
      isFalse,
    );
  });

  test('goleiros contrastam com os dois times e entre si', () {
    final home = _club(
      id: 'home',
      home: _kit(0xFFB5222A, 0xFF222222),
      away: _kit(0xFFFFFFFF, 0xFFB5222A),
      third: _kit(0xFF202020, 0xFFFFFFFF),
    );
    final away = _club(
      id: 'away',
      home: _kit(0xFF1F5FBF, 0xFFFFFFFF),
      away: _kit(0xFFFFFFFF, 0xFF1F5FBF),
      third: _kit(0xFFF0CD38, 0xFF202020),
    );

    final selection = MatchKitResolver.resolve(
      home: home,
      away: away,
      userClubId: away.id,
      userSlot: MatchKitSlot.third,
    );

    expect(selection.awayKit.primaryHex, away.thirdKit.primaryHex);
    expect(
      MatchKitResolver.contrastScore(
        selection.homeGoalkeeperKit,
        selection.homeKit,
      ),
      greaterThan(25),
    );
    expect(
      MatchKitResolver.contrastScore(
        selection.awayGoalkeeperKit,
        selection.awayKit,
      ),
      greaterThan(25),
    );
    expect(
      MatchKitResolver.contrastScore(
        selection.homeGoalkeeperKit,
        selection.awayGoalkeeperKit,
      ),
      greaterThan(25),
    );
  });

  test('todos os confrontos atuais terminam com uniformes distintos', () {
    final clubs = clubSeeds2026.map((seed) => seed.toClub()).toList();

    for (final userClub in clubs) {
      for (final opponent in clubs) {
        if (userClub.id == opponent.id) continue;
        for (final userSlot in MatchKitSlot.values) {
          final selection = MatchKitResolver.resolve(
            home: userClub,
            away: opponent,
            userClubId: userClub.id,
            userSlot: userSlot,
          );

          expect(
            MatchKitResolver.kitsConflict(
              selection.homeKit,
              selection.awayKit,
            ),
            isFalse,
            reason: '${userClub.shortName} ${userSlot.name} x '
                '${opponent.shortName} deve usar cores distintas.',
          );
        }
      }
    }
  });
}

ClubKit _kit(int primary, int secondary) => ClubKit(
      primaryHex: primary,
      secondaryHex: secondary,
      accentHex: secondary,
      shortsHex: primary,
      socksHex: secondary,
    );

Club _club({
  required String id,
  required ClubKit home,
  required ClubKit away,
  required ClubKit third,
}) =>
    Club(
      id: id,
      name: id,
      shortName: id.toUpperCase(),
      nickname: id,
      colors: ClubColors(
        primaryHex: home.primaryHex,
        secondaryHex: home.secondaryHex,
      ),
      homeKit: home,
      awayKit: away,
      thirdKit: third,
      reputation: 70,
      money: 1000000,
      transferBudget: 500000,
      stadium: const Stadium(
        name: 'Estádio',
        capacity: 20000,
        ticketPrice: 50,
      ),
      managerName: 'Técnico',
      fanBase: .5,
      squad: const [],
    );
