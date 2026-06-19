import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_colors.dart';

class CarDiagram extends StatelessWidget {
  final bool isLocked;
  final String windowsState;
  final bool lightsOn;
  final bool trunkOpen;
  final int batteryLevel;
  final String gear;
  final double speed;
  final double temperature;
  final String? address;
  final double? latitude;
  final double? longitude;

  const CarDiagram({
    super.key,
    required this.isLocked,
    required this.windowsState,
    required this.lightsOn,
    required this.trunkOpen,
    this.batteryLevel = 78,
    this.gear = 'P',
    this.speed = 0,
    this.temperature = 25,
    this.address,
    this.latitude,
    this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final carPosition = LatLng(
      latitude ?? -23.5505,
      longitude ?? -46.6333,
    );

    return Container(
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          // Mapa - parte maior
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  // Mapa OpenStreetMap
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: carPosition,
                      initialZoom: 16.0,
                      onTap: (_, __) {},
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.byd_connect',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: carPosition,
                            width: 50,
                            height: 70,
                            child: _CarMarkerMini(
                              isLocked: isLocked,
                              lightsOn: lightsOn,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Info chips no topo
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 8,
                    child: _InfoChipsRow(
                      batteryLevel: batteryLevel,
                      temperature: temperature,
                      speed: speed,
                      gear: gear,
                    ),
                  ),
                  // Status icons na base
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _StatusBar(
                      isLocked: isLocked,
                      windowsState: windowsState,
                      lightsOn: lightsOn,
                      trunkOpen: trunkOpen,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Barra de GPS
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withValues(alpha: 0.8),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.location_on, size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Localização do Veículo',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                          Text(address ?? 'Buscando...',
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w500),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChipsRow extends StatelessWidget {
  final int batteryLevel;
  final double temperature;
  final double speed;
  final String gear;

  const _InfoChipsRow({
    required this.batteryLevel,
    required this.temperature,
    required this.speed,
    required this.gear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _InfoChip(Icons.battery_full, '$batteryLevel%', _batteryColor),
        _InfoChip(Icons.thermostat, '${temperature.toInt()}°C', _tempColor),
        _InfoChip(Icons.speed, '${speed.toInt()} km/h', AppColors.accent),
        _InfoChip(Icons.directions_car, gear, AppColors.primary),
      ],
    );
  }

  Color get _batteryColor {
    if (batteryLevel > 60) return AppColors.accent;
    if (batteryLevel > 30) return AppColors.warning;
    return AppColors.error;
  }

  Color get _tempColor {
    return temperature > 30 ? AppColors.error : AppColors.primary;
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _InfoChip(this.icon, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(value, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final bool isLocked;
  final String windowsState;
  final bool lightsOn;
  final bool trunkOpen;

  const _StatusBar({
    required this.isLocked,
    required this.windowsState,
    required this.lightsOn,
    required this.trunkOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatusIcon(isLocked ? Icons.lock : Icons.lock_open, isLocked, AppColors.locked),
          _StatusIcon(Icons.window, windowsState != 'closed', AppColors.primary),
          _StatusIcon(Icons.highlight, lightsOn, AppColors.warning),
          _StatusIcon(Icons.inventory_2, trunkOpen, AppColors.error),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final Color activeColor;

  const _StatusIcon(this.icon, this.isActive, this.activeColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isActive ? activeColor.withValues(alpha: 0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 16, color: isActive ? activeColor : Colors.white.withValues(alpha: 0.4)),
    );
  }
}

class _CarMarkerMini extends StatelessWidget {
  final bool isLocked;
  final bool lightsOn;

  const _CarMarkerMini({required this.isLocked, required this.lightsOn});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Seta azul-petróleo em círculo branco (ícone do veículo padrão)
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4)],
          ),
          child: Icon(Icons.navigation, size: 14, color: AppColors.petroleumBlue),
        ),
        const SizedBox(height: 2),
        // Carro 3D personalizado
        SizedBox(
          width: 36,
          height: 24,
          child: CustomPaint(
            painter: _Car3DPainter(
              color: AppColors.primary,
              isLocked: isLocked,
              lightsOn: lightsOn,
            ),
          ),
        ),
        const SizedBox(height: 2),
        // Mini status
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MiniDot(isLocked ? AppColors.locked : AppColors.unlocked),
            const SizedBox(width: 2),
            _MiniDot(lightsOn ? AppColors.warning : Colors.grey),
          ],
        ),
      ],
    );
  }
}

