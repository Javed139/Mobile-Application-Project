
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/models.dart';

// Single source of truth, backed by Firebase Authentication
// and Cloud Firestore.
//
// Collections:
// products
// categories
// orders
// users/{uid}

class AppState extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  ThemeMode themeMode = ThemeMode.light;

  AppUser? user;

  final List<Category> categories = [];
  final List<Product> products = [];
  final List<CartItem> cart = [];
  final Set<String> wishlist = {};
  final List<Order> orders = [];
  final List<String> searchHistory = [];
  final List<Address> addresses = [];

  bool loadingCatalog = true;

  StreamSubscription? _authSub;
  StreamSubscription? _catSub;
  StreamSubscription? _prodSub;
  StreamSubscription? _orderSub;

  // --------------------------------------------------
  // INITIALIZATION
  // --------------------------------------------------

  AppState() {
    _listenCatalog();
    _authSub = _auth.authStateChanges().listen(_onAuth);

    // Upload demo data if Firestore catalog is empty.
    seedDemoData();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _catSub?.cancel();
    _prodSub?.cancel();
    _orderSub?.cancel();
    super.dispose();
  }

  // --------------------------------------------------
  // LIVE CATALOG DATA
  // --------------------------------------------------

  void _listenCatalog() {
    _catSub = _db.collection('categories').snapshots().listen(
          (snapshot) {
        final list = snapshot.docs
            .map((doc) => Category.fromMap(doc.id, doc.data()))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

        categories
          ..clear()
          ..addAll(list);

        notifyListeners();
      },
      onError: (error) {
        debugPrint('Categories listener error: $error');
      },
    );

    _prodSub = _db.collection('products').snapshots().listen(
          (snapshot) {
        products
          ..clear()
          ..addAll(
            snapshot.docs.map(
                  (doc) => Product.fromMap(doc.id, doc.data()),
            ),
          );

        loadingCatalog = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Products listener error: $error');
        loadingCatalog = false;
        notifyListeners();
      },
    );
  }

  // --------------------------------------------------
  // ORDERS
  // --------------------------------------------------

  void _listenOrders() {
    _orderSub?.cancel();

    final currentUser = user;

    if (currentUser == null) {
      orders.clear();
      return;
    }

    final collection = _db.collection('orders');

    final query = currentUser.isAdmin
        ? collection
        : collection.where('userId', isEqualTo: currentUser.uid);

    _orderSub = query.snapshots().listen(
          (snapshot) {
        final list = snapshot.docs
            .map((doc) => Order.fromMap(doc.id, doc.data()))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        orders
          ..clear()
          ..addAll(list);

        notifyListeners();
      },
      onError: (error) {
        debugPrint('Orders listener error: $error');
      },
    );
  }

  // --------------------------------------------------
  // AUTHENTICATION
  // --------------------------------------------------

  bool get loggedIn => user != null;

  Future<void> _onAuth(User? firebaseUser) async {
    if (firebaseUser == null) {
      user = null;

      await _orderSub?.cancel();
      _orderSub = null;

      orders.clear();
      wishlist.clear();
      addresses.clear();
      cart.clear();

      notifyListeners();
      return;
    }

    try {
      final userRef = _db.collection('users').doc(firebaseUser.uid);

      var snapshot = await userRef.get();

      if (!snapshot.exists) {
        await userRef.set({
          'name': firebaseUser.displayName ??
              _nameFromEmail(firebaseUser.email ?? ''),
          'email': firebaseUser.email ?? '',
          'role': 'customer',
          'wishlist': <String>[],
          'addresses': <Map<String, dynamic>>[],
        });

        snapshot = await userRef.get();
      }

      final data = snapshot.data() ?? {};

      user = AppUser(
        uid: firebaseUser.uid,
        name: (data['name'] ??
            _nameFromEmail(firebaseUser.email ?? '')) as String,
        email: (data['email'] ?? firebaseUser.email ?? '') as String,
        isAdmin: data['role'] == 'admin',
      );

      wishlist
        ..clear()
        ..addAll(
          List<String>.from(data['wishlist'] ?? const []),
        );

      addresses
        ..clear()
        ..addAll(
          ((data['addresses'] ?? const []) as List).map(
                (address) => Address.fromMap(
              Map<String, dynamic>.from(address as Map),
            ),
          ),
        );

      _listenOrders();
    } catch (error) {
      debugPrint('User profile loading error: $error');

      user = AppUser(
        uid: firebaseUser.uid,
        name: _nameFromEmail(firebaseUser.email ?? ''),
        email: firebaseUser.email ?? '',
        isAdmin: false,
      );
    }

    notifyListeners();
  }

  String _nameFromEmail(String email) {
    final name = email.split('@').first;

    if (name.isEmpty) return 'Guest';

    return name[0].toUpperCase() + name.substring(1);
  }

  String _authMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Incorrect email or password.';

      case 'email-already-in-use':
        return 'An account with this email already exists.';

      case 'weak-password':
        return 'Choose a stronger password (6+ characters).';

      case 'invalid-email':
        return 'That email address is not valid.';

      case 'network-request-failed':
        return 'No internet connection.';

      case 'too-many-requests':
        return 'Too many attempts. Try again in a few minutes.';

      default:
        return error.message ??
            'Something went wrong. Please try again.';
    }
  }

  // --------------------------------------------------
  // CUSTOMER LOGIN
  // --------------------------------------------------

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return null;
    } on FirebaseAuthException catch (error) {
      return _authMessage(error);
    } catch (error) {
      debugPrint('Customer login error: $error');
      return 'Login failed. Please try again.';
    }
  }

  // --------------------------------------------------
  // ADMIN LOGIN
  // --------------------------------------------------

  Future<String?> signInAsAdmin(
      String email,
      String password,
      ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        return 'Unable to sign in. Please try again.';
      }

      final userDoc = await _db
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      final data = userDoc.data();

      if (!userDoc.exists || data?['role'] != 'admin') {
        await _auth.signOut();

        return 'Access denied. This account is not an administrator.';
      }

      await _onAuth(firebaseUser);

      return null;
    } on FirebaseAuthException catch (error) {
      return _authMessage(error);
    } catch (error) {
      debugPrint('Admin login error: $error');

      await _auth.signOut();

      return 'Could not verify admin account. Please try again.';
    }
  }

  // --------------------------------------------------
  // CUSTOMER REGISTRATION
  // --------------------------------------------------

  Future<String?> register(
      String name,
      String email,
      String password,
      ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        return 'Account creation failed. Please try again.';
      }

      await firebaseUser.updateDisplayName(name);

      await _db.collection('users').doc(firebaseUser.uid).set({
        'name': name,
        'email': email.trim(),
        'role': 'customer',
        'wishlist': <String>[],
        'addresses': <Map<String, dynamic>>[],
      });

      await _onAuth(firebaseUser);

      return null;
    } on FirebaseAuthException catch (error) {
      return _authMessage(error);
    } catch (error) {
      debugPrint('Registration error: $error');
      return 'Registration failed. Please try again.';
    }
  }

  // --------------------------------------------------
  // PASSWORD RESET
  // --------------------------------------------------

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim(),
      );

      return null;
    } on FirebaseAuthException catch (error) {
      return _authMessage(error);
    } catch (error) {
      return 'Could not send password reset email.';
    }
  }

  // --------------------------------------------------
  // LOGOUT
  // --------------------------------------------------

  Future<void> logout() async {
    await _auth.signOut();
  }

  // --------------------------------------------------
  // PROFILE
  // --------------------------------------------------

  Future<void> updateProfile(String name, String email) async {
    final currentUser = user;

    if (currentUser == null) return;

    currentUser.name = name;
    notifyListeners();

    try {
      await _db.collection('users').doc(currentUser.uid).update({
        'name': name,
      });

      await _auth.currentUser?.updateDisplayName(name);
    } catch (error) {
      debugPrint('Profile update error: $error');
    }
  }

  // --------------------------------------------------
  // THEME
  // --------------------------------------------------

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;

    notifyListeners();
  }

  // --------------------------------------------------
  // SAVE WISHLIST AND ADDRESSES
  // --------------------------------------------------

  Future<void> _saveLists() async {
    final currentUser = user;

    if (currentUser == null) return;

    try {
      await _db.collection('users').doc(currentUser.uid).update({
        'wishlist': wishlist.toList(),
        'addresses': addresses.map((a) => a.toMap()).toList(),
      });
    } catch (error) {
      debugPrint('Saving user lists error: $error');
    }
  }

  // --------------------------------------------------
  // CATALOG
  // --------------------------------------------------

  Category? categoryById(String id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }

    return null;
  }

  List<Product> byCategory(String id) {
    return products.where((p) => p.categoryId == id).toList();
  }

  List<Product> get featured {
    return products.where((p) => p.featured).toList();
  }

  List<Product> get trending {
    return products.where((p) => p.trending).toList();
  }

  List<Product> get recommended {
    return (products.toList()
      ..sort((a, b) => b.rating.compareTo(a.rating)))
        .take(8)
        .toList();
  }

  // --------------------------------------------------
  // WISHLIST
  // --------------------------------------------------

  bool isWished(String id) {
    return wishlist.contains(id);
  }

  void toggleWish(String id) {
    if (wishlist.contains(id)) {
      wishlist.remove(id);
    } else {
      wishlist.add(id);
    }

    notifyListeners();
    _saveLists();
  }

  List<Product> get wishedProducts {
    return products.where((p) => wishlist.contains(p.id)).toList();
  }

  // --------------------------------------------------
  // CART
  // --------------------------------------------------

  int get cartCount {
    return cart.fold(0, (sum, item) => sum + item.qty);
  }

  double get subtotal {
    return cart.fold(0.0, (sum, item) => sum + item.total);
  }

  double get shipping {
    return cart.isEmpty || subtotal >= 10000 ? 0 : 250;
  }

  double get total {
    return subtotal + shipping;
  }

  void addToCart(
      Product product, {
        String? color,
        String? size,
        int qty = 1,
      }) {
    final selectedColor = color ??
        (product.colors.isNotEmpty ? product.colors.first : '');

    final selectedSize = size ??
        (product.sizes.isNotEmpty ? product.sizes.first : '');

    final existing = cart.where(
          (item) =>
      item.product.id == product.id &&
          item.color == selectedColor &&
          item.size == selectedSize,
    );

    if (existing.isNotEmpty) {
      existing.first.qty += qty;
    } else {
      cart.add(
        CartItem(
          product: product,
          color: selectedColor,
          size: selectedSize,
          qty: qty,
        ),
      );
    }

    notifyListeners();
  }

  void changeQty(CartItem item, int delta) {
    item.qty = (item.qty + delta).clamp(1, 99);
    notifyListeners();
  }

  void removeFromCart(CartItem item) {
    cart.remove(item);
    notifyListeners();
  }

  // --------------------------------------------------
  // PLACE ORDER
  // --------------------------------------------------

  Future<Order> placeOrder(Address address, String payment) async {
    final currentUser = user;

    if (currentUser == null) {
      throw Exception('Please log in before placing an order.');
    }

    if (cart.isEmpty) {
      throw Exception('Your cart is empty.');
    }

    final id =
        'VR-${DateTime.now().millisecondsSinceEpoch % 10000000}';

    final order = Order(
      id: id,
      date: DateTime.now(),
      items: cart
          .map(
            (item) => CartItem(
          product: item.product,
          color: item.color,
          size: item.size,
          qty: item.qty,
        ),
      )
          .toList(),
      total: total,
      payment: payment,
      address: '${address.line}, ${address.city}',
      userId: currentUser.uid,
    );

    final batch = _db.batch();

    batch.set(
      _db.collection('orders').doc(id),
      order.toMap(),
    );

    for (final item in cart) {
      batch.update(
        _db.collection('products').doc(item.product.id),
        {
          'stock': FieldValue.increment(-item.qty),
        },
      );
    }

    await batch.commit();

    cart.clear();
    notifyListeners();

    return order;
  }

  // --------------------------------------------------
  // ORDER STATUS
  // --------------------------------------------------

  Future<void> setOrderStatus(
      Order order,
      String status,
      ) async {
    await _db.collection('orders').doc(order.id).update({
      'status': status,
    });
  }

  // --------------------------------------------------
  // ADDRESSES
  // --------------------------------------------------

  void addAddress(Address address) {
    addresses.add(address);
    notifyListeners();
    _saveLists();
  }

  void removeAddress(Address address) {
    addresses.remove(address);
    notifyListeners();
    _saveLists();
  }

  // --------------------------------------------------
  // SEARCH HISTORY
  // --------------------------------------------------

  void remember(String query) {
    query = query.trim();

    if (query.isEmpty) return;

    searchHistory.remove(query);
    searchHistory.insert(0, query);

    if (searchHistory.length > 8) {
      searchHistory.removeLast();
    }

    notifyListeners();
  }

  void clearHistory() {
    searchHistory.clear();
    notifyListeners();
  }

  // --------------------------------------------------
  // ADMIN: PRODUCTS
  // --------------------------------------------------

  String newId(String prefix) {
    return '$prefix${DateTime.now().microsecondsSinceEpoch}';
  }

  Future<void> saveProduct(
      Product product, {
        bool isNew = false,
      }) async {
    await _db.collection('products').doc(product.id).set(
      product.toMap(),
    );
  }

  Future<void> deleteProduct(Product product) async {
    wishlist.remove(product.id);

    cart.removeWhere(
          (item) => item.product.id == product.id,
    );

    await _db.collection('products').doc(product.id).delete();

    notifyListeners();
    _saveLists();
  }

  Future<void> adjustStock(Product product, int delta) async {
    final newStock = (product.stock + delta).clamp(0, 99999);

    await _db.collection('products').doc(product.id).update({
      'stock': newStock,
    });
  }

  // --------------------------------------------------
  // ADMIN: CATEGORIES
  // --------------------------------------------------

  Future<void> addCategory(
      String name,
      String iconKey,
      Color color,
      ) async {
    final id = newId('c');

    final category = Category(
      id: id,
      name: name,
      iconKey: iconKey,
      color: color,
    );

    await _db.collection('categories').doc(id).set(
      category.toMap(),
    );
  }

  Future<void> renameCategory(
      Category category,
      String name,
      ) async {
    await _db.collection('categories').doc(category.id).update({
      'name': name,
    });
  }

  Future<void> updateCategory(
      Category category,
      String name,
      String iconKey,
      ) async {
    await _db.collection('categories').doc(category.id).update({
      'name': name,
      'iconKey': iconKey,
    });
  }

  Future<bool> deleteCategory(Category category) async {
    if (products.any((p) => p.categoryId == category.id)) {
      return false;
    }

    await _db.collection('categories').doc(category.id).delete();

    return true;
  }

  // --------------------------------------------------
  // DEMO DATA
  // --------------------------------------------------

  Future<void> seedDemoData() async {
    try {
      // Check Firestore directly, not the local lists.
      final productsSnapshot =
      await _db.collection('products').limit(1).get();

      final categoriesSnapshot =
      await _db.collection('categories').limit(1).get();

      // Only seed when BOTH collections are empty.
      if (productsSnapshot.docs.isNotEmpty ||
          categoriesSnapshot.docs.isNotEmpty) {
        debugPrint('Demo data already exists.');
        return;
      }

      final batch = _db.batch();

      // Add demo categories.
      for (final category in MockData.categories()) {
        batch.set(
          _db.collection('categories').doc(category.id),
          category.toMap(),
        );
      }

      // Add demo products.
      for (final product in MockData.products()) {
        batch.set(
          _db.collection('products').doc(product.id),
          product.toMap(),
        );
      }

      // Upload demo data to Firestore.
      await batch.commit();

      debugPrint(
        'Demo products and categories uploaded successfully.',
      );
    } catch (error) {
      debugPrint('Demo data seeding error: $error');
    }
  }
}
