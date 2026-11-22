import 'package:flutter/material.dart';

class Category {
  final String id;
  String name;
  IconData icon;
  Color color;
  Category({required this.id, required this.name, required this.icon, required this.color});
}

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
  List<String> images; // http(s) URLs or local file paths. Empty = styled placeholder.
  String? modelUrl; // .glb/.gltf for the 3D viewer
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

  int? get discountPercent =>
      oldPrice != null && oldPrice! > price ? (((oldPrice! - price) / oldPrice!) * 100).round() : null;
}

class CartItem {
  final Product product;
  String color;
  String size;
  int qty;
  CartItem({required this.product, required this.color, required this.size, this.qty = 1});
  double get total => product.price * qty;
}

class Address {
  final String id;
  String label, line, city, phone;
  Address({required this.id, required this.label, required this.line, required this.city, required this.phone});
}

class Order {
  final String id;
  final DateTime date;
  final List<CartItem> items;
  final double total;
  final String payment;
  final String address;
  String status; // Processing, Shipped, Delivered
  Order({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.payment,
    required this.address,
    this.status = 'Processing',
  });
}

class AppUser {
  String name, email;
  bool isAdmin;
  AppUser({required this.name, required this.email, this.isAdmin = false});
}

class Review {
  final String author, text;
  final int stars;
  Review(this.author, this.stars, this.text);
}
