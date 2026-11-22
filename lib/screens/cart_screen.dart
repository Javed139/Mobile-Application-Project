import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'checkout_screen.dart';
import 'product_detail_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text('Cart (${s.cartCount})')),
      body: s.cart.isEmpty
          ? EmptyState(icon: Icons.shopping_bag_outlined, title: 'Your cart is empty',
              message: 'Add something you like and it will show up here.',
              actionLabel: 'Keep shopping', onAction: () => Navigator.pop(context))
          : Column(children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  itemCount: s.cart.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (c, i) {
                    final it = s.cart[i];
                    return Dismissible(
                      key: ObjectKey(it),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => s.removeFromCart(it),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(20)),
                        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: cs.outlineVariant)),
                        child: Row(children: [
                          GestureDetector(
                            onTap: () => push(c, ProductDetailScreen(product: it.product)),
                            child: ClipRRect(borderRadius: BorderRadius.circular(14),
                                child: SizedBox(width: 84, height: 84, child: ProductImage(it.product))),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(it.product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text([it.color, it.size].where((e) => e.isNotEmpty).join(' · '), style: const TextStyle(color: AppColors.slate, fontSize: 12.5)),
                              const SizedBox(height: 8),
                              Row(children: [
                                Text(formatPrice(it.total), style: const TextStyle(fontWeight: FontWeight.w800)),
                                const Spacer(),
                                QtyStepper(qty: it.qty, onChanged: (v) => s.changeQty(it, v - it.qty)),
                              ]),
                            ]),
                          ),
                        ]),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                decoration: BoxDecoration(color: cs.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
                child: SafeArea(
                  top: false,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    SummaryRow('Subtotal', formatPrice(s.subtotal)),
                    SummaryRow('Delivery', s.shipping == 0 ? 'Free' : formatPrice(s.shipping)),
                    const Divider(height: 24),
                    SummaryRow('Total', formatPrice(s.total), bold: true),
                    const SizedBox(height: 14),
                    FilledButton(onPressed: () => push(context, const CheckoutScreen()), child: const Text('Proceed to checkout')),
                  ]),
                ),
              ),
            ]),
    );
  }
}

class SummaryRow extends StatelessWidget {
  final String label, value;
  final bool bold;
  const SummaryRow(this.label, this.value, {super.key, this.bold = false});
  @override
  Widget build(BuildContext context) {
    final st = TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w500, fontSize: bold ? 18 : 15, color: bold ? null : AppColors.slate);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [Text(label, style: st), const Spacer(), Text(value, style: st.copyWith(color: null))]),
    );
  }
}
