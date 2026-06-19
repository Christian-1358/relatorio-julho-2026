import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/car_repository.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_icon_button.dart';
import '../../widgets/status_indicator.dart';
import '../../widgets/car_diagram.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BYD Connect',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Connection status badge
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: repo.isConnected
                              ? AppColors.accent.withValues(alpha: 0.2)
                              : AppColors.textSecondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              repo.isConnected ? Icons.cloud_done : Icons.cloud_off,
                              size: 12,
                              color: repo.isConnected ? AppColors.accent : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              repo.isConnected ? 'Conectado' : 'Offline',
                              style: TextStyle(
                                color: repo.isConnected ? AppColors.accent : AppColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (repo.isSyncing) ...[
                              const SizedBox(width: 4),
                              SizedBox(
                                width: 8,
                                height: 8,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  StatusIndicator(isOnline: repo.carStatus.isOnline),
                ],
              ),
              const SizedBox(height: 24),

              // Car Status Card
              GlassCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Car image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'https://images.unsplash.com/photo-1619767886558-efdc259cde1a?w=200&q=80',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            cacheWidth: 160,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.directions_car,
                                  size: 48,
                                  color: AppColors.primary,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                repo.carStatus.carModel,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      repo.carStatus.carPlate,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 12,
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
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    repo.carStatus.isLocked
                                        ? Icons.lock
                                        : Icons.lock_open,
                                    size: 16,
                                    color: repo.carStatus.isLocked
                                        ? AppColors.locked
                                        : AppColors.unlocked,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    repo.carStatus.isLocked ? 'Travado' : 'Destrancado',
                                    style: TextStyle(
                                      color: repo.carStatus.isLocked
                                          ? AppColors.locked
                                          : AppColors.unlocked,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              '${repo.carStatus.batteryLevel}%',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Bateria',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Car Diagram com Mapa
              CarDiagram(
                isLocked: repo.carStatus.isLocked,
                windowsState: repo.carStatus.windowsState,
                lightsOn: repo.carStatus.lightsAreOn,
                trunkOpen: repo.carStatus.trunkIsOpen,
                batteryLevel: repo.carStatus.batteryLevel,
                gear: repo.carStatus.gear,
                speed: repo.carStatus.speed,
                temperature: repo.carStatus.temperature,
                address: 'São Paulo, SP',
                latitude: -23.5505,
                longitude: -46.6333,
              ),
              const SizedBox(height: 20),

              // Quick Actions
              const Text(
                'Ações Rápidas',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  GlassIconButton(
                    size: 72,
                    icon: repo.carStatus.acIsOn ? Icons.ac_unit : Icons.ac_unit_outlined,
                    label: 'Ar Cond.',
                    isActive: repo.carStatus.acIsOn,
                    onTap: () => repo.toggleAc(),
                  ),
                  GlassIconButton(
                    size: 72,
                    icon: Icons.lock,
                    label: repo.carStatus.isLocked ? 'Destrancar' : 'Travar',
                    isActive: !repo.carStatus.isLocked,
                    onTap: () => repo.toggleLock(),
                  ),
                  GlassIconButton(
                    size: 72,
                    icon: Icons.window,
                    label: 'Vidros',
                    onTap: () => Navigator.pushNamed(context, '/commands/windows'),
                  ),
                  GlassIconButton(
                    size: 72,
                    icon: Icons.inventory_2,
                    label: 'Porta-malas',
                    onTap: () => Navigator.pushNamed(context, '/commands/trunk'),
                  ),
                  GlassIconButton(
                    size: 72,
                    icon: Icons.flash_on,
                    label: 'Faróis',
                    isActive: repo.carStatus.lightsAreOn,
                    onTap: () => repo.toggleLights(),
                  ),
                  GlassIconButton(
                    size: 72,
                    icon: Icons.shield,
                    label: 'Sentinela',
                    isActive: repo.sentinelMode.isActive,
                    onTap: () => Navigator.pushNamed(context, '/sentinel'),
                  ),
                  GlassIconButton(
                    size: 72,
                    icon: Icons.thermostat,
                    label: 'Clima',
                    onTap: () => Navigator.pushNamed(context, '/climate'),
                  ),
                  GlassIconButton(
                    size: 72,
                    icon: Icons.chair,
                    label: 'Bancos',
                    onTap: () => Navigator.pushNamed(context, '/seats'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Status Info
              const Text(
                'Informações',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.route,
                      label: 'Autonomia',
                      value: '${repo.carStatus.range} km',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.speed,
                      label: 'Velocidade',
                      value: '${repo.carStatus.speed.toInt()} km/h',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.thermostat,
                      label: 'Temperatura',
                      value: '${repo.carStatus.temperature.toInt()}°C',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.straighten,
                      label: 'Marcha',
                      value: repo.carStatus.gear,
                    ),
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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
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
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
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
        ],
      ),
    );
  }
}
