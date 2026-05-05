import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/skeleton_loader.dart';
import 'providers/account_provider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AccountProvider>().fetchProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text('Mi Cuenta', style: AppTheme.heading2())),
      body: Consumer<AccountProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const ListScreenSkeleton(itemCount: 4);
          }
          final profile = provider.profile;
          if (profile == null) {
            return Center(child: Text('No se pudo cargar el perfil', style: AppTheme.body()));
          }

          return SingleChildScrollView(
            padding: AppTheme.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar + nombre
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.shadowSoft,
                        ),
                        child: const Icon(Icons.person_rounded,
                            color: AppTheme.primary, size: 48),
                      ),
                      const SizedBox(height: 16),
                      Text(profile.fullName, style: AppTheme.heading2()),
                      const SizedBox(height: 4),
                      Text(profile.email, style: AppTheme.body()),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.gap),

                // Información personal
                Text('Información Personal', style: AppTheme.heading3()),
                const SizedBox(height: 16),
                _InfoCard(items: [
                  _InfoRow(label: 'Teléfono', value: profile.phone),
                  _InfoRow(label: 'Fecha de Nacimiento', value: profile.dateOfBirth),
                  _InfoRow(label: 'Género', value: profile.gender),
                ]),
                const SizedBox(height: AppTheme.gap),

                // Información médica
                Text('Información Médica', style: AppTheme.heading3()),
                const SizedBox(height: 16),
                _InfoCard(items: [
                  _InfoRow(label: 'Grupo sanguíneo', value: profile.bloodType),
                  _InfoRow(
                    label: 'Alergias',
                    value: profile.allergies.isEmpty
                        ? 'Ninguna registrada'
                        : profile.allergies.join(', '),
                  ),
                ]),
                const SizedBox(height: AppTheme.gap),

                // Opciones
                Text('Opciones', style: AppTheme.heading3()),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    children: [
                      _OptionTile(
                        icon: Icons.notifications_outlined,
                        label: 'Notificaciones',
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notificaciones próximamente.')),
                        ),
                      ),
                      _OptionTile(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Privacidad',
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Aviso de privacidad próximamente.')),
                        ),
                      ),
                      _OptionTile(
                        icon: Icons.help_outline_rounded,
                        label: 'Ayuda y Soporte',
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ayuda y soporte próximamente.')),
                        ),
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<_InfoRow> items;
  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSoft,
      ),
      child: Column(
        children: items
            .asMap()
            .entries
            .map((e) => Column(
                  children: [
                    e.value,
                    if (e.key < items.length - 1)
                      const Divider(color: AppTheme.border, height: 24),
                  ],
                ))
            .toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.caption()),
        Text(value, style: AppTheme.bodyBold()),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showDivider;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppTheme.secondary, size: 22),
          title: Text(label, style: AppTheme.bodyBold()),
          trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.accent),
          onTap: onTap,
        ),
        if (showDivider)
          const Divider(height: 1, color: AppTheme.border, indent: 56),
      ],
    );
  }
}
