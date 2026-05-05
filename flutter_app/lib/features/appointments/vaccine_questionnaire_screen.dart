import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';

class VaccineQuestionnaireScreen extends StatefulWidget {
  const VaccineQuestionnaireScreen({super.key});

  @override
  State<VaccineQuestionnaireScreen> createState() =>
      _VaccineQuestionnaireScreenState();
}

class _VaccineQuestionnaireScreenState
    extends State<VaccineQuestionnaireScreen> {
  // null = not answered, true = Yes, false = No
  bool? _allergicReaction;
  bool? _isPregnant;

  bool get _isNextEnabled {
    return _allergicReaction != null && _isPregnant != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8), // Fondo gris clarito
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stepper con fondo blanco
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: _buildCustomStepper(),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Antes de continuar necesitamos confirmar algunos datos',
                            style: AppTheme.body().copyWith(
                                fontSize: 15, color: const Color(0xFF555555)),
                          ),
                          const SizedBox(height: 24),

                          // Tarjeta 1: Alergia
                          _QuestionCard(
                            question:
                                '¿El paciente ha tenido alguna reacción alérgica grave a una vacuna?',
                            yesLabel: 'Sí ha tenido',
                            noLabel: 'No ha tenido',
                            yesIcon: Icons.sentiment_dissatisfied_outlined,
                            noIcon: Icons.sentiment_satisfied_outlined,
                            selectedValue: _allergicReaction,
                            onChanged: (val) =>
                                setState(() => _allergicReaction = val),
                          ),

                          const SizedBox(height: 16),

                          // Tarjeta 2: Embarazo
                          _QuestionCard(
                            question:
                                '¿El paciente está embarazada o cree que podría estarlo?',
                            yesLabel: 'Sí está embarazada',
                            noLabel: 'No lo está',
                            yesIcon: Icons.pregnant_woman_rounded,
                            noIcon: Icons.sentiment_satisfied_outlined,
                            selectedValue: _isPregnant,
                            onChanged: (val) =>
                                setState(() => _isPregnant = val),
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
                border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isNextEnabled
                      ? () {
                          if (_allergicReaction == true || _isPregnant == true) {
                            _showErrorModal(context);
                          } else {
                            context.push(AppRoutes.vaccineBranch);
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF13299D), // Azul oscuro FDA
                    disabledBackgroundColor: const Color(0xFFE0E0E0),
                    disabledForegroundColor: const Color(0xFFAAAAAA),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  child: const Text('Siguiente',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                // Ícono ilustrativo
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF8E6), // Amarillo muy claro
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.warning_rounded, color: Color(0xFFF59E0B), size: 60),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.vaccines_rounded, color: AppTheme.blue, size: 24),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'Por seguridad del paciente, no podemos continuar con la cita',
                  style: AppTheme.heading2().copyWith(fontSize: 22, height: 1.3),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Es necesario contar con una valoración médica previa antes de continuar con la cita.',
                  style: AppTheme.body().copyWith(color: AppTheme.textSecondary, fontSize: 15, height: 1.4),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.pop(); // cerrar modal
                      context.push(AppRoutes.videoCall);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF13299D),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                    child: const Text('Hablar con un médico', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go(AppRoutes.home),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEEF4FF), // Azul muy claro
                      foregroundColor: const Color(0xFF13299D),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                    child: const Text('Salir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  // Se reutiliza el stepper visual con "Tipo de vacuna" activo
  Widget _buildCustomStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepItem(Icons.vaccines, 'Tipo\nde vacuna', true, false),
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
      ),
    );
  }

  Widget _buildStepItem(
      IconData icon, String label, bool isActive, bool isLast) {
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
            child: Icon(
              icon,
              color: isActive ? AppTheme.blue : AppTheme.accent,
              size: 20,
            ),
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

class _QuestionCard extends StatelessWidget {
  final String question;
  final String yesLabel;
  final String noLabel;
  final IconData yesIcon;
  final IconData noIcon;
  final bool? selectedValue;
  final ValueChanged<bool> onChanged;

  const _QuestionCard({
    required this.question,
    required this.yesLabel,
    required this.noLabel,
    required this.yesIcon,
    required this.noIcon,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: AppTheme.body().copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF333333),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _OptionButton(
                  label: yesLabel,
                  icon: yesIcon,
                  isSelected: selectedValue == true,
                  onTap: () => onChanged(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OptionButton(
                  label: noLabel,
                  icon: noIcon,
                  isSelected: selectedValue == false,
                  onTap: () => onChanged(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : AppTheme.border, // Azul si seleccionado
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF555555),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
