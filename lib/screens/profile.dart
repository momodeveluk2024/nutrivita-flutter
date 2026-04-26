import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/providers/auth_provider.dart';
import '../theme.dart';
import '../widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final vitA = vitaminColors['A']!;
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final displayName = user?.displayName ?? 'NutriVita user';
    final email = user?.email ?? '';
    final initials = user?.initials ?? '?';
    final isVerified = user?.isEmailVerified ?? false;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
            child: Text(
              'You',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.8,
                color: c.text,
              ),
            ),
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
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                color: c.text,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: TextStyle(
                                fontSize: 12,
                                color: c.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: NV.accentSoft,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          isVerified ? 'Verified' : 'Unverified',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: NV.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isVerified) ...[
                  const SizedBox(height: 14),
                  NVCard(
                    onTap: () => context.go('/verify-email'),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: NV.accentSoft,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mark_email_unread_outlined,
                            size: 22,
                            color: NV.accent,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Verify your email',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: c.text,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Use the local verification token from the API console.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: c.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, size: 20, color: c.textMuted),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                NVCard(
                  onTap: () => context.go('/app?tab=track'),
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
                        child: Icon(
                          Icons.local_fire_department,
                          size: 22,
                          color: vitA.fill,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '12-day streak',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: c.text,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Keep logging to extend it',
                              style: TextStyle(
                                fontSize: 12,
                                color: c.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.trending_up, size: 18, color: c.textMuted),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const SectionLabel(
                  'Your profile',
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                ),
                NVCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _Row(
                        icon: Icons.gps_fixed,
                        title: 'Goals',
                        detail: user?.goalsSummary ?? 'Set goals',
                        onTap: () => context.push('/app/profile/goals'),
                      ),
                      _div(c),
                      _Row(
                        icon: Icons.person_outline,
                        title: 'Body details',
                        detail: user?.bodySummary ?? 'Add details',
                        onTap: () => context.push('/app/profile/body'),
                      ),
                      _div(c),
                      _Row(
                        icon: Icons.eco_outlined,
                        title: 'Dietary preferences',
                        detail: user?.dietSummary ?? 'Set preferences',
                        onTap: () => context.push('/app/profile/diet'),
                      ),
                      _div(c),
                      _Row(
                        icon: Icons.notifications_outlined,
                        title: 'Reminders',
                        detail: user?.remindersSummary ?? 'Manage',
                        onTap: () => context.push('/app/profile/reminders'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const SectionLabel(
                  'Settings',
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                ),
                NVCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _Row(
                        icon: Icons.settings_outlined,
                        title: 'Units',
                        detail: user?.unitsLabel ?? 'Metric',
                        onTap: () => context.push('/app/profile/units'),
                      ),
                      _div(c),
                      _Row(
                        icon: Icons.auto_awesome_outlined,
                        title: 'Appearance',
                        detail:
                            user?.appearanceLabel ?? (dark ? 'Dark' : 'Light'),
                        onTap: () => context.push('/app/profile/appearance'),
                      ),
                      _div(c),
                      _Row(
                        icon: Icons.info_outline,
                        title: 'About NutriVita',
                        detail: '',
                        onTap: () => context.push('/app/profile/about'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await context.read<AuthProvider>().logout();
                      if (context.mounted) context.go('/');
                    },
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Sign out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: c.text,
                      side: BorderSide(color: c.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Version 1.0.0 - Made with care',
                    style: TextStyle(fontSize: 12, color: c.textMuted),
                  ),
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
  const _Row({
    required this.icon,
    required this.title,
    required this.detail,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
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
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: c.text,
                  ),
                ),
              ),
              if (detail.isNotEmpty)
                Flexible(
                  child: Text(
                    detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: c.textMuted),
                  ),
                ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 16, color: c.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
