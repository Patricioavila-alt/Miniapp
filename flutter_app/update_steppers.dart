import 'dart:io';

void main() {
  final dir = Directory('lib/features/appointments');
  final files = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    
    // Si es de vacunas
    if (file.path.contains('vaccine_')) {
      content = content.replaceAll(RegExp(r'Widget _buildCustomStepper\(\) \{[\s\S]*?Widget _buildDivider\(bool isActive\) \{[\s\S]*?\}\s*\}', multiLine: true), '''
  Widget _buildCustomStepper() {
    return SizedBox(
      width: double.infinity,
      child: SvgPicture.asset(
        \\'assets/icons/StepperVacunas.svg\\',
        fit: BoxFit.contain,
      ),
    );
  }
''');
      file.writeAsStringSync(content);
      print('Updated ${file.path}');
    }
    
    // Si es de pruebas
    if (file.path.contains('test_') && !file.path.contains('test_appointment_screen')) {
      content = content.replaceAll(RegExp(r'Widget _buildCustomStepper\(\) \{[\s\S]*?Widget _buildDivider\(bool isActive\) \{[\s\S]*?\}\s*\}', multiLine: true), '''
  Widget _buildCustomStepper() {
    return SizedBox(
      width: double.infinity,
      child: SvgPicture.asset(
        \\'assets/icons/StepperPruebas.svg\\',
        fit: BoxFit.contain,
      ),
    );
  }
''');
      file.writeAsStringSync(content);
      print('Updated ${file.path}');
    }
  }
}
