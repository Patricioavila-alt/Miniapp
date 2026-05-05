import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';

class TestOption {
  final String id;
  final String title;
  final String sku;
  final String price;

  TestOption({
    required this.id,
    required this.title,
    required this.sku,
    required this.price,
  });
}

class TestTypeScreen extends StatefulWidget {
  const TestTypeScreen({super.key});

  @override
  State<TestTypeScreen> createState() => _TestTypeScreenState();
}

class _TestTypeScreenState extends State<TestTypeScreen> {
  String? _selectedTestId;

  final List<TestOption> _tests = [
    TestOption(id: 'covid19', title: 'COVID-19', sku: 'PANBIO AUTOTEST', price: '\$1,000.00 MXN'),
    TestOption(id: 'covid_flu', title: 'COVID + Influenza A/B', sku: 'PANBIO COVID-1 FLU A&B KIT', price: '\$1,000.00 MXN'),
    TestOption(id: 'covid_rapid', title: 'COVID-19 Prueba rápida', sku: 'PANBIO COVID-19 AG NASA', price: '\$1,000.00 MXN'),
    TestOption(id: 'antigeno', title: 'Antígeno COVID-19', sku: 'ABBOTT ANTIGEN', price: '\$1,000.00 MXN'),
    TestOption(id: 'influenza', title: 'Influenza A/B', sku: 'RAPID INFLUENZA DIAGNOSTIC', price: '\$850.00 MXN'),
  ];

  bool get _isNextEnabled => _selectedTestId != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Cita para pruebas',
          style: AppTheme.heading2().copyWith(fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stepper (mismo estilo que vacunas)
                      _buildCustomStepper(),
                      const SizedBox(height: 24),

                      // Info Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF3FF),
                          borderRadius: BorderRadius.circular(12),
                          border: const Border(
                            left: BorderSide(color: AppTheme.blue, width: 4),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_rounded, color: AppTheme.blue, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Pruebas de diagnóstico en consultorio',
                                      style: AppTheme.bodyBold().copyWith(color: AppTheme.blue, fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text('Las pruebas se realizan por personal capacitado. El precio es por prueba y aplicación.',
                                      style: AppTheme.body().copyWith(color: AppTheme.textPrimary, fontSize: 13)),
                                ],
                              ),
                            ),
                            const Icon(Icons.close_rounded, color: AppTheme.textPrimary, size: 18),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Título
                      Text(
                        '¿Qué prueba necesitas realizarte?',
                        style: AppTheme.heading2().copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 16),

                      // Lista de pruebas (mismo estilo que vacunas)
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _tests.length,
                        separatorBuilder: (context, index) =>
                            const Divider(color: AppTheme.border, height: 1),
                        itemBuilder: (context, index) {
                          final test = _tests[index];
                          final isSelected = _selectedTestId == test.id;
                          return InkWell(
                            onTap: () => setState(() => _selectedTestId = test.id),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Radio Button (mismo estilo que vacunas)
                                  Container(
                                    width: 24,
                                    height: 24,
                                    margin: const EdgeInsets.only(top: 2, right: 16),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppTheme.blue
                                            : AppTheme.accent.withOpacity(0.5),
                                        width: isSelected ? 6 : 1.5,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(test.title,
                                            style: AppTheme.bodyBold().copyWith(fontSize: 15)),
                                        const SizedBox(height: 4),
                                        Text(test.sku,
                                            style: AppTheme.body().copyWith(fontSize: 13)),
                                        const SizedBox(height: 6),
                                        Text(
                                          test.price,
                                          style: AppTheme.bodyBold().copyWith(
                                              fontSize: 12, color: AppTheme.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),
                      // Nota de pie
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Text(
                          'Esta prueba es de carácter orientativo. Para diagnóstico definitivo, acude con un médico.',
                          style: AppTheme.body().copyWith(
                              fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Botón Siguiente (mismo estilo que vacunas)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isNextEnabled
                      ? () => context.push(AppRoutes.testBranch)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.blue,
                    disabledBackgroundColor: AppTheme.border,
                    disabledForegroundColor: AppTheme.textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  child: const Text('Siguiente',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepItem(Icons.biotech_outlined, 'Tipo\nde prueba', true),
          _buildDivider(false),
          _buildStepItem(Icons.storefront_outlined, 'Sucursal,\nfecha y hora', false),
          _buildDivider(false),
          _buildStepItem(Icons.person_outline, 'Información\ndel paciente', false),
          _buildDivider(false),
          _buildStepItem(Icons.event_available_outlined, 'Confirmar\ncita', false),
        ],
      ),
    );
  }

  Widget _buildStepItem(IconData icon, String label, bool isActive) {
    return Expanded(
      flex: 2,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? AppTheme.blue : AppTheme.border,
                width: 1.5,
              ),
            ),
            child: Icon(icon,
                color: isActive ? AppTheme.blue : AppTheme.accent, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTheme.label().copyWith(
              color: isActive ? AppTheme.blue : AppTheme.accent,
              fontSize: 10,
              height: 1.2,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isActive) {
    return Expanded(
      flex: 1,
      child: Container(
        height: 1.5,
        color: isActive ? AppTheme.blue : AppTheme.border,
        margin: const EdgeInsets.only(bottom: 24),
      ),
    );
  }
}
