import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';

class TestSuccessScreen extends StatelessWidget {
  const TestSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Cita para pruebas', style: AppTheme.heading2().copyWith(fontSize: 17)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(
                  child: SizedBox(
                    width: 160, height: 160,
                    child: Stack(alignment: Alignment.center, children: [
                      Container(width: 140, height: 140, decoration: const BoxDecoration(color: Color(0xFFEFF5E6), shape: BoxShape.circle)),
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                        child: const Icon(Icons.calendar_month_rounded, size: 50, color: Color(0xFFE0E0E0)),
                      ),
                      const Positioned(left: 18, bottom: 38, child: Icon(Icons.cancel, color: Color(0xFFEF4444), size: 36)),
                      Positioned(
                        right: 8, bottom: 18,
                        child: Transform.rotate(angle: -0.5,
                            child: const Icon(Icons.science_rounded, color: Color(0xFF8BC34A), size: 52)),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 48),
                Text('Tu cita se agendó con éxito', style: AppTheme.heading2().copyWith(fontSize: 22)),
                const SizedBox(height: 14),
                Text('Hemos registrado tu prueba. Tu folio es:', style: AppTheme.body().copyWith(fontSize: 14)),
                const SizedBox(height: 14),
                Text('FAV382', style: AppTheme.heading1().copyWith(color: const Color(0xFF13299D), fontSize: 24, letterSpacing: 2)),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(8)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.schedule_rounded, color: Color(0xFFF59E0B), size: 16),
                    const SizedBox(width: 8),
                    Text('Pendiente de pago', style: AppTheme.bodyBold().copyWith(color: const Color(0xFFD97706), fontSize: 13)),
                  ]),
                ),
                const SizedBox(height: 24),
                Text(
                  'Recuerda llegar con anticipación y llevar una identificación oficial.\n\n⚠️ Recuerda que el pago debe realizarse en línea antes de tu cita.',
                  style: AppTheme.body().copyWith(color: AppTheme.textPrimary, fontSize: 14, height: 1.4),
                ),
              ]),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF13299D),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                ),
                child: const Text('Pagar ahora', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
