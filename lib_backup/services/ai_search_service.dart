import '../models/models.dart';

class SearchOutcome {
  final List<Product> results;
  final double? maxPrice;
  final String? color;
  final Category? category;
  final List<String> keywords;
  const SearchOutcome(this.results, this.maxPrice, this.color, this.category, this.keywords);
}

/// On-device natural-language search. It extracts intent (price cap, colour,
/// category, keywords) and ranks products. Replace [search] with a call to an
/// embeddings / LLM endpoint later; the SearchOutcome contract can stay the same.
class AiSearchService {
  static const _stop = {
    'show', 'me', 'a', 'an', 'the', 'for', 'with', 'and', 'of', 'in', 'find', 'i', 'want', 'need', 'looking',
    'please', 'best', 'good', 'some', 'to', 'buy', 'get', 'my', 'rupees', 'rs', 'pkr', 'cheap', 'around', 'about',
    'under', 'below', 'within', 'upto', 'max', 'less', 'than', 'up', 'is', 'are', 'that', 'on',
  };
  static const _colors = [
    'black', 'white', 'red', 'blue', 'green', 'brown', 'grey', 'gray', 'pink', 'navy', 'beige', 'silver',
    'gold', 'yellow', 'orange', 'purple', 'olive', 'tan',
  ];
  static const _synonyms = {
    'backpack': 'bags', 'bag': 'bags', 'bags': 'bags', 'handbag': 'bags', 'tote': 'bags', 'duffel': 'bags',
    'sneakers': 'shoes', 'sneaker': 'shoes', 'shoe': 'shoes', 'shoes': 'shoes', 'boots': 'shoes', 'sandals': 'shoes',
    'shirt': 'clothes', 'tshirt': 'clothes', 'tee': 'clothes', 'jacket': 'clothes', 'hoodie': 'clothes',
    'jeans': 'clothes', 'clothes': 'clothes', 'dress': 'clothes',
    'watch': 'accessories', 'watches': 'accessories', 'sunglasses': 'accessories', 'wallet': 'accessories',
    'belt': 'accessories', 'accessories': 'accessories',
    'phone': 'electronics', 'headphones': 'electronics', 'earbuds': 'electronics', 'speaker': 'electronics',
    'laptop': 'electronics', 'electronics': 'electronics',
    'serum': 'beauty', 'skincare': 'beauty', 'beauty': 'beauty',
  };

  static SearchOutcome search(List<Product> all, List<Category> cats, String query) {
    var q = query.toLowerCase().trim();
    double? maxPrice;

    final capped = RegExp(r'(?:under|below|less than|within|upto|up to|max|maximum|budget of)\s*(?:rs\.?|rupees|pkr)?\s*(\d[\d,]*)\s*(k)?').firstMatch(q);
    final trailing = RegExp(r'(\d[\d,]*)\s*(k)?\s*(?:rupees|rs|pkr)').firstMatch(q);
    final m = capped ?? trailing;
    if (m != null) {
      maxPrice = double.tryParse(m.group(1)!.replaceAll(',', ''));
      if (maxPrice != null && m.group(2) == 'k') maxPrice *= 1000;
      q = q.replaceRange(m.start, m.end, ' ');
    }

    final tokens = q.split(RegExp(r'[^a-z0-9]+')).where((t) => t.isNotEmpty).toList();
    String? color;
    String? catId;
    final keywords = <String>[];
    for (final t in tokens) {
      if (_colors.contains(t)) {
        color = t;
      } else if (_stop.contains(t) || double.tryParse(t) != null) {
        continue;
      } else {
        keywords.add(t);
        catId ??= _synonyms[t];
        if (catId == null) {
          for (final c in cats) {
            if (c.name.toLowerCase() == t) catId = c.id;
          }
        }
      }
    }

    int score(Product p) {
      var s = 0;
      final name = p.name.toLowerCase();
      final desc = p.description.toLowerCase();
      for (final k in keywords) {
        if (name.contains(k)) s += 3;
        if (p.tags.any((t) => t.toLowerCase().contains(k))) s += 2;
        if (desc.contains(k)) s += 1;
        if (_synonyms[k] != null && _synonyms[k] == p.categoryId) s += 1;
      }
      return s;
    }

    final results = all.where((p) {
      if (maxPrice != null && p.price > maxPrice) return false;
      if (color != null && !p.colors.any((c) => c.toLowerCase() == color || (color == 'gray' && c.toLowerCase() == 'grey'))) {
        return false;
      }
      if (keywords.isEmpty) return true;
      final s = score(p);
      if (s == 0) return false;
      // When a category was understood, keep results inside it unless the product name matched directly.
      if (catId != null && p.categoryId != catId && !keywords.any((k) => p.name.toLowerCase().contains(k))) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        final c = score(b).compareTo(score(a));
        return c != 0 ? c : b.rating.compareTo(a.rating);
      });

    Category? cat;
    for (final c in cats) {
      if (c.id == catId) cat = c;
    }
    final hasIntent = keywords.isNotEmpty || color != null || maxPrice != null;
    return SearchOutcome(hasIntent ? results : <Product>[], maxPrice, color, cat, keywords);
  }
}
