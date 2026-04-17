import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../shared/widgets/skeleton_loader.dart';
import 'providers/health_record_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PrescriptionsScreen — Lista de Recetas Médicas
// ─────────────────────────────────────────────────────────────────────────────
class PrescriptionsScreen extends StatefulWidget {
  const PrescriptionsScreen({super.key});

  @override
  State<PrescriptionsScreen> createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen> {
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
          'Recetas médicas',
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
          final items = provider.prescriptions;
          if (items.isEmpty) {
            return const _EmptyState(
              icon: Icons.receipt_long_rounded,
              message: 'Sin recetas disponibles',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _PrescriptionCard(
              prescription: items[i],
              onTap: () => context
                  .push('/health-record/prescription/${items[i].id}'),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card de Receta
// ─────────────────────────────────────────────────────────────────────────────
class _PrescriptionCard extends StatelessWidget {
  final Prescription prescription;
  final VoidCallback onTap;

  const _PrescriptionCard({
    required this.prescription,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = prescription.status == 'active';

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
                color: isActive
                    ? AppTheme.primary.withOpacity(0.08)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                color: isActive ? AppTheme.primary : const Color(0xFFAAAAAA),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // Detalles
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prescription.diagnosis,
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
                    prescription.doctorName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Badge status
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppTheme.primary.withOpacity(0.1)
                              : const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isActive ? 'Activa' : 'Completada',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? AppTheme.primary
                                : const Color(0xFF888888),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        prescription.date,
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
