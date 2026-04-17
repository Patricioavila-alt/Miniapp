// Constantes de rutas para GoRouter
// NUNCA usar Navigator.push() — siempre context.push(AppRoutes.xxx)
class AppRoutes {
  static const String home               = '/';
  static const String appointments       = '/appointments';
  static const String appointmentDetail  = '/appointments/:id';
  static const String schedule           = '/appointments/schedule';
  static const String healthRecord       = '/health-record';
  static const String prescriptionDetail = '/health-record/prescription/:id';
  static const String documentDetail     = '/health-record/document/:id';
  static const String signDocument       = '/sign-document/:id';
  static const String videoCall          = '/video-call';
  static const String account            = '/account';
}
