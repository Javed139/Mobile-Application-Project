import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';
import 'viewer_3d_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _img = 0, _qty = 1;
  late String _color = widget.product.colors.isNotEmpty ? widget.product.colors.first : '';
  late String _size = widget.product.sizes.isNotEmpty ? widget.product.sizes.first : '';

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final s = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    final count = p.images.isEmpty ? 3 : p.images.length;
    final out = p.stock == 0;

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: MediaQuery.of(context).size.height * 0.46,
          backgroundColor: cs.surface,
          leading: _circle(context, Icons.arrow_back_rounded, () => Navigator.pop(context)),
          actions: [
            _circle(context, s.isWished(p.id) ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                () => s.toggleWish(p.id), color: s.isWished(p.id) ? AppColors.danger : null),
            _circle(context, Icons.shopping_bag_outlined, () => push(context, const CartScreen())),
            const SizedBox(width: 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(children: [
              Positioned.fill(
                child: PageView.builder(
                  itemCount: count,
                  onPageChanged: (v) => setState(() => _img = v),
                  itemBuilder: (_, i) => ProductImage(p, index: i),
                ),
              ),
              Positioned(
                bottom: 14, left: 0, right: 0,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  for (var i = 0; i < count; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _img ? 22 : 7, height: 7,
                      decoration: BoxDecoration(color: i == _img ? AppColors.ink : Colors.white, borderRadius: BorderRadius.circular(7)),
                    ),
                ]),
              ),
              if (p.modelUrl != null)
                Positioned(
                  right: 16, bottom: 34,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(minimumSize: const Size(0, 42), padding: const EdgeInsets.symmetric(horizontal: 16)),
                    onPressed: () => push(context, Viewer3DScreen(product: p)),
                    icon: const Icon(Icons.view_in_ar_rounded, size: 20),
                    label: const Text('View in 3D'),
                  ),
                ),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(p.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800))),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                RatingRow(p.rating, count: p.reviews),
                const Spacer(),
                Text(out ? 'Out of stock' : p.stock <= 10 ? 'Only ${p.stock} left' : 'In stock',
                    style: TextStyle(fontWeight: FontWeight.w700, color: out ? AppColors.danger : p.stock <= 10 ? AppColors.star : AppColors.success)),
              ]),
              const SizedBox(height: 14),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(formatPrice(p.price), style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: cs.primary)),
                if (p.oldPrice != null) ...[
                  const SizedBox(width: 10),
                  Text(formatPrice(p.oldPrice!), style: const TextStyle(decoration: TextDecoration.lineThrough, color: AppColors.slate)),
                ],
              ]),
              const SizedBox(height: 20),
              Text(p.description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55, color: AppColors.slate)),
              if (p.colors.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Colour: $_color', style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Wrap(spacing: 12, children: [
                  for (final c in p.colors)
                    GestureDetector(
                      onTap: () => setState(() => _color = c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _color == c ? cs.primary : Colors.transparent, width: 2)),
                        child: Container(
                          width: 34, height: 34,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: colorFromName(c), border: Border.all(color: cs.outlineVariant)),
                          child: _color == c ? Icon(Icons.check_rounded, size: 18, color: colorFromName(c).computeLuminance() > 0.5 ? Colors.black : Colors.white) : null,
                        ),
                      ),
                    ),
                ]),
              ],
              if (p.sizes.isNotEmpty) ...[
                const SizedBox(height: 22),
                const Text('Size', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final sz in p.sizes) ChoiceChip(label: Text(sz), selected: _size == sz, onSelected: (_) => setState(() => _size = sz)),
                ]),
              ],
              const SizedBox(height: 22),
              Row(children: [
                const Text('Quantity', style: TextStyle(fontWeight: FontWeight.w800)),
                const Spacer(),
                QtyStepper(qty: _qty, onChanged: (v) => setState(() => _qty = v)),
              ]),
              const SizedBox(height: 28),
              Text('Reviews', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              for (final r in MockData.reviews())
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: cs.outlineVariant)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      CircleAvatar(radius: 16, backgroundColor: AppColors.cobalt.withOpacity(0.12),
                          child: Text(r.author[0], style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.cobalt))),
                      const SizedBox(width: 10),
                      Text(r.author, style: const TextStyle(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      RatingRow(r.stars.toDouble()),
                    ]),
                    const SizedBox(height: 10),
                    Text(r.text, style: const TextStyle(height: 1.45, color: AppColors.slate)),
                  ]),
                ),
            ]),
          ),
        ),
      ]),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: BoxDecoration(color: cs.surface, border: Border(top: BorderSide(color: cs.outlineVariant))),
          child: Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: out ? null : () {
                  s.addToCart(p, color: _color, size: _size, qty: _qty);
                  snack(context, 'Added to cart');
                },
                child: const Text('Add to cart'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: out ? null : () {
                  s.addToCart(p, color: _color, size: _size, qty: _qty);
                  push(context, const CheckoutScreen());
                },
                child: const Text('Buy now'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _circle(BuildContext c, IconData icon, VoidCallback onTap, {Color? color}) => Padding(
        padding: const EdgeInsets.all(6),
        child: Material(
          color: Theme.of(c).colorScheme.surface.withOpacity(0.92),
          shape: const CircleBorder(),
          child: InkWell(customBorder: const CircleBorder(), onTap: onTap, child: Icon(icon, size: 22, color: color)),
        ),
      );
}

class QtyStepper extends StatelessWidget {
  final int qty;
  final ValueChanged<int> onChanged;
  const QtyStepper({super.key, required this.qty, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget btn(IconData i, VoidCallback f) => InkWell(
          borderRadius: BorderRadius.circular(12), onTap: f,
          child: Padding(padding: const EdgeInsets.all(8), child: Icon(i, size: 20)),
        );
    return Container(
      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: cs.outlineVariant)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        btn(Icons.remove_rounded, () => onChanged((qty - 1).clamp(1, 99))),
        SizedBox(width: 30, child: Text('$qty', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800))),
        btn(Icons.add_rounded, () => onChanged((qty + 1).clamp(1, 99))),
      ]),
    );
  }
}
