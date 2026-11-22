import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import 'auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _Page {
  final IconData icon, accent;
  final String title, body;
  const _Page(this.icon, this.accent, this.title, this.body);
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _i = 0;
  static const _pages = [
    _Page(Icons.auto_awesome_rounded, Icons.search_rounded, 'Search the way you talk',
        'Type "a black backpack under 5000 rupees" and Verra finds it. No filters needed.'),
    _Page(Icons.mic_rounded, Icons.graphic_eq_rounded, 'Say it out loud',
        'Tap the microphone, describe what you want, and see matching products instantly.'),
    _Page(Icons.view_in_ar_rounded, Icons.threed_rotation_rounded, 'Inspect in 3D',
        'Rotate and zoom products before you buy, so there are fewer surprises at your door.'),
  ];

  void _finish() => Navigator.of(context).pushReplacement(slideRoute(const LoginScreen()));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = _i == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Align(
            alignment: Alignment.centerRight,
            child: AnimatedOpacity(
              opacity: last ? 0 : 1, duration: const Duration(milliseconds: 200),
              child: TextButton(onPressed: last ? null : _finish, child: const Text('Skip')),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _ctrl,
              itemCount: _pages.length,
              onPageChanged: (v) => setState(() => _i = v),
              itemBuilder: (_, i) {
                final p = _pages[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    SizedBox(
                      height: 280,
                      child: Stack(alignment: Alignment.center, children: [
                        Container(width: 260, height: 260, decoration: BoxDecoration(
                            shape: BoxShape.circle, color: const Color(0xFFEFEBE6))),
                        Container(width: 190, height: 190, decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: AppColors.ink)),
                        Icon(p.icon, size: 84, color: Colors.white),
                        Positioned(right: 30, bottom: 40, child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: AppColors.cobalt, borderRadius: BorderRadius.circular(20)),
                          child: Icon(p.accent, color: Colors.white, size: 28),
                        )),
                      ]),
                    ),
                    const SizedBox(height: 32),
                    Text(p.title, textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    Text(p.body, textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.slate, height: 1.5)),
                  ]),
                );
              },
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var i = 0; i < _pages.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == _i ? 26 : 8, height: 8,
                decoration: BoxDecoration(
                  color: i == _i ? AppColors.ink : AppColors.slate.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8)),
              ),
          ]),
          Padding(
            padding: const EdgeInsets.all(24),
            child: FilledButton(
              onPressed: last ? _finish : () => _ctrl.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic),
              child: Text(last ? 'Get started' : 'Next'),
            ),
          ),
        ]),
      ),
    );
  }
}
