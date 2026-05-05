import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Modelos locales de datos
// ─────────────────────────────────────────────────────────────────────────────
class _ServiceOption {
  final String id;
  final String title;
  final String description;
  final String price;

  const _ServiceOption({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
  });
}

// Catálogo de pruebas
const _testOptions = [
  _ServiceOption(
    id: 'covid_antigen',
    title: 'Antígeno COVID-19',
    description: 'Detecta presencia activa del virus SARS-CoV-2.\nA partir de 2 años.',
    price: '\$1,000.00\u200AMXN',
  ),
  _ServiceOption(
    id: 'influenza',
    title: 'Influenza',
    description: 'Detecta activamente el virus A o B.\nA partir de 2 años.',
    price: '\$1,000.00\u200AMXN',
  ),
  _ServiceOption(
    id: 'duo',
    title: 'DUO (Influenza + COVID)',
    description: 'Ideal en temporada de enfermedades respiratorias.\nA partir de 5 años.',
    price: '\$1,000.00\u200AMXN',
  ),
  _ServiceOption(
    id: 'rapidas',
    title: 'Rápidas generales',
    description: 'Glucosa, Embarazo o VIH. Consulta disponibilidad.',
    price: '\$1,000.00\u200AMXN',
  ),
];

// Catálogo de vacunas
const _vaccineOptions = [
  _ServiceOption(
    id: 'vph',
    title: 'Vacuna VPH',
    description: 'Protege contra el Virus del Papiloma Humano.\nA partir de 9 años.',
    price: '\$1,500.00\u200AMXN',
  ),
  _ServiceOption(
    id: 'influenza_vac',
    title: 'Influenza',
    description: 'Protección anual contra la influenza estacional.\nA partir de 6 meses.',
    price: '\$350.00\u200AMXN',
  ),
  _ServiceOption(
    id: 'covid_vac',
    title: 'COVID-19',
    description: 'Vacuna de refuerzo contra el SARS-CoV-2.\nMayores de 12 años.',
    price: '\$950.00\u200AMXN',
  ),
  _ServiceOption(
    id: 'hepatitis_b',
    title: 'Hepatitis B',
    description: 'Esquema completo de 3 dosis.\nTodas las edades.',
    price: '\$650.00\u200AMXN',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// TestAppointmentScreen — Paso 1: Selección de tipo de prueba/vacuna
// ─────────────────────────────────────────────────────────────────────────────
class TestAppointmentScreen extends StatefulWidget {
  final String type; // 'test' | 'vaccine'
  const TestAppointmentScreen({super.key, required this.type});

  @override
  State<TestAppointmentScreen> createState() => _TestAppointmentScreenState();
}

class _TestAppointmentScreenState extends State<TestAppointmentScreen> {
  String? _selectedId;

  bool get _isVaccine => widget.type == 'vaccine';
  List<_ServiceOption> get _options => _isVaccine ? _vaccineOptions : _testOptions;

  String get _title => _isVaccine ? 'Cita para vacunas' : 'Cita para pruebas';
  String get _question => _isVaccine
      ? '¿Qué vacuna necesitas aplicarte?'
      : '¿Qué prueba necesitas realizarte?';
  String get _disclaimer => _isVaccine
      ? 'La administración de vacunas es realizada por personal capacitado. Consulta disponibilidad en tu sucursal.'
      : 'Esta prueba es de carácter orientativo. Para diagnóstico definitivo, acude con un médico.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _title,
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Stepper ──────────────────────────────────────────────────────
          _AppointmentStepper(
            currentStep: 0,
            isVaccine: _isVaccine,
          ),

          // ── Lista scrollable ─────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Título de sección
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 44, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _question,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_up_rounded,
                          color: Color(0xFF444444), size: 24),
                    ],
                  ),
                ),

                // Items de selección
                ..._options.map((option) => _ServiceRadioItem(
                      option: option,
                      isSelected: _selectedId == option.id,
                      onTap: () => setState(() => _selectedId = option.id),
                    )),

                const SizedBox(height: 16),
              ],
            ),
          ),

          // ── Disclaimer + Botón ───────────────────────────────────────────
          Container(
            color: const Color(0xFFF8F8F8),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text(
              _disclaimer,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF888888),
                height: 1.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _selectedId == null
                    ? null
                    : () {
                        // TODO: Navegar al paso 2 (Sucursal, fecha y hora)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Seleccionaste: ${_options.firstWhere((o) => o.id == _selectedId).title}'),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedId != null
                      ? const Color(0xFF1E3A8A)
                      : const Color(0xFFE0E0E0),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  disabledBackgroundColor: const Color(0xFFE0E0E0),
                  disabledForegroundColor: const Color(0xFF999999),
                ),
                child: const Text(
                  'Siguiente',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AppointmentStepper — Indicador de 4 pasos
// ─────────────────────────────────────────────────────────────────────────────
class _AppointmentStepper extends StatelessWidget {
  final int currentStep; // 0-based
  final bool isVaccine;

  const _AppointmentStepper({
    required this.currentStep,
    required this.isVaccine,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      (icon: Icons.biotech_rounded, label: isVaccine ? 'Tipo\nde vacuna' : 'Tipo\nde prueba'),
      (icon: Icons.calendar_month_rounded, label: 'Sucursal,\nfecha y hora'),
      (icon: Icons.person_outline_rounded, label: 'Información\ndel paciente'),
      (icon: Icons.check_box_outlined, label: 'Confirmar\ncita'),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Línea conectora
            final stepIdx = i ~/ 2;
            final isCompleted = stepIdx < currentStep;
            return Expanded(
              child: Container(
                height: 2,
                color: isCompleted
                    ? const Color(0xFF1E3A8A)
                    : const Color(0xFFDDDDDD),
              ),
            );
          }
          final stepIdx = i ~/ 2;
          final isActive = stepIdx == currentStep;
          final isCompleted = stepIdx < currentStep;
          final step = steps[stepIdx];

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive || isCompleted
                      ? const Color(0xFF1E3A8A)
                      : Colors.white,
                  border: Border.all(
                    color: isActive || isCompleted
                        ? const Color(0xFF1E3A8A)
                        : const Color(0xFFCCCCCC),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  step.icon,
                  size: 18,
                  color: isActive || isCompleted
                      ? Colors.white
                      : const Color(0xFFAAAAAA),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                step.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  height: 1.3,
                  fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive
                      ? const Color(0xFF1E3A8A)
                      : const Color(0xFF999999),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ServiceRadioItem — Row seleccionable de servicio
// ─────────────────────────────────────────────────────────────────────────────
class _ServiceRadioItem extends StatelessWidget {
  final _ServiceOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServiceRadioItem({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Radio button
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF1E3A8A)
                        : const Color(0xFFCCCCCC),
                    width: isSelected ? 6 : 1.5,
                  ),
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    option.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF777777),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    option.price,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: 0.1,
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
}
