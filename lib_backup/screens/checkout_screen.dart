import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Address? _addr;
  String _pay = 'Cash on delivery';
  static const _methods = {
    'Cash on delivery': Icons.payments_outlined,
    'Debit / credit card': Icons.credit_card_rounded,
    'JazzCash / Easypaisa': Icons.account_balance_wallet_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    _addr ??= s.addresses.isNotEmpty ? s.addresses.first : null;
    if (_addr != null && !s.addresses.contains(_addr)) _addr = s.addresses.isNotEmpty ? s.addresses.first : null;

    Widget card(Widget child) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: cs.outlineVariant)),
          child: child,
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: s.cart.isEmpty
          ? const EmptyState(icon: Icons.shopping_bag_outlined, title: 'Nothing to check out', message: 'Add items to your cart first.')
          : ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
              card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Text('Shipping address', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const Spacer(),
                  TextButton(onPressed: () => push(context, const AddressesScreen()), child: const Text('Manage')),
                ]),
                if (s.addresses.isEmpty)
                  const Text('Add an address to continue.', style: TextStyle(color: AppColors.slate))
                else
                  for (final a in s.addresses)
                    RadioListTile<Address>(
                      contentPadding: EdgeInsets.zero,
                      value: a, groupValue: _addr,
                      onChanged: (v) => setState(() => _addr = v),
                      title: Text(a.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('${a.line}, ${a.city}\n${a.phone}'),
                      isThreeLine: true,
                    ),
              ])),
              card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Payment method', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 4),
                for (final e in _methods.entries)
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    value: e.key, groupValue: _pay,
                    onChanged: (v) => setState(() => _pay = v!),
                    secondary: Icon(e.value),
                    title: Text(e.key),
                  ),
              ])),
              card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Order summary', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 10),
                for (final i in s.cart)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(children: [
                      Expanded(child: Text('${i.qty} × ${i.product.name}', maxLines: 1, overflow: TextOverflow.ellipsis)),
                      Text(formatPrice(i.total), style: const TextStyle(fontWeight: FontWeight.w600)),
                    ]),
                  ),
                const Divider(height: 24),
                SummaryRow('Subtotal', formatPrice(s.subtotal)),
                SummaryRow('Delivery', s.shipping == 0 ? 'Free' : formatPrice(s.shipping)),
                SummaryRow('Total', formatPrice(s.total), bold: true),
              ])),
              FilledButton(
                onPressed: _addr == null ? null : () {
                  final o = s.placeOrder(_addr!, _pay);
                  Navigator.of(context).pushReplacement(slideRoute(OrderSuccessScreen(order: o)));
                },
                child: Text('Confirm order · ${formatPrice(s.total)}'),
              ),
            ]),
    );
  }
}

class OrderSuccessScreen extends StatelessWidget {
  final Order order;
  const OrderSuccessScreen({super.key, required this.order});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 650),
              curve: Curves.elasticOut,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Container(
                width: 110, height: 110,
                decoration: const BoxDecoration(color: AppColors.ink, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, size: 64, color: Colors.white),
              ),
            ),
            const SizedBox(height: 28),
            Text('Order placed', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Order ${order.id} is confirmed.\nWe will let you know when it ships.', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.slate, height: 1.5)),
            const SizedBox(height: 32),
            FilledButton(onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst), child: const Text('Back to shopping')),
          ]),
        ),
      ),
    );
  }
}
