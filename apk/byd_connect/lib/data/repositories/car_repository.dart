import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/car_status.dart';
import '../models/climate_settings.dart';
import '../models/seat_settings.dart';
import '../models/sentinel_event.dart';
import '../models/media_state.dart';
import '../connection/connection_manager.dart';

class CarRepository extends ChangeNotifier {
  // Singleton pattern
  static final CarRepository _instance = CarRepository._internal();
  factory CarRepository() => _instance;
  CarRepository._internal() {
    _initConnectionListener();
  }

  CarStatus _carStatus = CarStatus();
  ClimateSettings _climateSettings = ClimateSettings();
  SeatSettings _seatSettings = SeatSettings();
  SentinelMode _sentinelMode = SentinelMode();
  MediaState _mediaState = MediaState();
  List<SentinelEvent> _sentinelEvents = _generateMockEvents();

  // Connection Manager
  final ConnectionManager _connManager = ConnectionManager();
  Timer? _syncTimer;
  bool _isSyncing = false;

  // Battery info
  double _voltage = 356.4;
  double _current = -15.3;
  double _batteryTemp = 28;
  int _capacity = 82;
  int _cycles = 127;
  int _health = 98;
  String _estimatedTime = '4h 32m';

  // Getters
  CarStatus get carStatus => _carStatus;
  ClimateSettings get climateSettings => _climateSettings;
  SeatSettings get seatSettings => _seatSettings;
  SentinelMode get sentinelMode => _sentinelMode;
  MediaState get mediaState => _mediaState;
  List<SentinelEvent> get sentinelEvents => _sentinelEvents;
  double get voltage => _voltage;
  double get current => _current;
  double get batteryTemp => _batteryTemp;
  int get capacity => _capacity;
  int get cycles => _cycles;
  int get health => _health;
  String get estimatedTime => _estimatedTime;
  ConnectionManager get connectionManager => _connManager;
  bool get isConnected => _connManager.isConnected;
  bool get isSyncing => _isSyncing;

  void _initConnectionListener() {
    _connManager.addListener(_onConnectionChanged);
  }

  void _onConnectionChanged() {
    if (_connManager.isConnected) {
      _startAutoSync();
      _syncFromCar();
    } else {
      _stopAutoSync();
    }
    notifyListeners();
  }

