import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/car_repository.dart';
import '../../widgets/glass_card.dart';

class CommandsScreen extends StatefulWidget {
  const CommandsScreen({super.key});

  @override
  State<CommandsScreen> createState() => _CommandsScreenState();
}

class _CommandsScreenState extends State<CommandsScreen> {
  bool _isLoading = false;

  Future<void> _toggleLock() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<CarRepository>(context, listen: false);
    await repo.toggleLock();
    setState(() => _isLoading = false);
  }

  Future<void> _toggleLights() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<CarRepository>(context, listen: false);
    await repo.toggleLights();
    setState(() => _isLoading = false);
  }

  Future<void> _honkHorn() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<CarRepository>(context, listen: false);
    await repo.honkHorn();
    setState(() => _isLoading = false);
  }

  Future<void> _toggleEngine() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<CarRepository>(context, listen: false);
    await repo.toggleEngine();
    setState(() => _isLoading = false);
  }

  Future<void> _toggleMirrors() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<CarRepository>(context, listen: false);
    await repo.toggleMirrors();
    setState(() => _isLoading = false);
  }

  Future<void> _findMyCar() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<CarRepository>(context, listen: false);
    await repo.findMyCar();
    setState(() => _isLoading = false);
  }

  Future<void> _toggleBatteryHeater() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<CarRepository>(context, listen: false);
    await repo.toggleBatteryHeater();
    setState(() => _isLoading = false);
  }

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
                'Comandos',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Controle remoto do veículo',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Lock/Unlock Card
              GlassCard(
                backgroundColor: repo.carStatus.isLocked
                    ? AppColors.locked.withValues(alpha: 0.1)
                    : AppColors.unlocked.withValues(alpha: 0.1),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              repo.carStatus.isLocked ? Icons.lock : Icons.lock_open,
                              color: repo.carStatus.isLocked
                                  ? AppColors.locked
                                  : AppColors.unlocked,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Trava Central',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  repo.carStatus.isLocked ? 'Veículo Travado' : 'Veículo Destravado',
                                  style: TextStyle(
                                    color: repo.carStatus.isLocked
                                        ? AppColors.locked
                                        : AppColors.unlocked,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (_isLoading)
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          GestureDetector(
                            onTap: _toggleLock,
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: repo.carStatus.isLocked
                                    ? AppColors.locked
                                    : AppColors.unlocked,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                repo.carStatus.isLocked ? Icons.lock : Icons.lock_open,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.cloud, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        const Text(
                          'Sincronizado via nuvem',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Windows
              const Text(
                'Vidros',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                onTap: () => Navigator.pushNamed(context, '/commands/windows'),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.window, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Controle de Vidros',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            repo.carStatus.windowsState == 'closed'
                                ? 'Fechados'
                                : repo.carStatus.windowsState == 'half'
                                    ? 'Meia Abertura'
                                    : 'Abertos',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Trunk
              const Text(
                'Porta-malas',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                onTap: () => Navigator.pushNamed(context, '/commands/trunk'),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.inventory_2, color: AppColors.warning),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Porta-malas',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            repo.carStatus.trunkPosition == 0
                                ? 'Fechado'
                                : '${repo.carStatus.trunkPosition}% aberto',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Commands Grid
              const Text(
                'Comandos Rápidos',
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
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9,
                children: [
                  _QuickCommandCard(
                    icon: Icons.volume_up,
                    label: 'Buzina',
                    color: AppColors.warning,
                    onTap: _honkHorn,
                  ),
                  _QuickCommandCard(
                    icon: Icons.power_settings_new,
                    label: 'Partida Remota',
                    color: repo.carStatus.engineRunning
                        ? AppColors.accent
                        : AppColors.textSecondary,
                    isActive: repo.carStatus.engineRunning,
                    onTap: _toggleEngine,
                  ),
                  _QuickCommandCard(
                    icon: Icons.engineering,
                    label: 'Start/Stop',
                    color: repo.carStatus.engineRunning
                        ? AppColors.accent
                        : AppColors.textSecondary,
                    isActive: repo.carStatus.engineRunning,
                    onTap: _toggleEngine,
                  ),
                  _QuickCommandCard(
                    icon: repo.carStatus.mirrorsFolded
                        ? Icons.sync
                        : Icons.sync,
                    label: repo.carStatus.mirrorsFolded ? 'Desdobrar' : 'Dobrar Espelhos',
                    color: repo.carStatus.mirrorsFolded
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    isActive: repo.carStatus.mirrorsFolded,
                    onTap: _toggleMirrors,
                  ),
                  _QuickCommandCard(
                    icon: Icons.location_on,
                    label: 'Localizar',
                    color: repo.carStatus.findMyCarActive
                        ? AppColors.accent
                        : AppColors.warning,
                    isActive: repo.carStatus.findMyCarActive,
                    onTap: _findMyCar,
                  ),
                  _QuickCommandCard(
                    icon: Icons.battery_charging_full,
                    label: 'Aquecedor',
                    color: repo.carStatus.batteryHeaterOn
                        ? AppColors.accent
                        : AppColors.textSecondary,
                    isActive: repo.carStatus.batteryHeaterOn,
                    onTap: _toggleBatteryHeater,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Lights
              const Text(
                'Luzes',
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
                        color: repo.carStatus.lightsAreOn
                            ? AppColors.warning.withValues(alpha: 0.2)
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.highlight,
                        color: repo.carStatus.lightsAreOn
                            ? AppColors.warning
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Faróis',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            repo.carStatus.lightsAreOn ? 'Ligados' : 'Desligados',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: repo.carStatus.lightsAreOn,
                      onChanged: (_) => _toggleLights(),
                      activeColor: AppColors.warning,
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

// Card para comandos rápidos com design moderno
class _QuickCommandCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isActive;

  const _QuickCommandCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isActive = false,
  });

  @override
  State<_QuickCommandCard> createState() => _QuickCommandCardState();
}

class _QuickCommandCardState extends State<_QuickCommandCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isActive
                  ? [
                      widget.color.withValues(alpha: _isPressed ? 0.5 : 0.4),
                      widget.color.withValues(alpha: _isPressed ? 0.3 : 0.2),
                    ]
                  : [
                      AppColors.glassBackground,
                      AppColors.glassBackground.withValues(alpha: 0.5),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isActive
                  ? widget.color.withValues(alpha: 0.8)
                  : AppColors.glassBorder,
              width: widget.isActive ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.05),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
              if (widget.isActive)
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isActive
                      ? widget.color.withValues(alpha: 0.3)
                      : widget.color.withValues(alpha: 0.1),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.isActive ? widget.color : AppColors.textSecondary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.isActive ? widget.color : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
