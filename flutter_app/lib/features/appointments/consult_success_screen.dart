import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class ConsultSuccessScreen extends StatelessWidget {
  const ConsultSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Cita médica',
          style: AppTheme.heading2().copyWith(fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ilustración central
                    Center(
                      child: SizedBox(
                        width: 160,
                        height: 160,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 140,
                              height: 140,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEFF5F3),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.calendar_month_rounded,
                                size: 50,
                                color: Color(0xFF13299D),
                              ),
                            ),
                            // Checkmark verde
                            const Positioned(
                              left: 16,
                              bottom: 38,
                              child: Icon(
                                Icons.check_circle,
                                color: Color(0xFF4CAF50),
                                size: 36,
                              ),
                            ),
                            // Estetoscopio
                            Positioned(
                              right: 8,
                              bottom: 18,
                              child: Transform.rotate(
                                angle: -0.5,
                                child: const Icon(
                                  Icons.medical_services_rounded,
                                  color: Color(0xFF2A433A),
                                  size: 52,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text(
                      '¡Tu cita está confirmada! 🎉',
                      style: AppTheme.heading2().copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Hemos registrado tu consulta. Tu folio es:',
                      style: AppTheme.body().copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'FAM248',
                      style: AppTheme.heading1().copyWith(
                        color: const Color(0xFF13299D),
                        fontSize: 24,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Card: servicio gratuito
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEFF5F3), Color(0xFFE8F0FE)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF13299D).withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF13299D),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.volunteer_activism_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sin costo para ti',
                                  style: AppTheme.bodyBold().copyWith(
                                    color: const Color(0xFF13299D),
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Nuestra orientación médica en sucursal es completamente gratuita. Tu salud es nuestra prioridad — ¡te esperamos con gusto!',
                                  style: AppTheme.body().copyWith(
                                    color: const Color(0xFF2A433A),
                                    fontSize: 13,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Recuerda llegar con anticipación y llevar una identificación oficial.',
                      style: AppTheme.body().copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Botón único — sin pago
            Container(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF13299D),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  child: const Text(
                    'Ir al inicio',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
