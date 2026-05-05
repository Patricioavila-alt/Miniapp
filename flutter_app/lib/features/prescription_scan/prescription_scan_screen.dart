import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/api/api_service.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';

// ─── Medication data model (mutable — edited by the user) ────────────────────
class _EditableMed {
  String name;
  String strength;      // gramaje seleccionado, e.g. "500mg"
  String dosage;        // instrucción de toma, e.g. "1 cápsula"
  String frequency;
  String duration;
  int quantity;
  final bool isAntibiotic;
  final bool isPsychotropic;
  final List<String> availableStrengths;
  final List<Map<String, dynamic>> alternatives;

  _EditableMed({
    required this.name,
    required this.strength,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.quantity,
    this.isAntibiotic = false,
    this.isPsychotropic = false,
    this.availableStrengths = const [],
    this.alternatives = const [],
  });

  factory _EditableMed.fromJson(Map<String, dynamic> json) => _EditableMed(
        name: json['name'] as String? ?? '',
        strength: json['strength'] as String? ?? '',
        dosage: json['dosage'] as String? ?? '',
        frequency: json['frequency'] as String? ?? '',
        duration: json['duration'] as String? ?? '',
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        isAntibiotic: json['is_antibiotic'] as bool? ?? false,
        isPsychotropic: json['is_psychotropic'] as bool? ?? false,
        availableStrengths:
            (json['available_strengths'] as List<dynamic>? ?? [])
                .whereType<String>()
                .toList(),
        alternatives: (json['alternatives'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .toList(),
      );
}

enum _ScanState { initial, loading, success, error }

// ─────────────────────────────────────────────────────────────────────────────
// PrescriptionScanScreen
// ─────────────────────────────────────────────────────────────────────────────
class PrescriptionScanScreen extends StatefulWidget {
  const PrescriptionScanScreen({super.key});

  @override
  State<PrescriptionScanScreen> createState() => _PrescriptionScanScreenState();
}

class _PrescriptionScanScreenState extends State<PrescriptionScanScreen> {
  _ScanState _state = _ScanState.initial;

  // Persists across scans — medications accumulate as the user adds more prescriptions
  final List<_EditableMed> _accumulated = [];
  Map<String, dynamic>? _lastScanInfo;
  String _errorMessage =
      'No pudimos validar tu receta. Intenta con una imagen más clara y legible.';

  // source == null → file picker (PDF/doc)
  Future<void> _pickAndValidate(ImageSource? source) async {
    String? filePath;

    try {
      if (source != null) {
        final picker = ImagePicker();
        final XFile? image =
            await picker.pickImage(source: source, imageQuality: 85);
        if (image == null) return;
        filePath = image.path;
      } else {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        );
        if (result == null || result.files.single.path == null) return;
        filePath = result.files.single.path!;
      }
    } catch (_) {
      return; // user cancelled or permission denied
    }

    if (!mounted) return;
    setState(() => _state = _ScanState.loading);

    try {
      final data = await ApiService.validatePrescription(filePath);
      if (!mounted) return;

      if (data['valid'] == true) {
        final newMeds = (data['medications'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(_EditableMed.fromJson)
            .toList();
        setState(() {
          _accumulated.addAll(newMeds);
          _lastScanInfo = data;
          _state = _ScanState.success;
        });
      } else {
        setState(() {
          _errorMessage = data['message'] as String? ?? _errorMessage;
          _state = _ScanState.error;
        });
      }
    } catch (e, st) {
      debugPrint('[PrescriptionScan] validate: $e\n$st');
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Error de conexión. Verifica tu red e intenta nuevamente.';
        _state = _ScanState.error;
      });
    }
  }

  // Returns to initial to scan another prescription; keeps accumulated meds
  void _prepareNewScan() => setState(() => _state = _ScanState.initial);

  void _handleContinue(BuildContext ctx) {
    final requiring = _accumulated
        .where((m) => m.isAntibiotic || m.isPsychotropic)
        .map((m) => {
              'name': '${m.name} ${m.strength}',
              'isAntibiotic': m.isAntibiotic,
              'isPsychotropic': m.isPsychotropic,
            })
        .toList();

    if (requiring.isNotEmpty) {
      ctx.push(AppRoutes.prescriptionDeliveryNote,
          extra: {'meds': requiring});
    } else {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text('Conectando con farmacia — próximamente.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Cargar receta',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        child: switch (_state) {
          _ScanState.initial => _InitialView(onPick: _pickAndValidate),
          _ScanState.loading => const _LoadingView(),
          _ScanState.success => _EditableSuccessView(
              key: ValueKey(_accumulated.length),
              meds: _accumulated,
              prescriptionInfo: _lastScanInfo!,
              onAddAnother: _prepareNewScan,
              onContinue: () => _handleContinue(context),
            ),
          _ScanState.error => _ErrorView(
              message: _errorMessage,
              onRetry: _prepareNewScan,
            ),
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _InitialView — opciones de origen
// ─────────────────────────────────────────────────────────────────────────────
class _InitialView extends StatelessWidget {
  final Future<void> Function(ImageSource?) onPick;
  const _InitialView({required this.onPick});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('initial'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.document_scanner_rounded,
                  size: 54, color: AppTheme.primary),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '¿Cómo deseas cargar\ntu receta médica?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nuestro sistema analizará tu receta y\nlocalizará tus medicamentos.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 40),
          _SourceCard(
            icon: Icons.camera_alt_rounded,
            title: 'Tomar foto',
            subtitle: 'Abre la cámara para fotografiar tu receta',
            onTap: () => onPick(ImageSource.camera),
          ),
          const SizedBox(height: 12),
          _SourceCard(
            icon: Icons.photo_library_rounded,
            title: 'Subir foto',
            subtitle: 'Selecciona una imagen de tu galería',
            onTap: () => onPick(ImageSource.gallery),
          ),
          const SizedBox(height: 12),
          _SourceCard(
            icon: Icons.upload_file_rounded,
            title: 'Subir documento',
            subtitle: 'PDF, JPG o PNG desde tu dispositivo',
            onTap: () => onPick(null),
          ),
          const SizedBox(height: 32),
          const Text(
            'Tus datos son procesados de forma\nsegura y confidencial.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12, color: AppTheme.accent, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _SourceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(icon, color: AppTheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        )),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.accent),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LoadingView
// ─────────────────────────────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      key: ValueKey('loading'),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 3),
            SizedBox(height: 32),
            Text(
              'Analizando tu receta médica...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Esto puede tardar unos segundos',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EditableSuccessView — lista editable de medicamentos detectados
// ─────────────────────────────────────────────────────────────────────────────
class _EditableSuccessView extends StatefulWidget {
  final List<_EditableMed> meds;
  final Map<String, dynamic> prescriptionInfo;
  final VoidCallback onAddAnother;
  final VoidCallback onContinue;

  const _EditableSuccessView({
    required super.key,
    required this.meds,
    required this.prescriptionInfo,
    required this.onAddAnother,
    required this.onContinue,
  });

  @override
  State<_EditableSuccessView> createState() => _EditableSuccessViewState();
}

class _EditableSuccessViewState extends State<_EditableSuccessView> {
  // Same reference as parent's _accumulated — mutations persist across scans
  late final List<_EditableMed> _meds;

  @override
  void initState() {
    super.initState();
    _meds = widget.meds;
  }

  Future<void> _deleteMed(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar medicamento'),
        content: Text(
            '¿Eliminar "${_meds[index].name} ${_meds[index].strength}" de tu receta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppTheme.accent)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar',
                style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() => _meds.removeAt(index));
  }

  Future<bool> _confirmStrengthChange({required bool isPsychotropic}) async {
    if (isPsychotropic) {
      // Psicotrópicos: advertencia más severa, no descartable con tap fuera
      return await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: AppTheme.error, size: 22),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Medicamento psicotrópico',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              content: const Text(
                'Este medicamento es de control especial. '
                'Modificar la dosis sin supervisión médica puede ser '
                'peligroso para tu salud y es de tu exclusiva responsabilidad.\n\n'
                '¿Deseas continuar de todas formas?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar',
                      style: TextStyle(color: AppTheme.accent)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text(
                    'Asumir responsabilidad',
                    style: TextStyle(
                        color: AppTheme.error, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ) ??
          false;
    }

    // Advertencia estándar para medicamentos no antibióticos y no psicotrópicos
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: const Text('Cambio de concentración'),
            content: const Text(
              'Cambiar la dosis sin consultar a tu médico puede ser riesgoso. '
              '¿Deseas continuar de todas formas?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar',
                    style: TextStyle(color: AppTheme.accent)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Continuar',
                    style: TextStyle(color: AppTheme.warning)),
              ),
            ],
          ),
        ) ??
        false;
  }

  // Called when user taps a gramaje chip directly on the card
  Future<void> _onStrengthTap(int index, String newStrength) async {
    if (_meds[index].strength == newStrength) return;
    // Antibiotics: no warning (critical dose set by doctor, user picks equivalent)
    // Non-antibiotics: require confirmation before changing
    if (!_meds[index].isAntibiotic) {
      final confirmed = await _confirmStrengthChange(
          isPsychotropic: _meds[index].isPsychotropic);
      if (!mounted || !confirmed) return;
    }
    setState(() => _meds[index].strength = newStrength);
  }

  // Applies edits from the edit sheet; may show dosage warning first
  Future<void> _applyEdit(int index, String name, String strength,
      String dosage, String frequency, String duration) async {
    if (strength != _meds[index].strength && !_meds[index].isAntibiotic) {
      if (!mounted) return;
      final confirmed = await _confirmStrengthChange(
          isPsychotropic: _meds[index].isPsychotropic);
      if (!mounted || !confirmed) return;
    }
    if (!mounted) return;
    setState(() {
      _meds[index]
        ..name = name
        ..strength = strength
        ..dosage = dosage
        ..frequency = frequency
        ..duration = duration;
    });
  }

  void _editMed(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditMedSheet(
        med: _meds[index],
        onSave: (name, strength, dosage, frequency, duration) {
          _applyEdit(index, name, strength, dosage, frequency, duration);
        },
      ),
    );
  }

  void _showAlternatives(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AlternativesSheet(
        currentName: '${_meds[index].name} ${_meds[index].strength}',
        alternatives: _meds[index].alternatives,
        onSelect: (alt) {
          Navigator.pop(context);
          setState(() {
            _meds[index].name = alt['name'] as String? ?? _meds[index].name;
            if (alt['strength'] != null) {
              _meds[index].strength = alt['strength'] as String;
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('success'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SuccessHeader(info: widget.prescriptionInfo),
          const SizedBox(height: 24),

          // Section header
          Row(
            children: [
              const Text(
                'Medicamentos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${_meds.length} detectado${_meds.length != 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 13, color: AppTheme.accent),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_meds.isEmpty)
            _EmptyMedsCard(onAddAnother: widget.onAddAnother)
          else ...[
            for (int i = 0; i < _meds.length; i++)
              _EditableMedCard(
                med: _meds[i],
                onDelete: () => _deleteMed(i),
                onEdit: () => _editMed(i),
                onStrengthTap: (s) => _onStrengthTap(i, s),
                onShowAlternatives: () => _showAlternatives(i),
              ),
          ],

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: _meds.isEmpty ? null : widget.onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              disabledBackgroundColor: AppTheme.border,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
              elevation: 0,
            ),
            child: const Text(
              'Ir al carrito',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: widget.onAddAnother,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.secondary,
              side: const BorderSide(color: AppTheme.border),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
            ),
            child: const Text(
              'Agregar otra receta',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SuccessHeader
// ─────────────────────────────────────────────────────────────────────────────
class _SuccessHeader extends StatelessWidget {
  final Map<String, dynamic> info;
  const _SuccessHeader({required this.info});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppTheme.success, size: 40),
              ),
              const SizedBox(height: 12),
              const Text(
                '¡Receta validada!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                info['message'] as String? ?? '',
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppTheme.border),
            boxShadow: AppTheme.shadowSoft,
          ),
          child: Column(
            children: [
              _DetailRow(
                  label: 'Paciente',
                  value: info['patient_name'] as String? ?? '-'),
              const Divider(height: 18, color: AppTheme.border),
              _DetailRow(
                  label: 'Médico',
                  value: info['doctor_name'] as String? ?? '-'),
              const Divider(height: 18, color: AppTheme.border),
              _DetailRow(
                  label: 'Fecha emisión',
                  value: info['issue_date'] as String? ?? '-'),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EditableMedCard — tarjeta de medicamento con chips de gramaje + acciones
// ─────────────────────────────────────────────────────────────────────────────
class _EditableMedCard extends StatelessWidget {
  final _EditableMed med;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final void Function(String) onStrengthTap;
  final VoidCallback onShowAlternatives;

  const _EditableMedCard({
    required this.med,
    required this.onDelete,
    required this.onEdit,
    required this.onStrengthTap,
    required this.onShowAlternatives,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: icon + name + actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 4, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.medication_rounded,
                      color: AppTheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${med.name} ${med.strength}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${med.dosage} · ${med.frequency}',
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        if (med.isPsychotropic) ...[
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.error.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: AppTheme.error.withOpacity(0.35)),
                            ),
                            child: const Text(
                              'Psicotrópico · Control especial',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.error,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      size: 18, color: AppTheme.accent),
                  onPressed: onEdit,
                  tooltip: 'Editar',
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      size: 18, color: AppTheme.error),
                  onPressed: onDelete,
                  tooltip: 'Eliminar',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

          // Concentración chips
          if (med.availableStrengths.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Concentración:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: med.availableStrengths.map((s) {
                      final isSelected = med.strength == s;
                      return ChoiceChip(
                        label: Text(s),
                        selected: isSelected,
                        onSelected: (_) => onStrengthTap(s),
                        selectedColor: AppTheme.primary.withOpacity(0.12),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.border,
                        ),
                        backgroundColor: AppTheme.surface,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        visualDensity: VisualDensity.compact,
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          // Duration + quantity
          Padding(
            padding: const EdgeInsets.fromLTRB(66, 6, 16, 14),
            child: Text(
              '${med.duration} · ${med.quantity} unidades',
              style: const TextStyle(fontSize: 12, color: AppTheme.accent),
            ),
          ),

          // Alternatives button
          if (med.alternatives.isNotEmpty) ...[
            const Divider(height: 1, color: AppTheme.border),
            TextButton.icon(
              onPressed: onShowAlternatives,
              icon: const Icon(Icons.swap_horiz_rounded,
                  size: 16, color: AppTheme.brandBlue),
              label: const Text(
                'Ver medicamentos equivalentes',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.brandBlue,
                ),
              ),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EmptyMedsCard
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyMedsCard extends StatelessWidget {
  final VoidCallback onAddAnother;
  const _EmptyMedsCard({required this.onAddAnother});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.medication_outlined,
              size: 40, color: AppTheme.accent),
          const SizedBox(height: 12),
          const Text(
            'No hay medicamentos en tu receta',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onAddAnother,
            child: const Text('Agregar otra receta',
                style: TextStyle(
                    color: AppTheme.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DetailRow — par label / valor alineados
// ─────────────────────────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: AppTheme.textSecondary)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EditMedSheet — bottom sheet para editar nombre/gramaje/dosis/frecuencia/duración
// ─────────────────────────────────────────────────────────────────────────────
class _EditMedSheet extends StatefulWidget {
  final _EditableMed med;
  final void Function(
      String name, String strength, String dosage, String frequency,
      String duration) onSave;

  const _EditMedSheet({required this.med, required this.onSave});

  @override
  State<_EditMedSheet> createState() => _EditMedSheetState();
}

class _EditMedSheetState extends State<_EditMedSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _dosageCtrl;
  late final TextEditingController _freqCtrl;
  late final TextEditingController _durCtrl;
  late String _selectedStrength;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.med.name);
    _dosageCtrl = TextEditingController(text: widget.med.dosage);
    _freqCtrl = TextEditingController(text: widget.med.frequency);
    _durCtrl = TextEditingController(text: widget.med.duration);
    _selectedStrength = widget.med.strength;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    _freqCtrl.dispose();
    _durCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Editar medicamento',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _SheetField(controller: _nameCtrl, label: 'Nombre del medicamento'),
          const SizedBox(height: 16),

          // Concentración chips inside the sheet
          if (widget.med.availableStrengths.isNotEmpty) ...[
            const Text(
              'Concentración',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: widget.med.availableStrengths.map((s) {
                final isSelected = _selectedStrength == s;
                return ChoiceChip(
                  label: Text(s),
                  selected: isSelected,
                  onSelected: (_) =>
                      setState(() => _selectedStrength = s),
                  selectedColor: AppTheme.primary.withOpacity(0.12),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppTheme.primary
                        : AppTheme.textSecondary,
                  ),
                  side: BorderSide(
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.border),
                  backgroundColor: AppTheme.surface,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  showCheckmark: false,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          _SheetField(
              controller: _dosageCtrl, label: 'Presentación (e.g., 1 cápsula)'),
          const SizedBox(height: 12),
          _SheetField(controller: _freqCtrl, label: 'Frecuencia'),
          const SizedBox(height: 12),
          _SheetField(controller: _durCtrl, label: 'Duración'),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final name = _nameCtrl.text.trim();
                final strength = _selectedStrength;
                final dosage = _dosageCtrl.text.trim();
                final frequency = _freqCtrl.text.trim();
                final duration = _durCtrl.text.trim();
                Navigator.of(context).pop();
                widget.onSave(name, strength, dosage, frequency, duration);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMd)),
                elevation: 0,
              ),
              child: const Text(
                'Guardar cambios',
                style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const _SheetField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.accent, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        filled: true,
        fillColor: AppTheme.background,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AlternativesSheet — bottom sheet para intercambiar por producto equivalente
// ─────────────────────────────────────────────────────────────────────────────
class _AlternativesSheet extends StatelessWidget {
  final String currentName;
  final List<Map<String, dynamic>> alternatives;
  final void Function(Map<String, dynamic>) onSelect;

  const _AlternativesSheet({
    required this.currentName,
    required this.alternatives,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Productos alternativos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Equivalentes terapéuticos de $currentName',
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          ...alternatives.map(
            (alt) => _AltItem(alt: alt, onSelect: () => onSelect(alt)),
          ),
        ],
      ),
    );
  }
}

class _AltItem extends StatelessWidget {
  final Map<String, dynamic> alt;
  final VoidCallback onSelect;
  const _AltItem({required this.alt, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final price = (alt['price'] as num?)?.toDouble();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.medication_rounded,
                color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${alt['name'] ?? ''} ${alt['strength'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      alt['brand'] as String? ?? '',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    if (price != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '\$${price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onSelect,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text(
              'Elegir',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.brandBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ErrorView
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('error'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  color: AppTheme.error, size: 44),
            ),
            const SizedBox(height: 24),
            const Text(
              'No pudimos validar\ntu receta',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMd)),
                  elevation: 0,
                ),
                child: const Text(
                  'Intentar de nuevo',
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
