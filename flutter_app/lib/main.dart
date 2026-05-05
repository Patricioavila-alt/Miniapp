import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';

// ─── Screens ──────────────────────────────────────────────────────────────────
import 'features/home/home_screen.dart';
import 'features/appointments/appointments_screen.dart';
import 'features/appointments/appointment_detail_screen.dart';
import 'features/appointments/schedule_type_screen.dart';
import 'features/appointments/schedule_screen.dart';
import 'features/appointments/consult_symptoms_screen.dart';
import 'features/appointments/consult_branch_screen.dart';
import 'features/appointments/consult_datetime_screen.dart';
import 'features/appointments/consult_patient_info_screen.dart';
import 'features/appointments/consult_confirmation_screen.dart';
import 'features/appointments/consult_success_screen.dart';
import 'features/appointments/test_appointment_screen.dart';
import 'features/appointments/vaccine_type_screen.dart';
import 'features/appointments/vaccine_questionnaire_screen.dart';
import 'features/appointments/vaccine_branch_screen.dart';
import 'features/appointments/vaccine_datetime_screen.dart';
import 'features/appointments/vaccine_patient_info_screen.dart';
import 'features/appointments/vaccine_confirmation_screen.dart';
import 'features/appointments/vaccine_success_screen.dart';
import 'features/appointments/vaccine_pay_in_branch_screen.dart';
import 'features/appointments/test_type_screen.dart';
import 'features/appointments/test_branch_screen.dart';
import 'features/appointments/test_datetime_screen.dart';
import 'features/appointments/test_patient_info_screen.dart';
import 'features/appointments/test_confirmation_screen.dart';
import 'features/appointments/test_success_screen.dart';
import 'features/appointments/test_result_validating_screen.dart';
import 'features/health_record/health_record_screen.dart';
import 'features/health_record/prescription_detail_screen.dart';
import 'features/health_record/prescriptions_screen.dart';
import 'features/health_record/document_detail_screen.dart';
import 'features/health_record/clinical_documents_screen.dart';
import 'features/prescription_scan/prescription_scan_screen.dart';
import 'features/prescription_scan/prescription_delivery_note_screen.dart';
import 'features/sign_document/sign_document_screen.dart';
import 'features/video_call/video_call_screen.dart';
import 'features/account/account_screen.dart';

// ─── Providers ────────────────────────────────────────────────────────────────
import 'features/home/providers/home_provider.dart';
import 'features/appointments/providers/appointments_provider.dart';
import 'features/health_record/providers/health_record_provider.dart';
import 'features/account/providers/account_provider.dart';

void main() {
  runApp(const MiSaludApp());
}

