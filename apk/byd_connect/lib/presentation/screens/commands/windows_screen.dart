import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/car_repository.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_icon_button.dart';

class WindowsScreen extends StatefulWidget {
  const WindowsScreen({super.key});

  @override
  State<WindowsScreen> createState() => _WindowsScreenState();
}

class _WindowsScreenState extends State<WindowsScreen> {
  bool _isLoading = false;

  Future<void> _setWindows(String state) async {
    setState(() => _isLoading = true);
    final repo = Provider.of<CarRepository>(context, listen: false);
    await repo.setWindows(state);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<CarRepository>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Vidros'),
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
                    const Icon(Icons.window, color: AppColors.primary, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status dos Vidros',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            repo.carStatus.windowsState == 'closed'
                                ? 'Fechados'
                                : repo.carStatus.windowsState == 'half'
                                    ? 'Meia Abertura'
                                    : 'Abertos',
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
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _WindowIndicator(
                        label: 'Dianteiro\nEsquerdo',
                        isOpen: repo.carStatus.windowsState != 'closed',
                      ),
                      _WindowIndicator(
                        label: 'Dianteiro\nDireito',
                        isOpen: repo.carStatus.windowsState != 'closed',
                      ),
                      _WindowIndicator(
                        label: 'Traseiro\nEsquerdo',
                        isOpen: repo.carStatus.windowsState == 'open',
                      ),
                      _WindowIndicator(
                        label: 'Traseiro\nDireito',
                        isOpen: repo.carStatus.windowsState == 'open',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Control buttons
              const Text(
                'Controle dos Vidros',
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
                    icon: Icons.fullscreen,
                    label: 'Fechar',
                    isActive: repo.carStatus.windowsState == 'closed',
                    size: 80,
                    activeColor: AppColors.accent,
                    onTap: _isLoading ? () {} : () => _setWindows('closed'),
                  ),
                  GlassIconButton(
                    icon: Icons.filter_center_focus,
                    label: 'Meia',
                    isActive: repo.carStatus.windowsState == 'half',
                    size: 80,
                    activeColor: AppColors.warning,
                    onTap: _isLoading ? () {} : () => _setWindows('half'),
                  ),
                  GlassIconButton(
                    icon: Icons.fullscreen_exit,
                    label: 'Abrir',
                    isActive: repo.carStatus.windowsState == 'open',
                    size: 80,
                    activeColor: AppColors.error,
                    onTap: _isLoading ? () {} : () => _setWindows('open'),
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

class _WindowIndicator extends StatelessWidget {
  final String label;
  final bool isOpen;

  const _WindowIndicator({
    required this.label,
    required this.isOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 50,
          height: isOpen ? 60 : 30,
          decoration: BoxDecoration(
            color: isOpen
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isOpen ? AppColors.primary : AppColors.glassBorder,
              width: 2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