  void _startAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _syncFromCar();
    });
  }

  void _stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  Future<void> _syncFromCar() async {
    if (_isSyncing || !_connManager.isConnected) return;

    _isSyncing = true;

    try {
      final data = await _connManager.getCarData();
      _updateFromMap(data);
    } catch (e) {
      debugPrint('Sync error: $e');
    }

    _isSyncing = false;
    notifyListeners();
  }

  void _updateFromMap(Map<String, dynamic> data) {
    // Update status
    if (data['status'] != null) {
      final status = data['status'] as Map<String, dynamic>;
      _carStatus = CarStatus(
        isOnline: status['isOnline'] ?? true,
        batteryLevel: status['batteryLevel'] ?? 78,
        gear: status['gear'] ?? 'P',
        isLocked: status['isLocked'] ?? true,
        speed: (status['speed'] ?? 0).toDouble(),
        range: status['range'] ?? 420,
        temperature: (status['temperature'] ?? 25).toDouble(),
        acIsOn: status['acIsOn'] ?? false,
        trunkIsOpen: status['trunkIsOpen'] ?? false,
        trunkPosition: status['trunkPosition'] ?? 0,
        windowsState: status['windowsState'] ?? 'closed',
        lightsAreOn: status['lightsAreOn'] ?? false,
        engineRunning: status['engineRunning'] ?? false,
        mirrorsFolded: status['mirrorsFolded'] ?? false,
        findMyCarActive: status['findMyCarActive'] ?? false,
        batteryHeaterOn: status['batteryHeaterOn'] ?? false,
        carModel: status['carModel'] ?? 'BYD Seal',
        carPlate: status['carPlate'] ?? 'ABC-1234',
        ownerName: status['ownerName'] ?? 'João Silva',
      );
    }

    // Update battery info
    if (data['battery'] != null) {
      final battery = data['battery'] as Map<String, dynamic>;
      _voltage = (battery['voltage'] ?? 356.4).toDouble();
      _current = (battery['current'] ?? -15.3).toDouble();
      _batteryTemp = (battery['temperature'] ?? 28).toDouble();
      _capacity = battery['capacity'] ?? 82;
      _cycles = battery['cycles'] ?? 127;
      _health = battery['health'] ?? 98;
      _estimatedTime = battery['estimatedTime'] ?? '4h 32m';
    }

    // Update tire pressure
    if (data['tirePressure'] != null) {
      final tire = data['tirePressure'] as Map<String, dynamic>;
      _carStatus = _carStatus.copyWith(
        tirePressureFL: (tire['frontLeft'] ?? 2.3).toDouble(),
        tirePressureFR: (tire['frontRight'] ?? 2.3).toDouble(),
        tirePressureRL: (tire['rearLeft'] ?? 2.3).toDouble(),
        tirePressureRR: (tire['rearRight'] ?? 2.3).toDouble(),
      );
    }

    // Update odometer
    if (data['odometer'] != null) {
      _carStatus = _carStatus.copyWith(odometer: data['odometer']);
    }

    // Update climate
    if (data['climate'] != null) {
      final climate = data['climate'] as Map<String, dynamic>;
      _climateSettings = ClimateSettings(
        isOn: climate['isOn'] ?? false,
        temperature: climate['temperature'] ?? 22,
        fanSpeed: climate['fanSpeed'] ?? 2,
        mode: climate['mode'] ?? 'auto',
        isRecirculating: climate['isRecirculating'] ?? false,
      );
    }

    // Update seats
    if (data['seats'] != null) {
      final seats = data['seats'] as Map<String, dynamic>;
      _seatSettings = SeatSettings(
        driverHeatLevel: seats['driverHeatLevel'] ?? 0,
        passengerHeatLevel: seats['passengerHeatLevel'] ?? 0,
        driverVentLevel: seats['driverVentLevel'] ?? 0,
        passengerVentLevel: seats['passengerVentLevel'] ?? 0,
      );
    }

    // Update sentinel
    if (data['sentinel'] != null) {
      final sentinel = data['sentinel'] as Map<String, dynamic>;
      _sentinelMode = SentinelMode(
        isActive: sentinel['isActive'] ?? false,
        mode: sentinel['mode'] ?? 'disarmed',
      );
    }
  }

  /// Forçar sincronização
  Future<void> syncNow() async {
    await _syncFromCar();
  }

  /// Conectar ao carro
  Future<bool> connect({
    required ConnectionType type,
    required String host,
    int port = 8080,
    String username = '',
    String password = '',
    String apiKey = '',
    bool ssl = false,
  }) async {
    final config = ConnectionConfig(
      type: type,
      host: host,
      port: port,
      username: username,
      password: password,
      apiKey: apiKey,
      ssl: ssl,
    );

    await _connManager.configure(config);
    return await _connManager.connect();
  }

  /// Desconectar do carro
  Future<void> disconnect() async {
    await _connManager.disconnect();
  }

  // Commands - these send commands to the real car when connected
  Future<void> toggleLock() async {
    if (_connManager.isConnected) {
      await _connManager.sendCommand('lock', {'locked': !_carStatus.isLocked});
    }
    await Future.delayed(const Duration(milliseconds: 800));
    _carStatus = _carStatus.copyWith(isLocked: !_carStatus.isLocked);
    notifyListeners();
  }

  Future<void> setWindows(String state) async {
    if (_connManager.isConnected) {
      await _connManager.sendCommand('windows', {'state': state});
    }
    await Future.delayed(const Duration(milliseconds: 800));
    _carStatus = _carStatus.copyWith(windowsState: state);
    notifyListeners();
  }

  Future<void> setTrunk(int position) async {
    if (_connManager.isConnected) {
      await _connManager.sendCommand('trunk', {'position': position});
    }
    await Future.delayed(const Duration(milliseconds: 800));
    _carStatus = _carStatus.copyWith(
      trunkPosition: position,
      trunkIsOpen: position > 0,
    );
    notifyListeners();
  }

  Future<void> toggleLights() async {
    if (_connManager.isConnected) {
      await _connManager.sendCommand('lights', {'on': !_carStatus.lightsAreOn});
    }
    await Future.delayed(const Duration(milliseconds: 500));
    _carStatus = _carStatus.copyWith(lightsAreOn: !_carStatus.lightsAreOn);
    notifyListeners();
  }

  // Novos comandos
  Future<void> honkHorn() async {
    if (_connManager.isConnected) {
      await _connManager.sendCommand('honk', {});
    }
    await Future.delayed(const Duration(milliseconds: 300));
    // Buzina - apenas feedback visual
    notifyListeners();
  }

  Future<void> toggleEngine() async {
    if (_connManager.isConnected) {
      await _connManager.sendCommand('engine', {'running': !_carStatus.engineRunning});
    }
    await Future.delayed(const Duration(milliseconds: 1000));
    _carStatus = _carStatus.copyWith(engineRunning: !_carStatus.engineRunning);
    notifyListeners();
  }

  Future<void> toggleMirrors() async {
    if (_connManager.isConnected) {
      await _connManager.sendCommand('mirrors', {'folded': !_carStatus.mirrorsFolded});
    }
    await Future.delayed(const Duration(milliseconds: 500));
    _carStatus = _carStatus.copyWith(mirrorsFolded: !_carStatus.mirrorsFolded);
    notifyListeners();
  }

  Future<void> findMyCar() async {
    if (_connManager.isConnected) {
      await _connManager.sendCommand('findMyCar', {});
    }
    await Future.delayed(const Duration(milliseconds: 300));
    _carStatus = _carStatus.copyWith(findMyCarActive: true);
    notifyListeners();
    await Future.delayed(const Duration(seconds: 5));
    _carStatus = _carStatus.copyWith(findMyCarActive: false);
    notifyListeners();
  }

  Future<void> toggleBatteryHeater() async {
    if (_connManager.isConnected) {
      await _connManager.sendCommand('batteryHeater', {'on': !_carStatus.batteryHeaterOn});
    }
    await Future.delayed(const Duration(milliseconds: 500));
    _carStatus = _carStatus.copyWith(batteryHeaterOn: !_carStatus.batteryHeaterOn);
    notifyListeners();
  }

  Future<void> toggleAc() async {
    if (_connManager.isConnected) {
      await _connManager.sendCommand('ac', {'on': !_carStatus.acIsOn});
    }
    await Future.delayed(const Duration(milliseconds: 500));
    _carStatus = _carStatus.copyWith(acIsOn: !_carStatus.acIsOn);
    _climateSettings = _climateSettings.copyWith(isOn: !_climateSettings.isOn);
    notifyListeners();
  }

  Future<void> setClimateTemp(int temp) async {
    if (_connManager.isConnected) {
      await _connManager.sendCommand('climateTemp', {'temperature': temp});
    }
    await Future.delayed(const Duration(milliseconds: 300));
    _climateSettings = _climateSettings.copyWith(temperature: temp);
    notifyListeners();
  }

  Future<void> setFanSpeed(int speed) async {
    if (_connManager.isConnected) {
      await _connManager.sendCommand('fanSpeed', {'speed': speed});
    }
    await Future.delayed(const Duration(milliseconds: 300));
    _climateSettings = _climateSettings.copyWith(fanSpeed: speed);
    notifyListeners();
  }

  Future<void> setClimateMode(String mode) async {
    if (_connManager.isConnected) {
      await _connManager.sendCommand('climateMode', {'mode': mode});
    }
    await Future.delayed(const Duration(milliseconds: 300));
    _climateSettings = _climateSettings.copyWith(mode: mode);
    notifyListeners();
  }

  Future<void> toggleRecirculating() async {
    if (_connManager.isConnected) {
      await _connManager.sendCommand('recirculating', {'on': !_climateSettings.isRecirculating});
    }
    await Future.delayed(const Duration(milliseconds: 300));
    _climateSettings = _climateSettings.copyWith(
      isRecirculating: !_climateSettings.isRecirculating,
    );
    notifyListeners();
  }

  Future<void> togglePreClimate() async {
    if (_connManager.isConnected) {
      await _connManager.sendCommand('preClimate', {'enabled': !_climateSettings.preClimateEnabled});
    }
    await Future.delayed(const Duration(milliseconds: 300));
    _climateSettings = _climateSettings.copyWith(
      preClimateEnabled: !_climateSettings.preClimateEnabled,
    );
    notifyListeners();
  }

  Future<void> setPreClimateTime(int minutes) async {
    if (_connManager.isConnected) {
      await _connManager.sendCommand('preClimateTime', {'minutes': minutes});
    }
    await Future.delayed(const Duration(milliseconds: 300));
    _climateSettings = _climateSettings.copyWith(preClimateTime: minutes);
    notifyListeners();
  }

  Future<void> setDriverHeat(int level) async {
    if (_connManager.isConnected) {
      await _connManager.sendCommand('driverHeat', {'level': level});
    }
    await Future.delayed(const Duration(milliseconds: 300));
    _seatSettings = _seatSettings.copyWith(driverHeatLevel: level);
    notifyListeners();
  }

  Future<void> setDriverVent(int level) async {
    if (_connManager.isConnected) {
      await _connManager.sendCommand('driverVent', {'level': level});
    }
    await Future.delayed(const Duration(milliseconds: 300));
    _seatSettings = _seatSettings.copyWith(driverVentLevel: level);
    notifyListeners();
  }

  Future<void> setPassengerHeat(int level) async {
    if (_connManager.isConnected) {
      await _connManager.sendCommand('passengerHeat', {'level': level});
    }
    await Future.delayed(const Duration(milliseconds: 300));
    _seatSettings = _seatSettings.copyWith(passengerHeatLevel: level);
    notifyListeners();
  }

  Future<void> setPassengerVent(int level) async {
    if (_connManager.isConnected) {
      await _connManager.sendCommand('passengerVent', {'level': level});
    }
    await Future.delayed(const Duration(milliseconds: 300));
    _seatSettings = _seatSettings.copyWith(passengerVentLevel: level);
    notifyListeners();
  }

  Future<void> toggleSeatSafeMode() async {
    if (_connManager.isConnected) {
      await _connManager.sendCommand('seatSafeMode', {});
    }
    await Future.delayed(const Duration(milliseconds: 300));
    _seatSettings = _seatSettings.copyWith(
      seatPosition: _seatSettings.seatPosition == 'safe' ? 'normal' : 'safe',
    );
    notifyListeners();
  }

  Future<void> saveSeatMemory(int memory) async {
    if (_connManager.isConnected) {
      await _connManager.sendCommand('saveSeatMemory', {'memory': memory});
    }
    await Future.delayed(const Duration(milliseconds: 300));
    // Save current position to memory
    _seatSettings = _seatSettings.copyWith(memoryPosition: memory);
    notifyListeners();
  }

  Future<void> recallSeatMemory(int memory) async {
    if (_connManager.isConnected) {
      await _connManager.sendCommand('recallSeatMemory', {'memory': memory});
    }
    await Future.delayed(const Duration(milliseconds: 300));
    _seatSettings = _seatSettings.copyWith(memoryPosition: memory);
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_connManager.isConnected) {
      await _connManager.sendCommand('mediaPlayPause', {});
    }
    await Future.delayed(const Duration(milliseconds: 200));
    _mediaState = _mediaState.copyWith(isPlaying: !_mediaState.isPlaying);
    notifyListeners();
  }

  Future<void> nextTrack() async {
    if (_connManager.isConnected) {
      await _connManager.sendCommand('mediaNext', {});
    }
    await Future.delayed(const Duration(milliseconds: 200));
    _mediaState = _mediaState.copyWith(
      currentTrack: 'Thunderstruck',
      artist: 'AC/DC',
      position: 0,
      duration: 292,
    );
    notifyListeners();
  }

  Future<void> previousTrack() async {
    if (_connManager.isConnected) {
      await _connManager.sendCommand('mediaPrevious', {});
    }
    await Future.delayed(const Duration(milliseconds: 200));
    _mediaState = _mediaState.copyWith(
      currentTrack: 'Highway to Hell',
      artist: 'AC/DC',
      position: 0,
      duration: 267,
    );
    notifyListeners();
  }

  Future<void> setVolume(int volume) async {
    if (_connManager.isConnected) {
      await _connManager.sendCommand('mediaVolume', {'volume': volume});
    }
    await Future.delayed(const Duration(milliseconds: 100));
    _mediaState = _mediaState.copyWith(volume: volume);
    notifyListeners();
  }

  Future<void> setSentinelMode(String mode) async {
    if (_connManager.isConnected) {
      await _connManager.sendCommand('sentinelMode', {'mode': mode});
    }
    await Future.delayed(const Duration(milliseconds: 500));
    _sentinelMode = _sentinelMode.copyWith(mode: mode, isActive: mode != 'disarmed');
    notifyListeners();
  }

  static List<SentinelEvent> _generateMockEvents() {
    return [
      SentinelEvent(
        id: '1',
        type: 'motion',
        description: 'Movimento detectado',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      SentinelEvent(
        id: '2',
        type: 'door',
        description: 'Porta aberta',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      SentinelEvent(
        id: '3',
        type: 'alarm',
        description: 'Alarme disparado',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _connManager.removeListener(_onConnectionChanged);
    super.dispose();
  }
}
