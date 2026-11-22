import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../profile_screen.dart' show StatusPill;

/// Demo credentials: admin@verra.app / admin123. Replace with a server-side
/// role check (e.g. custom claims) once the backend exists.
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _email = TextEditingController(text: 'admin@verra.app');
  final _pass = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(18)),
                  child: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.citron),
                ),
                const SizedBox(height: 20),
                Text('Admin sign in', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text('Demo password: admin123', style: TextStyle(color: AppColors.slate)),
                const SizedBox(height: 24),
                TextField(controller: _email, decoration: const InputDecoration(labelText: 'Admin email')),
                const SizedBox(height: 14),
                TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: () {
                    if (_email.text.trim() == 'admin@verra.app' && _pass.text == 'admin123') {
                      context.read<AppState>().user?.isAdmin = true;
                      Navigator.of(context).pushReplacement(slideRoute(const AdminDashboard()));
                    } else {
                      snack(context, 'Incorrect admin email or password');
                    }
                  },
                  child: const Text('Sign in'),
                ),
              ]),
            ),
          ),
        ),
      );
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});
  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Admin'),
            bottom: const TabBar(isScrollable: true, tabAlignment: TabAlignment.start, tabs: [
              Tab(text: 'Overview'), Tab(text: 'Products'), Tab(text: 'Categories'), Tab(text: 'Orders'),
            ]),
          ),
          body: const TabBarView(children: [_Overview(), _Products(), _Categories(), _Orders()]),
        ),
      );
}

class _Overview extends StatelessWidget {
  const _Overview();
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final revenue = s.orders.fold(0.0, (a, o) => a + o.total);
    final low = s.products.where((p) => p.stock <= 10).toList();
    final cs = Theme.of(context).colorScheme;
    Widget stat(IconData i, String v, String l, Color c) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(i, color: c),
              const SizedBox(height: 10),
              Text(v, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              Text(l, style: const TextStyle(color: AppColors.slate, fontSize: 12.5)),
            ]),
          ),
        );
    return ListView(padding: const EdgeInsets.all(20), children: [
      Row(children: [
        stat(Icons.inventory_2_rounded, '${s.products.length}', 'Products', AppColors.cobalt),
        const SizedBox(width: 12),
        stat(Icons.receipt_long_rounded, '${s.orders.length}', 'Orders', AppColors.success),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        stat(Icons.category_rounded, '${s.categories.length}', 'Categories', const Color(0xFF7B4BD3)),
        const SizedBox(width: 12),
        stat(Icons.payments_rounded, formatPrice(revenue), 'Revenue', AppColors.star),
      ]),
      const SizedBox(height: 24),
      Text('Low stock', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      if (low.isEmpty) const Text('All products are well stocked.', style: TextStyle(color: AppColors.slate)),
      for (final p in low)
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: cs.outlineVariant)),
          child: ListTile(
            title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Text('${p.stock} left', style: TextStyle(fontWeight: FontWeight.w800, color: p.stock == 0 ? AppColors.danger : AppColors.star)),
          ),
        ),
    ]);
  }
}

class _Products extends StatelessWidget {
  const _Products();
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => push(context, const ProductFormScreen()),
        icon: const Icon(Icons.add_rounded), label: const Text('Add product'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
        itemCount: s.products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (c, i) {
          final p = s.products[i];
          return Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: cs.outlineVariant)),
            child: Row(children: [
              ClipRRect(borderRadius: BorderRadius.circular(12), child: SizedBox(width: 60, height: 60, child: ProductImage(p))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text('${s.categoryById(p.categoryId)?.name ?? '—'} · ${formatPrice(p.price)}', style: const TextStyle(color: AppColors.slate, fontSize: 12.5)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Text('Stock', style: TextStyle(fontSize: 12.5, color: AppColors.slate)),
                    const SizedBox(width: 6),
                    _mini(Icons.remove_rounded, () => s.adjustStock(p, -1)),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('${p.stock}', style: const TextStyle(fontWeight: FontWeight.w800))),
                    _mini(Icons.add_rounded, () => s.adjustStock(p, 1)),
                  ]),
                ]),
              ),
              PopupMenuButton<String>(
                onSelected: (v) async {
                  if (v == 'edit') {
                    push(c, ProductFormScreen(product: p));
                  } else {
                    final ok = await showDialog<bool>(
                      context: c,
                      builder: (d) => AlertDialog(
                        title: const Text('Delete product?'),
                        content: Text('"${p.name}" will be removed from the store.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.pop(d, true), child: const Text('Delete', style: TextStyle(color: AppColors.danger))),
                        ],
                      ),
                    );
                    if (ok == true) s.deleteProduct(p);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ]),
          );
        },
      ),
    );
  }

  Widget _mini(IconData i, VoidCallback f) => InkWell(
        onTap: f, borderRadius: BorderRadius.circular(8),
        child: Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(border: Border.all(color: AppColors.slate.withOpacity(0.4)), borderRadius: BorderRadius.circular(8)), child: Icon(i, size: 16)),
      );
}

