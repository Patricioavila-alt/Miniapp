import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../shared/widgets/skeleton_loader.dart';
import 'providers/health_record_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ClinicalDocumentsScreen — Resultados de pruebas / documentos clínicos
// ─────────────────────────────────────────────────────────────────────────────
class ClinicalDocumentsScreen extends StatefulWidget {
  const ClinicalDocumentsScreen({super.key});

  @override
  State<ClinicalDocumentsScreen> createState() =>
      _ClinicalDocumentsScreenState();
}

class _ClinicalDocumentsScreenState extends State<ClinicalDocumentsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<HealthRecordProvider>().fetchAll());
  }

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
        title: const Text(
          'Resultados de pruebas',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<HealthRecordProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const ListScreenSkeleton();
          if (provider.error != null) {
            return ErrorBanner(onRetry: provider.fetchAll);
          }
          final items = provider.documents;
          if (items.isEmpty) {
            return const _EmptyState(
              icon: Icons.biotech_rounded,
              message: 'Sin resultados disponibles',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _DocumentCard(
              document: items[i],
              onTap: () =>
                  context.push('/health-record/document/${items[i].id}'),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card de Documento Clínico
// ─────────────────────────────────────────────────────────────────────────────
class _DocumentCard extends StatelessWidget {
  final ClinicalDocument document;
  final VoidCallback onTap;

  const _DocumentCard({required this.document, required this.onTap});

  IconData get _icon {
    switch (document.type) {
      case 'lab_result':
        return Icons.biotech_rounded;
      case 'consultation_summary':
        return Icons.description_rounded;
      default:
        return Icons.folder_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ícono
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, color: AppTheme.blue, size: 24),
            ),
            const SizedBox(width: 14),

            // Detalles
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    document.doctorName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.blue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Disponible',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        document.date,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFAAAAAA),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFCCCCCC), size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Estado vacío
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: const Color(0xFFCCCCCC)),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: Color(0xFF888888)),
          ),
        ],
      ),
    );
  }
}
