import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../models/models.dart';
import '../state/app_state.dart';

/// Renders a product image from a URL / local file, or a styled placeholder
/// tinted with the category colour when no image has been uploaded.
class ProductImage extends StatelessWidget {
  final Product product;
  final int index;
  final BoxFit fit;
  const ProductImage(this.product, {super.key, this.index = 0, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final cat = context.watch<AppState>().categoryById(product.categoryId);
    final tint = cat?.color ?? AppColors.cobalt;
    if (product.images.isNotEmpty) {
      final src = product.images[index % product.images.length];
      final img = src.startsWith('http')
          ? Image.network(src, fit: fit, width: double.infinity, height: double.infinity,
              errorBuilder: (_, __, ___) => _placeholder(tint, cat?.icon))
          : Image.file(File(src), fit: fit, width: double.infinity, height: double.infinity,
              errorBuilder: (_, __, ___) => _placeholder(tint, cat?.icon));
      return img;
    }
    return _placeholder(tint, cat?.icon);
  }

  Widget _placeholder(Color tint, IconData? icon) {
    final shift = [0.0, 0.12, -0.08][index % 3];
    final c = Color.lerp(tint, shift >= 0 ? Colors.white : Colors.black, shift.abs())!;
    return LayoutBuilder(builder: (context, box) {
      final s = box.biggest.shortestSide.isFinite ? box.biggest.shortestSide : 120.0;
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [c.withOpacity(0.28), c.withOpacity(0.08)],
          ),
        ),
        child: Stack(alignment: Alignment.center, children: [
          Positioned(right: -s * 0.12, top: -s * 0.12,
              child: Container(width: s * 0.55, height: s * 0.55,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: c.withOpacity(0.14)))),
          Transform.rotate(angle: [0.0, -0.18, 0.18][index % 3],
              child: Icon(icon ?? Icons.shopping_bag_rounded, size: s * 0.42, color: c.withOpacity(0.9))),
        ]),
      );
    });
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    final wished = s.isWished(product.id);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppSpace.radiusLg),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Stack(children: [
              Positioned.fill(child: ProductImage(product)),
              if (product.discountPercent != null)
                Positioned(left: 10, top: 10, child: _Badge('-${product.discountPercent}%')),
              Positioned(
                right: 8, top: 8,
                child: Material(
                  color: cs.surface.withOpacity(0.92),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => s.toggleWish(product.id),
                    child: Padding(
                      padding: const EdgeInsets.all(7),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                        child: Icon(
                          wished ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          key: ValueKey(wished), size: 20,
                          color: wished ? AppColors.danger : AppColors.slate,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              RatingRow(product.rating, count: product.reviews, size: 14),
              const SizedBox(height: 6),
              Row(children: [
                Text(formatPrice(product.price),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                if (product.oldPrice != null) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(formatPrice(product.oldPrice!), maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            decoration: TextDecoration.lineThrough, color: AppColors.slate)),
                  ),
                ],
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge(this.text);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: AppColors.citron, borderRadius: BorderRadius.circular(8)),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
      );
}

class RatingRow extends StatelessWidget {
  final double rating;
  final int? count;
  final double size;
  const RatingRow(this.rating, {super.key, this.count, this.size = 16});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.star_rounded, size: size + 2, color: AppColors.star),
        const SizedBox(width: 2),
        Text(rating.toStringAsFixed(1),
            style: TextStyle(fontSize: size - 1, fontWeight: FontWeight.w700)),
        if (count != null)
          Text(' ($count)', style: TextStyle(fontSize: size - 2, color: AppColors.slate)),
      ]);
}

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const SectionHeader(this.title, {super.key, this.onSeeAll});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 12, 12),
        child: Row(children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
          if (onSeeAll != null) TextButton(onPressed: onSeeAll, child: const Text('See all')),
        ]),
      );
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, message;
  final String? actionLabel;
  final VoidCallback? onAction;
  const EmptyState({super.key, required this.icon, required this.title, required this.message, this.actionLabel, this.onAction});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, shape: BoxShape.circle),
              child: Icon(icon, size: 40, color: AppColors.slate),
            ),
            const SizedBox(height: 20),
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.slate)),
            if (actionLabel != null) ...[
              const SizedBox(height: 20),
              SizedBox(width: 200, child: FilledButton(onPressed: onAction, child: Text(actionLabel!))),
            ],
          ]),
        ),
      );
}

/// Responsive product grid: column count follows the available width.
class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final bool shrink;
  const ProductGrid(this.products, {super.key, this.shrink = false});
  @override
  Widget build(BuildContext context) => GridView.builder(
        shrinkWrap: shrink,
        physics: shrink ? const NeverScrollableScrollPhysics() : null,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 230, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.66),
        itemCount: products.length,
        itemBuilder: (c, i) => ProductCard(
          product: products[i],
          onTap: () => push(c, _lazyDetail(products[i])),
        ),
      );
}

// Late-bound to avoid an import cycle between widgets and screens.
typedef DetailBuilder = Widget Function(Product p);
DetailBuilder? detailBuilder;
Widget _lazyDetail(Product p) => detailBuilder!(p);

class AppSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final bool readOnly, autofocus;
  final VoidCallback? onTap, onMic;
  final ValueChanged<String>? onSubmitted, onChanged;
  final String hint;
  const AppSearchField({
    super.key, this.controller, this.readOnly = false, this.autofocus = false, this.onTap, this.onMic,
    this.onSubmitted, this.onChanged, this.hint = 'Search or describe what you need',
  });
  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        readOnly: readOnly,
        autofocus: autofocus,
        onTap: onTap,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.slate),
          suffixIcon: onMic == null ? null : IconButton(icon: const Icon(Icons.mic_rounded), onPressed: onMic),
        ),
      );
}
