import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
// ignore: unused_import
import '../../core/routes/app_routes.dart';

class TestPatientInfoScreen extends StatefulWidget {
  const TestPatientInfoScreen({super.key});

  @override
  State<TestPatientInfoScreen> createState() => _TestPatientInfoScreenState();
}

class _TestPatientInfoScreenState extends State<TestPatientInfoScreen> {
  bool _isForMe = true;
  bool _hasAttemptedSubmit = false;

  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _curpController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cpController = TextEditingController();
  final _streetController = TextEditingController();
  final _extNumController = TextEditingController();
  final _intNumController = TextEditingController();

  String? _gender;
  String? _birthState;
  String? _addressState;
  String? _municipality;
  String? _colonia;

  final List<String> _genders = ['Mujer', 'Hombre', 'No binario'];
  final List<String> _states = ['Baja California Sur', 'Campeche', 'Chiapas', 'Chihuahua', 'Ciudad de México'];
  final List<String> _municipalities = ['Benito Juárez', 'Cuauhtémoc', 'Coyoacán'];
  final List<String> _colonias = ['Narvarte Poniente', 'Del Valle', 'Roma'];

  @override
  void initState() {
    super.initState();
    _fillMyData();
  }

  @override
  void dispose() {
    _nameController.dispose(); _dobController.dispose(); _curpController.dispose();
    _emailController.dispose(); _phoneController.dispose(); _cpController.dispose();
    _streetController.dispose(); _extNumController.dispose(); _intNumController.dispose();
    super.dispose();
  }

  void _fillMyData() {
    setState(() {
      _nameController.text = 'Alejandra Valverde Salgado';
      _dobController.text = '01/Agosto/1990';
      _gender = 'Mujer';
      _birthState = 'Ciudad de México';
      _curpController.text = 'VALS900801MDFXXX00';
      _emailController.text = 'alejandra@correo.com';
      _phoneController.text = '5500000000';
      _cpController.text = '03023';
      _addressState = 'Ciudad de México';
      _municipality = 'Benito Juárez';
      _colonia = 'Narvarte Poniente';
      _streetController.text = 'Av Universidad';
      _extNumController.text = '697';
      _intNumController.text = '12';
    });
  }

  void _clearData() {
    setState(() {
      _nameController.clear(); _dobController.clear(); _gender = null; _birthState = null;
      _curpController.clear(); _emailController.clear(); _phoneController.clear();
      _cpController.clear(); _addressState = null; _municipality = null; _colonia = null;
      _streetController.clear(); _extNumController.clear(); _intNumController.clear();
    });
  }

