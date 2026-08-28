enum InboxSenderType {
  board,
  agent,
  club,
  medical,
  staff,
  sponsor,
  media,
  system,
}

enum InboxActionType {
  none,
  transferOffer,
  transferNegotiation,
  player,
  club,
  match,
  medical,
  contract,
  managerOffer,
  sponsorship,
}

class InboxMessage {
  const InboxMessage({
    required this.id,
    required this.date,
    required this.senderType,
    required this.sender,
    required this.subject,
    required this.body,
    this.eventId,
    this.playerId,
    this.clubId,
    this.fixtureId,
    this.negotiationId,
    this.sponsorshipProposalId,
    this.actionType = InboxActionType.none,
    this.read = false,
    this.important = false,
    this.archived = false,
    this.deleted = false,
  });

  final String id;
  final DateTime date;
  final InboxSenderType senderType;
  final String sender;
  final String subject;
  final String body;
  final String? eventId;
  final String? playerId;
  final String? clubId;
  final String? fixtureId;
  final String? negotiationId;
  final String? sponsorshipProposalId;
  final InboxActionType actionType;
  final bool read;
  final bool important;
  final bool archived;
  final bool deleted;

  InboxMessage copyWith({
    bool? read,
    bool? important,
    bool? archived,
    bool? deleted,
  }) =>
      InboxMessage(
        id: id,
        date: date,
        senderType: senderType,
        sender: sender,
        subject: subject,
        body: body,
        eventId: eventId,
        playerId: playerId,
        clubId: clubId,
        fixtureId: fixtureId,
        negotiationId: negotiationId,
        sponsorshipProposalId: sponsorshipProposalId,
        actionType: actionType,
        read: read ?? this.read,
        important: important ?? this.important,
        archived: archived ?? this.archived,
        deleted: deleted ?? this.deleted,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'senderType': senderType.name,
        'sender': sender,
        'subject': subject,
        'body': body,
        'eventId': eventId,
        'playerId': playerId,
        'clubId': clubId,
        'fixtureId': fixtureId,
        'negotiationId': negotiationId,
        'sponsorshipProposalId': sponsorshipProposalId,
        'actionType': actionType.name,
        'read': read,
        'important': important,
        'archived': archived,
        'deleted': deleted,
      };

  factory InboxMessage.fromJson(Map<String, dynamic> json) => InboxMessage(
        id: json['id'] as String? ?? '',
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime(2026),
        senderType: InboxSenderType.values.firstWhere(
          (value) => value.name == json['senderType'],
          orElse: () => InboxSenderType.system,
        ),
        sender: json['sender'] as String? ?? 'Tática Manager',
        subject: json['subject'] as String? ?? 'Mensagem',
        body: json['body'] as String? ?? '',
        eventId: json['eventId'] as String?,
        playerId: json['playerId'] as String?,
        clubId: json['clubId'] as String?,
        fixtureId: json['fixtureId'] as String?,
        negotiationId: json['negotiationId'] as String?,
        sponsorshipProposalId: json['sponsorshipProposalId'] as String?,
        actionType: InboxActionType.values.firstWhere(
          (value) => value.name == json['actionType'],
          orElse: () => InboxActionType.none,
        ),
        read: json['read'] as bool? ?? false,
        important: json['important'] as bool? ?? false,
        archived: json['archived'] as bool? ?? false,
        deleted: json['deleted'] as bool? ?? false,
      );
}
