import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _isMuted = false;
  bool _isCameraOff = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.videoCallBg,
      body: SafeArea(
        child: Stack(
          children: [
            // Fondo simulado de videollamada
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: AppTheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: Colors.white60, size: 64),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Dr. Ana Rodríguez',
                    style: AppTheme.heading2().copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Videoconsulta en progreso...',
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  // Timer simulado
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '● 00:08:34',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            // Miniatura propia (esquina)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                width: 90,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.secondary,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.person_rounded,
                    color: Colors.white38, size: 40),
              ),
            ),

            // Botón cerrar
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
            ),

            // Controls
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CallButton(
                    icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    label: _isMuted ? 'Silenciado' : 'Micrófono',
                    onTap: () => setState(() => _isMuted = !_isMuted),
                    active: !_isMuted,
                  ),
                  const SizedBox(width: 16),
                  // Botón colgar
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: AppTheme.error,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.call_end_rounded,
                          color: Colors.white, size: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _CallButton(
                    icon: _isCameraOff
                        ? Icons.videocam_off_rounded
                        : Icons.videocam_rounded,
                    label: _isCameraOff ? 'Cámara off' : 'Cámara',
                    onTap: () => setState(() => _isCameraOff = !_isCameraOff),
                    active: !_isCameraOff,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  const _CallButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: active
                  ? Colors.white.withOpacity(0.15)
                  : AppTheme.error.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }
}
