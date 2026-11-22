import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/models.dart';

/// Single source of truth. Swap the in-memory lists for repository calls
/// (REST / Firebase) when the backend is ready; the UI only talks to this class.
class AppState extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;
  AppUser? user;

  final List<Category> categories = MockData.categories();
  final List<Product> products = MockData.products();
  final List<CartItem> cart = [];
  final Set<String> wishlist = {};
  final List<Order> orders = [];
  final List<String> searchHistory = [];
  final List<Address> addresses = [
    Address(id: 'a1', label: 'Home', line: 'House 12, Street 4, Satellite Town', city: 'Rawalpindi', phone: '0300 1234567'),
  ];
  int _idSeq = 100;

  // ---------- auth ----------
  bool get loggedIn => user != null;
  void login(String email, {String? name, bool admin = false}) {
    user = AppUser(name: name ?? _nameFromEmail(email), email: email, isAdmin: admin);
    notifyListeners();
  }

  void logout() {
    user = null;
    cart.clear();
    notifyListeners();
  }

  String _nameFromEmail(String e) {
    final n = e.split('@').first;
    return n.isEmpty ? 'Guest' : n[0].toUpperCase() + n.substring(1);
  }

  void updateProfile(String name, String email) {
    user?.name = name;
    user?.email = email;
    notifyListeners();
  }

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  // ---------- catalogue ----------
  Category? categoryById(String id) {
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  List<Product> byCategory(String id) => products.where((p) => p.categoryId == id).toList();
  List<Product> get featured => products.where((p) => p.featured).toList();
  List<Product> get trending => products.where((p) => p.trending).toList();
  List<Product> get recommended => (products.toList()..sort((a, b) => b.rating.compareTo(a.rating))).take(8).toList();

  // ---------- wishlist ----------
  bool isWished(String id) => wishlist.contains(id);
  void toggleWish(String id) {
    wishlist.contains(id) ? wishlist.remove(id) : wishlist.add(id);
    notifyListeners();
  }

  List<Product> get wishedProducts => products.where((p) => wishlist.contains(p.id)).toList();

  // ---------- cart ----------
  int get cartCount => cart.fold(0, (s, i) => s + i.qty);
  double get subtotal => cart.fold(0.0, (s, i) => s + i.total);
  double get shipping => cart.isEmpty || subtotal >= 10000 ? 0 : 250;
  double get total => subtotal + shipping;

  void addToCart(Product p, {String? color, String? size, int qty = 1}) {
    final c = color ?? (p.colors.isNotEmpty ? p.colors.first : '');
    final s = size ?? (p.sizes.isNotEmpty ? p.sizes.first : '');
    final existing = cart.where((i) => i.product.id == p.id && i.color == c && i.size == s);
    if (existing.isNotEmpty) {
      existing.first.qty += qty;
    } else {
      cart.add(CartItem(product: p, color: c, size: s, qty: qty));
    }
    notifyListeners();
  }

  void changeQty(CartItem i, int delta) {
    i.qty = (i.qty + delta).clamp(1, 99);
    notifyListeners();
  }

  void removeFromCart(CartItem i) {
    cart.remove(i);
    notifyListeners();
  }

  Order placeOrder(Address a, String payment) {
    final o = Order(
      id: 'VR-${++_idSeq}',
      date: DateTime.now(),
      items: cart.map((i) => CartItem(product: i.product, color: i.color, size: i.size, qty: i.qty)).toList(),
      total: total,
      payment: payment,
      address: '${a.line}, ${a.city}',
    );
    for (final i in cart) {
      i.product.stock = (i.product.stock - i.qty).clamp(0, 1 << 30);
    }
    orders.insert(0, o);
    cart.clear();
    notifyListeners();
    return o;
  }

  void setOrderStatus(Order o, String status) {
    o.status = status;
    notifyListeners();
  }

  // ---------- addresses ----------
  void addAddress(Address a) {
    addresses.add(a);
    notifyListeners();
  }

  void removeAddress(Address a) {
    addresses.remove(a);
    notifyListeners();
  }

  // ---------- search ----------
  void remember(String q) {
    q = q.trim();
    if (q.isEmpty) return;
    searchHistory.remove(q);
    searchHistory.insert(0, q);
    if (searchHistory.length > 8) searchHistory.removeLast();
    notifyListeners();
  }

  void clearHistory() {
    searchHistory.clear();
    notifyListeners();
  }

  // ---------- admin ----------
  String newId(String prefix) => '$prefix${++_idSeq}';

  void saveProduct(Product p, {bool isNew = false}) {
    if (isNew) products.insert(0, p);
    notifyListeners();
  }

  void deleteProduct(Product p) {
    products.remove(p);
    wishlist.remove(p.id);
    cart.removeWhere((i) => i.product.id == p.id);
    notifyListeners();
  }

  void adjustStock(Product p, int delta) {
    p.stock = (p.stock + delta).clamp(0, 99999);
    notifyListeners();
  }

  void addCategory(String name, IconData icon, Color color) {
    categories.add(Category(id: newId('c'), name: name, icon: icon, color: color));
    notifyListeners();
  }

  void renameCategory(Category c, String name) {
    c.name = name;
    notifyListeners();
  }

  bool deleteCategory(Category c) {
    if (products.any((p) => p.categoryId == c.id)) return false;
    categories.remove(c);
    notifyListeners();
    return true;
  }
}
