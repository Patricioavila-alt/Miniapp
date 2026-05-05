import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';

class TestConfirmationScreen extends StatefulWidget {
  const TestConfirmationScreen({super.key});

  @override
  State<TestConfirmationScreen> createState() => _TestConfirmationScreenState();
}

class _TestConfirmationScreenState extends State<TestConfirmationScreen> {
  bool _isAccepted = false;
  bool _isConfirming = false;

  void _confirmAppointment() async {
    setState(() => _isConfirming = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isConfirming = false);
    context.go(AppRoutes.testSuccess);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Cita para pruebas', style: AppTheme.heading2().copyWith(fontSize: 17)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stepper
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: _buildCustomStepper(),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Revisa los detalles y confirma tu cita',
                              style: AppTheme.heading2().copyWith(fontSize: 18)),
                          const SizedBox(height: 24),
                          _CollapsibleSection(
                            title: 'Tipo de prueba',
                            initiallyExpanded: true,
                            child: _buildTestTypeSummary(),
                          ),
                          const SizedBox(height: 16),
                          _CollapsibleSection(
                            title: 'Datos del paciente',
                            initiallyExpanded: true,
                            child: _buildPatientSummary(),
                          ),
                          const SizedBox(height: 16),
                          _CollapsibleSection(
                            title: 'Detalle de aplicación',
                            initiallyExpanded: true,
                            child: _buildApplicationSummary(),
                          ),
                          const SizedBox(height: 32),
                          // Checkbox de términos
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24, height: 24,
                                child: Checkbox(
                                  value: _isAccepted,
                                  onChanged: (val) => setState(() => _isAccepted = val ?? false),
                                  activeColor: const Color(0xFF13299D),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: AppTheme.body().copyWith(color: AppTheme.textPrimary, fontSize: 13, height: 1.4),
                                    children: const [
                                      TextSpan(text: 'Autorizo la realización de la prueba seleccionada y declaro haber leído el '),
                                      TextSpan(
                                        text: 'Aviso de privacidad.',
                                        style: TextStyle(color: Color(0xFF13299D), decoration: TextDecoration.underline, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Botones inferiores
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isAccepted && !_isConfirming ? _confirmAppointment : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF13299D),
                        disabledBackgroundColor: const Color(0xFFE0E0E0),
                        disabledForegroundColor: const Color(0xFFAAAAAA),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                      ),
                      child: _isConfirming
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Confirmar cita', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => context.pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFEFF4FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                      ),
                      child: const Text('Regresar', style: TextStyle(color: Color(0xFF13299D), fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestTypeSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.biotech_rounded, color: Color(0xFF2563EB), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Antígeno COVID-19', style: AppTheme.heading3().copyWith(fontSize: 15)),
              const SizedBox(height: 4),
              Text('Detecta presencia activa del virus SARS-CoV-2.\nA partir de 2 años.',
                  style: AppTheme.body().copyWith(color: AppTheme.textSecondary, fontSize: 12, height: 1.3)),
              const SizedBox(height: 8),
              RichText(text: TextSpan(children: [
                TextSpan(text: '\$1,000.00', style: AppTheme.heading3().copyWith(fontSize: 14)),
                TextSpan(text: 'MXN', style: AppTheme.body().copyWith(fontSize: 10, color: AppTheme.textSecondary)),
              ])),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildPatientSummary() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.account_circle_outlined, color: AppTheme.textSecondary, size: 24),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Alejandra Valverde Salgado', style: AppTheme.bodyBold().copyWith(fontSize: 14)),
          const SizedBox(height: 4),
          Text('01/Agosto/1990', style: AppTheme.body().copyWith(color: AppTheme.textSecondary, fontSize: 12)),
        ]),
      ],
    );
  }

  Widget _buildApplicationSummary() {
    return Column(children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.storefront_outlined, color: AppTheme.textSecondary, size: 24),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('México Centro, Xola', style: AppTheme.bodyBold().copyWith(fontSize: 14)),
          const SizedBox(height: 4),
          Text('XOLA 1001 COL: NARVARTE PONIENTE CIUDAD DE MEXICO, CIUDAD DE MEXICO MX',
              style: AppTheme.body().copyWith(color: AppTheme.textSecondary, fontSize: 11, height: 1.3)),
        ])),
      ]),
      const SizedBox(height: 20),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.calendar_today_outlined, color: AppTheme.textSecondary, size: 24),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Viernes, 20 de noviembre', style: AppTheme.bodyBold().copyWith(fontSize: 14)),
          const SizedBox(height: 4),
          Text('09:45 am', style: AppTheme.body().copyWith(color: AppTheme.textSecondary, fontSize: 12)),
        ]),
      ]),
    ]);
  }

  Widget _buildCustomStepper() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      _buildStepItem(Icons.check, 'Tipo\nde prueba', true, isCompleted: true),
      _buildDivider(true),
      _buildStepItem(Icons.check, 'Sucursal,\nfecha y hora', true, isCompleted: true),
      _buildDivider(true),
      _buildStepItem(Icons.check, 'Información\ndel paciente', true, isCompleted: true),
      _buildDivider(true),
      _buildStepItem(Icons.event_available_outlined, 'Confirmar\ncita', true),
    ]);
  }

  Widget _buildStepItem(IconData icon, String label, bool isActive, {bool isCompleted = false}) {
    final color = isCompleted ? const Color(0xFF13299D) : (isActive ? const Color(0xFF3B82F6) : AppTheme.accent);
    final bgColor = isCompleted ? const Color(0xFF13299D) : Colors.transparent;
    final iconColor = isCompleted ? Colors.white : color;
    return Expanded(flex: 2, child: Column(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle, border: Border.all(color: color, width: 1.5)),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      const SizedBox(height: 8),
      Text(label, textAlign: TextAlign.center,
          style: AppTheme.label().copyWith(color: color, fontSize: 10, height: 1.2,
              fontWeight: isActive || isCompleted ? FontWeight.w600 : FontWeight.w500)),
    ]));
  }

  Widget _buildDivider(bool isActive) => Expanded(flex: 1,
      child: Container(height: 1.5, color: isActive ? const Color(0xFF13299D) : AppTheme.border, margin: const EdgeInsets.only(bottom: 24)));
}

class _CollapsibleSection extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;
  const _CollapsibleSection({required this.title, required this.child, this.initiallyExpanded = false});
  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection> {
  late bool _isExpanded;
  @override
  void initState() { super.initState(); _isExpanded = widget.initiallyExpanded; }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
      child: Column(children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: _isExpanded ? const BorderRadius.vertical(top: Radius.circular(12)) : BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(widget.title, style: AppTheme.heading2().copyWith(fontSize: 16)),
              Icon(_isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: AppTheme.textPrimary),
            ]),
          ),
        ),
        if (_isExpanded) Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), child: widget.child),
      ]),
    );
  }
}
