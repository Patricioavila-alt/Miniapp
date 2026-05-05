import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';

// Modelo local para las vacunas
class VaccineOption {
  final String id;
  final String title;
  final String subtitle;
  final String price;
  final bool requiresDose;

  VaccineOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    this.requiresDose = false,
  });
}

class VaccineTypeScreen extends StatefulWidget {
  const VaccineTypeScreen({super.key});

  @override
  State<VaccineTypeScreen> createState() => _VaccineTypeScreenState();
}

class _VaccineTypeScreenState extends State<VaccineTypeScreen> {
  String? _selectedVaccineId;
  String? _selectedDose;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  final List<VaccineOption> _vaccines = [
    VaccineOption(
      id: 'influenza',
      title: 'Influenza',
      subtitle: 'Fluzactal / Vaxigrip Tetra\nDe 6 meses en adelante',
      price: '\$3,470.00 MXN',
    ),
    VaccineOption(
      id: 'covid',
      title: 'COVID-19',
      subtitle: 'Pfizer (Comirnaty)\nDe 5 años en adelante',
      price: '\$3,470.00 MXN',
      requiresDose: true,
    ),
    VaccineOption(
      id: 'herpes',
      title: 'Herpes Zóster',
      subtitle: 'Shingrix\nDe 50 años en adelante',
      price: '\$3,470.00 MXN',
    ),
    VaccineOption(
      id: 'vph_9',
      title: 'VPH',
      subtitle: 'Gardasil 9\nDe 9 años en adelante',
      price: '\$3,470.00 MXN',
    ),
    VaccineOption(
      id: 'vph_15',
      title: 'VPH',
      subtitle: 'Gardasil 9\nDe 15 años en adelante',
      price: '\$3,470.00 MXN',
    ),
    VaccineOption(
      id: 'neumococo',
      title: 'Neumococo',
      subtitle: 'PCV13 / PPSV23\nDe 2 meses en adelante',
      price: '\$3,470.00 MXN',
    ),
    VaccineOption(
      id: 'hepatitis_b',
      title: 'Hepatitis B',
      subtitle: 'Hepatitis B\nRecién nacido',
      price: '\$3,470.00 MXN',
    ),
    VaccineOption(
      id: 'tetanos_7',
      title: 'Tétanos-Difteria',
      subtitle: 'Tétanos-Difteria\nDe 7 años en adelante',
      price: '\$3,470.00 MXN',
    ),
    VaccineOption(
      id: 'tetanos_embarazo',
      title: 'Tétanos-Difteria-Tosferina',
      subtitle: 'Tétanos-Difteria-Tosferina\nEn el embarazo',
      price: '\$3,470.00 MXN',
    ),
    VaccineOption(
      id: 'tetanos_adulto',
      title: 'Tétanos-Difteria-Tosferina',
      subtitle: 'Tétanos-Difteria-Tosferina',
      price: '\$3,470.00 MXN',
    ),
  ];

  final List<String> _doses = [
    'Primera dosis',
    'Segunda dosis',
    'Tercera dosis',
    'Única dosis',
  ];

  bool get _isNextEnabled {
    if (_selectedVaccineId == null) return false;
    final selectedVac = _vaccines.firstWhere((v) => v.id == _selectedVaccineId);
    if (selectedVac.requiresDose && _selectedDose == null) return false;
    return true;
  }

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
                controller: _scrollController,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stepper Customizado
                      _buildCustomStepper(),
                      const SizedBox(height: 24),

                      // Info Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF3FF), // Azul claro
                          borderRadius: BorderRadius.circular(12),
                          border: const Border(
                            left: BorderSide(color: AppTheme.blue, width: 4),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_rounded,
                                color: AppTheme.blue, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Aplicación exclusiva en consultorio',
                                    style: AppTheme.bodyBold().copyWith(
                                        color: AppTheme.blue, fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'La vacuna se aplica por personal capacitado. El precio es por vacuna y aplicación.',
                                    style: AppTheme.body().copyWith(
                                        color: AppTheme.textPrimary,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.close_rounded,
                                color: AppTheme.textPrimary, size: 18),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Título
                      Text(
                        '¿Qué vacuna necesitas?',
                        style: AppTheme.heading2().copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 16),

                      // Lista de vacunas
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _vaccines.length,
                        separatorBuilder: (context, index) =>
                            const Divider(color: AppTheme.border, height: 1),
                        itemBuilder: (context, index) {
                          final vac = _vaccines[index];
                          final isSelected = _selectedVaccineId == vac.id;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedVaccineId = vac.id;
                                if (!vac.requiresDose) {
                                  _selectedDose =
                                      null; // Resetear dosis si no la necesita
                                }
                              });
                              if (vac.requiresDose) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (_scrollController.hasClients) {
                                    _scrollController.animateTo(
                                      _scrollController
                                          .position.maxScrollExtent,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeOut,
                                    );
                                  }
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Custom Radio Button
                                  Container(
                                    width: 24,
                                    height: 24,
                                    margin: const EdgeInsets.only(
                                        top: 2, right: 16),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(vac.title,
                                            style: AppTheme.bodyBold()
                                                .copyWith(fontSize: 15)),
                                        const SizedBox(height: 4),
                                        Text(vac.subtitle,
                                            style: AppTheme.body()
                                                .copyWith(fontSize: 13)),
                                        const SizedBox(height: 6),
                                        Text(
                                          vac.price,
                                          style: AppTheme.bodyBold().copyWith(
                                              fontSize: 12,
                                              color: AppTheme.textSecondary),
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

                      // Sección de Dosis (solo si _selectedVaccine requiere dosis)
                      if (_selectedVaccineId != null &&
                          _vaccines
                              .firstWhere((v) => v.id == _selectedVaccineId)
                              .requiresDose)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 32),
                            Text(
                              '¿Qué dosis te quieres aplicar?',
                              style: AppTheme.heading2().copyWith(fontSize: 18),
                            ),
                            const SizedBox(height: 16),
                            ..._doses.map((dose) {
                              final isSelected = _selectedDose == dose;
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedDose = dose;
                                  });
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        margin:
                                            const EdgeInsets.only(right: 16),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? AppTheme.blue
                                                : AppTheme.accent
                                                    .withOpacity(0.5),
                                            width: isSelected ? 6 : 1.5,
                                          ),
                                        ),
                                      ),
                                      Text(dose,
                                          style: AppTheme.body().copyWith(
                                              fontSize: 15,
                                              color: AppTheme.textPrimary)),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Botón Siguiente
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                border:
                    Border(top: BorderSide(color: AppTheme.border, width: 1)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isNextEnabled
                      ? () {
                          context.push(AppRoutes.vaccineQuestionnaire);
                        }
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
          _buildStepItem(Icons.vaccines, 'Tipo\nde vacuna', true, false),
          _buildDivider(false),
          _buildStepItem(Icons.storefront_outlined, 'Sucursal,\nfecha y hora',
              false, false),
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
        margin: const EdgeInsets.only(
            bottom: 24), // Para alinearlo con los círculos
      ),
    );
  }
}
