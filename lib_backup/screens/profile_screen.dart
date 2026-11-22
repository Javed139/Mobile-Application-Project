import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'admin/admin_screens.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    final u = s.user;

    Widget tile(IconData i, String t, VoidCallback f, {String? trailing}) => ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
            child: Icon(i, size: 22),
          ),
          title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: trailing != null ? Text(trailing, style: const TextStyle(color: AppColors.slate)) : const Icon(Icons.chevron_right_rounded),
          onTap: f,
        );

    return SafeArea(
      bottom: false,
      child: ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), children: [
        Text('Profile', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(24)),
          child: Row(children: [
            CircleAvatar(
              radius: 30, backgroundColor: AppColors.citron,
              child: Text((u?.name ?? 'G')[0].toUpperCase(), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.ink)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(u?.name ?? 'Guest', style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                Text(u?.email ?? '', style: TextStyle(color: Colors.white.withOpacity(0.7))),
              ]),
            ),
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: Colors.white),
              onPressed: () => push(context, const EditProfileScreen()),
              tooltip: 'Edit profile',
            ),
          ]),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: cs.outlineVariant)),
          child: Column(children: [
            tile(Icons.receipt_long_rounded, 'My orders', () => push(context, const OrdersScreen()), trailing: '${s.orders.length}'),
            tile(Icons.location_on_outlined, 'Saved addresses', () => push(context, const AddressesScreen()), trailing: '${s.addresses.length}'),
            tile(Icons.settings_outlined, 'Settings', () => push(context, const SettingsScreen())),
            tile(Icons.admin_panel_settings_outlined, 'Admin dashboard', () => push(context, const AdminLoginScreen())),
          ]),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
          onPressed: () {
            s.logout();
            Navigator.of(context).pushAndRemoveUntil(slideRoute(const LoginScreen()), (r) => false);
          },
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Log out'),
        ),
      ]),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final _name = TextEditingController(text: context.read<AppState>().user?.name);
  late final _email = TextEditingController(text: context.read<AppState>().user?.email);

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Edit profile')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Full name')),
          const SizedBox(height: 14),
          TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              context.read<AppState>().updateProfile(_name.text.trim(), _email.text.trim());
              Navigator.pop(context);
              snack(context, 'Profile updated');
            },
            child: const Text('Save changes'),
          ),
        ]),
      );
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: s.orders.isEmpty
          ? const EmptyState(icon: Icons.receipt_long_outlined, title: 'No orders yet', message: 'Your orders will appear here after checkout.')
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: s.orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final o = s.orders[i];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: cs.outlineVariant)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text(o.id, style: const TextStyle(fontWeight: FontWeight.w800)),
                      const Spacer(),
                      StatusPill(o.status),
                    ]),
                    const SizedBox(height: 8),
                    Text(o.items.map((e) => '${e.qty}× ${e.product.name}').join(', '), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.slate)),
                    const SizedBox(height: 8),
                    Text('${formatPrice(o.total)} · ${o.payment}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ]),
                );
              },
            ),
    );
  }
}

class StatusPill extends StatelessWidget {
  final String status;
  const StatusPill(this.status, {super.key});
  @override
  Widget build(BuildContext context) {
    final c = status == 'Delivered' ? AppColors.success : status == 'Shipped' ? AppColors.cobalt : AppColors.star;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: c.withOpacity(0.14), borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Saved addresses')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add address'),
      ),
      body: s.addresses.isEmpty
          ? const EmptyState(icon: Icons.location_off_outlined, title: 'No addresses', message: 'Add one so checkout is a single tap.')
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 90),
              itemCount: s.addresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final a = s.addresses[i];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: cs.outlineVariant)),
                  child: Row(children: [
                    const Icon(Icons.location_on_rounded, color: AppColors.cobalt),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(a.label, style: const TextStyle(fontWeight: FontWeight.w800)),
                        Text('${a.line}, ${a.city}\n${a.phone}', style: const TextStyle(color: AppColors.slate, height: 1.4)),
                      ]),
                    ),
                    IconButton(icon: const Icon(Icons.delete_outline_rounded), onPressed: () => s.removeAddress(a)),
                  ]),
                );
              },
            ),
    );
  }

  void _add(BuildContext context) {
    final label = TextEditingController(text: 'Home');
    final line = TextEditingController();
    final city = TextEditingController();
    final phone = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true, showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: label, decoration: const InputDecoration(labelText: 'Label (Home, Work…)')),
            const SizedBox(height: 12),
            TextField(controller: line, decoration: const InputDecoration(labelText: 'Street address')),
            const SizedBox(height: 12),
            TextField(controller: city, decoration: const InputDecoration(labelText: 'City')),
            const SizedBox(height: 12),
            TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone number')),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                if (line.text.trim().isEmpty || city.text.trim().isEmpty) {
                  snack(ctx, 'Enter a street address and city');
                  return;
                }
                final st = context.read<AppState>();
                st.addAddress(Address(id: st.newId('a'), label: label.text.trim(), line: line.text.trim(), city: city.text.trim(), phone: phone.text.trim()));
                Navigator.pop(ctx);
              },
              child: const Text('Save address'),
            ),
          ]),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(children: [
        SwitchListTile(
          secondary: const Icon(Icons.dark_mode_outlined),
          title: const Text('Dark mode'),
          value: s.themeMode == ThemeMode.dark,
          onChanged: (_) => s.toggleTheme(),
        ),
        ListTile(leading: const Icon(Icons.delete_sweep_outlined), title: const Text('Clear search history'), onTap: () { s.clearHistory(); snack(context, 'Search history cleared'); }),
        const ListTile(leading: Icon(Icons.info_outline_rounded), title: Text('Version'), trailing: Text('1.0.0')),
      ]),
    );
  }
}
