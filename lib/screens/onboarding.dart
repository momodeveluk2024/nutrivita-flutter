import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/models/visual_catalog.dart';
import '../theme.dart';
import '../widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _slide = 0;
  late final PageController _pageController;

  static const _slides = <_Slide>[
    _Slide(
      title: 'Know what you are eating',
      body:
          'See the full vitamin and mineral breakdown for real foods, down to the micro-gram.',
      category: 'vegetables',
      icon: Icons.auto_awesome,
    ),
    _Slide(
      title: 'Built around you',
      body:
          'Tell us a little about yourself and we will tailor daily targets to your body and goals.',
      category: 'dairy',
      icon: Icons.spa_outlined,
    ),
    _Slide(
      title: 'Track without the hassle',
      body:
          'A gentle daily log with the nutrients that matter most, without noisy calorie counting.',
      category: 'seafood',
      icon: Icons.timeline,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_slide < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.go('/sign-up');
    }
  }

  void _skip() {
    context.go('/sign-up');
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = NVColors(dark);
    final s = _slides[_slide];

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final heroHeight = constraints.maxHeight * 0.74;
            return Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (page) => setState(() => _slide = page),
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    return _SlideHero(
                      slide: _slides[index],
                      height: heroHeight,
                    );
                  },
                ),
                Positioned(
                  top: 18,
                  right: 20,
                  child: TextButton(
                    onPressed: _skip,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black.withValues(alpha: 0.18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('Skip'),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      24,
                      22,
                      24,
                      24 + MediaQuery.paddingOf(context).bottom,
                    ),
                    decoration: BoxDecoration(
                      color: c.bg,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(34),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: dark ? 0.36 : 0.10,
                          ),
                          blurRadius: 30,
                          offset: const Offset(0, -12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeOutCubic,
                          child: Column(
                            key: ValueKey(s.title),
                            children: [
                              Text(
                                s.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0,
                                  height: 1.12,
                                  color: c.text,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                s.body,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: c.textMuted,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(_slides.length, (i) {
                                final active = i == _slide;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOutCubic,
                                  width: active ? 26 : 7,
                                  height: 7,
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    color: active
                                        ? NV.accent
                                        : (dark
                                              ? NV.borderDark
                                              : const Color(0xFFD5DACD)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                );
                              }),
                            ),
                            NVPrimaryButton(
                              label: _slide == _slides.length - 1
                                  ? 'Start'
                                  : 'Next',
                              width: 140,
                              height: 52,
                              radius: 20,
                              trailingIcon: Icons.chevron_right,
                              onPressed: _next,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SlideHero extends StatelessWidget {
  const _SlideHero({required this.slide, required this.height});

  final _Slide slide;
  final double height;

  @override
  Widget build(BuildContext context) {
    final visual = categoryVisualFor(slide.category);
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          FoodPhoto(
            label: slide.title,
            imageUrl: visual.imageUrl,
            height: height,
            radius: 0,
            tone: 'cool',
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.02),
                  Colors.black.withValues(alpha: 0.16),
                  Colors.black.withValues(alpha: 0.58),
                ],
              ),
            ),
          ),
          Positioned(
            left: 24,
            bottom: 110,
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(slide.icon, color: visual.accent, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}

class _Slide {
  final String title;
  final String body;
  final String category;
  final IconData icon;

  const _Slide({
    required this.title,
    required this.body,
    required this.category,
    required this.icon,
  });
}
