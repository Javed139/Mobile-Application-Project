import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

enum SortBy { popular, priceLow, priceHigh, rating }

class ProductListScreen extends StatefulWidget {
  final String title;
  final String? categoryId;
  final List<Product>? products;
  const ProductListScreen({super.key, required this.title, this.categoryId, this.products});
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  SortBy _sort = SortBy.popular;
  RangeValues? _range;
  double _minRating = 0;
  bool _inStock = false;

  List<Product> _source(AppState s) => widget.products ?? (widget.categoryId != null ? s.byCategory(widget.categoryId!) : s.products);

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final all = _source(s);
    final maxP = all.isEmpty ? 1000.0 : all.map((p) => p.price).reduce((a, b) => a > b ? a : b);
    var list = all.where((p) {
      if (_range != null && (p.price < _range!.start || p.price > _range!.end)) return false;
      if (p.rating < _minRating) return false;
      if (_inStock && p.stock == 0) return false;
      return true;
    }).toList();
    switch (_sort) {
      case SortBy.priceLow: list.sort((a, b) => a.price.compareTo(b.price));
      case SortBy.priceHigh: list.sort((a, b) => b.price.compareTo(a.price));
      case SortBy.rating: list.sort((a, b) => b.rating.compareTo(a.rating));
      case SortBy.popular: list.sort((a, b) => b.reviews.compareTo(a.reviews));
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: [
        IconButton(icon: const Icon(Icons.tune_rounded), onPressed: () => _filters(maxP)),
      ]),
      body: Column(children: [
        SizedBox(
          height: 48,
          child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20), children: [
            for (final o in SortBy.values)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(const {SortBy.popular: 'Popular', SortBy.priceLow: 'Price: low to high', SortBy.priceHigh: 'Price: high to low', SortBy.rating: 'Top rated'}[o]!),
                  selected: _sort == o,
                  onSelected: (_) => setState(() => _sort = o),
                ),
              ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Align(alignment: Alignment.centerLeft, child: Text('${list.length} products', style: const TextStyle(color: AppColors.slate))),
        ),
        Expanded(
          child: list.isEmpty
              ? EmptyState(
                  icon: Icons.inventory_2_outlined, title: 'No products found',
                  message: 'Try widening the price range or lowering the rating filter.',
                  actionLabel: 'Clear filters',
                  onAction: () => setState(() { _range = null; _minRating = 0; _inStock = false; }),
                )
              : ProductGrid(list),
        ),
      ]),
    );
  }

  void _filters(double maxP) {
    var range = _range ?? RangeValues(0, maxP);
    var rating = _minRating;
    var stock = _inStock;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setM) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Filters', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            const Text('Price range', style: TextStyle(fontWeight: FontWeight.w700)),
            RangeSlider(
              values: range, min: 0, max: maxP, divisions: 20,
              labels: RangeLabels('Rs ${range.start.round()}', 'Rs ${range.end.round()}'),
              onChanged: (v) => setM(() => range = v),
            ),
            const SizedBox(height: 8),
            const Text('Minimum rating', style: TextStyle(fontWeight: FontWeight.w700)),
            Wrap(spacing: 8, children: [
              for (final r in [0.0, 3.0, 4.0, 4.5])
                ChoiceChip(label: Text(r == 0 ? 'Any' : '$r+'), selected: rating == r, onSelected: (_) => setM(() => rating = r)),
            ]),
            SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('In stock only'), value: stock, onChanged: (v) => setM(() => stock = v)),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () {
                setState(() {
                  _range = (range.start == 0 && range.end == maxP) ? null : range;
                  _minRating = rating;
                  _inStock = stock;
                });
                Navigator.pop(ctx);
              },
              child: const Text('Apply filters'),
            ),
          ]),
        );
      }),
    );
  }
}
