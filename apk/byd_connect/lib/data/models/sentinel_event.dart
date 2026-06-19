class SentinelEvent {
  final String id;
  final String type; // motion, alarm, door, etc
  final String description;
  final DateTime timestamp;
  final String thumbnailUrl;
  final String videoUrl;
  bool isRead;

  SentinelEvent({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    this.thumbnailUrl = '',
    this.videoUrl = '',
    this.isRead = false,
  });
}

class SentinelMode {
  final String mode; // armed, disarmed, auto
  final bool isActive;

  SentinelMode({
    this.mode = 'disarmed',
    this.isActive = false,
  });

  SentinelMode copyWith({
    String? mode,
    bool? isActive,
  }) {
    return SentinelMode(
      mode: mode ?? this.mode,
      isActive: isActive ?? this.isActive,
    );
  }
}
