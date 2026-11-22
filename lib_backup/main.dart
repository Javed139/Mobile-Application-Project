import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'screens/product_detail_screen.dart';
import 'screens/splash_screen.dart';
import 'state/app_state.dart';
import 'widgets/common.dart';

void main() {
  detailBuilder = (p) => ProductDetailScreen(product: p);
  runApp(ChangeNotifierProvider(create: (_) => AppState(), child: const VerraApp()));
}

class VerraApp extends StatelessWidget {
  const VerraApp({super.key});
  @override
  Widget build(BuildContext context) {
    final mode = context.select<AppState, ThemeMode>((s) => s.themeMode);
    return MaterialApp(
      title: 'Verra',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode,
      home: const SplashScreen(),
    );
  }
}
