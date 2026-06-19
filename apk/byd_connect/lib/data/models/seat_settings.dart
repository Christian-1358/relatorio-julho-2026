class SeatSettings {
  final int driverHeatLevel; // 0-3
  final int driverVentLevel; // 0-3
  final int passengerHeatLevel; // 0-3
  final int passengerVentLevel; // 0-3
  final String seatPosition; // normal, safe, memory
  final int memoryPosition; // 1, 2, 3

  SeatSettings({
    this.driverHeatLevel = 0,
    this.driverVentLevel = 0,
    this.passengerHeatLevel = 0,
    this.passengerVentLevel = 0,
    this.seatPosition = 'normal',
    this.memoryPosition = 1,
  });

  SeatSettings copyWith({
    int? driverHeatLevel,
    int? driverVentLevel,
    int? passengerHeatLevel,
    int? passengerVentLevel,
    String? seatPosition,
    int? memoryPosition,
  }) {
    return SeatSettings(
      driverHeatLevel: driverHeatLevel ?? this.driverHeatLevel,
      driverVentLevel: driverVentLevel ?? this.driverVentLevel,
      passengerHeatLevel: passengerHeatLevel ?? this.passengerHeatLevel,
      passengerVentLevel: passengerVentLevel ?? this.passengerVentLevel,
      seatPosition: seatPosition ?? this.seatPosition,
      memoryPosition: memoryPosition ?? this.memoryPosition,
    );
  }
}
