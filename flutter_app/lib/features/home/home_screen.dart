import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../shared/widgets/skeleton_loader.dart';
import 'providers/home_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen — Diseño FDA Mi Salud
// ─────────────────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bannerPage = 0;
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<HomeProvider>().fetchHome());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Saludo dinámico según la hora local
  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Buen día';
    if (h < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<HomeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const HomeScreenSkeleton();
          final data = provider.data;
          if (data == null) return const HomeScreenSkeleton();

          final firstName = data.userName.split(' ').first;

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 1. Barra superior (logo + dirección + íconos) ─────────
                  _TopBar(firstName: firstName),

                  const _SectionDivider(),

                  // ── 2. Título "Mi Salud" ───────────────────────────────────
                  const _MiSaludTitle(),

                  const _SectionDivider(),

                  // ── 3. Saludo + Avatar ────────────────────────────────────
                  _GreetingRow(greeting: _greeting, firstName: firstName),

                  const SizedBox(height: 4),

                  // ── 4. Quick Actions (scroll horizontal) ──────────────────
                  _QuickActionsRow(
                    actions: data.quickActions,
                    onActionTap: (id) => _onActionTap(context, id),
                  ),

                  const SizedBox(height: 24),

                  // ── 5. Banner de Promociones (PageView) ───────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _PromoBannerSection(
                      promotions: data.promotions,
                      controller: _pageController,
                      currentPage: _bannerPage,
                      onPageChanged: (i) => setState(() => _bannerPage = i),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── 6. Card "Surte tu receta" ─────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _SurteRecetaCard(
                      onTap: () => context.go(AppRoutes.healthRecord),
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onActionTap(BuildContext context, String id) {
    switch (id) {
      case 'video':
        context.push(AppRoutes.videoCall);
      case 'schedule':
        context.push(AppRoutes.schedule);
      case 'prescription':
      case 'expediente':
        context.go(AppRoutes.healthRecord);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _TopBar — logo A + dirección + WhatsApp + carrito
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final String firstName;
  const _TopBar({required this.firstName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          // Logo "A"
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Dirección
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enviar a $firstName',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF888888),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Row(
                  children: const [
                    Icon(Icons.location_on_rounded, size: 12, color: Color(0xFF555555)),
                    SizedBox(width: 2),
                    Text(
                      'Tulipán 111, 66635, CDMX',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF222222),
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        size: 15, color: Color(0xFF222222)),
                  ],
                ),
              ],
            ),
          ),

          // WhatsApp
          _CircleIconBtn(
            color: const Color(0xFF25D366),
            icon: Icons.chat_rounded,
            onTap: () {},
          ),
          const SizedBox(width: 10),

          // Carrito con badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                size: 26,
                color: Color(0xFF222222),
              ),
              Positioned(
                top: -5,
                right: -5,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MiSaludTitle — título centrado de sección
// ─────────────────────────────────────────────────────────────────────────────
class _MiSaludTitle extends StatelessWidget {
  const _MiSaludTitle();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: Text(
          'Mi Salud',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _GreetingRow — "Buen día Alejandra" + avatar con ring azul
// ─────────────────────────────────────────────────────────────────────────────
class _GreetingRow extends StatelessWidget {
  final String greeting;
  final String firstName;
  const _GreetingRow({required this.greeting, required this.firstName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$greeting $firstName',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          // Avatar con ring azul
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.blue, width: 2.5),
            ),
            child: ClipOval(
              child: Container(
                color: AppTheme.primaryLight,
                child: const Icon(
                  Icons.person_rounded,
                  color: AppTheme.primary,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _QuickActionsRow — scroll horizontal con tarjetas de acción
// ─────────────────────────────────────────────────────────────────────────────
class _QuickActionsRow extends StatelessWidget {
  final List<Map<String, dynamic>> actions;
  final void Function(String id) onActionTap;
  const _QuickActionsRow({required this.actions, required this.onActionTap});

  static const _styles = <String, _ActionStyle>{
    'expediente': _ActionStyle(
      icon: Icons.folder_special_rounded,
      bg: Color(0xFFFFF0EE),
      iconColor: AppTheme.primary,
    ),
    'videocam': _ActionStyle(
      icon: Icons.videocam_rounded,
      bg: Color(0xFFEEF4FF),
      iconColor: AppTheme.blue,
    ),
    'calendar': _ActionStyle(
      icon: Icons.calendar_today_rounded,
      bg: Color(0xFFEEFFF4),
      iconColor: Color(0xFF22C55E),
    ),
    'medical': _ActionStyle(
      icon: Icons.document_scanner_rounded,
      bg: Color(0xFFF5F0FF),
      iconColor: Color(0xFF8B5CF6),
    ),
    'medkit': _ActionStyle(
      icon: Icons.local_pharmacy_rounded,
      bg: Color(0xFFFFF7ED),
      iconColor: Color(0xFFF97316),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 116,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final action = actions[i];
          final id = action['id'] as String;
          final iconKey = action['icon'] as String;
          final label = (action['label'] as String).replaceAll(r'\n', '\n');
          final style = _styles[iconKey] ?? _styles['videocam']!;

          return GestureDetector(
            onTap: () => onActionTap(id),
            child: Container(
              width: 88,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEEEEEE)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: style.bg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(style.icon, color: style.iconColor, size: 26),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF444444),
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PromoBannerSection — PageView con imagen + texto + dots
// ─────────────────────────────────────────────────────────────────────────────
class _PromoBannerSection extends StatelessWidget {
  final List promotions;
  final PageController controller;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  const _PromoBannerSection({
    required this.promotions,
    required this.controller,
    required this.currentPage,
    required this.onPageChanged,
  });

  static const _bgColors = [
    Color(0xFFF4A17B), // Salmon — promo 1
    Color(0xFF7BBCF4), // Azul — promo 2
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Banner cards
        SizedBox(
          height: 178,
          child: PageView.builder(
            controller: controller,
            itemCount: promotions.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, i) {
              final promo = promotions[i];
              final bg = _bgColors[i % _bgColors.length];
              final titleColor = i == 0 ? AppTheme.primary : const Color(0xFF1A4B8C);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Imagen de fondo lado izquierdo
                    Positioned(
                      left: 0, top: 0, bottom: 0, width: 140,
                      child: CachedNetworkImage(
                        imageUrl: promo.imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const SizedBox(),
                      ),
                    ),
                    // Gradiente de transición imagen → color
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            stops: const [0.35, 0.55],
                            colors: [Colors.transparent, bg],
                          ),
                        ),
                      ),
                    ),
                    // Texto siempre visible en la derecha
                    Positioned(
                      right: 0, top: 0, bottom: 0, width: 210,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 20, 18, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              promo.title.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                                color: titleColor,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              promo.description,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF333333),
                                height: 1.45,
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                promo.ctaText,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF222222),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // Dots de página — el activo es azul y más ancho
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            promotions.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == currentPage ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == currentPage
                    ? AppTheme.blue
                    : const Color(0xFFCCCCCC),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SurteRecetaCard — card de acceso rápido a escanear receta
// ─────────────────────────────────────────────────────────────────────────────
class _SurteRecetaCard extends StatelessWidget {
  final VoidCallback onTap;
  const _SurteRecetaCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF4FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Ícono Rx
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.medication_rounded,
                color: AppTheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),

            // Texto
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Surte tu receta',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Agiliza tu compra con el escaneo inteligente',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF999999),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers internos
// ─────────────────────────────────────────────────────────────────────────────

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0));
}

class _CircleIconBtn extends StatelessWidget {
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconBtn(
      {required this.color, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

/// Estilo de cada Quick Action card
class _ActionStyle {
  final IconData icon;
  final Color bg;
  final Color iconColor;
  const _ActionStyle(
      {required this.icon, required this.bg, required this.iconColor});
}
