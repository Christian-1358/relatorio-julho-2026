import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/connection/connection_manager.dart';
import '../../widgets/glass_card.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final _hostController = TextEditingController(text: '192.168.1.100');
  final _portController = TextEditingController(text: '8080');
  final _usernameController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController(text: '');
  final _apiKeyController = TextEditingController(text: '');

  ConnectionType _selectedType = ConnectionType.http;
  bool _ssl = false;

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connManager = Provider.of<ConnectionManager>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Conexão',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _buildStatusCard(connManager),
            const SizedBox(height: 24),

            // Connection Type
            const Text(
              'Tipo de Conexão',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildConnectionTypeSelector(),
            const SizedBox(height: 24),

            // Server Configuration
            if (_selectedType != ConnectionType.none) ...[
              const Text(
                'Configuração do Servidor',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildServerConfig(),
              const SizedBox(height: 24),
            ],

            // Auth Configuration
            if (_selectedType == ConnectionType.http ||
                _selectedType == ConnectionType.ssh) ...[
              const Text(
                'Autenticação',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildAuthConfig(),
              const SizedBox(height: 24),
            ],

            // API Key (for HTTP/REST)
            if (_selectedType == ConnectionType.http) ...[
              const Text(
                'API Key (opcional)',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildApiKeyConfig(),
              const SizedBox(height: 24),
            ],

            // Connect Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: connManager.status == ConnectionStatus.connecting
                    ? null
                    : () => _handleConnect(connManager),
                style: ElevatedButton.styleFrom(
                  backgroundColor: connManager.isConnected
                      ? AppColors.error
                      : AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  connManager.isConnected
                      ? 'DESCONECTAR'
                      : connManager.status == ConnectionStatus.connecting
                          ? 'CONECTANDO...'
                          : 'CONECTAR',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Error message
            if (connManager.lastError.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        connManager.lastError,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Last Update
            if (connManager.lastUpdate != null) ...[
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Última atualização: ${_formatDateTime(connManager.lastUpdate!)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Info
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(ConnectionManager connManager) {
    Color statusColor;
    IconData statusIcon;

    switch (connManager.status) {
      case ConnectionStatus.connected:
        statusColor = AppColors.accent;
        statusIcon = Icons.cloud_done;
        break;
      case ConnectionStatus.connecting:
        statusColor = AppColors.warning;
        statusIcon = Icons.cloud_sync;
        break;
      case ConnectionStatus.error:
        statusColor = AppColors.error;
        statusIcon = Icons.cloud_off;
        break;
      case ConnectionStatus.waiting:
        statusColor = AppColors.textSecondary;
        statusIcon = Icons.cloud_queue;
        break;
      case ConnectionStatus.disconnected:
        statusColor = AppColors.textSecondary;
        statusIcon = Icons.cloud_off;
        break;
    }

    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  connManager.status.label,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedType == ConnectionType.none
                      ? 'Selecione um tipo de conexão'
                      : '${_selectedType.label} • ${connManager.config.host}:${connManager.config.port}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionTypeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ConnectionType.values.map((type) {
        final isSelected = _selectedType == type;
        return GestureDetector(
          onTap: () => setState(() => _selectedType = type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.glassBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _getConnectionIcon(type),
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  type.label,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getConnectionIcon(ConnectionType type) {
    switch (type) {
      case ConnectionType.http:
        return Icons.http;
      case ConnectionType.ssh:
        return Icons.terminal;
      case ConnectionType.websocket:
        return Icons.cable;
      case ConnectionType.mqtt:
        return Icons.hub;
      case ConnectionType.bluetooth:
        return Icons.bluetooth;
      case ConnectionType.none:
        return Icons.cloud_off;
    }
  }

  Widget _buildServerConfig() {
    return GlassCard(
      child: Column(
        children: [
          // Host
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildTextField(
                  controller: _hostController,
                  label: 'Host / IP',
                  hint: '192.168.1.100',
                  icon: Icons.computer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _portController,
                  label: 'Porta',
                  hint: '8080',
                  icon: Icons.numbers,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // SSL Toggle
          Row(
            children: [
              const Icon(Icons.lock, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Usar SSL/TLS',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              const Spacer(),
              Switch(
                value: _ssl,
                onChanged: (v) => setState(() => _ssl = v),
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuthConfig() {
    return GlassCard(
      child: Column(
        children: [
          _buildTextField(
            controller: _usernameController,
            label: 'Usuário',
            hint: 'admin',
            icon: Icons.person,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _passwordController,
            label: 'Senha',
            hint: '••••••••',
            icon: Icons.lock,
            obscure: true,
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeyConfig() {
    return GlassCard(
      child: Column(
        children: [
          _buildTextField(
            controller: _apiKeyController,
            label: 'API Key',
            hint: 'Sua chave de API',
            icon: Icons.key,
          ),
          const SizedBox(height: 8),
          const Text(
            'A API Key será adicionada ao header Authorization: Bearer',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5)),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return GlassCard(
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Informações',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '• HTTP/REST: Para APIs que retornam JSON\n'
            '• SSH: Para conexão direta com terminal do carro\n'
            '• WebSocket: Para comunicação em tempo real\n'
            '• MQTT: Para protocolo IoT leve\n'
            '• Bluetooth: Para conexão direta com OBD do carro',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleConnect(ConnectionManager connManager) async {
    if (connManager.isConnected) {
      await connManager.disconnect();
    } else {
      final config = ConnectionConfig(
        type: _selectedType,
        host: _hostController.text,
        port: int.tryParse(_portController.text) ?? 8080,
        username: _usernameController.text,
        password: _passwordController.text,
        apiKey: _apiKeyController.text,
        ssl: _ssl,
      );

      await connManager.configure(config);
      await connManager.connect();
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}
