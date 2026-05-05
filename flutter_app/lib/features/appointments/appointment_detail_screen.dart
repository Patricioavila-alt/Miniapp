import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../core/api/api_service.dart';
import '../../core/models/models.dart';

final _mxnFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 2);
const double _priceVideo   = 850.0;
const double _priceVaccine = 3470.0;
const double _priceTest    = 1000.0;

class AppointmentDetailScreen extends StatefulWidget {
  final String appointmentId;
  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  Appointment? _appointment;
  bool _isLoading = true;

  // Estados simulados para MVP
  // 'pending_payment' | 'paid' | 'confirmed' | 'validating' | 'no_show' | 'cancelled'
  String _localStatus = 'pending_payment';

  // Motivo de cancelación — vendrá del API en producción
  final String _cancellationReason = 'Cancelado voluntariamente por el usuario.';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final apt = await ApiService.getAppointment(widget.appointmentId);
      setState(() {
        _appointment = apt;
        _localStatus = apt.paymentStatus == 'pending' ? 'pending_payment' : 'paid';
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  /// Reagendar: solo si quedan >24h Y no está cancelada
  bool get _canReschedule {
    if (_localStatus == 'cancelled') return false;
    return true; // En producción parsear la fecha del API
  }

  /// No mostrar "Cancelar cita" si ya está cancelada, validando o no asistió
  bool get _showCancelLink =>
      _localStatus != 'cancelled' && _localStatus != 'no_show' && _localStatus != 'validating';

  void _cycleStatus() {
    const cycle = ['pending_payment', 'paid', 'confirmed', 'validating', 'no_show', 'cancelled'];
    final idx = cycle.indexOf(_localStatus);
    setState(() => _localStatus = cycle[(idx + 1) % cycle.length]);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.primary)));
    }

    final apt = _appointment;
    final isTest = apt?.isTest == true;
    final isVaccine = apt?.isVaccine == true;
    final payLabel = isTest ? 'Pagar prueba' : (isVaccine ? 'Pagar vacuna' : 'Pagar consulta');
    final paidLabel = isTest ? 'Prueba pagada' : (isVaccine ? 'Vacuna pagada' : 'Consulta pagada');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Detalle de la cita', style: AppTheme.heading2().copyWith(fontSize: 17)),
        centerTitle: true,
        actions: [
          if (kDebugMode)
            GestureDetector(
              onTap: _cycleStatus,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text('Sim.', style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ──── HEADER: Folio + badge ────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FAV${widget.appointmentId.hashCode.abs() % 1000}',
                          style: AppTheme.heading1().copyWith(
                            color: AppTheme.brandBlue,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildStatusBadge(paidLabel),
                      ],
                    ),
                  ),

                  const Divider(color: AppTheme.border, height: 1),

                  // ──── TIMELINE ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: _buildTimeline(payLabel, paidLabel),
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: AppTheme.border, height: 1),
                  const SizedBox(height: 8),

                  // ──── ACORDEONES ───────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _CollapsibleSection(
                          title: isTest ? 'Tipo de prueba' : (isVaccine ? 'Tipo de vacuna' : 'Tipo de consulta'),
                          initiallyExpanded: true,
                          child: _buildTypeSummary(apt),
                        ),
                        const SizedBox(height: 16),
                        _CollapsibleSection(
                          title: 'Datos del paciente',
                          initiallyExpanded: true,
                          child: _buildPatientSummary(),
                        ),
                        const SizedBox(height: 16),
                        _CollapsibleSection(
                          title: 'Detalle de aplicación',
                          initiallyExpanded: true,
                          child: _buildApplicationSummary(apt),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ──── BOTONES INFERIORES ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
            ),
            child: Column(
              children: [
                // Reagendar — solo si quedan >24h y no está cancelada
                if (_canReschedule)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go(AppRoutes.scheduleType),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.brandBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                        elevation: 0,
                      ),
                      child: const Text('Reagendar',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                if (_canReschedule) const SizedBox(height: 12),
                // Cancelar cita — oculto si ya está cancelada, no asistió o validando
                if (_showCancelLink)
                  GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('La cancelación estará disponible próximamente.')),
                    ),
                    child: Text(
                      'Cancelar cita',
                      style: AppTheme.bodyBold().copyWith(
                        color: AppTheme.brandBlue,
                        fontSize: 15,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Badge de estado ──────────────────────────────────────────────────────────
  Widget _buildStatusBadge(String paidLabel) {
    switch (_localStatus) {
      case 'paid':
        return _badge(Icons.check_circle_rounded, paidLabel, AppTheme.success, const Color(0xFFECFDF5));
      case 'confirmed':
        return _badge(Icons.check_circle_rounded, 'Asistencia confirmada', AppTheme.success, const Color(0xFFECFDF5));
      case 'validating':
        return _badge(Icons.biotech_rounded, 'Validando resultado', const Color(0xFF1D4ED8), const Color(0xFFEFF6FF));
      case 'no_show':
        return _badge(Icons.cancel_outlined, 'No asistió', AppTheme.textSecondary, const Color(0xFFF3F4F6));
      case 'cancelled':
        return _badgeCancelled();
      default: // pending_payment
        return _badge(Icons.schedule_rounded, 'Pendiente de pago', AppTheme.warning, const Color(0xFFFEF9C3));
    }
  }

  Widget _badge(IconData icon, String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(label, style: AppTheme.bodyBold().copyWith(color: color, fontSize: 13)),
      ]),
    );
  }

  Widget _badgeCancelled() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge rojo
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.close_rounded, color: AppTheme.error, size: 16),
            const SizedBox(width: 6),
            Text('Cancelada',
                style: AppTheme.bodyBold().copyWith(color: AppTheme.error, fontSize: 13)),
          ]),
        ),
        const SizedBox(height: 10),
        // Motivo de cancelación
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFECACA)),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.info_outline_rounded, color: AppTheme.error, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Motivo de cancelación',
                    style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF9B1C1C))),
                const SizedBox(height: 2),
                Text(
                  _cancellationReason,
                  style: GoogleFonts.manrope(fontSize: 12, color: const Color(0xFF9B1C1C), height: 1.4),
                ),
              ]),
            ),
          ]),
        ),
      ],
    );
  }

  // ── Timeline ─────────────────────────────────────────────────────────────────
  Widget _buildTimeline(String payLabel, String paidLabel) {
    // Definir qué pasos están completados y cuál es el activo
    final steps = _buildSteps(payLabel, paidLabel);
    return Column(
      children: steps.asMap().entries.map((e) {
        final i = e.key;
        final step = e.value;
        final isLast = i == steps.length - 1;
        return _TimelineRow(step: step, isLast: isLast, onPay: () {
          setState(() => _localStatus = 'paid');
        });
      }).toList(),
    );
  }

  List<_StepData> _buildSteps(String payLabel, String paidLabel) {
    switch (_localStatus) {
      case 'pending_payment':
        return [
          _StepData(label: 'Cita agendada', state: _StepState.completed),
          _StepData(
            label: payLabel,
            state: _StepState.active,
            description: 'Completa el pago para asegurar tu cita y bloquear el horario en la sucursal.',
            showPayButton: true,
            payButtonLabel: payLabel,
          ),
        ];
      case 'paid':
        return [
          _StepData(label: 'Cita agendada', state: _StepState.completed),
          _StepData(label: paidLabel, state: _StepState.completed),
          _StepData(label: 'Asistencia confirmada', state: _StepState.active,
              description: 'Tu pago fue registrado. Preséntate en la sucursal a la hora indicada.'),
        ];
      case 'confirmed':
        return [
          _StepData(label: 'Cita agendada', state: _StepState.completed),
          _StepData(label: paidLabel, state: _StepState.completed),
          _StepData(label: 'Asistencia confirmada', state: _StepState.completed),
        ];
      case 'validating':
        return [
          _StepData(label: 'Cita agendada', state: _StepState.completed),
          _StepData(label: paidLabel, state: _StepState.completed),
          _StepData(label: 'Asistencia confirmada', state: _StepState.completed),
          _StepData(label: 'Validando resultado', state: _StepState.active,
              description: 'Estamos validando tu resultado con el equipo médico.'),
        ];
      case 'no_show':
        return [
          _StepData(label: 'Cita agendada', state: _StepState.completed),
          _StepData(label: paidLabel, state: _StepState.completed),
          _StepData(label: 'Asistencia confirmada', state: _StepState.completed),
          _StepData(label: 'No asistió', state: _StepState.noShow),
        ];
      case 'cancelled':
        return [
          _StepData(label: 'Cita agendada', state: _StepState.completed),
          _StepData(label: paidLabel, state: _StepState.completed),
          _StepData(label: 'Cita cancelada', state: _StepState.cancelled),
        ];
      default:
        return [_StepData(label: 'Cita agendada', state: _StepState.completed)];
    }
  }

  // ── Acordeones ────────────────────────────────────────────────────────────────
  Widget _buildTypeSummary(Appointment? apt) {
    final isTest = apt?.isTest == true;
    final isVaccine = apt?.isVaccine == true;

    final IconData typeIcon = isTest
        ? Icons.biotech_rounded
        : (isVaccine ? Icons.vaccines_rounded : Icons.local_hospital_rounded);
    final Color iconBg = isTest
        ? const Color(0xFFEFF6FF)
        : (isVaccine ? const Color(0xFFE8F5E9) : AppTheme.primaryLight);
    final Color iconColor = isTest
        ? const Color(0xFF1D4ED8)
        : (isVaccine ? const Color(0xFF2E7D32) : AppTheme.primary);

    // Nombre desde doctorSpecialty, descripción desde notes
    final String itemName = apt?.doctorSpecialty ?? '—';
    final String itemDesc = apt?.notes ?? '';
    final double amount = apt?.price ?? (isTest ? _priceTest : isVaccine ? _priceVaccine : _priceVideo);
    final String price = _mxnFormat.format(amount);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
          child: Icon(typeIcon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(itemName,
              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          if (itemDesc.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(itemDesc,
                style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.textSecondary, height: 1.4)),
          ],
          const SizedBox(height: 8),
          RichText(text: TextSpan(children: [
            TextSpan(text: price,
                style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            TextSpan(text: ' MXN',
                style: GoogleFonts.manrope(fontSize: 10, color: AppTheme.textSecondary)),
          ])),
        ])),
      ]),
    );
  }

  Widget _buildPatientSummary() {
    return Row(children: [
      const Icon(Icons.account_circle_outlined, color: AppTheme.textSecondary, size: 24),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Alejandra Valverde Salgado',
            style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const SizedBox(height: 4),
        Text('01/Agosto/1990',
            style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.textSecondary)),
      ]),
    ]);
  }

  Widget _buildApplicationSummary(Appointment? apt) {
    return Column(children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.storefront_outlined, color: AppTheme.textSecondary, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('México Centro, Xola',
              style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text('XOLA 1001 COL: NARVARTE PONIENTE\nCIUDAD DE MEXICO, CIUDAD DE MEXICO MX',
              style: GoogleFonts.manrope(fontSize: 11, color: AppTheme.textSecondary, height: 1.4)),
        ])),
      ]),
      const SizedBox(height: 20),
      Row(children: [
        const Icon(Icons.calendar_today_outlined, color: AppTheme.textSecondary, size: 22),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(apt?.date ?? '—',
              style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text(apt?.time ?? '—',
              style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.textSecondary)),
        ]),
      ]),
    ]);
  }
}

