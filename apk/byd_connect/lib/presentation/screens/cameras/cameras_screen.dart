import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/glass_card.dart';

class CamerasScreen extends StatefulWidget {
  const CamerasScreen({super.key});

  @override
  State<CamerasScreen> createState() => _CamerasScreenState();
}

class _CamerasScreenState extends State<CamerasScreen> with TickerProviderStateMixin {
  int _selectedCamera = 0;
  int _viewMode = 0; // 0 = single, 1 = quad grid
  double _viewRotation = 0;
  double _viewZoom = 1.0;
  double _brightness = 0.0;
  double _contrast = 1.0;
  double _saturation = 1.0;
  bool _nightMode = false;
  bool _guideLines = false;
  bool _isRecording = false;
  bool _isFullScreen = false;
  bool _showControls = true;
  bool _ipCameraEnabled = false;
  String _ipCameraUrl = 'rtsp://192.168.1.100:554/stream';
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  late AnimationController _controlsAnimController;
  late Animation<double> _controlsAnimation;

  @override
  void initState() {
    super.initState();
    _controlsAnimController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _controlsAnimation = CurvedAnimation(
      parent: _controlsAnimController,
      curve: Curves.easeInOut,
    );
    _controlsAnimController.forward();
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _controlsAnimController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (_isRecording) {
        _recordingSeconds = 0;
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() => _recordingSeconds++);
        });
      } else {
        _recordingTimer?.cancel();
        _recordingTimer = null;
      }
    });
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _takePhoto() async {
    // Simulated photo capture - em produção usaria package:camera
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.camera_alt, color: Colors.white),
            const SizedBox(width: 12),
            Text('Foto capturada! (simulado)'),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _toggleFullScreen() {
    setState(() => _isFullScreen = !_isFullScreen);
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullScreen) {
      return _buildFullScreenView();
    }
    return _buildNormalView();
  }

  Widget _buildNormalView() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _buildCameraView(),
            const SizedBox(height: 16),
            _buildCameraSelector(),
            const SizedBox(height: 12),
            _buildQuickControls(),
            const SizedBox(height: 12),
            _buildImageControls(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFullScreenView() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        onDoubleTap: _toggleFullScreen,
        child: Stack(
          children: [
            // Camera view
            Positioned.fill(
              child: _viewMode == 1 ? _buildQuadGrid() : _buildCameraView(),
            ),
            // Controls overlay
            if (_showControls)
              FadeTransition(
                opacity: _controlsAnimation,
                child: SafeArea(
                  child: Column(
                    children: [
                      _buildFullScreenHeader(),
                      const Expanded(child: SizedBox()),
                      _buildFullScreenBottomControls(),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Câmeras',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              // View mode toggle
              _HeaderButton(
                icon: _viewMode == 0 ? Icons.grid_view : Icons.videocam,
                label: _viewMode == 0 ? 'Grid' : 'Única',
                onTap: () => setState(() => _viewMode = _viewMode == 0 ? 1 : 0),
              ),
              const SizedBox(width: 8),
              // Fullscreen toggle
              _HeaderButton(
                icon: Icons.fullscreen,
                label: 'Tela Cheia',
                onTap: _toggleFullScreen,
              ),
              const SizedBox(width: 8),
              // IP Camera toggle
              _HeaderButton(
                icon: Icons.cloud,
                label: 'IP',
                isActive: _ipCameraEnabled,
                onTap: _showIpCameraDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFullScreenHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black54, Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
            onPressed: _toggleFullScreen,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getCameraLabel(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_isRecording) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.fiber_manual_record, color: Colors.white, size: 12),
                  const SizedBox(width: 6),
                  Text(
                    _formatDuration(_recordingSeconds),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFullScreenBottomControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black54, Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Guide lines toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ControlChip(
                icon: Icons.timeline,
                label: 'Linhas',
                isActive: _guideLines,
                onTap: () => setState(() => _guideLines = !_guideLines),
              ),
              const SizedBox(width: 12),
              _ControlChip(
                icon: Icons.nightlight,
                label: 'Noite',
                isActive: _nightMode,
                onTap: () => setState(() => _nightMode = !_nightMode),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Main controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _CircleButton(
                icon: Icons.photo_camera,
                size: 50,
                onTap: _takePhoto,
              ),
              _CircleButton(
                icon: _isRecording ? Icons.stop : Icons.fiber_manual_record,
                size: 70,
                color: _isRecording ? AppColors.error : Colors.white,
                onTap: _toggleRecording,
              ),
              _CircleButton(
                icon: Icons.videocam,
                size: 50,
                onTap: () {
                  // Switch to next camera
                  setState(() {
                    _selectedCamera = (_selectedCamera + 1) % 4;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    if (_viewMode == 1) {
      return _buildQuadGrid();
    }
    if (_selectedCamera == 4) {
      return _build360View();
    }
    return _buildSingleCameraView(_selectedCamera);
  }

  Widget _buildQuadGrid() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 16 / 10,
          children: [
            _buildCameraTile(0, 'Frente'),
            _buildCameraTile(1, 'Traseira'),
            _buildCameraTile(2, 'Lateral D'),
            _buildCameraTile(3, 'Lateral E'),
          ],
        ),
      ),
    );
  }

  Widget _build360View() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // 360 View Interativo
            Expanded(
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _viewRotation += details.delta.dx * 0.01;
                    _viewZoom = (_viewZoom - details.delta.dy * 0.005).clamp(0.5, 2.0);
                  });
                },
                onScaleUpdate: (details) {
                  setState(() {
                    _viewZoom = (_viewZoom * details.scale).clamp(0.5, 2.0);
                  });
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Carro 360 com rotação
                      Transform.rotate(
                        angle: _viewRotation,
                        child: Transform.scale(
                          scale: _viewZoom,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.4),
                                  AppColors.accent.withValues(alpha: 0.1),
                                ],
                              ),
                              border: Border.all(color: AppColors.primary, width: 3),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Ícone do carro
                                Icon(
                                  Icons.directions_car,
                                  size: 100,
                                  color: AppColors.primary,
                                ),
                                // Indicadores de direção
                                Positioned(
                                  top: 10,
                                  child: _DirectionMarker(label: 'Frente', isActive: _viewRotation.abs() < 0.3),
                                ),
                                Positioned(
                                  bottom: 10,
                                  child: Transform.rotate(
                                    angle: 3.14159,
                                    child: _DirectionMarker(label: 'Trás', isActive: (_viewRotation.abs() - 3.14).abs() < 0.3),
                                  ),
                                ),
                                Positioned(
                                  left: 10,
                                  child: Transform.rotate(
                                    angle: -1.5708,
                                    child: _DirectionMarker(label: 'Lat E', isActive: (_viewRotation - 1.57).abs() < 0.3 || (_viewRotation + 1.57).abs() < 0.3),
                                  ),
                                ),
                                Positioned(
                                  right: 10,
                                  child: Transform.rotate(
                                    angle: 1.5708,
                                    child: _DirectionMarker(label: 'Lat D', isActive: (_viewRotation - 1.57).abs() < 0.3 || (_viewRotation + 1.57).abs() < 0.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Instruções
                      Positioned(
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.touch_app, size: 16, color: Colors.white70),
                              const SizedBox(width: 8),
                              Text(
                                'Arraste para girar • Pinça para zoom (${(_viewZoom * 100).toInt()}%)',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Indicador de zoom
                      Positioned(
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '360° • ${(_viewZoom * 100).toInt()}%',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 6 botões de vista rápida
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ViewAngleButton(label: 'Frente', icon: Icons.arrow_upward, isActive: _viewRotation.abs() < 0.3, onTap: () => setState(() => _viewRotation = 0)),
                _ViewAngleButton(label: 'Diag. D', icon: Icons.arrow_forward, isActive: (_viewRotation - 0.78).abs() < 0.3, onTap: () => setState(() => _viewRotation = 0.78)),
                _ViewAngleButton(label: 'Lateral', icon: Icons.arrow_forward, isActive: (_viewRotation - 1.57).abs() < 0.3 || (_viewRotation + 1.57).abs() < 0.3, onTap: () => setState(() => _viewRotation = 1.57)),
                _ViewAngleButton(label: 'Diag. E', icon: Icons.arrow_back, isActive: (_viewRotation + 0.78).abs() < 0.3 || (_viewRotation - 2.36).abs() < 0.3, onTap: () => setState(() => _viewRotation = -0.78)),
                _ViewAngleButton(label: 'Tras.', icon: Icons.arrow_downward, isActive: (_viewRotation.abs() - 3.14).abs() < 0.3, onTap: () => setState(() => _viewRotation = 3.14)),
                _ViewAngleButton(label: 'Cima', icon: Icons.keyboard_double_arrow_up, isActive: false, onTap: () => setState(() => _viewZoom = 0.7)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraTile(int index, String label) {
    return GestureDetector(
      onTap: () => setState(() => _selectedCamera = index),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedCamera == index ? AppColors.primary : AppColors.glassBorder,
            width: _selectedCamera == index ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            // Camera feed simulation
            Center(
              child: Icon(
                Icons.videocam,
                size: 40,
                color: _nightMode
                    ? Colors.blue.shade200
                    : AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
            // Label
            Positioned(
              bottom: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
            // Night mode tint
            if (_nightMode)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade900.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleCameraView(int index) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GestureDetector(
          onTap: _toggleControls,
          onDoubleTap: _toggleFullScreen,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: _nightMode ? Colors.grey.shade900 : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Stack(
              children: [
                // Camera feed simulation
                Center(
                  child: Icon(
                    Icons.videocam,
                    size: 80,
                    color: _nightMode
                        ? Colors.blue.shade200
                        : AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                ),
                // IP Camera mode
                if (_ipCameraEnabled)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_done,
                          size: 60,
                          color: AppColors.primary.withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _ipCameraUrl,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Câmera IP Conectada',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Image controls overlay
                if (_brightness != 0 || _contrast != 1 || _saturation != 1)
                  Positioned.fill(
                    child: ColorFiltered(
                      colorFilter: ColorFilter.matrix(_buildColorMatrix()),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                // Grid overlay
                if (_guideLines)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GuideLinesPainter(),
                    ),
                  ),
                // Night mode overlay
                if (_nightMode)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 1.5,
                          colors: [
                            Colors.transparent,
                            Colors.indigo.shade900.withValues(alpha: 0.4),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                // LIVE badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: _buildLiveBadge(),
                ),
                // Camera label
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getCameraLabel(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                // Recording indicator
                if (_isRecording)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.fiber_manual_record, color: Colors.white, size: 10),
                          const SizedBox(width: 6),
                          Text(
                            _formatDuration(_recordingSeconds),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Bottom controls
                if (_showControls && !_isFullScreen)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _CameraControlButton(
                          icon: Icons.photo_camera,
                          label: 'Foto',
                          onTap: _takePhoto,
                        ),
                        _CameraControlButton(
                          icon: _isRecording ? Icons.stop : Icons.fiber_manual_record,
                          label: _isRecording ? 'Parar' : 'REC',
                          color: _isRecording ? AppColors.error : null,
                          onTap: _toggleRecording,
                        ),
                        _CameraControlButton(
                          icon: _guideLines ? Icons.grid_on : Icons.grid_off,
                          label: 'Linhas',
                          isActive: _guideLines,
                          onTap: () => setState(() => _guideLines = !_guideLines),
                        ),
                        _CameraControlButton(
                          icon: _nightMode ? Icons.nightlight : Icons.wb_sunny,
                          label: 'Noite',
                          isActive: _nightMode,
                          onTap: () => setState(() => _nightMode = !_nightMode),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fiber_manual_record, color: Colors.white, size: 8),
          SizedBox(width: 4),
          Text(
            'AO VIVO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraSelector() {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _CameraButton(
            icon: Icons.camera_front,
            label: 'Frente',
            isActive: _selectedCamera == 0,
            onTap: () => setState(() => _selectedCamera = 0),
          ),
          _CameraButton(
            icon: Icons.camera_rear,
            label: 'Traseira',
            isActive: _selectedCamera == 1,
            onTap: () => setState(() => _selectedCamera = 1),
          ),
          _CameraButton(
            icon: Icons.camera,
            label: 'Lat D',
            isActive: _selectedCamera == 2,
            onTap: () => setState(() => _selectedCamera = 2),
          ),
          _CameraButton(
            icon: Icons.camera,
            label: 'Lat E',
            isActive: _selectedCamera == 3,
            onTap: () => setState(() => _selectedCamera = 3),
          ),
          _CameraButton(
            icon: Icons.panorama,
            label: '360°',
            isActive: _selectedCamera == 4,
            onTap: () => setState(() => _selectedCamera = 4),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _QuickControlCard(
              icon: _isRecording ? Icons.stop : Icons.fiber_manual_record,
              label: _isRecording ? 'Parar REC' : 'Gravar',
              color: _isRecording ? AppColors.error : null,
              isActive: _isRecording,
              onTap: _toggleRecording,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickControlCard(
              icon: Icons.photo_camera,
              label: 'Capturar',
              onTap: _takePhoto,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickControlCard(
              icon: Icons.timeline,
              label: 'Linhas',
              isActive: _guideLines,
              onTap: () => setState(() => _guideLines = !_guideLines),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickControlCard(
              icon: _nightMode ? Icons.nightlight : Icons.wb_sunny,
              label: 'Noite',
              isActive: _nightMode,
              onTap: () => setState(() => _nightMode = !_nightMode),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageControls() {
    if (!_showControls) return const SizedBox.shrink();

    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.tune, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Ajustes de Imagem',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _brightness = 0.0;
                    _contrast = 1.0;
                    _saturation = 1.0;
                  });
                },
                child: const Text('Resetar'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ImageSlider(
            icon: Icons.brightness_6,
            label: 'Brilho',
            value: _brightness,
            min: -0.5,
            max: 0.5,
            onChanged: (v) => setState(() => _brightness = v),
          ),
          const SizedBox(height: 8),
          _ImageSlider(
            icon: Icons.contrast,
            label: 'Contraste',
            value: _contrast,
            min: 0.5,
            max: 2.0,
            onChanged: (v) => setState(() => _contrast = v),
          ),
          const SizedBox(height: 8),
          _ImageSlider(
            icon: Icons.color_lens,
            label: 'Saturação',
            value: _saturation,
            min: 0.0,
            max: 2.0,
            onChanged: (v) => setState(() => _saturation = v),
          ),
        ],
      ),
    );
  }

  String _getCameraLabel() {
    const labels = ['Frente', 'Traseira', 'Lateral Direito', 'Lateral Esquerdo', '360°'];
    return labels[_selectedCamera];
  }

  List<double> _buildColorMatrix() {
    final b = _brightness;
    final c = _contrast;
    final s = _saturation;

    final t = (1 - c) / 2;
    final sr = (1 - s) * 0.3086;
    final sg = (1 - s) * 0.6094;
    final sb = (1 - s) * 0.0820;

    return [
      c * (sr + s), c * sg, c * sb, 0, b + t,
      c * sr, c * (sg + s), c * sb, 0, b + t,
      c * sr, c * sg, c * (sb + s), 0, b + t,
      0, 0, 0, 1, 0,
    ];
  }

  void _showIpCameraDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Câmera IP',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'URL RTSP',
                hintText: 'rtsp://192.168.1.100:554/stream',
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: AppColors.textPrimary),
              controller: TextEditingController(text: _ipCameraUrl),
              onChanged: (v) => setState(() => _ipCameraUrl = v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Switch(
                  value: _ipCameraEnabled,
                  onChanged: (v) {
                    setState(() => _ipCameraEnabled = v);
                    Navigator.pop(context);
                  },
                  activeColor: AppColors.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Conectar automaticamente',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _HeaderButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.glassBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ControlChip({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white24 : Colors.black38,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.size,
    this.color = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.2),
          border: Border.all(color: color, width: 3),
        ),
        child: Icon(icon, color: color, size: size * 0.5),
      ),
    );
  }
}

class _CameraControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool isActive;

  const _CameraControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? c.withValues(alpha: 0.2) : Colors.black38,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? c : Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? c : Colors.white,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickControlCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool isActive;

  const _QuickControlCard({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? c.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? c : AppColors.glassBorder,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? c : AppColors.textSecondary, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? c : AppColors.textSecondary,
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

class _ImageSlider extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _ImageSlider({
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 18),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.surfaceLight,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            value.toStringAsFixed(1),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _CameraButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CameraButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Horizontal center line
    final centerY = size.height / 2;
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      paint,
    );

    // Vertical center line
    final centerX = size.width / 2;
    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, size.height),
      paint,
    );

    // Guide lines for parking (converging lines)
    final guidePaint = Paint()
      ..color = Colors.yellow.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Top converging lines
    canvas.drawLine(
      Offset(size.width * 0.2, size.height),
      Offset(size.width * 0.4, size.height * 0.5),
      guidePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.8, size.height),
      Offset(size.width * 0.6, size.height * 0.5),
      guidePaint,
    );

    // Distance markers
    final markerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 1; i <= 3; i++) {
      final y = size.height - (size.height * 0.2 * i);
      canvas.drawLine(
        Offset(size.width * 0.3, y),
        Offset(size.width * 0.7, y),
        markerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DirectionMarker extends StatelessWidget {
  final String label;
  final bool isActive;

  const _DirectionMarker({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.black38,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.white70,
          fontSize: 10,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _ViewAngleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ViewAngleButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.glassBorder,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontSize: 9,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
