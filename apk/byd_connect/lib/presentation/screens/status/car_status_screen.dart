import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/car_repository.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/car_diagram.dart';

class CarStatusScreen extends StatelessWidget {
  const CarStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<CarRepository>(context);
    final status = repo.carStatus;

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
                'Status do Carro',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Car Diagram
              CarDiagram(
                isLocked: status.isLocked,
                windowsState: status.windowsState,
                lightsOn: status.lightsAreOn,
                trunkOpen: status.trunkIsOpen,
              ),
              const SizedBox(height: 24),

              // Main Status Cards
              Row(
                children: [
                  Expanded(
                    child: _StatusCard(
                      icon: Icons.battery_full,
                      label: 'Bateria',
                      value: '${status.batteryLevel}%',
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatusCard(
                      icon: Icons.route,
                      label: 'Autonomia',
                      value: '${status.range} km',
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatusCard(
                      icon: Icons.speed,
                      label: 'Velocidade',
                      value: '${status.speed.toInt()} km/h',
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatusCard(
                      icon: Icons.straighten,
                      label: 'Marcha',
                      value: status.gear,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatusCard(
                      icon: Icons.thermostat,
                      label: 'Temperatura',
                      value: '${status.temperature.toInt()}°C',
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatusCard(
                      icon: Icons.speed,
                      label: 'Hodômetro',
                      value: '${status.odometer} km',
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tire Pressure
              const Text(
                'Pressão dos Pneus',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _TirePressure(label: 'DI', value: status.tirePressureFL),
                    _TirePressure(label: 'DD', value: status.tirePressureFR),
                    _TirePressure(label: 'TI', value: status.tirePressureRL),
                    _TirePressure(label: 'TD', value: status.tirePressureRR),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 12V Battery
              const Text(
                'Bateria 12V',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.battery_full, color: AppColors.accent, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Voltage',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${status.voltage12V} V',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Cintos de Segurança
              const Text(
                'Cintos de Segurança',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SeatbeltIndicator(
                      label: 'Motorista',
                      isFastened: status.driverSeatbeltFastened,
                    ),
                    _SeatbeltIndicator(
                      label: 'Passageiro',
                      isFastened: status.passengerSeatbeltFastened,
                    ),
                    _SeatbeltIndicator(
                      label: 'Traseiro E',
                      isFastened: status.rearLeftSeatbeltFastened,
                    ),
                    _SeatbeltIndicator(
                      label: 'Traseiro D',
                      isFastened: status.rearRightSeatbeltFastened,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeatbeltIndicator extends StatelessWidget {
  final String label;
  final bool isFastened;

  const _SeatbeltIndicator({
    required this.label,
    required this.isFastened,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isFastened
                ? AppColors.accent.withValues(alpha: 0.2)
                : AppColors.error.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: isFastened ? AppColors.accent : AppColors.error,
              width: 2,
            ),
          ),
          child: Icon(
            isFastened ? Icons.check : Icons.close,
            color: isFastened ? AppColors.accent : AppColors.error,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isFastened ? AppColors.textPrimary : AppColors.error,
            fontSize: 11,
            fontWeight: isFastened ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isFastened
                ? AppColors.accent.withValues(alpha: 0.2)
                : AppColors.error.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isFastened ? 'OK' : 'ALERTA',
            style: TextStyle(
              color: isFastened ? AppColors.accent : AppColors.error,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatusCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _TirePressure extends StatelessWidget {
  final String label;
  final double value;

  const _TirePressure({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${value.toStringAsFixed(1)} bar',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
