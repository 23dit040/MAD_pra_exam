class Event {
  final String id;
  final String name;
  final DateTime dateTime;
  final int maxCapacity;
  final String organizerId;
  final DateTime createdAt;
  final bool synced;

  Event({
    required this.id,
    required this.name,
    required this.dateTime,
    required this.maxCapacity,
    required this.organizerId,
    required this.createdAt,
    this.synced = false,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'])
          : DateTime.now(),
      maxCapacity: json['maxCapacity'] ?? 0,
      organizerId: json['organizerId'] ?? '',
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
      'dateTime': dateTime.toIso8601String(),
      'maxCapacity': maxCapacity,
      'organizerId': organizerId,
      'createdAt': createdAt.toIso8601String(),
      'synced': synced,
    };
  }

  Event copyWith({
    String? id,
    String? name,
    DateTime? dateTime,
    int? maxCapacity,
    String? organizerId,
    DateTime? createdAt,
    bool? synced,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      dateTime: dateTime ?? this.dateTime,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      organizerId: organizerId ?? this.organizerId,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
    );
  }
}
