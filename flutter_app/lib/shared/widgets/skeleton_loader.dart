import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// ─── Shimmer base ──────────────────────────────────────────────────────────────
class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    this.width = double.infinity,
    required this.height,
    this.radius = AppTheme.radiusSm,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment(_animation.value - 1, 0),
            end: Alignment(_animation.value + 1, 0),
            colors: const [
              Color(0xFFEDE9E3),
              Color(0xFFF5F2EE),
              Color(0xFFEDE9E3),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Skeleton para tarjeta de cita/expediente ─────────────────────────────────
class AppointmentCardSkeleton extends StatelessWidget {
  const AppointmentCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSoft,
      ),
      child: const Row(
        children: [
          // Avatar placeholder
          _ShimmerBox(
            width: 52,
            height: 52,
            radius: 26,
          ),
          SizedBox(width: 14),
          // Text lines
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(height: 14, width: 160),
                SizedBox(height: 8),
                _ShimmerBox(height: 12, width: 100),
                SizedBox(height: 10),
                _ShimmerBox(height: 24, width: 130, radius: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Skeleton para la HomeScreen ──────────────────────────────────────────────
class HomeScreenSkeleton extends StatelessWidget {
  const HomeScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: AppTheme.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerBox(height: 22, width: 160),
                    SizedBox(height: 8),
                    _ShimmerBox(height: 14, width: 120),
                  ],
                ),
                _ShimmerBox(width: 44, height: 44, radius: 22),
              ],
            ),
            const SizedBox(height: AppTheme.gap),

            // Contextual widget
            const _ShimmerBox(height: 180, radius: AppTheme.radiusXl),
            const SizedBox(height: AppTheme.gap),

            // Quick actions label
            const _ShimmerBox(height: 16, width: 120),
            const SizedBox(height: 16),

            // Quick actions grid
            Row(
              children: List.generate(
                  4,
                  (i) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: i < 3 ? 12 : 0),
                          child: const _ShimmerBox(
                              height: 80, radius: AppTheme.radiusMd),
                        ),
                      )),
            ),
            const SizedBox(height: AppTheme.gap),

            // Promociones label
            const _ShimmerBox(height: 16, width: 100),
            const SizedBox(height: 16),

            // Promo banners
            const Row(
              children: [
                Expanded(
                    child: _ShimmerBox(height: 160, radius: AppTheme.radiusLg)),
                SizedBox(width: 16),
                Expanded(
                    child: _ShimmerBox(height: 160, radius: AppTheme.radiusLg)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Skeleton para lista (citas / expediente) ────────────────────────────────
class ListScreenSkeleton extends StatelessWidget {
  final int itemCount;
  const ListScreenSkeleton({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const AppointmentCardSkeleton(),
    );
  }
}

// ─── Widget de error reutilizable ─────────────────────────────────────────────
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorBanner({
    super.key,
    this.message = 'Sin conexión al servidor',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  size: 36, color: AppTheme.primary),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: AppTheme.bodyBold(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Verifica tu conexión e intenta de nuevo.',
              style: AppTheme.caption(),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
