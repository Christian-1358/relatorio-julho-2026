class CarStatus {
  final bool isOnline;
  final int batteryLevel;
  final String gear; // P, D, N, R
  final bool isLocked;
  final double speed; // km/h
  final int range; // km
  final double temperature; // Celsius
  final double tirePressureFL;
  final double tirePressureFR;
  final double tirePressureRL;
  final double tirePressureRR;
  final double voltage12V;
  final int odometer; // km
  final bool acIsOn;
  final bool trunkIsOpen;
  final int trunkPosition; // 0=closed, 30, 60, 100=fully open
  final String windowsState; // closed, half, open
  final bool lightsAreOn;
  // Novos comandos
  final bool engineRunning; // Partida Remota / Start/Stop
  final bool mirrorsFolded; // Espelhos dobrados
  final bool findMyCarActive; // Localizar carro
  final bool batteryHeaterOn; // Aquecedor da bateria
  // Info do carro
  final String carModel;
  final String carPlate;
  final String ownerName;
  // Cintos
  final bool driverSeatbeltFastened;
  final bool passengerSeatbeltFastened;
  final bool rearLeftSeatbeltFastened;
  final bool rearRightSeatbeltFastened;

  CarStatus({
    this.isOnline = true,
    this.batteryLevel = 78,
    this.gear = 'P',
    this.isLocked = true,
    this.speed = 0,
    this.range = 420,
    this.temperature = 25,
    this.tirePressureFL = 2.3,
    this.tirePressureFR = 2.3,
    this.tirePressureRL = 2.3,
    this.tirePressureRR = 2.3,
    this.voltage12V = 12.6,
    this.odometer = 12580,
    this.acIsOn = false,
    this.trunkIsOpen = false,
    this.trunkPosition = 0,
    this.windowsState = 'closed',
    this.lightsAreOn = false,
    this.engineRunning = false,
    this.mirrorsFolded = false,
    this.findMyCarActive = false,
    this.batteryHeaterOn = false,
    this.carModel = 'BYD Seal',
    this.carPlate = 'ABC-1234',
    this.ownerName = 'João Silva',
    this.driverSeatbeltFastened = true,
    this.passengerSeatbeltFastened = true,
    this.rearLeftSeatbeltFastened = true,
    this.rearRightSeatbeltFastened = false,
  });

  CarStatus copyWith({
    bool? isOnline,
    int? batteryLevel,
    String? gear,
    bool? isLocked,
    double? speed,
    int? range,
    double? temperature,
    double? tirePressureFL,
    double? tirePressureFR,
    double? tirePressureRL,
    double? tirePressureRR,
    double? voltage12V,
    int? odometer,
    bool? acIsOn,
    bool? trunkIsOpen,
    int? trunkPosition,
    String? windowsState,
    bool? lightsAreOn,
    bool? engineRunning,
    bool? mirrorsFolded,
    bool? findMyCarActive,
    bool? batteryHeaterOn,
    String? carModel,
    String? carPlate,
    String? ownerName,
    bool? driverSeatbeltFastened,
    bool? passengerSeatbeltFastened,
    bool? rearLeftSeatbeltFastened,
    bool? rearRightSeatbeltFastened,
  }) {
    return CarStatus(
      isOnline: isOnline ?? this.isOnline,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      gear: gear ?? this.gear,
      isLocked: isLocked ?? this.isLocked,
      speed: speed ?? this.speed,
      range: range ?? this.range,
      temperature: temperature ?? this.temperature,
      tirePressureFL: tirePressureFL ?? this.tirePressureFL,
      tirePressureFR: tirePressureFR ?? this.tirePressureFR,
      tirePressureRL: tirePressureRL ?? this.tirePressureRL,
      tirePressureRR: tirePressureRR ?? this.tirePressureRR,
      voltage12V: voltage12V ?? this.voltage12V,
      odometer: odometer ?? this.odometer,
      acIsOn: acIsOn ?? this.acIsOn,
      trunkIsOpen: trunkIsOpen ?? this.trunkIsOpen,
      trunkPosition: trunkPosition ?? this.trunkPosition,
      windowsState: windowsState ?? this.windowsState,
      lightsAreOn: lightsAreOn ?? this.lightsAreOn,
      engineRunning: engineRunning ?? this.engineRunning,
      mirrorsFolded: mirrorsFolded ?? this.mirrorsFolded,
      findMyCarActive: findMyCarActive ?? this.findMyCarActive,
      batteryHeaterOn: batteryHeaterOn ?? this.batteryHeaterOn,
      carModel: carModel ?? this.carModel,
      carPlate: carPlate ?? this.carPlate,
      ownerName: ownerName ?? this.ownerName,
      driverSeatbeltFastened: driverSeatbeltFastened ?? this.driverSeatbeltFastened,
      passengerSeatbeltFastened: passengerSeatbeltFastened ?? this.passengerSeatbeltFastened,
      rearLeftSeatbeltFastened: rearLeftSeatbeltFastened ?? this.rearLeftSeatbeltFastened,
      rearRightSeatbeltFastened: rearRightSeatbeltFastened ?? this.rearRightSeatbeltFastened,
    );
  }
}
