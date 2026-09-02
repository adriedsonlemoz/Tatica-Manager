import '../../domain/season/career_event.dart';
import '../../domain/season/career_state.dart';
import '../../domain/season/inbox_message.dart';

abstract final class InboxEngine {
  static CareerState appendMessages(
    CareerState state,
    List<InboxMessage> messages,
  ) {
    if (messages.isEmpty) return state;
    final existing = state.inbox.map((item) => item.id).toSet();
    final additions = messages
        .where((message) => message.id.isNotEmpty && existing.add(message.id))
        .toList(growable: false);
    if (additions.isEmpty) return state;
    final merged = [...state.inbox, ...additions];
    final trimmed = merged.length <= 120
        ? merged
        : merged.sublist(merged.length - 120);
    return state.copyWith(inbox: trimmed);
  }

  static CareerState appendEvents(
    CareerState state,
    List<CareerEvent> events,
  ) {
    if (events.isEmpty) return state;
    final existing = state.inbox.map((item) => item.id).toSet();
    final additions = <InboxMessage>[];
    for (final event in events) {
      final id = 'inbox-${event.id}';
      if (existing.contains(id)) continue;
      additions.add(_fromEvent(event));
      existing.add(id);
    }
    return appendMessages(state, additions);
  }


  static CareerState markRead(CareerState state, String messageId, bool read) =>
      state.copyWith(
        inbox: state.inbox
            .map((item) => item.id == messageId ? item.copyWith(read: read) : item)
            .toList(growable: false),
      );

  static CareerState toggleImportant(CareerState state, String messageId) =>
      state.copyWith(
        inbox: state.inbox
            .map(
              (item) => item.id == messageId
                  ? item.copyWith(important: !item.important)
                  : item,
            )
            .toList(growable: false),
      );

  static CareerState archive(CareerState state, String messageId, bool archived) =>
      state.copyWith(
        inbox: state.inbox
            .map(
              (item) => item.id == messageId
                  ? item.copyWith(archived: archived, read: true)
                  : item,
            )
            .toList(growable: false),
      );

  static CareerState delete(CareerState state, String messageId) =>
      state.copyWith(
        inbox: state.inbox
            .map(
              (item) => item.id == messageId
                  ? item.copyWith(deleted: true, archived: false, read: true)
                  : item,
            )
            .toList(growable: false),
      );

  static InboxMessage _fromEvent(CareerEvent event) {
    final sender = switch (event.type) {
      CareerEventType.transferOffer => ('Outro clube', InboxSenderType.club),
      CareerEventType.contractExpiring => ('Diretoria', InboxSenderType.board),
      CareerEventType.playerRecovered ||
      CareerEventType.injuryEnded => ('Departamento médico', InboxSenderType.medical),
      CareerEventType.suspensionEnded ||
      CareerEventType.training => ('Comissão técnica', InboxSenderType.staff),
      CareerEventType.nextMatch => ('Comissão técnica', InboxSenderType.staff),
      CareerEventType.matchReport => ('Imprensa esportiva', InboxSenderType.system),
      CareerEventType.managerOffer => ('Diretoria', InboxSenderType.board),
      CareerEventType.seasonStarted => ('Diretoria', InboxSenderType.board),
      CareerEventType.info => ('Central do clube', InboxSenderType.system),
    };
    final action = event.negotiationId != null
        ? InboxActionType.transferNegotiation
        : event.type == CareerEventType.transferOffer
            ? InboxActionType.transferOffer
            : event.type == CareerEventType.contractExpiring
                ? InboxActionType.contract
                : event.type == CareerEventType.nextMatch ||
                        event.type == CareerEventType.matchReport
                    ? InboxActionType.match
                    : event.type == CareerEventType.managerOffer
                        ? InboxActionType.managerOffer
                        : event.playerId != null
                            ? InboxActionType.player
                            : event.clubId != null
                                ? InboxActionType.club
                                : InboxActionType.none;
    return InboxMessage(
      id: 'inbox-${event.id}',
      date: event.date,
      senderType: sender.$2,
      sender: sender.$1,
      subject: event.title,
      body: event.message,
      eventId: event.id,
      playerId: event.playerId,
      clubId: event.clubId,
      fixtureId: event.fixtureId,
      negotiationId: event.negotiationId,
      actionType: action,
      important: event.type == CareerEventType.transferOffer ||
          event.type == CareerEventType.contractExpiring ||
          event.type == CareerEventType.managerOffer,
    );
  }
}
