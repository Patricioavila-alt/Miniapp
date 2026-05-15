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
  final _descController = TextEditingController();
  bool _hasAttemptedSubmit = false;

  // null = sin selección, true = primera vez, false = seguimiento
  bool? _isFirstVisit;

  // Chips rápidos — cambian según el tipo de visita
  static const _firstVisitChips = [
    'Fiebre',
    'Dolor de cabeza',
    'Tos',
    'Dolor de garganta',
    'Náuseas',
    'Fatiga',
    'Dolor de cuerpo',
    'Mareos',
  ];

  static const _followUpChips = [
    'Mejoría parcial',
    'Sin cambios',
    'Empeoré',
    'Efectos secundarios',
    'Dudas sobre mi tratamiento',
    'Revisión de estudios',
    'Nueva molestia',
  ];

  List<String> get _currentChips =>
      _isFirstVisit == true ? _firstVisitChips : _followUpChips;

  final Set<String> _selectedChips = {};

  bool get _isTypeSelected => _isFirstVisit != null;
  bool get _isDescValid => _descController.text.trim().length >= 10;
  bool get _isValid => _isTypeSelected && _isDescValid;

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  void _onTypeSelected(bool isFirst) {
    setState(() {
      _isFirstVisit = isFirst;
      _selectedChips.clear();
      _descController.clear();
    });
  }

  void _toggleChip(String chip) {
    setState(() {
      if (_selectedChips.contains(chip)) {
        _selectedChips.remove(chip);
      } else {
        _selectedChips.add(chip);
      }
      _rebuildText();
    });
  }

  void _rebuildText() {
    final chips = _selectedChips.join(', ');
    _descController.text = chips;
    _descController.selection = TextSelection.fromPosition(
      TextPosition(offset: _descController.text.length),
    );
  }

  // ─── copy dinámico según tipo de visita ────────────────────────────────────
  String get _title => _isFirstVisit == true
      ? '¿Qué síntomas o molestias tienes?'
      : '¿Cómo has evolucionado desde tu última consulta?';

  String get _subtitle => _isFirstVisit == true
      ? 'Cuéntanos brevemente qué está pasando para que el médico llegue bien preparado.'
      : 'Cuéntanos si mejoraste, si tienes nuevas molestias o dudas sobre tu tratamiento.';

  String get _chipsLabel => _isFirstVisit == true
      ? 'Síntomas frecuentes'
      : 'Estado de tu evolución';

  String get _textLabel => _isFirstVisit == true
      ? 'Describe tus síntomas *'
      : 'Cuéntanos cómo te has sentido *';

  String get _placeholder => _isFirstVisit == true
      ? 'Ej. Llevo 3 días con fiebre de 38°C, dolor de cabeza intenso y mucho cansancio...'
      : 'Ej. Mejoré los primeros días pero el dolor de cabeza regresó. También tengo dudas sobre si debo continuar con el antibiótico...';

  @override
  Widget build(BuildContext context) {
    final typeError = _hasAttemptedSubmit && !_isTypeSelected;
    final descError = _hasAttemptedSubmit && !_isDescValid;

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
                          // ── Tipo de visita ──────────────────────────────
                          Text(
                            '¿Es tu primera visita o es un seguimiento?',
                            style: AppTheme.heading2().copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Esto nos ayuda a preparar mejor tu atención.',
                            style: AppTheme.body().copyWith(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildTypeButton(
                                label: 'Primera vez',
                                icon: Icons.person_add_alt_1_outlined,
                                isSelected: _isFirstVisit == true,
                                onTap: () => _onTypeSelected(true),
                              ),
                              const SizedBox(width: 12),
                              _buildTypeButton(
                                label: 'Seguimiento',
                                icon: Icons.update_rounded,
                                isSelected: _isFirstVisit == false,
                                onTap: () => _onTypeSelected(false),
                              ),
                            ],
                          ),
                          if (typeError)
                            const Padding(
                              padding: EdgeInsets.only(top: 8, left: 4),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      color: Color(0xFFEF4444), size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'Selecciona el tipo de cita para continuar.',
                                    style: TextStyle(
                                        color: Color(0xFFEF4444), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),

                          // ── Contenido dinámico (solo visible tras seleccionar tipo) ──
                          if (_isFirstVisit != null) ...[
                            const SizedBox(height: 28),
                            const Divider(height: 1),
                            const SizedBox(height: 24),

                            Text(
                              _title,
                              style:
                                  AppTheme.heading2().copyWith(fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _subtitle,
                              style: AppTheme.body().copyWith(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Chips rápidos
                            Text(
                              _chipsLabel,
                              style: AppTheme.bodyBold().copyWith(
                                fontSize: 13,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _currentChips.map((chip) {
                                final isSelected = _selectedChips.contains(chip);
                                return GestureDetector(
                                  onTap: () => _toggleChip(chip),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFEFF4FF)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF13299D)
                                            : AppTheme.border,
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Text(
                                      chip,
                                      style: AppTheme.body().copyWith(
                                        fontSize: 13,
                                        color: isSelected
                                            ? const Color(0xFF13299D)
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
                              _textLabel,
                              style: AppTheme.body().copyWith(
                                color: descError
                                    ? const Color(0xFFEF4444)
                                    : AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _descController,
                              maxLines: 6,
                              maxLength: 500,
                              onChanged: (_) => setState(() {}),
                              style: AppTheme.body().copyWith(
                                fontSize: 14,
                                color: AppTheme.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: _placeholder,
                                hintStyle: AppTheme.body().copyWith(
                                  color: AppTheme.textSecondary.withOpacity(0.6),
                                  fontSize: 13,
                                ),
                                filled: true,
                                fillColor: descError
                                    ? const Color(0xFFFDE8E8)
                                    : const Color(0xFFF9F9F9),
                                contentPadding: const EdgeInsets.all(16),
                                alignLabelWithHint: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: descError
                                        ? const Color(0xFFEF4444)
                                        : AppTheme.border,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: descError
                                        ? const Color(0xFFEF4444)
                                        : AppTheme.border,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: descError
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
                            if (descError)
                              const Padding(
                                padding: EdgeInsets.only(top: 4, left: 4),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline,
                                        color: Color(0xFFEF4444), size: 14),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Describe tu consulta con al menos 10 caracteres.',
                                        style: TextStyle(
                                            color: Color(0xFFEF4444),
                                            fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Botón Siguiente — deshabilitado hasta que todo esté completo
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
                  onPressed: _isValid
                      ? () => context.push(AppRoutes.consultBranch)
                      : () => setState(() => _hasAttemptedSubmit = true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isValid
                        ? const Color(0xFF13299D)
                        : const Color(0xFFE0E0E0),
                    disabledBackgroundColor: const Color(0xFFE0E0E0),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  child: Text(
                    'Siguiente',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _isValid ? Colors.white : const Color(0xFFAAAAAA),
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

  Widget _buildTypeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF4FF) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF13299D) : AppTheme.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 28,
                color: isSelected
                    ? const Color(0xFF13299D)
                    : AppTheme.textSecondary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTheme.bodyBold().copyWith(
                  fontSize: 14,
                  color: isSelected
                      ? const Color(0xFF13299D)
                      : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
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