class _Categories extends StatelessWidget {
  const _Categories();
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context),
        icon: const Icon(Icons.add_rounded), label: const Text('Add category'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
        itemCount: s.categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (c, i) {
          final cat = s.categories[i];
          return Container(
            decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: cs.outlineVariant)),
            child: ListTile(
              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: cat.color.withOpacity(0.14), borderRadius: BorderRadius.circular(12)), child: Icon(cat.icon, color: cat.color)),
              title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${s.byCategory(cat.id).length} products'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _edit(c, cat: cat)),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () {
                    if (!s.deleteCategory(cat)) snack(c, 'Move or delete this category\'s products first');
                  },
                ),
              ]),
            ),
          );
        },
      ),
    );
  }

  void _edit(BuildContext context, {Category? cat}) {
    final ctrl = TextEditingController(text: cat?.name ?? '');
    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(cat == null ? 'New category' : 'Rename category'),
        content: TextField(controller: ctrl, autofocus: true, decoration: const InputDecoration(labelText: 'Category name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final n = ctrl.text.trim();
              if (n.isEmpty) return;
              final s = context.read<AppState>();
              if (cat == null) {
                const palette = [Color(0xFF0E7C86), Color(0xFFB5446E), Color(0xFF5B6CFF), Color(0xFF8A6D3B), Color(0xFF2B9348)];
                const icons = [Icons.chair_rounded, Icons.sports_soccer_rounded, Icons.toys_rounded, Icons.menu_book_rounded, Icons.kitchen_rounded];
                final k = s.categories.length;
                s.addCategory(n, icons[k % icons.length], palette[k % palette.length]);
              } else {
                s.renameCategory(cat, n);
              }
              Navigator.pop(d);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _Orders extends StatelessWidget {
  const _Orders();
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    if (s.orders.isEmpty) {
      return const EmptyState(icon: Icons.receipt_long_outlined, title: 'No orders yet', message: 'Orders placed from the store will show up here.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: s.orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final o = s.orders[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: cs.outlineVariant)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Text(o.id, style: const TextStyle(fontWeight: FontWeight.w800)), const Spacer(), StatusPill(o.status)]),
            const SizedBox(height: 6),
            Text(o.items.map((e) => '${e.qty}× ${e.product.name}').join(', '), style: const TextStyle(color: AppColors.slate)),
            const SizedBox(height: 4),
            Text('${formatPrice(o.total)} · ${o.address}', style: const TextStyle(fontSize: 12.5)),
            const SizedBox(height: 10),
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 'Processing', label: Text('Processing')),
                ButtonSegment(value: 'Shipped', label: Text('Shipped')),
                ButtonSegment(value: 'Delivered', label: Text('Delivered')),
              ],
              selected: {o.status},
              onSelectionChanged: (v) => s.setOrderStatus(o, v.first),
            ),
          ]),
        );
      },
    );
  }
}

