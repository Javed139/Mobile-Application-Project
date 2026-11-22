
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../../core/utils.dart';

// ======================================================
// ADMIN LOGIN
// ======================================================

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _key = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  bool _hidePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _login() async {
    if (_loading || !_key.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final error = await context.read<AppState>().signInAsAdmin(
        _email.text.trim(),
        _pass.text,
      );

      if (!mounted) return;

      if (error != null) {
        _showMessage(error);
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const AdminDashboard(),
        ),
            (route) => false,
      );
    } catch (e) {
      if (mounted) {
        _showMessage('Admin login failed. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: _key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.limeAccent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Admin sign in',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Sign in with your authorized administrator account.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Admin email',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isEmpty ||
                          !email.contains('@') ||
                          !email.contains('.')) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _pass,
                    obscureText: _hidePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _hidePassword = !_hidePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                        ),
                      )
                          : const Text('Sign in'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================
// ADMIN DASHBOARD
// ======================================================

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  Future<void> _logout(BuildContext context) async {
    await context.read<AppState>().logout();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const AdminLoginScreen(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Verra Admin',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              tooltip: 'Logout',
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.dashboard_outlined), text: 'Overview'),
              Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Products'),
              Tab(icon: Icon(Icons.category_outlined), text: 'Categories'),
              Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Orders'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminOverviewTab(),
            AdminProductsTab(),
            AdminCategoriesTab(),
            AdminOrdersTab(),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// OVERVIEW
// ======================================================

class AdminOverviewTab extends StatelessWidget {
  const AdminOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        final totalProducts = state.products.length;
        final totalCategories = state.categories.length;
        final totalOrders = state.orders.length;
        final lowStock = state.products.where((p) => p.stock <= 5).length;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Dashboard Overview',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text('Manage your Verra online store.'),
            const SizedBox(height: 22),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                _StatCard(
                  title: 'Products',
                  value: '$totalProducts',
                  icon: Icons.inventory_2_outlined,
                ),
                _StatCard(
                  title: 'Categories',
                  value: '$totalCategories',
                  icon: Icons.category_outlined,
                ),
                _StatCard(
                  title: 'Orders',
                  value: '$totalOrders',
                  icon: Icons.receipt_long_outlined,
                ),
                _StatCard(
                  title: 'Low Stock',
                  value: '$lowStock',
                  icon: Icons.warning_amber_rounded,
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'Recent Orders',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (state.orders.isEmpty)
              const EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No orders yet',
                message: 'Customer orders will appear here.',
              )
            else
              ...state.orders.take(5).map(
                    (order) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.shopping_bag_outlined),
                    ),
                    title: Text(order.id),
                    subtitle: Text(
                      '${order.items.length} item(s) • ${order.status}',
                    ),
                    trailing: Text(formatPrice(order.total)),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// PRODUCTS MANAGEMENT
// ======================================================

class AdminProductsTab extends StatelessWidget {
  const AdminProductsTab({super.key});

  Future<void> _deleteProduct(
      BuildContext context,
      Product product,
      ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    try {
      await context.read<AppState>().deleteProduct(product);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete product: $e')),
        );
      }
    }
  }

  void _openForm(BuildContext context, {Product? product}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        return Scaffold(
          body: state.loadingCatalog && state.products.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : state.products.isEmpty
              ? const EmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'No products found',
            message: 'Add your first product to the store.',
          )
              : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: state.products.length,
            itemBuilder: (context, index) {
              final product = state.products[index];
              final category =
              state.categoryById(product.categoryId);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 75,
                        height: 75,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: ProductImage(product),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(category?.name ?? 'Uncategorized'),
                            const SizedBox(height: 4),
                            Text(formatPrice(product.price)),
                            Text('Stock: ${product.stock}'),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _openForm(context, product: product);
                          } else if (value == 'delete') {
                            _deleteProduct(context, product);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openForm(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Product'),
          ),
        );
      },
    );
  }
}

