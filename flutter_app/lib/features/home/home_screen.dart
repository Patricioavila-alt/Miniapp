import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../shared/widgets/skeleton_loader.dart';
import '../../shared/widgets/in_app_webview_screen.dart';
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
                  _TopBar(
                    firstName: firstName,
                    address: provider.currentAddress,
                  ),

                  const _SectionDivider(),

                  // ── 2. Título "Mi Salud" ───────────────────────────────────
                  const _MiSaludTitle(),

                  const _SectionDivider(),

                  // ── 3. Saludo + Avatar ────────────────────────────────────
                  _GreetingRow(greeting: _greeting, firstName: firstName),

                  const SizedBox(height: 4),

                  // ── 4. Quick Actions grid ─────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text(
                      '¿Qué necesitas hoy?',
                      style: AppTheme.heading2().copyWith(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionsRow(
                    actions: data.quickActions,
                    onActionTap: (id) => _onActionTap(context, id),
                  ),

                  const SizedBox(height: 24),

                  // -- 5. Banner de Promociones (PageView) --
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
                      onTap: () => context.push(AppRoutes.prescriptionScan),
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
        openWebPortal(
          context,
          url: 'https://www.orientacionenlinea.com/',
          title: 'Orientación en Línea',
        );
      case 'vaccine':
        context.push(AppRoutes.vaccineType);
      case 'tests':
        context.push(AppRoutes.testType);
      case 'medicoGeneral':
        openWebPortal(context, url: 'https://app.nimbo-x.com/', title: 'Médico General');
        break;
      case 'pediatra':
        openWebPortal(context, url: 'https://app.nimbo-x.com/', title: 'Pediatra');
        break;
      case 'dermatologia':
        openWebPortal(context, url: 'https://app.nimbo-x.com/', title: 'Dermatología');
        break;
      case 'diabetes':
        openWebPortal(context, url: 'https://app.nimbo-x.com/', title: 'Nutriólogo');
        break;
      case 'saludMental':
        openWebPortal(context, url: 'https://app.nimbo-x.com/', title: 'Salud Mental');
        break;
      case 'redmedica':
        break;
      case 'prescription':
        context.push(AppRoutes.prescriptionScan);
      case 'schedule':
        context.push(AppRoutes.scheduleType);
      case 'records':
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
  final String address;
  const _TopBar({required this.firstName, required this.address});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          // Logo "A" -> "FA"
          SvgPicture.asset(
            'assets/icons/FALogoMni.svg',
            width: 40,
            height: 40,
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
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 12, color: Color(0xFF555555)),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        address,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF222222),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 15, color: Color(0xFF222222)),
                  ],
                ),
              ],
            ),
          ),

          // WhatsApp
          GestureDetector(
            onTap: () async {
              final url = Uri.parse(
                'https://api.whatsapp.com/send/?phone=5218007112222&text=Hola',
              );
              try {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } catch (_) {
                await launchUrl(url, mode: LaunchMode.platformDefault);
              }
            },
            child: SvgPicture.asset(
              'assets/icons/WALogo.svg',
              width: 36,
              height: 36,
            ),
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
            style: AppTheme.heading3(),
          ),
          // Avatar JPG con borde azul
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF233BC1), width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: ClipOval(
                child: Image.asset(
                  'assets/icons/ProfilePic.jpg',
                  fit: BoxFit.cover,
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
// _QuickActionsRow -- grid 2 columnas, tarjetas horizontales
class _QuickActionsRow extends StatelessWidget {
  final List<Map<String, dynamic>> actions;
  final void Function(String id) onActionTap;
  const _QuickActionsRow({required this.actions, required this.onActionTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
        ),
        itemCount: actions.length,
        itemBuilder: (context, i) {
          final action = actions[i];
          final id = action['id'] as String;
          final iconKey = action['icon'] as String;
          final label = (action['label'] as String).replaceAll(r'\n', '\n');

          return GestureDetector(
            onTap: () => onActionTap(id),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFFFFF), Color(0xFFEAF8FA)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Image.asset(
                    'assets/icons/$iconKey.png',
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF222222),
                        height: 1.3,
                      ),
                      maxLines: 2,
                    ),
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
    Color(0xFFF4A17B),
    Color(0xFF7BBCF4),
    Color(0xFFF4A17B), // fallback for extra promos
  ];

  // Determina si el slide es un asset local (prefix 'asset:')
  static bool _isAsset(String url) => url.startsWith('asset:');
  static String _assetPath(String url) =>
      'assets/icons/${url.substring('asset:'.length)}';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 2046 / 544,
          child: PageView.builder(
            controller: controller,
            itemCount: promotions.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, i) {
              final promo = promotions[i];
              final isAsset = _isAsset(promo.imageUrl);

              // ── Slide full-bleed (imagen local diseñada) ─────────────────
              if (isAsset) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey.shade200,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    _assetPath(promo.imageUrl),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                );
              }

              // ── Slide con imagen de red + texto overlay ──────────────────
              final bg = _bgColors[i % _bgColors.length];
              final titleColor =
                  i == 0 ? AppTheme.primary : const Color(0xFF1A4B8C);

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
                    // Imagen lado izquierdo
                    Positioned(
                      left: 0, top: 0, bottom: 0, width: 140,
                      child: CachedNetworkImage(
                        imageUrl: promo.imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const Center(
                          child: Icon(Icons.image_not_supported,
                              color: Colors.white54, size: 40),
                        ),
                      ),
                    ),
                    // Gradiente imagen → color
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            stops: const [0.35, 0.65],
                            colors: [bg.withOpacity(0.0), bg],
                          ),
                        ),
                      ),
                    ),
                    // Texto derecha
                    Positioned(
                      right: 0, top: 0, bottom: 0, width: 210,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 18, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              promo.title.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: titleColor,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              promo.description,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF333333),
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Botón "Ver más" esquina inferior derecha
                    if (promo.ctaText.isNotEmpty)
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            promo.ctaText,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3B82F6),
                            ),
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

        // Dots de paginación
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F7FF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/icons/RecetaIA.png',
                width: 60,
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 16),
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
                  SizedBox(height: 4),
                  Text(
                    'Agiliza tu compra con el escaneo inteligente',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.blue,
                size: 20,
              ),
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
