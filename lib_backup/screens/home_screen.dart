import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';
import 'product_list_screen.dart';
import 'search_screen.dart';
import 'shell_screen.dart';
import 'voice_search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final first = (s.user?.name ?? 'there').split(' ').first;
    return SafeArea(
      bottom: false,
      child: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Good to see you,', style: TextStyle(color: AppColors.slate)),
                  Text(first, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                ]),
              ),
              IconButton(
                onPressed: () => push(context, const CartScreen()),
                icon: Badge(
                  isLabelVisible: s.cartCount > 0,
                  label: Text('${s.cartCount}'),
                  child: const Icon(Icons.shopping_bag_outlined, size: 28),
                ),
              ),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: AppSearchField(
              readOnly: true,
              hint: 'Try "black backpack under 5000"',
              onTap: () => push(context, const SearchScreen(autofocus: true, showBack: true)),
              onMic: () => push(context, const VoiceSearchScreen()),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: _Banners()),
        SliverToBoxAdapter(child: SectionHeader('Shop by category', onSeeAll: () {
          context.findAncestorStateOfType<ShellScreenState>()?.goTo(1);
        })),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 98,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: s.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (c, i) {
                final cat = s.categories[i];
                return GestureDetector(
                  onTap: () => push(c, ProductListScreen(title: cat.name, categoryId: cat.id)),
                  child: SizedBox(
                    width: 72,
                    child: Column(children: [
                      Container(
                        width: 68, height: 68,
                        decoration: BoxDecoration(color: cat.color.withOpacity(0.16), shape: BoxShape.circle),
                        child: Icon(cat.icon, color: cat.color, size: 30),
                      ),
                      const SizedBox(height: 8),
                      Text(cat.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    ]),
                  ),
                );
              },
            ),
          ),
        ),
        SliverToBoxAdapter(child: SectionHeader('Featured', onSeeAll: () => push(context, ProductListScreen(title: 'Featured', products: s.featured)))),
        SliverToBoxAdapter(child: _HorizontalProducts(s.featured)),
        SliverToBoxAdapter(child: SectionHeader('Trending now', onSeeAll: () => push(context, ProductListScreen(title: 'Trending now', products: s.trending)))),
        SliverToBoxAdapter(child: ProductGrid(s.trending.take(4).toList(), shrink: true)),
        SliverToBoxAdapter(child: SectionHeader('Recommended for you')),
        SliverToBoxAdapter(child: _HorizontalProducts(s.recommended)),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
      ]),
    );
  }
}

class _HorizontalProducts extends StatelessWidget {
  final List<Product> items;
  const _HorizontalProducts(this.items);
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 270,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (c, i) => SizedBox(
            width: 168,
            child: ProductCard(product: items[i], onTap: () => push(c, ProductDetailScreen(product: items[i]))),
          ),
        ),
      );
}

class _Banners extends StatefulWidget {
  const _Banners();
  @override
  State<_Banners> createState() => _BannersState();
}

class _BannersState extends State<_Banners> {
  final _ctrl = PageController(viewportFraction: 0.92);
  int _i = 0;
  static const _data = [
    ('Season sale', 'Up to 30% off\nselected sneakers', Icons.snowshoeing_rounded, Color(0xFF151515)),
    ('New in electronics', 'Noise cancelling,\nall day battery', Icons.headphones_rounded, Color(0xFF3A3A3F)),
    ('Free delivery', 'On every order\nover Rs 10,000', Icons.local_shipping_rounded, Color(0xFF8A4B2D)),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 18),
      SizedBox(
        height: 160,
        child: PageView.builder(
          controller: _ctrl,
          itemCount: _data.length,
          onPageChanged: (v) => setState(() => _i = v),
          itemBuilder: (_, i) {
            final d = _data[i];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color: d.$4, borderRadius: BorderRadius.circular(AppSpace.radiusLg)),
              clipBehavior: Clip.antiAlias,
              child: Stack(children: [
                Positioned(right: -20, bottom: -28, child: Icon(d.$3, size: 150, color: Colors.white.withOpacity(0.12))),
                Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(d.$1, style: const TextStyle(color: Color(0xFFFFB38F), fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(d.$2, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.2)),
                ]),
              ]),
            );
          },
        ),
      ),
      const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        for (var i = 0; i < _data.length; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == _i ? 20 : 6, height: 6,
            decoration: BoxDecoration(
                color: i == _i ? AppColors.cobalt : AppColors.slate.withOpacity(0.3), borderRadius: BorderRadius.circular(6)),
          ),
      ]),
    ]);
  }
}
