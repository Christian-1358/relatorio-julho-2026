import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Tipos de conexão suportados
enum ConnectionType {
  none('Nenhuma'),
  http('HTTP/REST API'),
  ssh('SSH'),
  websocket('WebSocket'),
  mqtt('MQTT'),
  bluetooth('Bluetooth');

  final String label;
  const ConnectionType(this.label);
}

/// Status da conexão
enum ConnectionStatus {
  disconnected('Desconectado'),
  connecting('Conectando...'),
  connected('Conectado'),
  error('Erro'),
  waiting('Aguardando...');

  final String label;
  const ConnectionStatus(this.label);
}

/// Configuração de conexão
class ConnectionConfig {
  final ConnectionType type;
  final String host;
  final int port;
  final String username;
  final String password;
  final String apiKey;
  final Map<String, String> headers;
  final int timeout;
  final bool ssl;

  ConnectionConfig({
    this.type = ConnectionType.none,
    this.host = '192.168.1.100',
    this.port = 8080,
    this.username = '',
    this.password = '',
    this.apiKey = '',
    this.headers = const {},
    this.timeout = 30,
    this.ssl = false,
  });

  String get baseUrl => '${ssl ? 'https' : 'http'}://$host:$port';

  ConnectionConfig copyWith({
    ConnectionType? type,
    String? host,
    int? port,
    String? username,
    String? password,
    String? apiKey,
    Map<String, String>? headers,
    int? timeout,
    bool? ssl,
  }) {
    return ConnectionConfig(
      type: type ?? this.type,
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      password: password ?? this.password,
      apiKey: apiKey ?? this.apiKey,
      headers: headers ?? this.headers,
      timeout: timeout ?? this.timeout,
      ssl: ssl ?? this.ssl,
    );
  }
}

/// Resposta da API
class ApiResponse {
  final bool success;
  final dynamic data;
  final String? error;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.statusCode = 200,
  });
}

/// Manager de conexão com o carro
class ConnectionManager extends ChangeNotifier {
  static final ConnectionManager _instance = ConnectionManager._internal();
  factory ConnectionManager() => _instance;

  ConnectionManager._internal() {
    _loadConfig();
  }

  ConnectionConfig _config = ConnectionConfig();
  ConnectionStatus _status = ConnectionStatus.disconnected;
  String _lastError = '';
  HttpClient? _httpClient;
  WebSocket? _ws;
  Socket? _sshSocket;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  DateTime? _lastUpdate;

  // Getters
  ConnectionConfig get config => _config;
  ConnectionStatus get status => _status;
  String get lastError => _lastError;
  DateTime? get lastUpdate => _lastUpdate;
  bool get isConnected => _status == ConnectionStatus.connected;

  // Salvar config
  Future<void> _loadConfig() async {
    // Em produção, carregaria de SharedPreferences
  }

  Future<void> _saveConfig() async {
    // Em produção, salvaria em SharedPreferences
  }

  /// Configurar conexão
  Future<void> configure(ConnectionConfig config) async {
    _config = config;
    await _saveConfig();
    notifyListeners();
  }

  /// Conectar
  Future<bool> connect() async {
    if (_config.type == ConnectionType.none) {
      _setError('Selecione um tipo de conexão');
      return false;
    }

    _setStatus(ConnectionStatus.connecting);

    try {
      switch (_config.type) {
        case ConnectionType.http:
        case ConnectionType.websocket:
          return await _connectHttp();
        case ConnectionType.ssh:
          return await _connectSSH();
        case ConnectionType.mqtt:
          return await _connectMQTT();
        case ConnectionType.bluetooth:
          return await _connectBluetooth();
        case ConnectionType.none:
          return false;
      }
    } catch (e) {
      _setError('Erro ao conectar: $e');
      return false;
    }
  }

  /// Desconectar
  Future<void> disconnect() async {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();

    switch (_config.type) {
      case ConnectionType.http:
        _httpClient?.close();
        _httpClient = null;
        break;
      case ConnectionType.websocket:
        await _ws?.close();
        _ws = null;
        break;
      case ConnectionType.ssh:
        _sshSocket?.destroy();
        _sshSocket = null;
        break;
      case ConnectionType.mqtt:
        // MQTT cleanup
        break;
      case ConnectionType.bluetooth:
        // Bluetooth cleanup
        break;
      case ConnectionType.none:
        break;
    }

    _setStatus(ConnectionStatus.disconnected);
  }

  /// Conectar via HTTP/REST
  Future<bool> _connectHttp() async {
    _httpClient = HttpClient();

    try {
      // Testar conexão com endpoint de status
      final response = await _makeRequest('/api/status');
      if (response.success) {
        _setStatus(ConnectionStatus.connected);
        _startHeartbeat();
        return true;
      } else {
        _setError(response.error ?? 'Falha na conexão HTTP');
        return false;
      }
    } catch (e) {
      // Simular conexão bem-sucedida para demo
      _setStatus(ConnectionStatus.connected);
      _startHeartbeat();
      return true;
    }
  }

  /// Conectar via SSH
  Future<bool> _connectSSH() async {
    try {
      _sshSocket = await Socket.connect(
        _config.host,
        _config.port,
        timeout: Duration(seconds: _config.timeout),
      );

      // Ler banner inicial
      final buffer = StringBuffer();
      await for (final data in _sshSocket!) {
        buffer.write(String.fromCharCodes(data));
        if (buffer.toString().contains('\n')) break;
      }

      _setStatus(ConnectionStatus.connected);
      _startHeartbeat();
      return true;
    } catch (e) {
      // Simular SSH para demo
      _setStatus(ConnectionStatus.connected);
      _startHeartbeat();
      return true;
    }
  }

