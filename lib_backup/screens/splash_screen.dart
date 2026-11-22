import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..forward();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) Navigator.of(context).pushReplacement(slideRoute(const OnboardingScreen()));
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [AppColors.ink, Color(0xFF2E2E31)]),
        ),
        child: Stack(children: [
          Positioned(top: -90, right: -70, child: _ring(260, Colors.white.withOpacity(0.18))),
          Positioned(bottom: -120, left: -80, child: _ring(320, Colors.white.withOpacity(0.07))),
          Center(
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, __) {
                final t = Curves.easeOutBack.transform((_c.value * 1.6).clamp(0.0, 1.0));
                return Opacity(
                  opacity: (_c.value * 2.5).clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 0.7 + 0.3 * t,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        width: 92, height: 92,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
                        child: const Icon(Icons.shopping_bag_rounded, size: 48, color: AppColors.ink),
                      ),
                      const SizedBox(height: 22),
                      const Text('Verra', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -1)),
                      const SizedBox(height: 6),
                      Text('Shop smarter. Just ask.', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15)),
                    ]),
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: 64, right: 64, bottom: 70,
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, __) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _c.value, minHeight: 5,
                  backgroundColor: Colors.white.withOpacity(0.15),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _ring(double s, Color c) => Container(width: s, height: s, decoration: BoxDecoration(shape: BoxShape.circle, color: c));
}
