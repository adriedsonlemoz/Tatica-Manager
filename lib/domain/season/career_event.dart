enum CareerEventType {
  playerRecovered,
  injuryEnded,
  suspensionEnded,
  contractExpiring,
  transferOffer,
  managerOffer,
  nextMatch,
  matchReport,
  training,
  seasonStarted,
  info,
}

class CareerEvent {
  const CareerEvent({
    required this.id,
    required this.date,
    required this.type,
    required this.title,
    required this.message,
    this.playerId,
    this.clubId,
    this.fixtureId,
    this.negotiationId,
    this.amount,
    this.read = false,
  });

  final String id;
  final DateTime date;
  final CareerEventType type;
  final String title;
  final String message;
  final String? playerId;
  final String? clubId;
  final String? fixtureId;
  final String? negotiationId;
  final int? amount;
  final bool read;

  CareerEvent copyWith({bool? read}) => CareerEvent(
        id: id,
        date: date,
        type: type,
        title: title,
        message: message,
        playerId: playerId,
        clubId: clubId,
        fixtureId: fixtureId,
        negotiationId: negotiationId,
        amount: amount,
        read: read ?? this.read,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'type': type.name,
        'title': title,
        'message': message,
        'playerId': playerId,
        'clubId': clubId,
        'fixtureId': fixtureId,
        'negotiationId': negotiationId,
        'amount': amount,
        'read': read,
      };

  factory CareerEvent.fromJson(Map<String, dynamic> json) => CareerEvent(
        id: json['id'] as String? ?? '',
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime(2026),
        type: CareerEventType.values.firstWhere(
          (value) => value.name == json['type'],
          orElse: () => CareerEventType.info,
        ),
        title: json['title'] as String? ?? 'Notícia',
        message: json['message'] as String? ?? '',
        playerId: json['playerId'] as String?,
        clubId: json['clubId'] as String?,
        fixtureId: json['fixtureId'] as String?,
        negotiationId: json['negotiationId'] as String?,
        amount: json['amount'] as int?,
        // Notícias de saves anteriores à introdução deste campo não devem
        // reaparecer em massa como pendências.
        read: json.containsKey('read') ? json['read'] == true : true,
      );
}
