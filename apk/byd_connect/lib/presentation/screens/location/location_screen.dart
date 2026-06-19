import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/car_repository.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_icon_button.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<CarRepository>(context);
    final carPosition = LatLng(-23.5505, -46.6333);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Localização',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Mapa Real OpenStreetMap
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    // Mapa
                    SizedBox(
                      height: 280,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Stack(
                          children: [
                            FlutterMap(
                              options: MapOptions(
                                initialCenter: carPosition,
                                initialZoom: 16.0,
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
                                        isLocked: repo.carStatus.isLocked,
                                        lightsOn: repo.carStatus.lightsAreOn,
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _InfoChip(Icons.battery_full, '${repo.carStatus.batteryLevel}%', _batteryColor(repo.carStatus.batteryLevel)),
                                  _InfoChip(Icons.route, '${repo.carStatus.range} km', AppColors.primary),
                                  _InfoChip(Icons.speed, '${repo.carStatus.speed.toInt()} km/h', AppColors.accent),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Info do carro e endereço
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Info do carro e dono
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.directions_car, color: AppColors.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      repo.carStatus.carModel,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            repo.carStatus.carPlate,
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.person, size: 12, color: AppColors.textSecondary),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: Text(
                                            repo.carStatus.ownerName,
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 11,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              GlassIconButton(
                                icon: Icons.navigation,
                                label: '',
                                size: 44,
                                onTap: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Endereço
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.location_on, color: AppColors.accent, size: 18),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Localização Atual',
                                      style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                                    Text('Av. Paulista, 1578 - Bela Vista, São Paulo',
                                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
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
              ),
              const SizedBox(height: 24),

              // Info do Veículo
              _InfoCard(repo: repo),
              const SizedBox(height: 24),

              // Recent Trips
              const Text(
                'Viagens Recentes',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _TripCard(
                date: 'Hoje, 14:32',
                origin: 'Av. Paulista, 1578',
                destination: 'Shopping Ibirapuera',
                distance: '8.5 km',
                duration: '22 min',
              ),
              const SizedBox(height: 8),
              _TripCard(
                date: 'Hoje, 09:15',
                origin: 'Casa',
                destination: 'Av. Paulista, 1578',
                distance: '12.3 km',
                duration: '35 min',
              ),
              const SizedBox(height: 8),
              _TripCard(
                date: 'Ontem, 18:45',
                origin: 'Restaurante Tokio',
                destination: 'Casa',
                distance: '6.2 km',
                duration: '18 min',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _batteryColor(int level) {
    if (level > 60) return AppColors.accent;
    if (level > 30) return AppColors.warning;
    return AppColors.error;
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
        // Seta azul-petroleum em círculo branco (ícone do veículo padrão)
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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(
              color: isLocked ? AppColors.locked : AppColors.unlocked, shape: BoxShape.circle)),
            const SizedBox(width: 2),
            Container(width: 8, height: 8, decoration: BoxDecoration(
              color: lightsOn ? AppColors.warning : Colors.grey, shape: BoxShape.circle)),
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

class _InfoCard extends StatelessWidget {
  final CarRepository repo;
  const _InfoCard({required this.repo});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _InfoItem(Icons.battery_full, 'Bateria', '${repo.carStatus.batteryLevel}%',
            repo.carStatus.batteryLevel > 60 ? AppColors.accent : repo.carStatus.batteryLevel > 30 ? AppColors.warning : AppColors.error),
          _InfoItem(Icons.route, 'Autonomia', '${repo.carStatus.range} km', AppColors.primary),
          _InfoItem(Icons.speed, 'Velocidade', '${repo.carStatus.speed.toInt()} km/h', AppColors.accent),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoItem(this.icon, this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}

class _TripCard extends StatelessWidget {
  final String date;
  final String origin;
  final String destination;
  final String distance;
  final String duration;

  const _TripCard({required this.date, required this.origin, required this.destination, required this.distance, required this.duration});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.route, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                Text(origin, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                const Text('→', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                Text(destination, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(distance, style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold)),
              Text(duration, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
