import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/api_service.dart';
import '../../core/models/models.dart';

class PrescriptionDetailScreen extends StatefulWidget {
  final String prescriptionId;
  const PrescriptionDetailScreen({super.key, required this.prescriptionId});

  @override
  State<PrescriptionDetailScreen> createState() =>
      _PrescriptionDetailScreenState();
}

class _PrescriptionDetailScreenState extends State<PrescriptionDetailScreen> {
  Prescription? _prescription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rx = await ApiService.getPrescription(widget.prescriptionId);
      setState(() { _prescription = rx; _isLoading = false; });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Receta Médica', style: AppTheme.heading2()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _prescription == null
              ? Center(child: Text('Receta no encontrada', style: AppTheme.body()))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final rx = _prescription!;
    return SingleChildScrollView(
      padding: AppTheme.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor + diagnóstico
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: AppTheme.border),
              boxShadow: AppTheme.shadowSoft,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Diagnóstico', style: AppTheme.label()),
                const SizedBox(height: 4),
                Text(rx.diagnosis, style: AppTheme.heading3()),
                const Divider(color: AppTheme.border, height: 24),
                Text('Dr.: ${rx.doctorName}', style: AppTheme.bodyBold()),
                Text(rx.doctorSpecialty, style: AppTheme.caption()),
                Text('Fecha: ${rx.date}', style: AppTheme.caption()),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.gap),

          // Medicamentos
          Text('Medicamentos', style: AppTheme.heading3()),
          const SizedBox(height: 16),
          ...rx.medications.map((med) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight, shape: BoxShape.circle),
                  child: const Icon(Icons.medication_rounded, color: AppTheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(med.name, style: AppTheme.bodyBold()),
                      Text(med.dosage, style: AppTheme.caption()),
                      Text('Duración: ${med.duration}',
                          style: AppTheme.caption().copyWith(color: AppTheme.primary)),
                    ],
                  ),
                ),
              ],
            ),
          )),

          // Notas
          if (rx.notes.isNotEmpty) ...[
            const SizedBox(height: AppTheme.gap),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.secondary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppTheme.secondary, size: 18),
                      const SizedBox(width: 8),
                      Text('Indicaciones', style: AppTheme.bodyBold().copyWith(color: AppTheme.secondary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(rx.notes, style: AppTheme.body()),
                ],
              ),
            ),
          ],

          // QR Code
          const SizedBox(height: AppTheme.gap),
          Text('Código QR de Receta', style: AppTheme.heading3()),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.border),
                boxShadow: AppTheme.shadowSoft,
              ),
              child: QrImageView(
                data: rx.qrCodeData,
                version: QrVersions.auto,
                size: 180,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppTheme.secondary,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppTheme.secondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
