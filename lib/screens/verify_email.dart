import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../core/providers/auth_provider.dart';
import '../theme.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, this.initialToken});

  final String? initialToken;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with SingleTickerProviderStateMixin {
  Timer? _pollTimer;
  bool _resending = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  late final AnimationController _entryCtrl;
  late final Animation<double> _entryAnim;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _entryAnim = CurvedAnimation(
      parent: _entryCtrl,
      curve: Curves.easeOutCubic,
    );
    _entryCtrl.forward();

    // Start polling for email verification every 3 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await _checkVerification();
    });

    // Start cooldown so user can't resend immediately (they just got one)
    _startCooldown(30);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    _entryCtrl.dispose();
    super.dispose();
  }

  void _startCooldown(int seconds) {
    _resendCooldown = seconds;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _resendCooldown--;
        if (_resendCooldown <= 0) {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _checkVerification() async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await user.reload();
    final refreshedUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (refreshedUser?.emailVerified == true && mounted) {
      // Force refresh the token so the backend sees email_verified
      await refreshedUser?.getIdToken(true);
      try {
        if (!mounted) return;
        await context.read<AuthProvider>().loadMe();
      } catch (_) {}
      if (mounted) context.go('/app');
    }
  }

  Future<void> _resendVerification() async {
    if (_resendCooldown > 0 || _resending) return;
    setState(() => _resending = true);
    HapticFeedback.lightImpact();
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
      if (mounted) {
        _startCooldown(60);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent! Check your inbox.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  Future<void> _signOut() async {
    await context.read<AuthProvider>().logout();
    if (mounted) context.go('/sign-in');
  }

  @override
  Widget build(BuildContext context) {
    final c = NVColors.of(context);
    final media = MediaQuery.of(context);
    final email =
        firebase_auth.FirebaseAuth.instance.currentUser?.email ?? 'your email';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            Theme.of(context).brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: c.bg,
        body: FadeTransition(
          opacity: _entryAnim,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _signOut,
                        style: TextButton.styleFrom(
                          foregroundColor: c.textMuted,
                          textStyle: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        child: const Text('Sign out'),
                      ),
                    ],
                  ),

                  const Spacer(flex: 2),

                  // Animated mail icon
                  _AnimatedMailIcon(),

                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Check your inbox',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      color: c.text,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  Text.rich(
                    TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: c.textMuted,
                        height: 1.55,
                      ),
                      children: [
                        const TextSpan(
                          text: 'We sent a verification link to\n',
                        ),
                        TextSpan(
                          text: email,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            color: NV.accent,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Click the link in your email to verify your account.\nThis page will update automatically.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: c.textMuted.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Checking status indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: NV.accent.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Waiting for verification…',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: c.textMuted.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // Resend button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed:
                          (_resendCooldown > 0 || _resending)
                              ? null
                              : _resendVerification,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: (_resendCooldown > 0 || _resending)
                              ? c.border
                              : NV.accent,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        foregroundColor: NV.accent,
                        disabledForegroundColor: c.textMuted,
                        textStyle: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: _resending
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: c.textMuted,
                              ),
                            )
                          : Text(
                              _resendCooldown > 0
                                  ? 'Resend in ${_resendCooldown}s'
                                  : 'Resend verification email',
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Manual check button
                  TextButton(
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      await _checkVerification();
                      if (mounted) {
                        final user =
                            firebase_auth.FirebaseAuth.instance.currentUser;
                        if (user?.emailVerified != true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Not verified yet. Please check your email.',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: c.textMuted,
                      textStyle: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: const Text("I've already verified →"),
                  ),

                  const Spacer(flex: 3),

                  // Bottom helper
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: c.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 20,
                          color: c.textMuted,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Can't find the email? Check your spam folder or try a different email address.",
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: c.textMuted,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: media.padding.bottom + 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  ANIMATED MAIL ICON
// ═══════════════════════════════════════════════════════════════

class _AnimatedMailIcon extends StatefulWidget {
  @override
  State<_AnimatedMailIcon> createState() => _AnimatedMailIconState();
}

class _AnimatedMailIconState extends State<_AnimatedMailIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _bounce = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounce,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_bounce.value),
          child: child,
        );
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              NV.accent.withValues(alpha: 0.15),
              NV.accent.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.mark_email_unread_rounded,
          size: 44,
          color: NV.accent,
        ),
      ),
    );
  }
}
