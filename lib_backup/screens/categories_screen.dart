import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/utils.dart';
import '../state/app_state.dart';
import 'product_list_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return SafeArea(
      bottom: false,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Text('Categories', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 240, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 1.05),
            itemCount: s.categories.length,
            itemBuilder: (c, i) {
              final cat = s.categories[i];
              final n = s.byCategory(cat.id).length;
              return GestureDetector(
                onTap: () => push(c, ProductListScreen(title: cat.name, categoryId: cat.id)),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cat.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(children: [
                    Positioned(right: -18, bottom: -18, child: Icon(cat.icon, size: 96, color: cat.color.withOpacity(0.22))),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: cat.color, borderRadius: BorderRadius.circular(14)),
                        child: Icon(cat.icon, color: Colors.white),
                      ),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                        Text('$n products', style: const TextStyle(fontSize: 12.5, color: Color(0xFF6B7194))),
                      ]),
                    ]),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}
