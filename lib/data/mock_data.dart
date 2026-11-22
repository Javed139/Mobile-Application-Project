import 'package:flutter/material.dart';
import '../models/models.dart';

class MockData {
  static const sample3d = 'https://modelviewer.dev/shared-assets/models/Astronaut.glb';

  static List<Category> categories() => [
    Category(id: 'bags', name: 'Bags', iconKey: 'backpack', color: const Color(0xFF4F7396)),
    Category(id: 'shoes', name: 'Shoes', iconKey: 'shoes', color: const Color(0xFFD2573A)),
    Category(id: 'clothes', name: 'Clothes', iconKey: 'clothes', color: const Color(0xFFB08A00)),
    Category(id: 'accessories', name: 'Accessories', iconKey: 'watch', color: const Color(0xFF55524E)),
    Category(id: 'electronics', name: 'Electronics', iconKey: 'headphones', color: const Color(0xFF3E3E42)),
    Category(id: 'beauty', name: 'Beauty', iconKey: 'beauty', color: const Color(0xFFE0558F)),
  ];

  static List<Product> products() => [
        Product(id: 'p1', name: 'Metro Commuter Backpack', categoryId: 'bags', price: 4200, oldPrice: 5600,
            rating: 4.7, reviews: 312, stock: 24, colors: ['Black', 'Navy', 'Olive'], sizes: ['20L', '28L'],
            featured: true, trending: true, modelUrl: sample3d, tags: ['backpack', 'laptop', 'travel', 'waterproof'],
            description: 'Water-resistant 900D shell with a padded 15.6" laptop sleeve, hidden back pocket and breathable shoulder straps. Built for the daily commute.'),
        Product(id: 'p2', name: 'Alto Leather Tote', categoryId: 'bags', price: 8900, rating: 4.5, reviews: 148, stock: 9,
            colors: ['Tan', 'Black'], sizes: [], featured: true, tags: ['handbag', 'tote', 'leather', 'office'],
            description: 'Full-grain leather tote with a structured base, zip closure and an interior organiser pocket.'),
        Product(id: 'p3', name: 'Trail Duffel 40L', categoryId: 'bags', price: 6500, oldPrice: 7200, rating: 4.4, reviews: 87, stock: 15,
            colors: ['Grey', 'Black'], sizes: ['40L'], tags: ['duffel', 'gym', 'travel'],
            description: 'Roomy duffel with a ventilated shoe compartment and a detachable crossbody strap.'),
        Product(id: 'p4', name: 'Stride Run Sneakers', categoryId: 'shoes', price: 9800, oldPrice: 12500, rating: 4.8, reviews: 540, stock: 40,
            colors: ['White', 'Black', 'Blue'], sizes: ['40', '41', '42', '43', '44'], featured: true, trending: true,
            modelUrl: sample3d, tags: ['sneakers', 'running', 'sports', 'lightweight'],
            description: 'Responsive foam midsole and breathable knit upper. Light enough for race day, comfortable enough for every day.'),
        Product(id: 'p5', name: 'Oxford Classic Derby', categoryId: 'shoes', price: 11200, rating: 4.3, reviews: 66, stock: 7,
            colors: ['Brown', 'Black'], sizes: ['40', '41', '42', '43'], tags: ['formal', 'leather', 'office'],
            description: 'Hand-finished leather derby with a cushioned insole and durable rubber outsole.'),
        Product(id: 'p6', name: 'Cloud Slide Sandals', categoryId: 'shoes', price: 2400, rating: 4.2, reviews: 201, stock: 60,
            colors: ['Black', 'Beige', 'Pink'], sizes: ['39', '40', '41', '42', '43'], trending: true, tags: ['sandals', 'casual', 'summer'],
            description: 'Ultra-soft moulded slides with a non-slip sole. Easy on, easy to clean.'),
        Product(id: 'p7', name: 'Everyday Heavy Tee', categoryId: 'clothes', price: 1800, rating: 4.6, reviews: 422, stock: 100,
            colors: ['White', 'Black', 'Olive', 'Grey'], sizes: ['S', 'M', 'L', 'XL'], trending: true, tags: ['tshirt', 'cotton', 'basic'],
            description: '240 GSM combed cotton with a relaxed fit that keeps its shape wash after wash.'),
        Product(id: 'p8', name: 'Northwind Puffer Jacket', categoryId: 'clothes', price: 13500, oldPrice: 16000, rating: 4.7, reviews: 119, stock: 12,
            colors: ['Black', 'Navy'], sizes: ['M', 'L', 'XL'], featured: true, tags: ['jacket', 'winter', 'warm'],
            description: 'Lightweight recycled-fill puffer that packs into its own pocket. Warm down to near freezing.'),
        Product(id: 'p9', name: 'Slim Stretch Jeans', categoryId: 'clothes', price: 4500, rating: 4.4, reviews: 233, stock: 35,
            colors: ['Blue', 'Black'], sizes: ['30', '32', '34', '36'], tags: ['jeans', 'denim', 'casual'],
            description: 'Slim-tapered denim with 2% stretch for all-day comfort.'),
        Product(id: 'p10', name: 'Chrono Steel Watch', categoryId: 'accessories', price: 15800, oldPrice: 18900, rating: 4.6, reviews: 98, stock: 11,
            colors: ['Silver', 'Black', 'Gold'], sizes: [], featured: true, modelUrl: sample3d, tags: ['watch', 'analog', 'gift'],
            description: 'Sapphire-coated glass, 5 ATM water resistance and a quartz movement with date window.'),
        Product(id: 'p11', name: 'Aviator Polarized Sunglasses', categoryId: 'accessories', price: 3600, rating: 4.3, reviews: 175, stock: 48,
            colors: ['Gold', 'Black'], sizes: [], trending: true, tags: ['sunglasses', 'uv', 'summer'],
            description: 'Polarized UV400 lenses in a featherweight metal frame.'),
        Product(id: 'p12', name: 'Slim Bifold Wallet', categoryId: 'accessories', price: 2100, rating: 4.5, reviews: 260, stock: 80,
            colors: ['Brown', 'Black', 'Tan'], sizes: [], tags: ['wallet', 'leather', 'gift'],
            description: 'RFID-blocking leather bifold with six card slots and a coin pocket.'),
        Product(id: 'p13', name: 'Pulse ANC Headphones', categoryId: 'electronics', price: 18900, oldPrice: 22500, rating: 4.8, reviews: 612, stock: 18,
            colors: ['Black', 'White', 'Navy'], sizes: [], featured: true, trending: true, modelUrl: sample3d,
            tags: ['headphones', 'wireless', 'bluetooth', 'noise cancelling'],
            description: 'Adaptive noise cancelling, 40-hour battery and multipoint Bluetooth 5.3.'),
        Product(id: 'p14', name: 'Orbit Portable Speaker', categoryId: 'electronics', price: 7400, rating: 4.4, reviews: 144, stock: 26,
            colors: ['Black', 'Blue', 'Red'], sizes: [], tags: ['speaker', 'bluetooth', 'waterproof', 'outdoor'],
            description: 'IP67 waterproof speaker with 360° sound and 16 hours of playtime.'),
        Product(id: 'p15', name: 'Buds Air Earbuds', categoryId: 'electronics', price: 5200, oldPrice: 6500, rating: 4.2, reviews: 330, stock: 52,
            colors: ['White', 'Black'], sizes: [], trending: true, tags: ['earbuds', 'wireless', 'bluetooth'],
            description: 'Compact true-wireless earbuds with low-latency mode and a pocketable charging case.'),
        Product(id: 'p16', name: 'Glow Vitamin C Serum', categoryId: 'beauty', price: 2900, rating: 4.6, reviews: 187, stock: 44,
            colors: [], sizes: ['30ml'], tags: ['skincare', 'serum', 'face'],
            description: 'Brightening 15% vitamin C serum with hyaluronic acid. Fragrance free.'),
      ];

  static List<Review> reviews() => [
        Review('Ayesha K.', 5, 'Exactly as pictured and arrived in two days. The quality is far better than the price suggests.'),
        Review('Hamza R.', 4, 'Solid build and comfortable. Sizing runs slightly small, so consider going one up.'),
        Review('Sana M.', 5, 'Third purchase from Verra. Packaging is great and support was quick when I needed to exchange.'),
      ];

  static const suggestions = [
    'Show me a black backpack under 5000 rupees',
    'Wireless headphones under 20000',
    'White sneakers for running',
    'Leather wallet as a gift',
    'Waterproof speaker for outdoors',
  ];
}