  /// Conectar via WebSocket
  Future<bool> _connectWebSocket() async {
    try {
      _ws = await WebSocket.connect(_config.baseUrl);

      _ws!.listen(
        (data) => _handleWebSocketMessage(data),
        onError: (e) => _setError('WebSocket error: $e'),
        onDone: () {
          _setStatus(ConnectionStatus.disconnected);
          _scheduleReconnect();
        },
      );

      _setStatus(ConnectionStatus.connected);
      return true;
    } catch (e) {
      _setError('WebSocket error: $e');
      return false;
    }
  }

  /// Conectar via MQTT (simulado)
  Future<bool> _connectMQTT() async {
    // Em produção, usaria package:mqtt
    _setStatus(ConnectionStatus.connected);
    _startHeartbeat();
    return true;
  }

  /// Conectar via Bluetooth (simulado)
  Future<bool> _connectBluetooth() async {
    // Em produção, usaria flutter_blue_plus
    _setStatus(ConnectionStatus.connected);
    _startHeartbeat();
    return true;
  }

  /// Fazer requisição HTTP
  Future<ApiResponse> _makeRequest(String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    try {
      final request = await _httpClient!.openUrl(
        method,
        Uri.parse('${_config.baseUrl}$endpoint'),
      );

      // Adicionar headers
      request.headers.set('Content-Type', 'application/json');
      if (_config.apiKey.isNotEmpty) {
        request.headers.set('Authorization', 'Bearer ${_config.apiKey}');
      }
      _config.headers.forEach((key, value) {
        request.headers.set(key, value);
      });

      if (body != null) {
        request.write(jsonEncode(body));
      }

      final response = await request.close().timeout(
        Duration(seconds: _config.timeout),
      );

      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(
          success: true,
          data: jsonDecode(responseBody),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          success: false,
          error: 'HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Obter dados do carro (simulado com dados realistas)
  Future<Map<String, dynamic>> getCarData() async {
    if (!isConnected) {
      throw Exception('Não conectado');
    }

    // Se conectado via HTTP real, fazer requisição
    if (_config.type == ConnectionType.http && _httpClient != null) {
      final response = await _makeRequest('/api/car/status');
      if (response.success) {
        _lastUpdate = DateTime.now();
        return response.data;
      }
    }

    // Retornar dados simulados realistas
    _lastUpdate = DateTime.now();
    return _generateSimulatedCarData();
  }

  /// Gerar dados simulados realistas
  Map<String, dynamic> _generateSimulatedCarData() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'status': {
        'isOnline': true,
        'batteryLevel': 78,
        'gear': 'P',
        'isLocked': true,
        'speed': 0,
        'range': 420,
        'temperature': 25,
        'acIsOn': false,
        'trunkIsOpen': false,
        'trunkPosition': 0,
        'windowsState': 'closed',
        'lightsAreOn': false,
        'engineRunning': false,
        'mirrorsFolded': false,
      },
      'battery': {
        'voltage': 356.4,
        'current': -15.3,
        'temperature': 28,
        'capacity': 82,
        'cycles': 127,
        'health': 98,
        'estimatedTime': '4h 32m',
      },
      'tirePressure': {
        'frontLeft': 2.3,
        'frontRight': 2.3,
        'rearLeft': 2.3,
        'rearRight': 2.3,
      },
      'odometer': 12580,
      'location': {
        'latitude': -23.5505,
        'longitude': -46.6333,
        'address': 'São Paulo, SP',
      },
      'climate': {
        'isOn': false,
        'temperature': 22,
        'fanSpeed': 2,
        'mode': 'auto',
        'isRecirculating': false,
      },
      'seats': {
        'driverHeatLevel': 0,
        'passengerHeatLevel': 0,
        'driverVentLevel': 0,
        'passengerVentLevel': 0,
      },
      'sentinel': {
        'isActive': false,
        'mode': 'disarmed',
        'events': [],
      },
    };
  }

  /// Enviar comando para o carro
  Future<ApiResponse> sendCommand(String command, Map<String, dynamic>? params) async {
    if (!isConnected) {
      return ApiResponse(success: false, error: 'Não conectado');
    }

    switch (_config.type) {
      case ConnectionType.http:
        return await _makeRequest(
          '/api/command/$command',
          method: 'POST',
          body: params,
        );
      case ConnectionType.websocket:
        _ws?.add(jsonEncode({
          'command': command,
          'params': params,
          'timestamp': DateTime.now().toIso8601String(),
        }));
        return ApiResponse(success: true);
      case ConnectionType.ssh:
        // Enviar via SSH
        _sshSocket?.write('car control --$command\n');
        return ApiResponse(success: true);
      default:
        // Simular comando
        return ApiResponse(success: true, data: {'executed': true});
    }
  }

  /// Processar mensagem WebSocket
  void _handleWebSocketMessage(dynamic data) {
    try {
      final message = jsonDecode(data as String);
      // Processar mensagem do carro
      notifyListeners();
    } catch (e) {
      debugPrint('WebSocket message error: $e');
    }
  }

  /// Iniciar heartbeat
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkConnection();
    });
  }

  /// Verificar conexão
  Future<void> _checkConnection() async {
    if (!isConnected) return;

    try {
      await getCarData();
    } catch (e) {
      _setError('Conexão perdida');
      _scheduleReconnect();
    }
  }

  /// Agendar reconexão
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      connect();
    });
  }

  void _setStatus(ConnectionStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String error) {
    _lastError = error;
    _setStatus(ConnectionStatus.error);
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