  bool get _isDateFilled => _dobController.text.isNotEmpty;
  bool get _isUnderage {
    if (!_isDateFilled) return false;
    final match = RegExp(r'\d{4}$').firstMatch(_dobController.text);
    if (match != null) {
      final year = int.tryParse(match.group(0)!);
      if (year != null) return (DateTime.now().year - year) < 18;
    }
    return false;
  }
  bool get _isCurpValid => _curpController.text.length >= 18;
  bool get _isEmailValid => RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text);
  bool get _isPhoneValid => _phoneController.text.length == 10;

  bool _isFormValid() {
    return _nameController.text.isNotEmpty && _isDateFilled && !_isUnderage &&
        _gender != null && _birthState != null &&
        _curpController.text.isNotEmpty && _isCurpValid &&
        _emailController.text.isNotEmpty && _isEmailValid &&
        _phoneController.text.isNotEmpty && _isPhoneValid &&
        _cpController.text.isNotEmpty && _addressState != null &&
        _municipality != null && _colonia != null &&
        _streetController.text.isNotEmpty && _extNumController.text.isNotEmpty;
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
                  children: [
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: _buildCustomStepper(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('¿Para quién es esta prueba?', style: AppTheme.heading2().copyWith(fontSize: 18)),
                          const SizedBox(height: 16),
                          Row(children: [
                            _buildTargetButton(title: 'Para mí', icon: Icons.person_outline, isSelected: _isForMe, onTap: () {
                              if (!_isForMe) { setState(() => _isForMe = true); _fillMyData(); }
                            }),
                            const SizedBox(width: 12),
                            _buildTargetButton(title: 'Para otra persona', icon: Icons.group_outlined, isSelected: !_isForMe, onTap: () {
                              if (_isForMe) { setState(() => _isForMe = false); _clearData(); }
                            }),
                          ]),
                          const SizedBox(height: 24),
                          _CollapsibleSection(
                            title: 'Información personal del paciente',
                            initiallyExpanded: true,
                            child: _buildPersonalInfoForm(),
                          ),
                          const SizedBox(height: 16),
                          _CollapsibleSection(
                            title: 'Dirección',
                            initiallyExpanded: false,
                            child: _buildAddressForm(),
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
                border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _hasAttemptedSubmit = true);
                    if (_isFormValid()) context.push(AppRoutes.testConfirmation);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF13299D),
                    disabledBackgroundColor: const Color(0xFFE0E0E0),
                    disabledForegroundColor: const Color(0xFFAAAAAA),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                  ),
                  child: const Text('Siguiente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetButton({required String title, required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isSelected ? const Color(0xFF13299D) : AppTheme.border, width: isSelected ? 1.5 : 1),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 18, color: isSelected ? const Color(0xFF13299D) : AppTheme.textPrimary),
            const SizedBox(width: 8),
            Text(title, style: AppTheme.bodyBold().copyWith(color: isSelected ? const Color(0xFF13299D) : AppTheme.textPrimary, fontSize: 13)),
          ]),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoForm() {
    final bool isReadOnly = _isForMe;
    String? nameError = (_hasAttemptedSubmit && _nameController.text.isEmpty) ? 'Este campo es requerido' : null;
    String? dobError;
    if (_hasAttemptedSubmit) {
      if (!_isDateFilled) dobError = 'Este campo es requerido';
      else if (_isUnderage) dobError = 'Ingresa una fecha válida.';
    }
    String? curpError;
    if (_hasAttemptedSubmit) {
      if (_curpController.text.isEmpty) curpError = 'Este campo es requerido';
      else if (!_isCurpValid) curpError = 'Ingresa una CURP válida.';
    }
    String? emailError;
    if (_hasAttemptedSubmit) {
      if (_emailController.text.isEmpty) emailError = 'Este campo es requerido';
      else if (!_isEmailValid) emailError = 'Revisa que tu correo tenga un formato válido';
    }
    String? phoneError;
    if (_hasAttemptedSubmit) {
      if (_phoneController.text.isEmpty) phoneError = 'Este campo es requerido';
      else if (!_isPhoneValid) phoneError = 'Ingresa un número de 10 dígitos';
    }
    String? genderError = (_hasAttemptedSubmit && _gender == null) ? 'Este campo es requerido' : null;
    String? stateError = (_hasAttemptedSubmit && _birthState == null) ? 'Este campo es requerido' : null;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (_hasAttemptedSubmit && _isUnderage)
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFFDE8E8), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFCA5A5))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.cancel, color: Color(0xFFEF4444), size: 20),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Edad fuera del rango permitido', style: AppTheme.bodyBold().copyWith(color: const Color(0xFF991B1B))),
              const SizedBox(height: 4),
              Text('Esta prueba no se puede realizar para la edad del paciente. Puedes revisar los datos ingresados o elegir otra.',
                  style: AppTheme.body().copyWith(color: const Color(0xFF7F1D1D))),
            ])),
            const Icon(Icons.close, color: AppTheme.textSecondary, size: 20),
          ]),
        ),
      _buildTextField('Nombre completo *', _nameController, readOnly: isReadOnly, errorText: nameError),
      _buildTextField('Fecha de nacimiento *', _dobController, readOnly: isReadOnly, prefixIcon: Icons.calendar_today_outlined, errorText: dobError),
      _buildDropdown('¿Cuál es tu género? *', _gender, _genders, (val) { if (!isReadOnly) setState(() => _gender = val); }, readOnly: isReadOnly, errorText: genderError),
      _buildDropdown('Estado de nacimiento *', _birthState, _states, (val) { if (!isReadOnly) setState(() => _birthState = val); }, readOnly: isReadOnly, errorText: stateError),
      _buildTextField('CURP *', _curpController, readOnly: isReadOnly, errorText: curpError),
      _buildTextField('Correo electrónico *', _emailController, readOnly: false, errorText: emailError),
      _buildPhoneField('Teléfono *', _phoneController, errorText: phoneError),
    ]);
  }

  Widget _buildAddressForm() {
    String? getError(TextEditingController ctrl) => (_hasAttemptedSubmit && ctrl.text.isEmpty) ? 'Este campo es requerido' : null;
    String? getDropdownError(String? val) => (_hasAttemptedSubmit && val == null) ? 'Este campo es requerido' : null;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: () {},
        child: Row(children: [
          const Icon(Icons.location_on_outlined, color: Color(0xFF3B82F6), size: 20),
          const SizedBox(width: 8),
          Text('Usar mi ubicación', style: AppTheme.bodyBold().copyWith(color: const Color(0xFF3B82F6), fontSize: 14, decoration: TextDecoration.underline)),
        ]),
      ),
      const SizedBox(height: 24),
      _buildTextField('Código postal *', _cpController, errorText: getError(_cpController)),
      _buildDropdown('Estado *', _addressState, _states, (val) => setState(() => _addressState = val), errorText: getDropdownError(_addressState)),
      _buildDropdown('Municipio *', _municipality, _municipalities, (val) => setState(() => _municipality = val), errorText: getDropdownError(_municipality)),
      _buildDropdown('Colonia *', _colonia, _colonias, (val) => setState(() => _colonia = val), errorText: getDropdownError(_colonia)),
      _buildTextField('Calle *', _streetController, errorText: getError(_streetController)),
      _buildTextField('Número exterior *', _extNumController, errorText: getError(_extNumController)),
      _buildTextField('Número interior', _intNumController),
    ]);
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false, IconData? prefixIcon, String? errorText}) {
    final bool hasError = errorText != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppTheme.body().copyWith(color: hasError ? const Color(0xFFEF4444) : AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onChanged: (_) { if (_hasAttemptedSubmit) setState(() {}); },
          style: AppTheme.body().copyWith(color: readOnly ? AppTheme.textSecondary : AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: hasError ? const Color(0xFFFDE8E8) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: hasError ? const Color(0xFFEF4444) : AppTheme.textSecondary, size: 20) : null,
            suffixIcon: hasError ? const Icon(Icons.cancel, color: Color(0xFFEF4444), size: 20) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: hasError ? const Color(0xFFEF4444) : AppTheme.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: hasError ? const Color(0xFFEF4444) : AppTheme.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: hasError ? const Color(0xFFEF4444) : const Color(0xFF13299D))),
          ),
        ),
        if (hasError) Padding(
          padding: const EdgeInsets.only(top: 4, left: 4),
          child: Row(children: [
            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 14),
            const SizedBox(width: 4),
            Text(errorText, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildPhoneField(String label, TextEditingController controller, {String? errorText}) {
    final bool hasError = errorText != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppTheme.body().copyWith(color: hasError ? const Color(0xFFEF4444) : AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Container(width: 24, height: 16, color: Colors.green, child: const Center(child: Icon(Icons.flag, size: 12, color: Colors.white))),
              const SizedBox(width: 8),
              Text('+52', style: AppTheme.body().copyWith(fontSize: 14)),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(child: TextFormField(
            controller: controller,
            onChanged: (_) { if (_hasAttemptedSubmit) setState(() {}); },
            keyboardType: TextInputType.phone,
            style: AppTheme.body().copyWith(fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: hasError ? const Color(0xFFFDE8E8) : Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: hasError ? const Icon(Icons.cancel, color: Color(0xFFEF4444), size: 20) : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: hasError ? const Color(0xFFEF4444) : AppTheme.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: hasError ? const Color(0xFFEF4444) : AppTheme.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: hasError ? const Color(0xFFEF4444) : const Color(0xFF13299D))),
            ),
          )),
        ]),
        if (hasError) Padding(
          padding: const EdgeInsets.only(top: 4, left: 4),
          child: Row(children: [
            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 14),
            const SizedBox(width: 4),
            Text(errorText, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged, {bool readOnly = false, String? errorText}) {
    final bool hasError = errorText != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppTheme.body().copyWith(color: hasError ? const Color(0xFFEF4444) : AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: hasError ? const Color(0xFFFDE8E8) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: hasError ? const Color(0xFFEF4444) : AppTheme.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value, isExpanded: true,
              hint: Text('Selecciona una opción', style: AppTheme.body().copyWith(color: AppTheme.textSecondary, fontSize: 14)),
              icon: Icon(Icons.arrow_drop_down, color: hasError ? const Color(0xFFEF4444) : AppTheme.textSecondary),
              style: AppTheme.body().copyWith(color: readOnly ? AppTheme.textSecondary : AppTheme.textPrimary, fontSize: 14),
              items: items.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
              onChanged: readOnly ? null : (val) { onChanged(val); if (_hasAttemptedSubmit) setState(() {}); },
            ),
          ),
        ),
        if (hasError) Padding(
          padding: const EdgeInsets.only(top: 4, left: 4),
          child: Row(children: [
            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 14),
            const SizedBox(width: 4),
            Text(errorText, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildCustomStepper() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      _buildStepItem(Icons.check, 'Tipo\nde prueba', true, isCompleted: true),
      _buildDivider(true),
      _buildStepItem(Icons.check, 'Sucursal,\nfecha y hora', true, isCompleted: true),
      _buildDivider(true),
      _buildStepItem(Icons.person_outline, 'Información\ndel paciente', true),
      _buildDivider(false),
      _buildStepItem(Icons.event_available_outlined, 'Confirmar\ncita', false),
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
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

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
