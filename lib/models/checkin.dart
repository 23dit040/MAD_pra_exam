class CheckIn {
  final String id;
  final String participantId;
  final String eventId;
  final DateTime checkedInAt;
  final String status; // 'success', 'duplicate', 'failed'
  final String? errorMessage;
  final bool synced;
  final DateTime createdAt;

  CheckIn({
    required this.id,
    required this.participantId,
    required this.eventId,
    required this.checkedInAt,
    required this.status,
    this.errorMessage,
    this.synced = false,
    required this.createdAt,
  });

  factory CheckIn.fromJson(Map<String, dynamic> json) {
    return CheckIn(
      id: json['_id'] ?? json['id'] ?? '',
      participantId: json['participantId'] ?? '',
      eventId: json['eventId'] ?? '',
      checkedInAt: json['checkedInAt'] != null
          ? DateTime.parse(json['checkedInAt'])
          : DateTime.now(),
      status: json['status'] ?? 'success',
      errorMessage: json['errorMessage'],
      synced: json['synced'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantId': participantId,
      'eventId': eventId,
      'checkedInAt': checkedInAt.toIso8601String(),
      'status': status,
      'errorMessage': errorMessage,
      'synced': synced,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  CheckIn copyWith({
    String? id,
    String? participantId,
    String? eventId,
    DateTime? checkedInAt,
    String? status,
    String? errorMessage,
    bool? synced,
    DateTime? createdAt,
  }) {
    return CheckIn(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      eventId: eventId ?? this.eventId,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      synced: synced ?? this.synced,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
