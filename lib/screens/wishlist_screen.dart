import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'product_detail_screen.dart';
import 'shell_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    final items = s.wishedProducts;
    return SafeArea(
      bottom: false,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text('Wishlist', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        ),
        Expanded(
          child: items.isEmpty
              ? EmptyState(icon: Icons.favorite_border_rounded, title: 'Nothing saved yet',
                  message: 'Tap the heart on any product to keep it here.',
                  actionLabel: 'Browse products',
                  onAction: () => context.findAncestorStateOfType<ShellScreenState>()?.goTo(0))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (c, i) {
                    final p = items[i];
                    return GestureDetector(
                      onTap: () => push(c, ProductDetailScreen(product: p)),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: cs.outlineVariant)),
                        child: Row(children: [
                          ClipRRect(borderRadius: BorderRadius.circular(14), child: SizedBox(width: 88, height: 88, child: ProductImage(p))),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              RatingRow(p.rating, count: p.reviews, size: 14),
                              const SizedBox(height: 6),
                              Text(formatPrice(p.price), style: const TextStyle(fontWeight: FontWeight.w800)),
                            ]),
                          ),
                          Column(children: [
                            IconButton(icon: const Icon(Icons.close_rounded, color: AppColors.slate), onPressed: () => s.toggleWish(p.id), tooltip: 'Remove'),
                            IconButton(
                              icon: const Icon(Icons.add_shopping_cart_rounded, color: AppColors.cobalt),
                              tooltip: 'Add to cart',
                              onPressed: p.stock == 0 ? null : () {
                                s.addToCart(p);
                                snack(context, 'Added to cart');
                              },
                            ),
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