// ─── Shell con Bottom Navigation ─────────────────────────────────────────────
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    // Shell route para el Bottom Nav
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (context, state) => _fadeTransition(
            state, const HomeScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.appointments,
          pageBuilder: (context, state) => _fadeTransition(
            state, const AppointmentsScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.healthRecord,
          pageBuilder: (context, state) => _fadeTransition(
            state, const HealthRecordScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.account,
          pageBuilder: (context, state) => _fadeTransition(
            state, const AccountScreen(),
          ),
        ),
      ],
    ),

    // Rutas secundarias (stack — sin bottom nav)
    GoRoute(
      path: '/appointments/schedule-type',
      pageBuilder: (context, state) =>
          _slideTransition(state, const ScheduleTypeScreen()),
    ),
    GoRoute(
      path: AppRoutes.schedule,
      pageBuilder: (context, state) =>
          _slideTransition(state, const ScheduleScreen()),
    ),
    GoRoute(
      path: '/appointments/schedule-tests',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final type = extra['type'] as String? ?? 'test';
        return _slideTransition(
            state, TestAppointmentScreen(type: type));
      },
    ),
    GoRoute(
      path: AppRoutes.consultSymptoms,
      pageBuilder: (context, state) =>
          _slideTransition(state, const ConsultSymptomsScreen()),
    ),
    GoRoute(
      path: AppRoutes.consultBranch,
      pageBuilder: (context, state) =>
          _slideTransition(state, const ConsultBranchScreen()),
    ),
    GoRoute(
      path: AppRoutes.consultDateTime,
      pageBuilder: (context, state) =>
          _slideTransition(state, const ConsultDateTimeScreen()),
    ),
    GoRoute(
      path: AppRoutes.consultPatientInfo,
      pageBuilder: (context, state) =>
          _slideTransition(state, const ConsultPatientInfoScreen()),
    ),
    GoRoute(
      path: AppRoutes.consultConfirmation,
      pageBuilder: (context, state) =>
          _slideTransition(state, const ConsultConfirmationScreen()),
    ),
    GoRoute(
      path: AppRoutes.consultSuccess,
      pageBuilder: (context, state) =>
          _slideTransition(state, const ConsultSuccessScreen()),
    ),
    GoRoute(
      path: AppRoutes.vaccineType,
      pageBuilder: (context, state) =>
          _slideTransition(state, const VaccineTypeScreen()),
    ),
    GoRoute(
      path: AppRoutes.vaccineQuestionnaire,
      pageBuilder: (context, state) =>
          _slideTransition(state, const VaccineQuestionnaireScreen()),
    ),
    GoRoute(
      path: AppRoutes.vaccineBranch,
      pageBuilder: (context, state) =>
          _slideTransition(state, const VaccineBranchScreen()),
    ),
    GoRoute(
      path: AppRoutes.vaccineDateTime,
      pageBuilder: (context, state) =>
          _slideTransition(state, const VaccineDateTimeScreen()),
    ),
    GoRoute(
      path: AppRoutes.vaccinePatientInfo,
      pageBuilder: (context, state) =>
          _slideTransition(state, const VaccinePatientInfoScreen()),
    ),
    GoRoute(
      path: AppRoutes.vaccineConfirmation,
      pageBuilder: (context, state) =>
          _slideTransition(state, const VaccineConfirmationScreen()),
    ),
    GoRoute(
      path: AppRoutes.vaccineSuccess,
      pageBuilder: (context, state) =>
          _slideTransition(state, const VaccineSuccessScreen()),
    ),
    GoRoute(
      path: AppRoutes.vaccinePayInBranch,
      pageBuilder: (context, state) =>
          _slideTransition(state, const VaccinePayInBranchScreen()),
    ),
    GoRoute(
      path: AppRoutes.testType,
      pageBuilder: (context, state) =>
          _slideTransition(state, const TestTypeScreen()),
    ),
    GoRoute(
      path: AppRoutes.testBranch,
      pageBuilder: (context, state) =>
          _slideTransition(state, const TestBranchScreen()),
    ),
    GoRoute(
      path: AppRoutes.testDateTime,
      pageBuilder: (context, state) =>
          _slideTransition(state, const TestDateTimeScreen()),
    ),
    GoRoute(
      path: AppRoutes.testPatientInfo,
      pageBuilder: (context, state) =>
          _slideTransition(state, const TestPatientInfoScreen()),
    ),
    GoRoute(
      path: AppRoutes.testConfirmation,
      pageBuilder: (context, state) =>
          _slideTransition(state, const TestConfirmationScreen()),
    ),
    GoRoute(
      path: AppRoutes.testSuccess,
      pageBuilder: (context, state) =>
          _slideTransition(state, const TestSuccessScreen()),
    ),
    GoRoute(
      path: AppRoutes.testValidating,
      pageBuilder: (context, state) =>
          _slideTransition(state, const TestResultValidatingScreen()),
    ),
    GoRoute(
      path: '/appointments/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return _slideTransition(state, AppointmentDetailScreen(appointmentId: id));
      },
    ),
    GoRoute(
      path: AppRoutes.prescriptionScan,
      pageBuilder: (context, state) =>
          _slideTransition(state, const PrescriptionScanScreen()),
    ),
    GoRoute(
      path: AppRoutes.prescriptionDeliveryNote,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final meds = (extra['meds'] as List).cast<Map<String, dynamic>>();
        return _slideTransition(
            state, PrescriptionDeliveryNoteScreen(meds: meds));
      },
    ),
    GoRoute(
      path: '/health-record/prescriptions',
      pageBuilder: (context, state) =>
          _slideTransition(state, const PrescriptionsScreen()),
    ),
    GoRoute(
      path: '/health-record/prescription/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return _slideTransition(state, PrescriptionDetailScreen(prescriptionId: id));
      },
    ),
    GoRoute(
      path: '/health-record/documents-list',
      pageBuilder: (context, state) =>
          _slideTransition(state, const ClinicalDocumentsScreen()),
    ),
    GoRoute(
      path: '/health-record/document/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return _slideTransition(state, DocumentDetailScreen(documentId: id));
      },
    ),
    GoRoute(
      path: '/sign-document/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return _slideTransition(state, SignDocumentScreen(documentId: id));
      },
    ),
    GoRoute(
      path: AppRoutes.videoCall,
      pageBuilder: (context, state) =>
          _slideTransition(state, const VideoCallScreen()),
    ),
  ],
);

// ─── Helpers de transición ────────────────────────────────────────────────────
CustomTransitionPage<void> _fadeTransition(
    GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 220),
  );
}

CustomTransitionPage<void> _slideTransition(
    GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, _, child) {
      final offset = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return SlideTransition(position: offset, child: child);
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

// ─── Root App ─────────────────────────────────────────────────────────────────
class MiSaludApp extends StatelessWidget {
  const MiSaludApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentsProvider()),
        ChangeNotifierProvider(create: (_) => HealthRecordProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
      ],
      child: MaterialApp.router(
        title: 'Mi Salud FdA',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        routerConfig: _router,
      ),
    );
  }
}

// ─── AppShell — Bottom Navigation ─────────────────────────────────────────────
class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  int _tabIndex(String location) {
    if (location.startsWith('/appointments')) return 1;
    if (location.startsWith('/health-record')) return 2;
    if (location.startsWith('/account')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2A433A).withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _tabIndex(location),
          elevation: 0,
          backgroundColor: AppTheme.surface,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.accent,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            switch (index) {
              case 0:
                context.go(AppRoutes.home);
              case 1:
                context.go(AppRoutes.appointments);
              case 2:
                context.go(AppRoutes.healthRecord);
              case 3:
                context.go(AppRoutes.account);
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today_rounded),
              label: 'Mis Citas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_outlined),
              activeIcon: Icon(Icons.folder_rounded),
              label: 'Expediente',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Mi Cuenta',
            ),
          ],
        ),
      ),
    );
  }
}
