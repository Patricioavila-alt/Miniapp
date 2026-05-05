import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';

class ConsultConfirmationScreen extends StatefulWidget {
  const ConsultConfirmationScreen({super.key});

  @override
  State<ConsultConfirmationScreen> createState() =>
      _ConsultConfirmationScreenState();
}

class _ConsultConfirmationScreenState
    extends State<ConsultConfirmationScreen> {
  bool _isAccepted = false;
  bool _isConfirming = false;

  Future<void> _confirmAppointment() async {
    setState(() => _isConfirming = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isConfirming = false);
    context.go(AppRoutes.consultSuccess);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: _buildCustomStepper(),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Revisa los detalles y confirma tu cita',
                            style: AppTheme.heading2().copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 24),

                          _CollapsibleSection(
                            title: 'Síntomas',
                            initiallyExpanded: true,
                            child: _buildSymptomsSummary(),
                          ),
                          const SizedBox(height: 16),
                          _CollapsibleSection(
                            title: 'Datos del paciente',
                            initiallyExpanded: true,
                            child: _buildPatientSummary(),
                          ),
                          const SizedBox(height: 16),
                          _CollapsibleSection(
                            title: 'Detalle de la consulta',
                            initiallyExpanded: true,
                            child: _buildConsultSummary(),
                          ),
                          const SizedBox(height: 32),

                          // Checkbox de términos
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _isAccepted,
                                  onChanged: (val) =>
                                      setState(() => _isAccepted = val ?? false),
                                  activeColor: AppTheme.brandBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: AppTheme.body().copyWith(
                                        color: AppTheme.textPrimary,
                                        fontSize: 13,
                                        height: 1.4),
                                    children: const [
                                      TextSpan(
                                          text:
                                              'Confirmo que los datos proporcionados son correctos y acepto el '),
                                      TextSpan(
                                        text: 'Aviso de privacidad',
                                        style: TextStyle(
                                          color: AppTheme.brandBlue,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      TextSpan(text: ' y los '),
                                      TextSpan(
                                        text: 'Términos y condiciones.',
                                        style: TextStyle(
                                          color: AppTheme.brandBlue,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w500,
                                        ),
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border:
                    Border(top: BorderSide(color: AppTheme.border, width: 1)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _isAccepted && !_isConfirming
                              ? _confirmAppointment
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.brandBlue,
                        disabledBackgroundColor: const Color(0xFFE0E0E0),
                        disabledForegroundColor: AppTheme.accent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                      child: _isConfirming
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Confirmar cita',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
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
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                      child: const Text(
                        'Regresar',
                        style: TextStyle(
                          color: AppTheme.brandBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Widget _buildSymptomsSummary() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.chat_bubble_outline_rounded,
            color: AppTheme.textSecondary, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Fiebre, Dolor de cabeza, cansancio general desde hace 3 días.',
            style: AppTheme.body().copyWith(
              color: AppTheme.textPrimary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPatientSummary() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.account_circle_outlined,
            color: AppTheme.textSecondary, size: 24),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alejandra Valverde Salgado',
                style: AppTheme.bodyBold().copyWith(fontSize: 14)),
            const SizedBox(height: 4),
            Text('01/Agosto/1990',
                style: AppTheme.body()
                    .copyWith(color: AppTheme.textSecondary, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildConsultSummary() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.storefront_outlined,
                color: AppTheme.textSecondary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('México Centro, Xola',
                      style: AppTheme.bodyBold().copyWith(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    'XOLA 1001 COL: NARVARTE PONIENTE CIUDAD DE MEXICO, CIUDAD DE MEXICO MX',
                    style: AppTheme.body().copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.calendar_today_outlined,
                color: AppTheme.textSecondary, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Viernes, 20 de noviembre',
                    style: AppTheme.bodyBold().copyWith(fontSize: 14)),
                const SizedBox(height: 4),
                Text('09:45 am',
                    style: AppTheme.body().copyWith(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStepItem(Icons.check, 'Síntomas', true, false,
            isCompleted: true),
        _buildDivider(true),
        _buildStepItem(Icons.check, 'Sucursal,\nfecha y hora', true, false,
            isCompleted: true),
        _buildDivider(true),
        _buildStepItem(Icons.check, 'Información\ndel paciente', true, false,
            isCompleted: true),
        _buildDivider(true),
        _buildStepItem(
            Icons.event_available_outlined, 'Confirmar\ncita', true, true),
      ],
    );
  }

  Widget _buildStepItem(IconData icon, String label, bool isActive, bool isLast,
      {bool isCompleted = false}) {
    final color = isCompleted
        ? AppTheme.brandBlue
        : (isActive ? AppTheme.blue : AppTheme.accent);
    final bgColor = isCompleted ? AppTheme.brandBlue : Colors.transparent;
    final iconColor = isCompleted ? Colors.white : color;

    return Expanded(
      flex: 2,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.5),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTheme.label().copyWith(
              color: color,
              fontSize: 10,
              height: 1.2,
              fontWeight:
                  isActive || isCompleted ? FontWeight.w600 : FontWeight.w500,
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
        color: isActive ? AppTheme.brandBlue : AppTheme.border,
        margin: const EdgeInsets.only(bottom: 24),
      ),
    );
  }
}

class _CollapsibleSection extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;

  const _CollapsibleSection({
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: _isExpanded
                ? const BorderRadius.vertical(top: Radius.circular(12))
                : BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.title,
                      style: AppTheme.heading2().copyWith(fontSize: 16)),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.textPrimary,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: widget.child,
            ),
        ],
      ),
    );
  }
}
