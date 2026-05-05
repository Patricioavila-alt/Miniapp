import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';

class DateTestOption {
  final String dayNumber;
  final String dayName;
  final bool isAvailable;
  DateTestOption(this.dayNumber, this.dayName, {this.isAvailable = true});
}

class TimeTestOption {
  final String time;
  final bool isAvailable;
  TimeTestOption(this.time, {this.isAvailable = true});
}

class TestDateTimeScreen extends StatefulWidget {
  const TestDateTimeScreen({super.key});
  @override
  State<TestDateTimeScreen> createState() => _TestDateTimeScreenState();
}

class _TestDateTimeScreenState extends State<TestDateTimeScreen> {
  final List<String> _offices = ['Consultorio Xola 1', 'Consultorio Xola 2', 'Consultorio Xola 3'];
  String? _selectedOffice = 'Consultorio Xola 1';

  final List<String> _months = ['Noviembre', 'Diciembre'];
  String? _selectedMonth = 'Noviembre';

  final List<DateTestOption> _dates = [
    DateTestOption('17', 'Mar'),
    DateTestOption('18', 'Mié', isAvailable: false),
    DateTestOption('19', 'Jue'),
    DateTestOption('20', 'Vie'),
    DateTestOption('21', 'Sáb', isAvailable: false),
    DateTestOption('22', 'Dom'),
    DateTestOption('23', 'Lun'),
  ];
  DateTestOption? _selectedDate;

  final List<TimeTestOption> _times = [
    TimeTestOption('09:00'), TimeTestOption('09:15'), TimeTestOption('09:30'), TimeTestOption('09:45'),
    TimeTestOption('10:00'), TimeTestOption('10:15'), TimeTestOption('10:30'), TimeTestOption('10:45', isAvailable: false),
    TimeTestOption('11:00', isAvailable: false), TimeTestOption('11:15'), TimeTestOption('11:30', isAvailable: false),
    TimeTestOption('11:45', isAvailable: false), TimeTestOption('12:00'), TimeTestOption('12:15'),
    TimeTestOption('12:30'), TimeTestOption('12:45'), TimeTestOption('13:00'), TimeTestOption('13:15'),
    TimeTestOption('13:30'), TimeTestOption('13:45'), TimeTestOption('14:00'),
    TimeTestOption('14:15', isAvailable: false), TimeTestOption('14:30'), TimeTestOption('14:45', isAvailable: false),
  ];
  TimeTestOption? _selectedTime;

  bool get _isNextEnabled => _selectedDate != null && _selectedTime != null;

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

                    // Consultorios
                    Container(
                      color: Colors.white,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text('Elige un consultorio', style: AppTheme.heading2().copyWith(fontSize: 18)),
                          ),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: _offices.map((office) {
                                final isSelected = _selectedOffice == office;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedOffice = office),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.white : const Color(0xFFF5F5F5),
                                      border: Border(
                                        bottom: BorderSide(
                                          color: isSelected ? const Color(0xFF13299D) : Colors.transparent,
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                    child: Text(office, style: AppTheme.bodyBold().copyWith(
                                        color: isSelected ? const Color(0xFF13299D) : AppTheme.textSecondary, fontSize: 14)),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Fechas
                    Container(
                      color: Colors.white,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text('¿Cuándo te gustaría realizarte la prueba?',
                                style: AppTheme.heading2().copyWith(fontSize: 18)),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: _buildMonthDropdown(),
                          ),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: _dates.map((date) {
                                final isSelected = _selectedDate == date;
                                return _buildDateCard(date, isSelected);
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Horarios
                    Container(
                      color: Colors.white,
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Selecciona el horario que prefieras',
                              style: AppTheme.heading2().copyWith(fontSize: 18)),
                          const SizedBox(height: 4),
                          Text('Zona horaria: (UTC-06:00) Ciudad de México',
                              style: AppTheme.body().copyWith(color: AppTheme.textSecondary, fontSize: 13)),
                          const SizedBox(height: 24),
                          GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.2,
                            ),
                            itemCount: _times.length,
                            itemBuilder: (context, index) {
                              final time = _times[index];
                              final isSelected = _selectedTime == time;
                              return _buildTimePill(time, isSelected);
                            },
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: TextButton(
                              onPressed: () {},
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Text('Ver más horarios', style: AppTheme.bodyBold().copyWith(color: const Color(0xFF13299D), fontSize: 14)),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF13299D), size: 20),
                              ]),
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
                border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isNextEnabled ? () => context.push(AppRoutes.testPatientInfo) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF13299D),
                    disabledBackgroundColor: const Color(0xFFE0E0E0),
                    disabledForegroundColor: const Color(0xFFAAAAAA),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                  ),
                  child: const Text('Siguiente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.border)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedMonth,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF13299D), size: 20),
          isDense: true,
          style: AppTheme.body().copyWith(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
          items: _months.map((m) => DropdownMenuItem<String>(value: m, child: Text(m))).toList(),
          onChanged: (val) => setState(() => _selectedMonth = val),
        ),
      ),
    );
  }

  Widget _buildDateCard(DateTestOption date, bool isSelected) {
    return GestureDetector(
      onTap: date.isAvailable ? () => setState(() => _selectedDate = date) : null,
      child: Container(
        width: 60, height: 70,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : (date.isAvailable ? AppTheme.border : const Color(0xFFEEEEEE)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(date.dayNumber, style: AppTheme.heading2().copyWith(
              color: isSelected ? const Color(0xFF3B82F6) : (date.isAvailable ? AppTheme.textPrimary : const Color(0xFFCCCCCC)), fontSize: 18)),
          const SizedBox(height: 2),
          Text(date.dayName, style: AppTheme.body().copyWith(
              color: isSelected ? const Color(0xFF3B82F6) : (date.isAvailable ? AppTheme.textSecondary : const Color(0xFFCCCCCC)), fontSize: 12)),
        ]),
      ),
    );
  }

  Widget _buildTimePill(TimeTestOption time, bool isSelected) {
    return GestureDetector(
      onTap: time.isAvailable ? () => setState(() => _selectedTime = time) : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : (time.isAvailable ? AppTheme.border : const Color(0xFFEEEEEE)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(time.time, style: AppTheme.bodyBold().copyWith(
            color: isSelected ? const Color(0xFF3B82F6) : (time.isAvailable ? AppTheme.textPrimary : const Color(0xFFCCCCCC)), fontSize: 13)),
      ),
    );
  }

  Widget _buildCustomStepper() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      _buildStepItem(Icons.check, 'Tipo\nde prueba', true, isCompleted: true),
      _buildDivider(true),
      _buildStepItem(Icons.storefront_outlined, 'Sucursal,\nfecha y hora', true),
      _buildDivider(false),
      _buildStepItem(Icons.person_outline, 'Información\ndel paciente', false),
      _buildDivider(false),
      _buildStepItem(Icons.event_available_outlined, 'Confirmar\ncita', false),
    ]);
  }

  Widget _buildStepItem(IconData icon, String label, bool isActive, {bool isCompleted = false}) {
    final color = isCompleted ? const Color(0xFF13299D) : (isActive ? const Color(0xFF3B82F6) : AppTheme.accent);
    final bgColor = isCompleted ? const Color(0xFF13299D) : Colors.transparent;
    return Expanded(flex: 2, child: Column(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle, border: Border.all(color: color, width: 1.5)),
        child: Icon(icon, color: isCompleted ? Colors.white : color, size: 20),
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
