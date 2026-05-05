import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
// ignore: unused_import
import '../../core/routes/app_routes.dart';

// Modelo simulado para sucursales
class BranchOption {
  final String id;
  final String name;
  final String address;

  BranchOption({
    required this.id,
    required this.name,
    required this.address,
  });
}

class VaccineBranchScreen extends StatefulWidget {
  const VaccineBranchScreen({super.key});

  @override
  State<VaccineBranchScreen> createState() => _VaccineBranchScreenState();
}

class _VaccineBranchScreenState extends State<VaccineBranchScreen> {
  String? _selectedBranchId;
  String? _selectedState;
  String? _selectedMunicipality;

  final List<String> _states = [
    'Baja California Sur',
    'Ciudad de México',
    'Coahuila',
    'Colima',
    'Chiapas'
  ];

  final List<String> _municipalities = [
    'Benito Juárez',
    'Cuauhtémoc',
    'Coyoacán',
  ];

  final List<BranchOption> _branches = [
    BranchOption(
      id: 'scop',
      name: 'México Centro, Centro SCOP',
      address:
          'AV UNIVERSIDAD 216 Y 218 COL: NARVARTE CIUDAD DE MEXICO, CIUDAD DE MEXICO MX',
    ),
    BranchOption(
      id: 'eugenia',
      name: 'México Centro, Eugenia',
      address:
          'AV CUAUHTEMOC 919-B COL: NARVARTE CIUDAD DE MEXICO, CIUDAD DE MEXICO MX',
    ),
    BranchOption(
      id: 'xola',
      name: 'México Centro, Xola',
      address:
          'XOLA 1001 COL: NARVARTE PONIENTE CIUDAD DE MEXICO, CIUDAD DE MEXICO MX',
    ),
    BranchOption(
      id: 'viaducto',
      name: 'México Centro, Viaducto',
      address:
          'CALZ. DE TLALPAN 449 A COL: ALAMOS CIUDAD DE MEXICO, CIUDAD DE MEXICO MX',
    ),
    BranchOption(
      id: 'del_valle',
      name: 'México Centro, Del Valle',
      address:
          'AV. XOLA 701 COL: DEL VALLE NORTE CIUDAD DE MEXICO, CIUDAD DE MEXICO MX',
    ),
    BranchOption(
      id: 'gabriel_mancera',
      name: 'México Centro, Gabriel Mancera',
      address:
          'GABRIEL MANCERA 123 COL: DEL VALLE CIUDAD DE MEXICO, CIUDAD DE MEXICO MX',
    ),
  ];

  bool get _isNextEnabled => _selectedBranchId != null;

  @override
  Widget build(BuildContext context) {
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
          'Cita para vacuna',
          style: AppTheme.heading2().copyWith(fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        // Stepper con fondo blanco
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          child: _buildCustomStepper(),
                        ),
                        // Área simulada del mapa interactivo
                        _buildMapSection(),
                        // Resto del contenido
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMyAddressCard(),
                              const SizedBox(height: 32),
                              Text(
                                'Elige tu sucursal',
                                style:
                                    AppTheme.heading2().copyWith(fontSize: 20),
                              ),
                              const SizedBox(height: 16),
                              _buildFilters(),
                              const SizedBox(height: 24),
                              Text(
                                '${_branches.length} resultados',
                                style: AppTheme.bodyBold().copyWith(
                                  color: AppTheme.textSecondary,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final branch = _branches[index];
                          final isSelected = _selectedBranchId == branch.id;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedBranchId = branch.id;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFEFF4FF)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(
                                            0xFF3B82F6) // Azul selección
                                        : AppTheme.border,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      color: isSelected
                                          ? const Color(0xFF3B82F6)
                                          : AppTheme.textSecondary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            branch.name,
                                            style: AppTheme.bodyBold().copyWith(
                                              color: isSelected
                                                  ? const Color(0xFF3B82F6)
                                                  : AppTheme.textPrimary,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            branch.address,
                                            style: AppTheme.body().copyWith(
                                              color: AppTheme.textSecondary,
                                              fontSize: 12,
                                              height: 1.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: _branches.length,
                      ),
                    ),
                  ),
                  // Espacio al final
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
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
                  onPressed: _isNextEnabled
                      ? () {
                          context.push(AppRoutes.vaccineDateTime);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF13299D),
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

  Widget _buildMapSection() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: const BoxDecoration(
        color: Color(0xFFE5E9EC), // Color base para mapa de fondo
        border: Border(
          bottom: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Fondo simulado de calles con íconos
          Opacity(
            opacity: 0.1,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
              ),
              itemBuilder: (context, index) => const Icon(Icons.add, size: 24),
            ),
          ),
          // Algunos pines dispersos
          const Positioned(top: 40, left: 60, child: _MapPin()),
          const Positioned(top: 80, right: 80, child: _MapPin()),
          const Positioned(bottom: 50, left: 150, child: _MapPin(isMain: true)),

          // Controles de mapa simulados
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.my_location_rounded,
                  color: AppTheme.textPrimary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF), // Azul muy muy claro
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD6E4FF)), // Azul borde suave
      ),
      child: Row(
        children: [
          const Icon(Icons.home_outlined,
              color: AppTheme.textPrimary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mi dirección',
                    style: AppTheme.bodyBold().copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  'Av. Universidad 697, 03023',
                  style: AppTheme.body()
                      .copyWith(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Botón Usar mi dirección
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF3B82F6)),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    color: Color(0xFF3B82F6), size: 16),
                const SizedBox(width: 6),
                Text(
                  'Usar mi dirección',
                  style: AppTheme.bodyBold()
                      .copyWith(color: const Color(0xFF3B82F6), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Dropdown Estado
          _buildDropdownFilter(
            label: 'Estado',
            value: _selectedState,
            items: _states,
            onChanged: (val) => setState(() => _selectedState = val),
          ),
          const SizedBox(width: 12),
          // Dropdown Municipio
          _buildDropdownFilter(
            label: 'Municipio',
            value: _selectedMunicipality,
            items: _municipalities,
            onChanged: (val) => setState(() => _selectedMunicipality = val),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: value != null ? const Color(0xFF3B82F6) : AppTheme.border,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            label,
            style: AppTheme.body()
                .copyWith(color: AppTheme.textPrimary, fontSize: 13),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: value != null
                ? const Color(0xFF3B82F6)
                : AppTheme.textSecondary,
            size: 20,
          ),
          isDense: true,
          style: AppTheme.body().copyWith(
            color:
                value != null ? const Color(0xFF3B82F6) : AppTheme.textPrimary,
            fontSize: 13,
            fontWeight: value != null ? FontWeight.w600 : FontWeight.w400,
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

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
          _buildStepItem(Icons.check, 'Tipo\nde vacuna', true, false,
              isCompleted: true),
          _buildDivider(true),
          _buildStepItem(Icons.storefront_outlined, 'Sucursal,\nfecha y hora',
              true, false),
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
              border: Border.all(
                color: color,
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
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

class _MapPin extends StatelessWidget {
  final bool isMain;
  const _MapPin({this.isMain = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isMain ? 36 : 24,
      height: isMain ? 36 : 24,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFD32F2F), width: 1.5),
      ),
      child: Center(
        child: Text(
          'A',
          style: TextStyle(
            color: const Color(0xFFD32F2F),
            fontWeight: FontWeight.w900,
            fontSize: isMain ? 18 : 12,
            fontFamily: 'Arial',
          ),
        ),
      ),
    );
  }
}
