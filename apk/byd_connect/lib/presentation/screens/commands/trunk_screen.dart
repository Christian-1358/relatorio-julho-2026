import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/car_repository.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_icon_button.dart';

class TrunkScreen extends StatefulWidget {
  const TrunkScreen({super.key});

  @override
  State<TrunkScreen> createState() => _TrunkScreenState();
}

class _TrunkScreenState extends State<TrunkScreen> {
  bool _isLoading = false;

  Future<void> _setTrunk(int position) async {
    setState(() => _isLoading = true);
    final repo = Provider.of<CarRepository>(context, listen: false);
    await repo.setTrunk(position);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<CarRepository>(context);
    final currentPos = repo.carStatus.trunkPosition;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Porta-malas'),
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Status card
              GlassCard(
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2,
                      color: currentPos > 0 ? AppColors.warning : AppColors.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status do Porta-malas',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            currentPos == 0
                                ? 'Fechado'
                                : '$currentPos% Aberto',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
              ),
              const SizedBox(height: 32),

              // Visual representation
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Trunk back
                      Container(
                        width: 200,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                      ),
                      // Opening lid
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 200,
                        height: currentPos == 0 ? 20 : (currentPos / 100) * 80 + 20,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: Radius.circular(currentPos > 0 ? 0 : 12),
                            bottomRight: Radius.circular(currentPos > 0 ? 0 : 12),
                          ),
                          border: Border.all(color: AppColors.primary, width: 2),
                        ),
                        child: Center(
                          child: Icon(
                            currentPos > 0 ? Icons.arrow_downward : Icons.arrow_upward,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Control buttons
              const Text(
                'Controle do Porta-malas',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GlassIconButton(
                    icon: Icons.close_fullscreen,
                    label: 'Fechar',
                    isActive: currentPos == 0,
                    size: 70,
                    activeColor: AppColors.accent,
                    onTap: _isLoading ? () {} : () => _setTrunk(0),
                  ),
                  GlassIconButton(
                    icon: Icons.vertical_align_bottom,
                    label: '30%',
                    isActive: currentPos == 30,
                    size: 70,
                    activeColor: AppColors.warning,
                    onTap: _isLoading ? () {} : () => _setTrunk(30),
                  ),
                  GlassIconButton(
                    icon: Icons.vertical_align_center,
                    label: '60%',
                    isActive: currentPos == 60,
                    size: 70,
                    activeColor: AppColors.primary,
                    onTap: _isLoading ? () {} : () => _setTrunk(60),
                  ),
                  GlassIconButton(
                    icon: Icons.vertical_align_top,
                    label: '100%',
                    isActive: currentPos == 100,
                    size: 70,
                    activeColor: AppColors.error,
                    onTap: _isLoading ? () {} : () => _setTrunk(100),
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
