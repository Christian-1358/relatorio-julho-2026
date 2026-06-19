import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/car_repository.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/circular_gauge.dart';

class BatteryScreen extends StatelessWidget {
  const BatteryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<CarRepository>(context);

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
                'Bateria',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Main Gauge
              Center(
                child: CircularGauge(
                  value: repo.carStatus.batteryLevel / 100,
                  size: 220,
                  centerText: '${repo.carStatus.batteryLevel}%',
                  subtitle: 'State of Charge',
                  gradientColors: [
                    AppColors.error,
                    AppColors.warning,
                    AppColors.accent,
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 24h Chart placeholder
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gráfico 24h',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CustomPaint(
                        painter: _ChartPainter(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 8 Indicators
              const Text(
                'Indicadores',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.8,
                children: [
                  _IndicatorCard(
                    label: 'Voltage',
                    value: '${repo.voltage} V',
                    icon: Icons.electric_bolt,
                    color: AppColors.primary,
                  ),
                  _IndicatorCard(
                    label: 'Current',
                    value: '${repo.current} A',
                    icon: Icons.electrical_services,
                    color: AppColors.accent,
                  ),
                  _IndicatorCard(
                    label: 'Temperature',
                    value: '${repo.batteryTemp}°C',
                    icon: Icons.thermostat,
                    color: AppColors.warning,
                  ),
                  _IndicatorCard(
                    label: 'SoC',
                    value: '${repo.carStatus.batteryLevel}%',
                    icon: Icons.battery_full,
                    color: AppColors.accent,
                  ),
                  _IndicatorCard(
                    label: 'Capacity',
                    value: '${repo.capacity} kWh',
                    icon: Icons.memory,
                    color: AppColors.primary,
                  ),
                  _IndicatorCard(
                    label: 'Cycles',
                    value: '${repo.cycles}',
                    icon: Icons.loop,
                    color: AppColors.primary,
                  ),
                  _IndicatorCard(
                    label: 'Health',
                    value: '${repo.health}%',
                    icon: Icons.favorite,
                    color: AppColors.error,
                  ),
                  _IndicatorCard(
                    label: 'Est. Time',
                    value: repo.estimatedTime,
                    icon: Icons.schedule,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IndicatorCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _IndicatorCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    final points = [0.8, 0.75, 0.7, 0.72, 0.68, 0.65, 0.6, 0.58, 0.55, 0.52, 0.5, 0.48, 0.45, 0.42, 0.4, 0.38, 0.35, 0.32, 0.3, 0.28, 0.26, 0.25, 0.24, 0.23];

    for (var i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = points[i] * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Fill
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.3),
          AppColors.primary.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
