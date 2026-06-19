import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/car_repository.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_icon_button.dart';

class ClimateScreen extends StatefulWidget {
  const ClimateScreen({super.key});

  @override
  State<ClimateScreen> createState() => _ClimateScreenState();
}

class _ClimateScreenState extends State<ClimateScreen> {
  bool _isLoading = false;

  Future<void> _toggleAc() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<CarRepository>(context, listen: false);
    await repo.toggleAc();
    setState(() => _isLoading = false);
  }

  Future<void> _setTemp(int temp) async {
    setState(() => _isLoading = true);
    final repo = Provider.of<CarRepository>(context, listen: false);
    await repo.setClimateTemp(temp);
    setState(() => _isLoading = false);
  }

  Future<void> _setFanSpeed(int speed) async {
    setState(() => _isLoading = true);
    final repo = Provider.of<CarRepository>(context, listen: false);
    await repo.setFanSpeed(speed);
    setState(() => _isLoading = false);
  }

  Future<void> _setMode(String mode) async {
    setState(() => _isLoading = true);
    final repo = Provider.of<CarRepository>(context, listen: false);
    await repo.setClimateMode(mode);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<CarRepository>(context);
    final climate = repo.climateSettings;

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
                  const Text(
                    'Climatização',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_isLoading)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Main On/Off Card
              GlassCard(
                backgroundColor: climate.isOn
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.surface,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _toggleAc,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: climate.isOn ? AppColors.primary : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          climate.isOn ? Icons.power : Icons.power_off,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            climate.isOn ? 'Ar Condicionado Ligado' : 'Ar Condicionado Desligado',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (climate.isOn)
                            Text(
                              '${climate.temperature}°C • Ventilação ${climate.fanSpeed}/7',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Temperature Control
              if (climate.isOn) ...[
                const Text(
                  'Temperatura',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GlassIconButton(
                            icon: Icons.remove,
                            label: '',
                            size: 56,
                            onTap: () => _setTemp(climate.temperature - 1),
                          ),
                          Text(
                            '${climate.temperature}°C',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GlassIconButton(
                            icon: Icons.add,
                            label: '',
                            size: 56,
                            onTap: () => _setTemp(climate.temperature + 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Quick temperature buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GlassIconButton(
                      icon: Icons.ac_unit,
                      label: 'Máx Frio',
                      size: 70,
                      activeColor: AppColors.accent,
                      onTap: () => _setTemp(16),
                    ),
                    GlassIconButton(
                      icon: Icons.wb_sunny,
                      label: '22°C',
                      size: 70,
                      activeColor: AppColors.primary,
                      isActive: climate.temperature == 22,
                      onTap: () => _setTemp(22),
                    ),
                    GlassIconButton(
                      icon: Icons.whatshot,
                      label: 'Máx Quente',
                      size: 70,
                      activeColor: AppColors.error,
                      onTap: () => _setTemp(30),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Fan Speed
                const Text(
                  'Velocidade do Ventilador',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (index) {
                          final level = index + 1;
                          final isActive = level <= climate.fanSpeed;
                          return GestureDetector(
                            onTap: () => _setFanSpeed(level),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isActive ? AppColors.primary : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '$level',
                                  style: TextStyle(
                                    color: isActive ? Colors.white : AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('0', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          Text('Ventilação ${climate.fanSpeed}/7',
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                          const Text('7', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Modes
                const Text(
                  'Modo',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GlassIconButton(
                      icon: Icons.ac_unit,
                      label: 'Frio',
                      size: 70,
                      activeColor: AppColors.accent,
                      isActive: climate.mode == 'cooling',
                      onTap: () => _setMode('cooling'),
                    ),
                    GlassIconButton(
                      icon: Icons.wb_sunny,
                      label: 'Aquecer',
                      size: 70,
                      activeColor: AppColors.error,
                      isActive: climate.mode == 'heating',
                      onTap: () => _setMode('heating'),
                    ),
                    GlassIconButton(
                      icon: Icons.autorenew,
                      label: 'Auto',
                      size: 70,
                      activeColor: AppColors.primary,
                      isActive: climate.mode == 'auto',
                      onTap: () => _setMode('auto'),
                    ),
                    GlassIconButton(
                      icon: Icons.door_front_door,
                      label: 'Desembaçar',
                      size: 70,
                      activeColor: AppColors.warning,
                      isActive: climate.mode == 'defrost',
                      onTap: () => _setMode('defrost'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Recirculate
                GlassCard(
                  onTap: () async {
                    final repo = Provider.of<CarRepository>(context, listen: false);
                    await repo.toggleRecirculating();
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: climate.isRecirculating
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.refresh,
                          color: climate.isRecirculating ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Recircular Ar',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Switch(
                        value: climate.isRecirculating,
                        onChanged: (_) async {
                          final repo = Provider.of<CarRepository>(context, listen: false);
                          await repo.toggleRecirculating();
                        },
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Pré-Clima
                GlassCard(
                  onTap: () async {
                    final repo = Provider.of<CarRepository>(context, listen: false);
                    await repo.togglePreClimate();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: climate.preClimateEnabled
                                  ? AppColors.accent.withValues(alpha: 0.2)
                                  : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.schedule,
                              color: climate.preClimateEnabled ? AppColors.accent : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pré-Climatização',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  climate.preClimateEnabled
                                      ? 'Ativado - Liga ${climate.preClimateTime} min antes'
                                      : 'Desativado',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: climate.preClimateEnabled,
                            onChanged: (_) async {
                              final repo = Provider.of<CarRepository>(context, listen: false);
                              await repo.togglePreClimate();
                            },
                            activeColor: AppColors.accent,
                          ),
                        ],
                      ),
                      if (climate.preClimateEnabled) ...[
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.glassBorder),
                        const SizedBox(height: 12),
                        const Text(
                          'Tempo antes:',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _PreClimateButton(
                              label: '5 min',
                              isSelected: climate.preClimateTime == 5,
                              onTap: () async {
                                final repo = Provider.of<CarRepository>(context, listen: false);
                                await repo.setPreClimateTime(5);
                              },
                            ),
                            _PreClimateButton(
                              label: '10 min',
                              isSelected: climate.preClimateTime == 10,
                              onTap: () async {
                                final repo = Provider.of<CarRepository>(context, listen: false);
                                await repo.setPreClimateTime(10);
                              },
                            ),
                            _PreClimateButton(
                              label: '15 min',
                              isSelected: climate.preClimateTime == 15,
                              onTap: () async {
                                final repo = Provider.of<CarRepository>(context, listen: false);
                                await repo.setPreClimateTime(15);
                              },
                            ),
                            _PreClimateButton(
                              label: '30 min',
                              isSelected: climate.preClimateTime == 30,
                              onTap: () async {
                                final repo = Provider.of<CarRepository>(context, listen: false);
                                await repo.setPreClimateTime(30);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info, color: AppColors.accent, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'O ar condicionado ligará ${climate.preClimateTime} minutos antes do seu agendamento.',
                                  style: const TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PreClimateButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PreClimateButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
