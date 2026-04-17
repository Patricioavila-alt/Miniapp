import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/api_service.dart';
import '../../core/models/models.dart';

class SignDocumentScreen extends StatefulWidget {
  final String documentId;
  const SignDocumentScreen({super.key, required this.documentId});

  @override
  State<SignDocumentScreen> createState() => _SignDocumentScreenState();
}

class _SignDocumentScreenState extends State<SignDocumentScreen> {
  SignatureDocument? _document;
  bool _isLoading = true;
  bool _isSigning = false;
  bool _hasSigned = false;
  final _signKey = GlobalKey<SignatureState>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final docs = await ApiService.getSignatureDocuments();
      final doc = docs.firstWhere(
        (d) => d.id == widget.documentId,
        orElse: () => throw Exception('Not found'),
      );
      setState(() { _document = doc; _isLoading = false; });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sign() async {
    setState(() => _isSigning = true);
    try {
      await ApiService.signDocument(widget.documentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documento firmado exitosamente')),
        );
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al firmar el documento')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSigning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Firmar Documento', style: AppTheme.heading2()),
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
                      Text(_document!.title, style: AppTheme.heading2()),
                      const SizedBox(height: 8),
                      Text(_document!.date, style: AppTheme.caption()),
                      const SizedBox(height: AppTheme.gap),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Text(_document!.contentPreview, style: AppTheme.body()),
                      ),
                      const SizedBox(height: AppTheme.gap),
                      Text('Firma Digital', style: AppTheme.heading3()),
                      const SizedBox(height: 12),
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(
                            color: _hasSigned ? AppTheme.primary : AppTheme.border,
                            width: _hasSigned ? 2 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd - 1),
                          child: Signature(
                            key: _signKey,
                            color: AppTheme.secondary,
                            strokeWidth: 2.5,
                            onSign: () => setState(() => _hasSigned = true),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              _signKey.currentState?.clear();
                              setState(() => _hasSigned = false);
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text('Limpiar'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.gap),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (_hasSigned && !_isSigning) ? _sign : null,
                          child: _isSigning
                              ? const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Confirmar y Firmar'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
