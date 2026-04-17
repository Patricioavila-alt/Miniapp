import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/api_service.dart';
import '../../core/models/models.dart';

class DocumentDetailScreen extends StatefulWidget {
  final String documentId;
  const DocumentDetailScreen({super.key, required this.documentId});

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  ClinicalDocument? _document;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final doc = await ApiService.getDocument(widget.documentId);
      setState(() { _document = doc; _isLoading = false; });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Documento Clínico', style: AppTheme.heading2()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _document == null
              ? Center(child: Text('Documento no encontrado', style: AppTheme.body()))
              : SingleChildScrollView(
                  padding: AppTheme.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary,
                          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Documento', style: AppTheme.label().copyWith(color: AppTheme.accent)),
                            const SizedBox(height: 8),
                            Text(_document!.title,
                                style: AppTheme.heading2().copyWith(color: Colors.white)),
                            const SizedBox(height: 8),
                            Text('Dr. ${_document!.doctorName}',
                                style: AppTheme.body().copyWith(color: AppTheme.accent)),
                            Text(_document!.date,
                                style: AppTheme.caption().copyWith(color: Colors.white60)),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.gap),
                      Text('Resumen', style: AppTheme.heading3()),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(color: AppTheme.border),
                          boxShadow: AppTheme.shadowSoft,
                        ),
                        child: Text(_document!.summary, style: AppTheme.body()),
                      ),
                    ],
                  ),
                ),
    );
  }
}