// ======================================================
// PRODUCT FORM
// ======================================================

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _oldPrice;
  late final TextEditingController _stock;
  late final TextEditingController _images;
  late final TextEditingController _modelUrl;
  late final TextEditingController _colors;
  late final TextEditingController _sizes;
  late final TextEditingController _tags;

  String? _categoryId;
  bool _featured = false;
  bool _trending = false;
  bool _saving = false;

  bool get _editing => widget.product != null;

  @override
  void initState() {
    super.initState();

    final p = widget.product;

    _name = TextEditingController(text: p?.name ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _price = TextEditingController(text: p?.price.toString() ?? '');
    _oldPrice = TextEditingController(text: p?.oldPrice?.toString() ?? '');
    _stock = TextEditingController(text: p?.stock.toString() ?? '20');
    _images = TextEditingController(text: p?.images.join('\n') ?? '');
    _modelUrl = TextEditingController(text: p?.modelUrl ?? '');
    _colors = TextEditingController(text: p?.colors.join(', ') ?? '');
    _sizes = TextEditingController(text: p?.sizes.join(', ') ?? '');
    _tags = TextEditingController(text: p?.tags.join(', ') ?? '');

    _categoryId = p?.categoryId;
    _featured = p?.featured ?? false;
    _trending = p?.trending ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _oldPrice.dispose();
    _stock.dispose();
    _images.dispose();
    _modelUrl.dispose();
    _colors.dispose();
    _sizes.dispose();
    _tags.dispose();
    super.dispose();
  }

  List<String> _parseList(String value) {
    return value
        .split(RegExp(r'[,;\n]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;

    if (_categoryId == null || _categoryId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
      );
      return;
    }

    setState(() => _saving = true);

    final existing = widget.product;

    final product = Product(
      id: existing?.id ?? context.read<AppState>().newId('p'),
      name: _name.text.trim(),
      description: _description.text.trim(),
      categoryId: _categoryId!,
      price: double.parse(_price.text.trim()),
      oldPrice: _oldPrice.text.trim().isEmpty
          ? null
          : double.tryParse(_oldPrice.text.trim()),
      stock: int.parse(_stock.text.trim()),
      images: _parseList(_images.text),
      modelUrl:
      _modelUrl.text.trim().isEmpty ? null : _modelUrl.text.trim(),
      colors: _parseList(_colors.text),
      sizes: _parseList(_sizes.text),
      tags: _parseList(_tags.text),
      rating: existing?.rating ?? 4.5,
      reviews: existing?.reviews ?? 0,
      featured: _featured,
      trending: _trending,
    );

    try {
      await context.read<AppState>().saveProduct(
        product,
        isNew: !_editing,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editing
                ? 'Product updated successfully.'
                : 'Product added successfully.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save product: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Widget _field(
      TextEditingController controller,
      String label, {
        TextInputType keyboardType = TextInputType.text,
        int maxLines = 1,
        bool required = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          alignLabelWithHint: maxLines > 1,
        ),
        validator: required
            ? (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          return null;
        }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<AppState>().categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Edit Product' : 'Add Product'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _field(_name, 'Product Name', required: true),
            _field(
              _description,
              'Description',
              maxLines: 3,
              required: true,
            ),
            _field(
              _price,
              'Price (PKR)',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              required: true,
            ),
            _field(
              _oldPrice,
              'Old Price (Optional)',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            _field(
              _stock,
              'Stock Quantity',
              keyboardType: TextInputType.number,
              required: true,
            ),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              initialValue: categories.any((c) => c.id == _categoryId)
                  ? _categoryId
                  : null,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: categories
                  .map(
                    (category) => DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name),
                ),
              )
                  .toList(),
              onChanged: (value) {
                setState(() => _categoryId = value);
              },
            ),
            const SizedBox(height: 14),
            _field(
              _images,
              'Image URLs (one per line)',
              maxLines: 3,
            ),
            _field(_modelUrl, '3D Model URL (Optional)'),
            _field(_colors, 'Colors (comma separated)'),
            _field(_sizes, 'Sizes (comma separated)'),
            _field(_tags, 'Tags (comma separated)'),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Featured Product'),
              value: _featured,
              onChanged: (value) {
                setState(() => _featured = value);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Trending Product'),
              value: _trending,
              onChanged: (value) {
                setState(() => _trending = value);
              },
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const CircularProgressIndicator()
                  : Text(_editing ? 'Update Product' : 'Save Product'),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// CATEGORIES MANAGEMENT
// ======================================================

class AdminCategoriesTab extends StatelessWidget {
  const AdminCategoriesTab({super.key});

  Future<void> _showCategoryDialog(
      BuildContext context, {
        Category? category,
      }) async {
    final nameController = TextEditingController(
      text: category?.name ?? '',
    );

    String iconKey = category?.iconKey ?? categoryIcons.keys.first;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                category == null ? 'Add Category' : 'Edit Category',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Category Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: iconKey,
                    decoration: const InputDecoration(
                      labelText: 'Category Icon',
                      border: OutlineInputBorder(),
                    ),
                    items: categoryIcons.entries
                        .map(
                          (entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Row(
                          children: [
                            Icon(entry.value),
                            const SizedBox(width: 10),
                            Text(entry.key),
                          ],
                        ),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => iconKey = value);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;
                    Navigator.pop(dialogContext, true);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true || !context.mounted) {
      nameController.dispose();
      return;
    }

    try {
      final state = context.read<AppState>();

      if (category == null) {
        await state.addCategory(
          nameController.text.trim(),
          iconKey,
          const Color(0xFF4F7396),
        );
      } else {
        await state.updateCategory(
          category,
          nameController.text.trim(),
          iconKey,
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category saved.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save category: $e')),
        );
      }
    } finally {
      nameController.dispose();
    }
  }

  Future<void> _deleteCategory(
      BuildContext context,
      Category category,
      ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    try {
      final deleted =
      await context.read<AppState>().deleteCategory(category);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            deleted
                ? 'Category deleted.'
                : 'This category contains products. Move or delete those products first.',
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete category: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        return Scaffold(
          body: state.categories.isEmpty
              ? const EmptyState(
            icon: Icons.category_outlined,
            title: 'No categories found',
            message: 'Add a category to organize your products.',
          )
              : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: state.categories.length,
            itemBuilder: (context, index) {
              final category = state.categories[index];

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                    category.color.withValues(alpha: 0.15),
                    child: Icon(
                      category.icon,
                      color: category.color,
                    ),
                  ),
                  title: Text(
                    category.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${state.byCategory(category.id).length} products',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showCategoryDialog(
                          context,
                          category: category,
                        );
                      } else if (value == 'delete') {
                        _deleteCategory(context, category);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showCategoryDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Category'),
          ),
        );
      },
    );
  }
}

// ======================================================
// ORDERS MANAGEMENT
// ======================================================

class AdminOrdersTab extends StatelessWidget {
  const AdminOrdersTab({super.key});

  static const List<String> statuses = [
    'Processing',
    'Confirmed',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  Future<void> _changeStatus(
      BuildContext context,
      Order order,
      String status,
      ) async {
    try {
      await context.read<AppState>().setOrderStatus(order, status);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order status updated.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update order: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        if (state.orders.isEmpty) {
          return const EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No orders found',
            message: 'Customer orders will appear here.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: state.orders.length,
          itemBuilder: (context, index) {
            final order = state.orders[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            order.id,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          formatPrice(order.total),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Date: ${order.date.day}/${order.date.month}/${order.date.year}',
                    ),
                    Text('Payment: ${order.payment}'),
                    Text('Address: ${order.address}'),
                    const Divider(height: 24),
                    const Text(
                      'Items',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    ...order.items.map(
                          (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          '${item.product.name}  × ${item.qty}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: statuses.contains(order.status)
                          ? order.status
                          : 'Processing',
                      decoration: const InputDecoration(
                        labelText: 'Order Status',
                        border: OutlineInputBorder(),
                      ),
                      items: statuses
                          .map(
                            (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ),
                      )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _changeStatus(context, order, value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