// ─── Datos del paso del timeline ─────────────────────────────────────────────
enum _StepState { completed, active, pending, noShow, cancelled }

class _StepData {
  final String label;
  final _StepState state;
  final String? description;
  final bool showPayButton;
  final String? payButtonLabel;
  const _StepData({
    required this.label,
    required this.state,
    this.description,
    this.showPayButton = false,
    this.payButtonLabel,
  });
}

// ─── Fila del timeline ────────────────────────────────────────────────────────
class _TimelineRow extends StatelessWidget {
  final _StepData step;
  final bool isLast;
  final VoidCallback onPay;
  const _TimelineRow({required this.step, required this.isLast, required this.onPay});

  @override
  Widget build(BuildContext context) {
    final Color dotColor;
    final bool dotFilled;
    switch (step.state) {
      case _StepState.completed:
        dotColor = AppTheme.brandBlue;
        dotFilled = true;
        break;
      case _StepState.active:
        dotColor = AppTheme.brandBlue;
        dotFilled = false;
        break;
      case _StepState.noShow:
        dotColor = AppTheme.accent;
        dotFilled = false;
        break;
      case _StepState.cancelled:
        dotColor = AppTheme.error;
        dotFilled = false;
        break;
      default:
        dotColor = AppTheme.border;
        dotFilled = false;
    }

    final Color labelColor = step.state == _StepState.pending
        ? AppTheme.textSecondary
        : (step.state == _StepState.cancelled
            ? AppTheme.error
            : AppTheme.textPrimary);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dot + vertical line
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 14, height: 14,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: dotFilled ? dotColor : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: dotColor, width: 2.5),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: step.state == _StepState.completed
                          ? AppTheme.brandBlue
                          : AppTheme.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Contenido
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.label,
                      style: AppTheme.bodyBold().copyWith(
                        fontSize: 14,
                        color: labelColor,
                      )),
                  if (step.description != null) ...[
                    const SizedBox(height: 6),
                    Text(step.description!,
                        style: AppTheme.body().copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        )),
                  ],
                  if (step.showPayButton) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onPay,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.brandBlue,
                          side: const BorderSide(color: AppTheme.brandBlue, width: 1.5),
                          backgroundColor: const Color(0xFFEFF4FF),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                        ),
                        child: Text(step.payButtonLabel ?? 'Pagar',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Acordeón ─────────────────────────────────────────────────────────────────
class _CollapsibleSection extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;
  const _CollapsibleSection({required this.title, required this.child, this.initiallyExpanded = true});
  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection> {
  late bool _isExpanded;
  @override
  void initState() { super.initState(); _isExpanded = widget.initiallyExpanded; }
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
