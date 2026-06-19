import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/car_repository.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_icon_button.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  bool _isLoading = false;
  bool _isShuffle = false;
  String _repeatMode = 'off'; // off, one, all

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _toggleShuffle() {
    setState(() => _isShuffle = !_isShuffle);
  }

  void _toggleRepeat() {
    setState(() {
      if (_repeatMode == 'off') {
        _repeatMode = 'all';
      } else if (_repeatMode == 'all') {
        _repeatMode = 'one';
      } else {
        _repeatMode = 'off';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<CarRepository>(context);
    final media = repo.mediaState;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              const Text(
                'Mídia',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Album Art
              Expanded(
                child: Center(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.8),
                          AppColors.accent.withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.album,
                      size: 120,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Track Info
              Text(
                media.currentTrack,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                media.artist,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),

              // Progress Bar
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: AppColors.surfaceLight,
                        thumbColor: AppColors.primary,
                      ),
                      child: Slider(
                        value: media.position.toDouble(),
                        min: 0,
                        max: media.duration.toDouble(),
                        onChanged: (value) {},
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatTime(media.position),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _formatTime(media.duration),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GlassIconButton(
                    icon: Icons.shuffle,
                    label: '',
                    size: 48,
                    isActive: _isShuffle,
                    activeColor: _isShuffle ? AppColors.accent : AppColors.textSecondary,
                    onTap: _toggleShuffle,
                  ),
                  GlassIconButton(
                    icon: Icons.skip_previous,
                    label: '',
                    size: 56,
                    onTap: () async {
                      setState(() => _isLoading = true);
                      await repo.previousTrack();
                      setState(() => _isLoading = false);
                    },
                  ),
                  GlassIconButton(
                    icon: media.isPlaying ? Icons.pause : Icons.play_arrow,
                    label: '',
                    size: 80,
                    activeColor: AppColors.primary,
                    onTap: () async {
                      setState(() => _isLoading = true);
                      await repo.togglePlayPause();
                      setState(() => _isLoading = false);
                    },
                  ),
                  GlassIconButton(
                    icon: Icons.skip_next,
                    label: '',
                    size: 56,
                    onTap: () async {
                      setState(() => _isLoading = true);
                      await repo.nextTrack();
                      setState(() => _isLoading = false);
                    },
                  ),
                  GlassIconButton(
                    icon: _repeatMode == 'one' ? Icons.repeat_one : Icons.repeat,
                    label: '',
                    size: 48,
                    isActive: _repeatMode != 'off',
                    activeColor: _repeatMode != 'off' ? AppColors.accent : AppColors.textSecondary,
                    onTap: _toggleRepeat,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Extra controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GlassIconButton(
                    icon: Icons.favorite_border,
                    label: '',
                    size: 44,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Adicionado aos favoritos!'),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  GlassIconButton(
                    icon: Icons.queue_music,
                    label: '',
                    size: 44,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Playlist - Em breve!'),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  GlassIconButton(
                    icon: Icons.equalizer,
                    label: '',
                    size: 44,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Equalizador - Em breve!'),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  GlassIconButton(
                    icon: Icons.volume_up,
                    label: '',
                    size: 44,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Volume
              GlassCard(
                child: Row(
                  children: [
                    const Icon(Icons.volume_down, color: AppColors.textSecondary),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.surfaceLight,
                          thumbColor: AppColors.textPrimary,
                        ),
                        child: Slider(
                          value: media.volume.toDouble(),
                          min: 0,
                          max: 100,
                          onChanged: (value) async {
                            await repo.setVolume(value.toInt());
                          },
                        ),
                      ),
                    ),
                    const Icon(Icons.volume_up, color: AppColors.textSecondary),
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
