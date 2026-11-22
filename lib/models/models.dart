
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Icons an admin can assign to a category.
/// Firestore stores the icon key, not IconData.
const Map<String, IconData> categoryIcons = {
  'backpack': Icons.backpack_rounded,
  'shoes': Icons.directions_walk_rounded,
  'clothes': Icons.checkroom_rounded,
  'watch': Icons.watch_rounded,
  'headphones': Icons.headphones_rounded,
  'beauty': Icons.spa_rounded,
  'chair': Icons.chair_rounded,
  'sports': Icons.sports_soccer_rounded,
  'toys': Icons.toys_rounded,
  'book': Icons.menu_book_rounded,
  'kitchen': Icons.kitchen_rounded,
};

// --------------------------------------------------
// CATEGORY
// --------------------------------------------------

class Category {
  final String id;
  String name;
  String iconKey;
  Color color;

  Category({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.color,
  });

  IconData get icon {
    return categoryIcons[iconKey] ?? Icons.category_rounded;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'iconKey': iconKey,
      'color': color.toARGB32(),
    };
  }

  factory Category.fromMap(String id, Map<String, dynamic> map) {
    final rawColor = map['color'];

    return Category(
      id: id,
      name: map['name']?.toString() ?? '',
      iconKey: map['iconKey']?.toString() ?? 'backpack',
      color: Color(
        rawColor is num ? rawColor.toInt() : 0xFF4F7396,
      ),
    );
  }
}

// --------------------------------------------------
// PRODUCT
// --------------------------------------------------

class Product {
  final String id;
  String name;
  String description;
  String categoryId;
  double price;
  double? oldPrice;
  double rating;
  int reviews;
  int stock;
  List<String> colors;
  List<String> sizes;
  List<String> images;
  String? modelUrl;
  bool featured;
  bool trending;
  List<String> tags;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.price,
    this.oldPrice,
    this.rating = 4.5,
    this.reviews = 0,
    this.stock = 20,
    this.colors = const [],
    this.sizes = const [],
    this.images = const [],
    this.modelUrl,
    this.featured = false,
    this.trending = false,
    this.tags = const [],
  });

  int? get discountPercent {
    if (oldPrice != null && oldPrice! > price && oldPrice! > 0) {
      return (((oldPrice! - price) / oldPrice!) * 100).round();
    }

    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'price': price,
      'oldPrice': oldPrice,
      'rating': rating,
      'reviews': reviews,
      'stock': stock,
      'colors': colors,
      'sizes': sizes,
      'images': images,
      'modelUrl': modelUrl,
      'featured': featured,
      'trending': trending,
      'tags': tags,
    };
  }

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    double readDouble(dynamic value, double fallback) {
      return value is num ? value.toDouble() : fallback;
    }

    int readInt(dynamic value, int fallback) {
      return value is num ? value.toInt() : fallback;
    }

    List<String> readStringList(dynamic value) {
      if (value is! List) return [];

      return value
          .where((item) => item != null)
          .map((item) => item.toString())
          .toList();
    }

    return Product(
      id: id,
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      categoryId: map['categoryId']?.toString() ?? '',
      price: readDouble(map['price'], 0),
      oldPrice: map['oldPrice'] is num
          ? (map['oldPrice'] as num).toDouble()
          : null,
      rating: readDouble(map['rating'], 4.5),
      reviews: readInt(map['reviews'], 0),
      stock: readInt(map['stock'], 0),
      colors: readStringList(map['colors']),
      sizes: readStringList(map['sizes']),
      images: readStringList(map['images']),
      modelUrl: map['modelUrl']?.toString(),
      featured: map['featured'] == true,
      trending: map['trending'] == true,
      tags: readStringList(map['tags']),
    );
  }
}

// --------------------------------------------------
// CART ITEM
// --------------------------------------------------

class CartItem {
  final Product product;
  String color;
  String size;
  int qty;

  CartItem({
    required this.product,
    required this.color,
    required this.size,
    this.qty = 1,
  });

  double get total => product.price * qty;
}

// --------------------------------------------------
// ADDRESS
// --------------------------------------------------

class Address {
  final String id;
  String label;
  String line;
  String city;
  String phone;

  Address({
    required this.id,
    required this.label,
    required this.line,
    required this.city,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'line': line,
      'city': city,
      'phone': phone,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id']?.toString() ?? '',
      label: map['label']?.toString() ?? '',
      line: map['line']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
    );
  }
}

// --------------------------------------------------
// ORDER
// --------------------------------------------------

class Order {
  final String id;
  final DateTime date;
  final List<CartItem> items;
  final double total;
  final String payment;
  final String address;
  final String userId;
  String status;

  Order({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.payment,
    required this.address,
    this.userId = '',
    this.status = 'Processing',
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': date.millisecondsSinceEpoch,
      'total': total,
      'payment': payment,
      'address': address,
      'status': status,
      'items': items.map((item) {
        return {
          'productId': item.product.id,
          'name': item.product.name,
          'price': item.product.price,
          'color': item.color,
          'size': item.size,
          'qty': item.qty,
        };
      }).toList(),
    };
  }

  factory Order.fromMap(String id, Map<String, dynamic> map) {
    final rawDate = map['date'];

    DateTime orderDate;

    if (rawDate is Timestamp) {
      orderDate = rawDate.toDate();
    } else if (rawDate is num) {
      orderDate = DateTime.fromMillisecondsSinceEpoch(
        rawDate.toInt(),
      );
    } else {
      orderDate = DateTime.now();
    }

    final rawItems = map['items'];

    final items = rawItems is List
        ? rawItems.map((raw) {
      final item = Map<String, dynamic>.from(raw as Map);

      return CartItem(
        product: Product(
          id: item['productId']?.toString() ?? '',
          name: item['name']?.toString() ?? '',
          description: '',
          categoryId: '',
          price: item['price'] is num
              ? (item['price'] as num).toDouble()
              : 0,
        ),
        color: item['color']?.toString() ?? '',
        size: item['size']?.toString() ?? '',
        qty: item['qty'] is num
            ? (item['qty'] as num).toInt()
            : 1,
      );
    }).toList()
        : <CartItem>[];

    return Order(
      id: id,
      date: orderDate,
      items: items,
      total: map['total'] is num
          ? (map['total'] as num).toDouble()
          : 0,
      payment: map['payment']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      status: map['status']?.toString() ?? 'Processing',
    );
  }
}

// --------------------------------------------------
// APP USER
// --------------------------------------------------

class AppUser {
  final String uid;
  String name;
  String email;
  bool isAdmin;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.isAdmin = false,
  });
}

// --------------------------------------------------
// REVIEW
// --------------------------------------------------

class Review {
  final String author;
  final String text;
  final int stars;

  Review(this.author, this.stars, this.text);
}
