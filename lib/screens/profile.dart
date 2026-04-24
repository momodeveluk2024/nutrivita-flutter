import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import 'splash.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final vitA = vitaminColors['A']!;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
            child: Text('You',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                    color: c.text)),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              children: [
                NVCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: NV.accent,
                          shape: BoxShape.circle,
                        ),
                        child: const Text('AM',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Amelia Chen',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                    color: c.text)),
                            const SizedBox(height: 2),
                            Text('amelia@example.com',
                                style: TextStyle(fontSize: 12, color: c.textMuted)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: NV.accentSoft,
                            borderRadius: BorderRadius.circular(100)),
                        child: const Text('Pro',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: NV.accent)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                NVCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: vitA.bg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.local_fire_department,
                            size: 22, color: vitA.fill),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('12-day streak',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: c.text)),
                            const SizedBox(height: 2),
                            Text('Keep logging to extend it',
                                style:
                                    TextStyle(fontSize: 12, color: c.textMuted)),
                          ],
                        ),
                      ),
                      Icon(Icons.trending_up, size: 18, color: c.textMuted),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                  child: const SectionLabel('Your profile'),
                ),
                NVCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _Row(icon: Icons.gps_fixed, title: 'Goals', detail: 'Immunity · Energy'),
                      _div(c),
                      _Row(icon: Icons.person_outline, title: 'Body details', detail: 'F, 28, 165 cm'),
                      _div(c),
                      _Row(icon: Icons.eco_outlined, title: 'Dietary preferences', detail: 'Pescatarian'),
                      _div(c),
                      _Row(icon: Icons.notifications_outlined, title: 'Reminders', detail: 'On'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                  child: const SectionLabel('Settings'),
                ),
                NVCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _Row(icon: Icons.settings_outlined, title: 'Units', detail: 'Metric'),
                      _div(c),
                      _Row(
                        icon: Icons.auto_awesome_outlined,
                        title: 'Appearance',
                        detail: dark ? 'Dark' : 'Light',
                      ),
                      _div(c),
                      _Row(icon: Icons.info_outline, title: 'About NutriVita', detail: ''),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const SplashScreen()),
                      (_) => false,
                    ),
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Sign out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: c.text,
                      side: BorderSide(color: c.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text('Version 1.0.0 · Made with care',
                      style: TextStyle(fontSize: 12, color: c.textMuted)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _div(NVColors c) => Container(height: 1, color: c.border);
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;
  const _Row({required this.icon, required this.title, required this.detail});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.surfaceMuted,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: c.text),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500, color: c.text)),
          ),
          if (detail.isNotEmpty)
            Text(detail, style: TextStyle(fontSize: 13, color: c.textMuted)),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, size: 16, color: c.textMuted),
        ],
      ),
    );
  }
}
