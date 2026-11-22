import 'package:flutter/material.dart';

String formatPrice(num v) {
  final s = v.round().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return 'Rs $b';
}

Color colorFromName(String name) {
  const map = {
    'black': Color(0xFF1B1B1F), 'white': Color(0xFFF7F7F7), 'red': Color(0xFFD83A3A),
    'blue': Color(0xFF2F5BD9), 'navy': Color(0xFF1B2A5C), 'green': Color(0xFF2E9461),
    'olive': Color(0xFF6B7140), 'brown': Color(0xFF7A5230), 'tan': Color(0xFFC9A47A),
    'beige': Color(0xFFE3D5BC), 'grey': Color(0xFF8D8F9A), 'gray': Color(0xFF8D8F9A),
    'pink': Color(0xFFEF8DB2), 'silver': Color(0xFFC3C7D1), 'gold': Color(0xFFD9B04A),
    'yellow': Color(0xFFF2C94C), 'orange': Color(0xFFEE8A3A), 'purple': Color(0xFF7B4BD3),
  };
  return map[name.toLowerCase()] ?? Colors.blueGrey;
}

Route<T> slideRoute<T>(Widget page) => PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(begin: const Offset(0.06, 0), end: Offset.zero).animate(curved),
            child: child,
          ),
        );
      },
    );

Future<T?> push<T>(BuildContext c, Widget page) => Navigator.of(c).push<T>(slideRoute<T>(page));

void snack(BuildContext c, String msg) {
  ScaffoldMessenger.of(c)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
}
