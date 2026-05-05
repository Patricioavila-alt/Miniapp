import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class VaccinePayInBranchScreen extends StatelessWidget {
  const VaccinePayInBranchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Ocultar botón de retroceso
        title: Text(
          'Cita para vacuna',
          style: AppTheme.heading2().copyWith(fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // Centrado
                  children: [
                    // Ilustración central
                    Center(
                      child: SizedBox(
                        width: 160,
                        height: 160,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Círculo de fondo azul claro
                            Container(
                              width: 140,
                              height: 140,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEFF4FF), // Azul muy claro
                                shape: BoxShape.circle,
                              ),
                            ),
                            // Ícono principal (Hospital/Sucursal)
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
                                Icons.storefront_rounded,
                                size: 50,
                                color: Color(0xFF13299D),
                              ),
                            ),
                            // Check verde
                            const Positioned(
                              right: 20,
                              bottom: 25,
                              child: Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF10B981), // Verde esmeralda
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Título
                    Text(
                      'Te esperamos en la sucursal',
                      textAlign: TextAlign.center,
                      style: AppTheme.heading2().copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 24),

                    // Texto descriptivo amigable
                    Text(
                      'Recuerda llegar al menos 10 minutos antes de tu cita para realizar el pago en recepción.\n\nSi cambias de opinión, aún puedes realizar el pago en línea en cualquier momento desde el detalle de tu cita en la aplicación.',
                      textAlign: TextAlign.center,
                      style: AppTheme.body().copyWith(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Botón inferior
            Container(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navegamos al inicio
                    context.go('/');
                  },
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
