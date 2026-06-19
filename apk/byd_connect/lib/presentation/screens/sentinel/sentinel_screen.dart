import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/car_repository.dart';
import '../../../data/models/sentinel_event.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_icon_button.dart';

class SentinelScreen extends StatefulWidget {
  const SentinelScreen({super.key});

  @override
  State<SentinelScreen> createState() => _SentinelScreenState();
}

class _SentinelScreenState extends State<SentinelScreen> {
  Future<void> _setMode(String mode) async {
    final repo = Provider.of<CarRepository>(context, listen: false);
    await repo.setSentinelMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<CarRepository>(context);
    final mode = repo.sentinelMode;
    final events = repo.sentinelEvents;

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
                'Sentinela',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Proteção inteligente do veículo',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Mode Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ModeCard(
                    icon: Icons.shield,
                    label: 'Armar',
                    isActive: mode.mode == 'armed',
                    color: AppColors.error,
                    onTap: () => _setMode('armed'),
                  ),
                  _ModeCard(
                    icon: Icons.shield_outlined,
                    label: 'Desarmar',
                    isActive: mode.mode == 'disarmed',
                    color: AppColors.textSecondary,
                    onTap: () => _setMode('disarmed'),
                  ),
                  _ModeCard(
                    icon: Icons.auto_awesome,
                    label: 'Auto',
                    isActive: mode.mode == 'auto',
                    color: AppColors.accent,
                    onTap: () => _setMode('auto'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Status Card
              GlassCard(
                backgroundColor: mode.isActive
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.surface,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: mode.isActive
                            ? AppColors.error.withValues(alpha: 0.2)
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        mode.isActive ? Icons.security : Icons.shield_outlined,
                        color: mode.isActive ? AppColors.error : AppColors.textSecondary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mode.isActive ? 'Modo Ativo' : 'Modo Inativo',
                            style: TextStyle(
                              color: mode.isActive ? AppColors.error : AppColors.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            mode.isActive
                                ? 'Proteção armada e monitoramento ativo'
                                : 'Proteção desativada',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: mode.isActive ? AppColors.error : AppColors.offline,
                        boxShadow: mode.isActive
                            ? [
                                BoxShadow(
                                  color: AppColors.error.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Clips Gallery
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Galeria de Clipes',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Ver todos',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(
                              Icons.videocam,
                              color: AppColors.textSecondary.withValues(alpha: 0.5),
                              size: 32,
                            ),
                          ),
                          Positioned(
                            left: 8,
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${index + 1}:32',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Recent Events
              const Text(
                'Eventos Recentes',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...events.map((event) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _EventCard(event: event),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? color : AppColors.glassBorder,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isActive ? color : AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? color : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final SentinelEvent event;

  const _EventCard({required this.event});

  IconData get _icon {
    switch (event.type) {
      case 'motion':
        return Icons.directions_run;
      case 'door':
        return Icons.door_front_door;
      case 'alarm':
        return Icons.notifications_active;
      default:
        return Icons.event;
    }
  }

  Color get _color {
    switch (event.type) {
      case 'motion':
        return AppColors.warning;
      case 'door':
        return AppColors.primary;
      case 'alarm':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min atrás';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h atrás';
    } else {
      return '${diff.inDays}d atrás';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon, color: _color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.description,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatTime(event.timestamp),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (!event.isRead)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }
}
