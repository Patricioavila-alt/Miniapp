import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';

class ConsultSymptomsScreen extends StatefulWidget {
  const ConsultSymptomsScreen({super.key});

  @override
  State<ConsultSymptomsScreen> createState() => _ConsultSymptomsScreenState();
}

class _ConsultSymptomsScreenState extends State<ConsultSymptomsScreen> {
  final _symptomsController = TextEditingController();
  bool _hasAttemptedSubmit = false;

  static const _quickSymptoms = [
    'Fiebre',
    'Dolor de cabeza',
    'Tos',
    'Dolor de garganta',
    'Náuseas',
    'Fatiga',
    'Dolor de cuerpo',
    'Mareos',
  ];

  final Set<String> _selectedQuickSymptoms = {};

  bool get _isValid => _symptomsController.text.trim().length >= 10;

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  void _toggleQuickSymptom(String symptom) {
    setState(() {
      if (_selectedQuickSymptoms.contains(symptom)) {
        _selectedQuickSymptoms.remove(symptom);
      } else {
        _selectedQuickSymptoms.add(symptom);
      }
      _rebuildSymptomsText();
    });
  }

  void _rebuildSymptomsText() {
    if (_selectedQuickSymptoms.isEmpty) return;
    final existing = _symptomsController.text.trim();
    final chips = _selectedQuickSymptoms.join(', ');
    if (existing.isEmpty) {
      _symptomsController.text = chips;
    } else {
      // Actualiza solo si el texto actual coincide exactamente con los chips anteriores
      _symptomsController.text = chips;
    }
    _symptomsController.selection = TextSelection.fromPosition(
      TextPosition(offset: _symptomsController.text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _hasAttemptedSubmit && !_isValid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
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
                    // Stepper
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: _buildCustomStepper(),
                    ),
                    const SizedBox(height: 8),

                    // Contenido principal
                    Container(
                      color: Colors.white,
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¿Cuáles son tus síntomas?',
                            style: AppTheme.heading2().copyWith(fontSize: 20),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Descríbelos para ayudarnos a preparar mejor tu consulta.',
                            style: AppTheme.body().copyWith(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Síntomas frecuentes
                          Text(
                            'Síntomas frecuentes',
                            style: AppTheme.bodyBold().copyWith(
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _quickSymptoms.map((symptom) {
                              final isSelected =
                                  _selectedQuickSymptoms.contains(symptom);
                              return GestureDetector(
                                onTap: () => _toggleQuickSymptom(symptom),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFEFF4FF)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF3B82F6)
                                          : AppTheme.border,
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Text(
                                    symptom,
                                    style: AppTheme.body().copyWith(
                                      fontSize: 13,
                                      color: isSelected
                                          ? const Color(0xFF3B82F6)
                                          : AppTheme.textPrimary,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),

                          // Área de texto
                          Text(
                            'Describe tus síntomas *',
                            style: AppTheme.body().copyWith(
                              color: hasError
                                  ? const Color(0xFFEF4444)
                                  : AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _symptomsController,
                            maxLines: 6,
                            maxLength: 500,
                            onChanged: (_) {
                              if (_hasAttemptedSubmit) setState(() {});
                            },
                            style: AppTheme.body().copyWith(
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Ej. Llevo 3 días con fiebre de 38°C, dolor de cabeza intenso y cansancio general...',
                              hintStyle: AppTheme.body().copyWith(
                                color: AppTheme.textSecondary.withOpacity(0.6),
                                fontSize: 13,
                              ),
                              filled: true,
                              fillColor: hasError
                                  ? const Color(0xFFFDE8E8)
                                  : const Color(0xFFF9F9F9),
                              contentPadding: const EdgeInsets.all(16),
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: hasError
                                      ? const Color(0xFFEF4444)
                                      : AppTheme.border,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: hasError
                                      ? const Color(0xFFEF4444)
                                      : AppTheme.border,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: hasError
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF13299D),
                                  width: 1.5,
                                ),
                              ),
                              counterStyle: AppTheme.body().copyWith(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                          if (hasError)
                            const Padding(
                              padding: EdgeInsets.only(top: 4, left: 4),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      color: Color(0xFFEF4444), size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'Describe tus síntomas con al menos 10 caracteres.',
                                    style: TextStyle(
                                        color: Color(0xFFEF4444), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Botón Siguiente
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border:
                    Border(top: BorderSide(color: AppTheme.border, width: 1)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _hasAttemptedSubmit = true);
                    if (_isValid) {
                      context.push(AppRoutes.consultBranch);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF13299D),
                    disabledBackgroundColor: const Color(0xFFE0E0E0),
                    disabledForegroundColor: const Color(0xFFAAAAAA),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  child: const Text(
                    'Siguiente',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStepItem(
            Icons.chat_bubble_outline_rounded, 'Síntomas', true, false),
        _buildDivider(false),
        _buildStepItem(
            Icons.storefront_outlined, 'Sucursal,\nfecha y hora', false, false),
        _buildDivider(false),
        _buildStepItem(
            Icons.person_outline, 'Información\ndel paciente', false, false),
        _buildDivider(false),
        _buildStepItem(
            Icons.event_available_outlined, 'Confirmar\ncita', false, true),
      ],
    );
  }

  Widget _buildStepItem(IconData icon, String label, bool isActive, bool isLast,
      {bool isCompleted = false}) {
    final color = isCompleted
        ? const Color(0xFF13299D)
        : (isActive ? const Color(0xFF3B82F6) : AppTheme.accent);
    final bgColor = isCompleted ? const Color(0xFF13299D) : Colors.transparent;
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
        color: isActive ? const Color(0xFF13299D) : AppTheme.border,
        margin: const EdgeInsets.only(bottom: 24),
      ),
    );
  }
}
