import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import 'categories_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'wishlist_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});
  @override
  State<ShellScreen> createState() => ShellScreenState();
}

class ShellScreenState extends State<ShellScreen> {
  int _index = 0;
  void goTo(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final wishCount = context.select<AppState, int>((s) => s.wishlist.length);
    return Scaffold(
      body: IndexedStack(index: _index, children: const [
        HomeScreen(),
        CategoriesScreen(),
        SearchScreen(),
        WishlistScreen(),
        ProfileScreen(),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: goTo,
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          const NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view_rounded), label: 'Categories'),
          const NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome_rounded), label: 'Search'),
          NavigationDestination(
            icon: Badge(isLabelVisible: wishCount > 0, label: Text('$wishCount'), child: const Icon(Icons.favorite_border_rounded)),
            selectedIcon: const Icon(Icons.favorite_rounded),
            label: 'Wishlist',
          ),
          const NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