/// Add or edit a product. Works for any category, and categories themselves
/// are managed dynamically in the Categories tab.
class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});
  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _key = GlobalKey<FormState>();
  late final Product? p = widget.product;
  late final _name = TextEditingController(text: p?.name);
  late final _desc = TextEditingController(text: p?.description);
  late final _price = TextEditingController(text: p?.price.round().toString());
  late final _old = TextEditingController(text: p?.oldPrice?.round().toString());
  late final _stock = TextEditingController(text: p?.stock.toString() ?? '10');
  late final _colors = TextEditingController(text: p?.colors.join(', '));
  late final _sizes = TextEditingController(text: p?.sizes.join(', '));
  late final _model = TextEditingController(text: p?.modelUrl);
  late String? _cat = p?.categoryId;
  late List<String> _images = List.of(p?.images ?? []);
  late bool _featured = p?.featured ?? false;
  late bool _trending = p?.trending ?? false;

  @override
  void dispose() {
    for (final c in [_name, _desc, _price, _old, _stock, _colors, _sizes, _model]) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> _split(String v) => v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  Future<void> _pick() async {
    final files = await ImagePicker().pickMultiImage(imageQuality: 85);
    if (files.isNotEmpty) setState(() => _images.addAll(files.map((f) => f.path)));
  }

  void _save() {
    if (!_key.currentState!.validate()) return;
    final s = context.read<AppState>();
    final isNew = p == null;
    final prod = p ?? Product(id: s.newId('p'), name: '', description: '', categoryId: _cat!, price: 0);
    prod
      ..name = _name.text.trim()
      ..description = _desc.text.trim()
      ..categoryId = _cat!
      ..price = double.parse(_price.text)
      ..oldPrice = double.tryParse(_old.text)
      ..stock = int.tryParse(_stock.text) ?? 0
      ..colors = _split(_colors.text)
      ..sizes = _split(_sizes.text)
      ..images = _images
      ..modelUrl = _model.text.trim().isEmpty ? null : _model.text.trim()
      ..featured = _featured
      ..trending = _trending;
    s.saveProduct(prod, isNew: isNew);
    Navigator.pop(context);
    snack(context, isNew ? 'Product added' : 'Product updated');
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    String? req(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;
    return Scaffold(
      appBar: AppBar(title: Text(p == null ? 'Add product' : 'Edit product')),
      body: Form(
        key: _key,
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 32), children: [
          SizedBox(
            height: 96,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              InkWell(
                onTap: _pick,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 96,
                  decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: cs.outlineVariant)),
                  child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.add_photo_alternate_outlined), SizedBox(height: 4), Text('Upload', style: TextStyle(fontSize: 12)),
                  ]),
                ),
              ),
              for (final path in _images)
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Stack(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: SizedBox(
                        width: 96, height: 96,
                        child: path.startsWith('http') ? Image.network(path, fit: BoxFit.cover) : Image.file(File(path), fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: 4, right: 4,
                      child: GestureDetector(
                        onTap: () => setState(() => _images.remove(path)),
                        child: const CircleAvatar(radius: 11, backgroundColor: Colors.black54, child: Icon(Icons.close_rounded, size: 14, color: Colors.white)),
                      ),
                    ),
                  ]),
                ),
            ]),
          ),
          const SizedBox(height: 18),
          TextFormField(controller: _name, validator: req, decoration: const InputDecoration(labelText: 'Product name')),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _cat,
            decoration: const InputDecoration(labelText: 'Category'),
            items: [for (final c in s.categories) DropdownMenuItem(value: c.id, child: Text(c.name))],
            onChanged: (v) => setState(() => _cat = v),
            validator: (v) => v == null ? 'Choose a category' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(controller: _desc, validator: req, maxLines: 4, decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: TextFormField(
                controller: _price, keyboardType: TextInputType.number,
                validator: (v) => double.tryParse(v ?? '') == null ? 'Enter a number' : null,
                decoration: const InputDecoration(labelText: 'Price (Rs)'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: TextFormField(controller: _old, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Old price (optional)'))),
          ]),
          const SizedBox(height: 14),
          TextFormField(controller: _stock, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stock quantity')),
          const SizedBox(height: 14),
          TextFormField(controller: _colors, decoration: const InputDecoration(labelText: 'Colours', helperText: 'Separate with commas: Black, Navy')),
          const SizedBox(height: 14),
          TextFormField(controller: _sizes, decoration: const InputDecoration(labelText: 'Sizes or variants', helperText: 'Separate with commas: S, M, L  or  128GB, 256GB')),
          const SizedBox(height: 14),
          TextFormField(controller: _model, decoration: const InputDecoration(labelText: '3D model URL (.glb, optional)')),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Show in Featured'), value: _featured, onChanged: (v) => setState(() => _featured = v)),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Show in Trending'), value: _trending, onChanged: (v) => setState(() => _trending = v)),
          const SizedBox(height: 12),
          FilledButton(onPressed: _save, child: Text(p == null ? 'Add product' : 'Save changes')),
        ]),
      ),
    );
  }
}
