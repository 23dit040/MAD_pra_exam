class Participant {
  final String id;
  final String name;
  final String ticketId;
  final String eventId;
  final DateTime createdAt;
  final bool synced;

  Participant({
    required this.id,
    required this.name,
    required this.ticketId,
    required this.eventId,
    required this.createdAt,
    this.synced = false,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      ticketId: json['ticketId'] ?? '',
      eventId: json['eventId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      synced: json['synced'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ticketId': ticketId,
      'eventId': eventId,
      'createdAt': createdAt.toIso8601String(),
      'synced': synced,
    };
  }

  Participant copyWith({
    String? id,
    String? name,
    String? ticketId,
    String? eventId,
    DateTime? createdAt,
    bool? synced,
  }) {
    return Participant(
      id: id ?? this.id,
      name: name ?? this.name,
      ticketId: ticketId ?? this.ticketId,
      eventId: eventId ?? this.eventId,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
    );
  }
}