class _Car3DPainter extends CustomPainter {
  final Color color;
  final bool isLocked;
  final bool lightsOn;

  _Car3DPainter({
    required this.color,
    required this.isLocked,
    required this.lightsOn,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final carWidth = size.width;
    final carHeight = size.height;

    // Sombra do carro
    final shadowPath = ui.Path()
      ..moveTo(4, carHeight * 0.3)
      ..lineTo(carWidth * 0.15, carHeight * 0.7)
      ..lineTo(carWidth * 0.85, carHeight * 0.7)
      ..lineTo(carWidth - 4, carHeight * 0.3)
      ..close();
    canvas.drawPath(shadowPath, shadowPaint);

    // Corpo principal do carro (vista superior)
    final bodyPath = ui.Path()
      ..moveTo(carWidth * 0.5, 0)
      ..lineTo(carWidth * 0.85, carHeight * 0.25)
      ..lineTo(carWidth * 0.85, carHeight * 0.65)
      ..lineTo(carWidth * 0.5, carHeight)
      ..lineTo(carWidth * 0.15, carHeight * 0.65)
      ..lineTo(carWidth * 0.15, carHeight * 0.25)
      ..close();

    // Gradiente para efeito 3D
    final bodyGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color,
        color.withValues(alpha: 0.8),
        color.withValues(alpha: 0.6),
      ],
    );
    paint.shader = bodyGradient.createShader(Rect.fromLTWH(0, 0, carWidth, carHeight));
    canvas.drawPath(bodyPath, paint);

    // Janelas (mais escuro)
    final windowPaint = Paint()
      ..color = AppColors.primaryDark.withValues(alpha: 0.8);

    final windowPath = ui.Path()
      ..moveTo(carWidth * 0.5, carHeight * 0.08)
      ..lineTo(carWidth * 0.72, carHeight * 0.28)
      ..lineTo(carWidth * 0.72, carHeight * 0.45)
      ..lineTo(carWidth * 0.5, carHeight * 0.55)
      ..lineTo(carWidth * 0.28, carHeight * 0.45)
      ..lineTo(carWidth * 0.28, carHeight * 0.28)
      ..close();
    canvas.drawPath(windowPath, windowPaint);

    // Faróis
    if (lightsOn) {
      final lightPaint = Paint()..color = Colors.yellow;
      canvas.drawOval(
        Rect.fromLTWH(carWidth * 0.55, carHeight * 0.1, carWidth * 0.12, carHeight * 0.12),
        lightPaint,
      );
      // Brilho do farol
      final glowPaint = Paint()
        ..color = Colors.yellow.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawOval(
        Rect.fromLTWH(carWidth * 0.53, carHeight * 0.08, carWidth * 0.16, carHeight * 0.16),
        glowPaint,
      );
    }

    // Luzes traseiras
    final tailPaint = Paint()..color = AppColors.error;
    canvas.drawOval(
      Rect.fromLTWH(carWidth * 0.35, carHeight * 0.72, carWidth * 0.08, carHeight * 0.1),
      tailPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(carWidth * 0.57, carHeight * 0.72, carWidth * 0.08, carHeight * 0.1),
      tailPaint,
    );

    // Reflexo no para-brisa
    final reflectPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(carWidth * 0.35, carHeight * 0.2),
      Offset(carWidth * 0.48, carHeight * 0.15),
      reflectPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MiniDot extends StatelessWidget {
  final Color color;
  const _MiniDot(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
