import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/car_repository.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<CarRepository>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A), Color(0xFF0A0A0C)],
          ),
        ),
        child: Stack(
          children: [
            // Background blur effects
            _BackgroundEffects(),
            // Main content
            SafeArea(
              bottom: false,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Header
                      SliverToBoxAdapter(child: _LiquidGlassHeader(carName: repo.carStatus.carModel)),

                      // Hero - Car Image & Status
                      SliverToBoxAdapter(child: _HeroSection(repo: repo)),

                      // Status Cards Grid
                      SliverToBoxAdapter(child: _StatusCardsGrid(repo: repo)),

                      // Controls Grid
                      SliverToBoxAdapter(child: _ControlsGrid(repo: repo)),

                      // Map Section
                      SliverToBoxAdapter(child: _LiquidMapSection(repo: repo)),

                      // Diagnostics
                      SliverToBoxAdapter(child: _DiagnosticsSection(repo: repo)),

                      // Bottom spacing for nav bar
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _LiquidGlassNavBar(currentIndex: 0),
    );
  }
}

// ============ BACKGROUND EFFECTS ============
class _BackgroundEffects extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top left glow
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                const Color(0xFF3A7BD5).withValues(alpha: 0.15),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        // Bottom right glow
        Positioned(
          bottom: -50,
          right: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                const Color(0xFF30D158).withValues(alpha: 0.1),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        // Center glow
        Positioned(
          top: 200,
          right: -150,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                const Color(0xFFFF9F0A).withValues(alpha: 0.08),
                Colors.transparent,
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

// ============ LIQUID GLASS HEADER ============
class _LiquidGlassHeader extends StatelessWidget {
  final String carName;

  const _LiquidGlassHeader({required this.carName});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            border: Border(
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
          ),
          child: Row(
            children: [
              // Profile avatar
              _GlassCircle(size: 44, child: Icon(Icons.person, color: Colors.white.withValues(alpha: 0.9), size: 22)),
              const SizedBox(width: 14),
              // Car info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      carName,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF30D158), shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text('Conectado • Atualizado agora', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              // Notification bell
              _GlassIconButton(icon: Icons.notifications_none, onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ GLASS WIDGETS ============
class _GlassCircle extends StatelessWidget {
  final Widget child;
  final double size;
  final Color? backgroundColor;
  final double blur;

  const _GlassCircle({required this.child, this.size = 44, this.backgroundColor, this.blur = 20});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor ?? Colors.white.withValues(alpha: 0.1),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final Color? activeColor;

  const _GlassIconButton({required this.icon, required this.onTap, this.isActive = false, this.activeColor});

  @override
  State<_GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<_GlassIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.isActive
              ? (widget.activeColor ?? const Color(0xFF3A7BD5)).withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: _isPressed ? 0.15 : 0.08),
          border: Border.all(
            color: widget.isActive
                ? (widget.activeColor ?? const Color(0xFF3A7BD5)).withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: widget.isActive
              ? [
                  BoxShadow(
                    color: (widget.activeColor ?? const Color(0xFF3A7BD5)).withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Icon(
            widget.icon,
            color: widget.isActive
                ? (widget.activeColor ?? const Color(0xFF3A7BD5))
                : Colors.white.withValues(alpha: 0.9),
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _LiquidGlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;
  final Color? tintColor;
  final VoidCallback? onTap;

  const _LiquidGlassCard({
    required this.child,
    this.padding,
    this.borderRadius = 24,
    this.tintColor,
    this.onTap,
  });

  @override
  State<_LiquidGlassCard> createState() => _LiquidGlassCardState();
}

class _LiquidGlassCardState extends State<_LiquidGlassCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final tint = widget.tintColor ?? Colors.white;

    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onTap != null ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              padding: widget.padding ?? const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    tint.withValues(alpha: 0.15),
                    tint.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: tint.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

// ============ HERO SECTION ============
class _HeroSection extends StatelessWidget {
  final CarRepository repo;

  const _HeroSection({required this.repo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Car 3D Image with status overlay
          Stack(
            alignment: Alignment.center,
            children: [
              // Glow effect behind car
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      repo.carStatus.isLocked
                          ? const Color(0xFF3A7BD5).withValues(alpha: 0.2)
                          : const Color(0xFF30D158).withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // Car image
              Image.network(
                'https://images.unsplash.com/photo-1619767886558-efdc259cde1a?w=600&q=90',
                height: 180,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  width: 280,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.directions_car, size: 80, color: Colors.white.withValues(alpha: 0.3)),
                ),
              ),
              // Status badge
              Positioned(
                top: 10,
                right: 10,
                child: _GlassCircle(
                  size: 52,
                  backgroundColor: repo.carStatus.isLocked
                      ? const Color(0xFF3A7BD5).withValues(alpha: 0.3)
                      : const Color(0xFF30D158).withValues(alpha: 0.3),
                  child: Icon(
                    repo.carStatus.isLocked ? Icons.lock : Icons.lock_open,
                    color: repo.carStatus.isLocked ? const Color(0xFF3A7BD5) : const Color(0xFF30D158),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Overall status bar
          _LiquidGlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            tintColor: repo.carStatus.batteryLevel > 50 ? const Color(0xFF30D158) : const Color(0xFFFF9F0A),
            child: Row(
              children: [
                _StatusIndicator(
                  icon: Icons.shield,
                  label: repo.carStatus.isLocked ? 'Protegido' : 'Desprotegido',
                  color: repo.carStatus.isLocked ? const Color(0xFF3A7BD5) : const Color(0xFFFF9F0A),
                ),
                const SizedBox(width: 24),
                _StatusIndicator(
                  icon: Icons.bolt,
                  label: '${repo.carStatus.batteryLevel}%',
                  color: repo.carStatus.batteryLevel > 50
                      ? const Color(0xFF30D158)
                      : repo.carStatus.batteryLevel > 20
                          ? const Color(0xFFFF9F0A)
                          : const Color(0xFFFF3B30),
                ),
                const SizedBox(width: 24),
                _StatusIndicator(
                  icon: Icons.route,
                  label: '${repo.carStatus.range} km',
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: const Color(0xFF30D158), size: 16),
                      const SizedBox(width: 6),
                      const Text('Excelente', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
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

class _StatusIndicator extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusIndicator({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ============ STATUS CARDS GRID ============
class _StatusCardsGrid extends StatelessWidget {
  final CarRepository repo;

  const _StatusCardsGrid({required this.repo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Status do Veículo', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _StatusCard(icon: Icons.battery_full, label: 'Bateria', value: '${repo.carStatus.batteryLevel}%', color: const Color(0xFF30D158))),
              const SizedBox(width: 12),
              Expanded(child: _StatusCard(icon: Icons.route, label: 'Autonomia', value: '${repo.carStatus.range} km', color: const Color(0xFF5E5CE6))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _StatusCard(icon: Icons.thermostat, label: 'Temperatura', value: '${repo.carStatus.temperature.toInt()}°C', color: const Color(0xFFFF9F0A))),
              const SizedBox(width: 12),
              Expanded(child: _StatusCard(icon: Icons.speed, label: 'Velocidade', value: '${repo.carStatus.speed.toInt()} km/h', color: const Color(0xFF3A7BD5))),
            ],
          ),
          const SizedBox(height: 12),
          _LiquidGlassCard(
            padding: const EdgeInsets.all(18),
            tintColor: const Color(0xFF3A7BD5),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A7BD5).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.location_on, color: Color(0xFF3A7BD5), size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Localização', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('São Paulo, SP - Brasil', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatusCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return _LiquidGlassCard(
      padding: const EdgeInsets.all(18),
      tintColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 14),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
        ],
      ),
    );
  }
}

// ============ CONTROLS GRID ============
class _ControlsGrid extends StatelessWidget {
  final CarRepository repo;

  const _ControlsGrid({required this.repo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Controles Rápidos', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
            children: [
              _ControlTile(
                icon: repo.carStatus.isLocked ? Icons.lock : Icons.lock_open,
                label: repo.carStatus.isLocked ? 'Travar' : 'Destravar',
                color: const Color(0xFF3A7BD5),
                isActive: repo.carStatus.isLocked,
                onTap: () => repo.toggleLock(),
              ),
              _ControlTile(
                icon: Icons.highlight,
                label: 'Faróis',
                color: const Color(0xFFFFCC00),
                isActive: repo.carStatus.lightsAreOn,
                onTap: () => repo.toggleLights(),
              ),
              _ControlTile(icon: Icons.volume_up, label: 'Buzina', color: const Color(0xFFFF9F0A), onTap: () {}),
              _ControlTile(icon: Icons.ac_unit, label: 'Climatização', color: const Color(0xFF5E5CE6), onTap: () {}),
              _ControlTile(icon: Icons.flash_on, label: 'Partida', color: const Color(0xFF30D158), onTap: () {}),
              _ControlTile(icon: Icons.location_searching, label: 'Localizar', color: const Color(0xFF3A7BD5), onTap: () {}),
              _ControlTile(icon: Icons.battery_charging_full, label: 'Carregar', color: const Color(0xFF30D158), isActive: false, onTap: () {}),
              _ControlTile(icon: Icons.more_horiz, label: 'Mais', color: Colors.white.withValues(alpha: 0.5), onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _ControlTile({
    required this.icon,
    required this.label,
    required this.color,
    this.isActive = false,
    required this.onTap,
  });

  @override
  State<_ControlTile> createState() => _ControlTileState();
}

class _ControlTileState extends State<_ControlTile> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isPressed ? 0.93 : 1.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.isActive
                      ? [widget.color.withValues(alpha: 0.35), widget.color.withValues(alpha: 0.15)]
                      : [Colors.white.withValues(alpha: 0.12), Colors.white.withValues(alpha: 0.05)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: widget.isActive ? widget.color.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.1),
                  width: 1.5,
                ),
                boxShadow: widget.isActive
                    ? [
                        BoxShadow(color: widget.color.withValues(alpha: 0.25), blurRadius: 20, spreadRadius: 0),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isActive
                          ? widget.color.withValues(alpha: 0.25)
                          : Colors.white.withValues(alpha: 0.1),
                      boxShadow: widget.isActive
                          ? [BoxShadow(color: widget.color.withValues(alpha: 0.3), blurRadius: 12)]
                          : null,
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.isActive ? widget.color : Colors.white.withValues(alpha: 0.9),
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.isActive ? widget.color : Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============ LIQUID MAP SECTION ============
class _LiquidMapSection extends StatelessWidget {
  final CarRepository repo;

  const _LiquidMapSection({required this.repo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mapa em Tempo Real', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1A3A5C).withValues(alpha: 0.4),
                      const Color(0xFF0D1B2A).withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
                ),
                child: Stack(
                  children: [
                    // Map background simulation
                    CustomPaint(size: const Size(double.infinity, 220), painter: _MapGridPainter()),
                    // Center location marker
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF3A7BD5).withValues(alpha: 0.3),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFF3A7BD5).withValues(alpha: 0.4), blurRadius: 30),
                              ],
                            ),
                            child: const Icon(Icons.directions_car, color: Colors.white, size: 32),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('Localização em tempo real', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                    // Map info overlay
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: _LiquidGlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        borderRadius: 16,
                        tintColor: const Color(0xFF30D158),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF30D158), shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text('GPS Ativo', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: _GlassIconButton(
                        icon: Icons.fullscreen,
                        onTap: () {},
                        activeColor: const Color(0xFF3A7BD5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Vertical lines
    for (var i = 0; i <= 10; i++) {
      final x = size.width * (i / 10);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    // Horizontal lines
    for (var i = 0; i <= 6; i++) {
      final y = size.height * (i / 6);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============ DIAGNOSTICS SECTION ============
class _DiagnosticsSection extends StatelessWidget {
  final CarRepository repo;

  const _DiagnosticsSection({required this.repo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Diagnóstico', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
          const SizedBox(height: 14),
          _LiquidGlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _DiagnosticRow(icon: Icons.settings, label: 'Motor', status: 'Operacional', color: const Color(0xFF30D158), isGood: true),
                const Divider(color: Color(0x20FFFFFF), height: 24),
                _DiagnosticRow(icon: Icons.tire_repair, label: 'Pneus', status: 'Pressão OK', color: const Color(0xFF30D158), isGood: true),
                const Divider(color: Color(0x20FFFFFF), height: 24),
                _DiagnosticRow(icon: Icons.handyman, label: 'Freios', status: '95% eficiência', color: const Color(0xFFFFCC00), isGood: true),
                const Divider(color: Color(0x20FFFFFF), height: 24),
                _DiagnosticRow(
                  icon: Icons.battery_full,
                  label: 'Bateria 12V',
                  status: repo.carStatus.batteryLevel < 30 ? 'Atenção' : 'Excelente',
                  color: repo.carStatus.batteryLevel < 30 ? const Color(0xFFFF3B30) : const Color(0xFF30D158),
                  isGood: repo.carStatus.batteryLevel >= 30,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagnosticRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String status;
  final Color color;
  final bool isGood;

  const _DiagnosticRow({required this.icon, required this.label, required this.status, required this.color, required this.isGood});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(status, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Icon(isGood ? Icons.check_circle : Icons.warning, color: color, size: 24),
      ],
    );
  }
}

// ============ LIQUID GLASS NAV BAR ============
class _LiquidGlassNavBar extends StatelessWidget {
  final int currentIndex;

  const _LiquidGlassNavBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 0.5)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavBarItem(icon: Icons.directions_car, label: 'Veículo', isActive: currentIndex == 0, color: const Color(0xFF3A7BD5)),
                  _NavBarItem(icon: Icons.location_on, label: 'Localização', isActive: currentIndex == 1, color: const Color(0xFF30D158)),
                  _NavBarItem(icon: Icons.bolt, label: 'Automação', isActive: currentIndex == 2, color: const Color(0xFFFF9F0A)),
                  _NavBarItem(icon: Icons.build, label: 'Diagnóstico', isActive: currentIndex == 3, color: const Color(0xFFFF3B30)),
                  _NavBarItem(icon: Icons.person, label: 'Perfil', isActive: currentIndex == 4, color: Colors.white.withValues(alpha: 0.7)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color color;

  const _NavBarItem({required this.icon, required this.label, required this.isActive, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? color : Colors.white.withValues(alpha: 0.4),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? color : Colors.white.withValues(alpha: 0.4),
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
