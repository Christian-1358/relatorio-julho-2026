import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/car_repository.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_icon_button.dart';

class SeatsScreen extends StatefulWidget {
  const SeatsScreen({super.key});

  @override
  State<SeatsScreen> createState() => _SeatsScreenState();
}

class _SeatsScreenState extends State<SeatsScreen> {
  bool _isLoading = false;

  Future<void> _setDriverHeat(int level) async {
    setState(() => _isLoading = true);
    final repo = Provider.of<CarRepository>(context, listen: false);
    await repo.setDriverHeat(level);
    setState(() => _isLoading = false);
  }

  Future<void> _setDriverVent(int level) async {
    setState(() => _isLoading = true);
    final repo = Provider.of<CarRepository>(context, listen: false);
    await repo.setDriverVent(level);
    setState(() => _isLoading = false);
  }

  Future<void> _setPassengerHeat(int level) async {
    setState(() => _isLoading = true);
    final repo = Provider.of<CarRepository>(context, listen: false);
    await repo.setPassengerHeat(level);
    setState(() => _isLoading = false);
  }

  Future<void> _setPassengerVent(int level) async {
    setState(() => _isLoading = true);
    final repo = Provider.of<CarRepository>(context, listen: false);
    await repo.setPassengerVent(level);
    setState(() => _isLoading = false);
  }

  Future<void> _toggleSeatSafeMode() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<CarRepository>(context, listen: false);
    await repo.toggleSeatSafeMode();
    setState(() => _isLoading = false);
  }

  Future<void> _saveSeatMemory(int memory) async {
    setState(() => _isLoading = true);
    final repo = Provider.of<CarRepository>(context, listen: false);
    await repo.saveSeatMemory(memory);
    setState(() => _isLoading = false);
  }

  Future<void> _recallSeatMemory(int memory) async {
    setState(() => _isLoading = true);
    final repo = Provider.of<CarRepository>(context, listen: false);
    await repo.recallSeatMemory(memory);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<CarRepository>(context);
    final seats = repo.seatSettings;

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
                    'Bancos',
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

              // Driver Seat
              const Text(
                'Banco do Motorista',
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
                      children: [
                        // Seat icon
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.chair, color: AppColors.textSecondary, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Aquecimento',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: List.generate(4, (index) {
                                  final level = index;
                                  final isActive = level <= seats.driverHeatLevel;
                                  return GestureDetector(
                                    onTap: () => _setDriverHeat(level),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      margin: const EdgeInsets.only(right: 4),
                                      decoration: BoxDecoration(
                                        color: isActive ? AppColors.error : AppColors.surfaceLight,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$level',
                                          style: TextStyle(
                                            color: isActive ? Colors.white : AppColors.textSecondary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const SizedBox(width: 76),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ventilação',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: List.generate(4, (index) {
                                  final level = index;
                                  final isActive = level <= seats.driverVentLevel;
                                  return GestureDetector(
                                    onTap: () => _setDriverVent(level),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      margin: const EdgeInsets.only(right: 4),
                                      decoration: BoxDecoration(
                                        color: isActive ? AppColors.accent : AppColors.surfaceLight,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$level',
                                          style: TextStyle(
                                            color: isActive ? Colors.white : AppColors.textSecondary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Passenger Seat
              const Text(
                'Banco do Passageiro',
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
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.chair_alt, color: AppColors.textSecondary, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Aquecimento',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: List.generate(4, (index) {
                                  final level = index;
                                  final isActive = level <= seats.passengerHeatLevel;
                                  return GestureDetector(
                                    onTap: () => _setPassengerHeat(level),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      margin: const EdgeInsets.only(right: 4),
                                      decoration: BoxDecoration(
                                        color: isActive ? AppColors.error : AppColors.surfaceLight,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$level',
                                          style: TextStyle(
                                            color: isActive ? Colors.white : AppColors.textSecondary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const SizedBox(width: 76),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ventilação',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: List.generate(4, (index) {
                                  final level = index;
                                  final isActive = level <= seats.passengerVentLevel;
                                  return GestureDetector(
                                    onTap: () => _setPassengerVent(level),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      margin: const EdgeInsets.only(right: 4),
                                      decoration: BoxDecoration(
                                        color: isActive ? AppColors.accent : AppColors.surfaceLight,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$level',
                                          style: TextStyle(
                                            color: isActive ? Colors.white : AppColors.textSecondary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Position & Memory
              const Text(
                'Posição e Memórias',
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
                    child: GestureDetector(
                      onTap: _toggleSeatSafeMode,
                      child: GlassCard(
                        backgroundColor: seats.seatPosition == 'safe'
                            ? AppColors.warning.withValues(alpha: 0.15)
                            : AppColors.surface,
                        child: Column(
                          children: [
                            Icon(
                              Icons.lock,
                              color: seats.seatPosition == 'safe'
                                  ? AppColors.warning
                                  : AppColors.textSecondary,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Seguro pra Mover',
                              style: TextStyle(
                                color: seats.seatPosition == 'safe'
                                    ? AppColors.warning
                                    : AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: seats.seatPosition == 'safe'
                                    ? AppColors.warning.withValues(alpha: 0.2)
                                    : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                seats.seatPosition == 'safe' ? 'ATIVADO' : 'Desativado',
                                style: TextStyle(
                                  color: seats.seatPosition == 'safe'
                                      ? AppColors.warning
                                      : AppColors.textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GlassCard(
                      child: Column(
                        children: [
                          const Text(
                            'Memórias',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(3, (index) {
                              final mem = index + 1;
                              final isActive = seats.memoryPosition == mem;
                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: () => _recallSeatMemory(mem),
                                    onLongPress: () => _saveSeatMemory(mem),
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? AppColors.primary
                                            : AppColors.surfaceLight,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isActive
                                              ? AppColors.primary
                                              : AppColors.glassBorder,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'M$mem',
                                          style: TextStyle(
                                            color: isActive
                                                ? Colors.white
                                                : AppColors.textSecondary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Toque pra lembrar • Segure pra salvar',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
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
