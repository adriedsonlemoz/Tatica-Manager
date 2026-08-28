import '../../domain/club/club.dart';
import '../../domain/player/player.dart';
import '../../domain/season/career_event.dart';
import 'cpu_manager_engine.dart';

/// Converte negócios concluídos pela CPU em notícias usando o mesmo sistema de
/// CareerEvent já persistido pela carreira.
abstract final class CpuMarketNewsEngine {
  static List<CareerEvent> build({
    required CpuMarketResult result,
    required DateTime date,
    required int season,
    required int round,
  }) {
    if (result.moves.isEmpty) return const [];

    final clubsById = {for (final club in result.clubs) club.id: club};
    final events = <CareerEvent>[];
    for (final move in result.moves) {
      final buyer = clubsById[move.toClubId];
      if (buyer == null) continue;
      final player = _findPlayer(buyer, move.playerId);
      if (player == null) continue;
      final seller = move.fromClubId == null ? null : clubsById[move.fromClubId];

      final highlight = _headline(player, move.type);
      final message = switch (move.type) {
        CpuMarketMoveType.freeAgentSigning =>
          '${buyer.name} acertou a contratação de ${player.displayName}, que estava livre no mercado.',
        CpuMarketMoveType.transfer =>
          '${buyer.name} contratou ${player.displayName} de ${seller?.name ?? 'outro clube'} por ${_money(move.fee)}.',
      };
      events.add(
        CareerEvent(
          id: 'cpu-market-$season-$round-${move.playerId}-${move.toClubId}',
          date: date,
          type: CareerEventType.info,
          title: highlight,
          message: message,
          playerId: move.playerId,
          clubId: move.toClubId,
          amount: move.fee > 0 ? move.fee : null,
        ),
      );
    }
    return events;
  }

  static Player? _findPlayer(Club club, String playerId) {
    for (final player in club.squad) {
      if (player.id == playerId) return player;
    }
    return null;
  }

  static String _headline(Player player, CpuMarketMoveType type) {
    if (player.overall >= 82) return 'Contratação de destaque';
    if (player.age <= 23 && player.potential >= 84) {
      return 'Jovem promessa muda de clube';
    }
    if (type == CpuMarketMoveType.freeAgentSigning) {
      return 'Agente livre assina contrato';
    }
    return 'Transferência concluída';
  }

  static String _money(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return 'R\$ $buffer';
  }
}
