import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../data/mock_data.dart';
import '../services/ai_search_service.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'voice_search_screen.dart';

class SearchScreen extends StatefulWidget {
  final bool autofocus, showBack;
  const SearchScreen({super.key, this.autofocus = false, this.showBack = false});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  SearchOutcome? _outcome;

  void _run(String q) {
    final s = context.read<AppState>();
    if (q.trim().isEmpty) {
      setState(() => _outcome = null);
      return;
    }
    _ctrl.text = q;
    _ctrl.selection = TextSelection.collapsed(offset: q.length);
    s.remember(q);
    FocusScope.of(context).unfocus();
    setState(() => _outcome = AiSearchService.search(s.products, s.categories, q));
  }

  Future<void> _voice() async {
    final q = await push<String>(context, const VoiceSearchScreen(returnQuery: true));
    if (q != null && q.isNotEmpty) _run(q);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 20, 8),
            child: Row(children: [
              if (widget.showBack) IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context))
              else const SizedBox(width: 12),
              Expanded(
                child: AppSearchField(
                  controller: _ctrl,
                  autofocus: widget.autofocus,
                  onSubmitted: _run,
                  onMic: _voice,
                  onChanged: (v) { if (v.isEmpty) setState(() => _outcome = null); },
                ),
              ),
            ]),
          ),
          Expanded(child: _outcome == null ? _idle(s) : _results(_outcome!)),
        ]),
      ),
    );
  }

  Widget _idle(AppState s) => ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
        if (s.searchHistory.isNotEmpty) ...[
          Row(children: [
            const Expanded(child: Text('Recent searches', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
            TextButton(onPressed: s.clearHistory, child: const Text('Clear')),
          ]),
          for (final h in s.searchHistory)
            ListTile(
              contentPadding: EdgeInsets.zero, dense: true,
              leading: const Icon(Icons.history_rounded, color: AppColors.slate),
              title: Text(h),
              trailing: const Icon(Icons.north_west_rounded, size: 18, color: AppColors.slate),
              onTap: () => _run(h),
            ),
          const SizedBox(height: 16),
        ],
        const Text('Try asking', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 4),
        const Text('Describe what you want in plain language.', style: TextStyle(color: AppColors.slate)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final q in MockData.suggestions) ActionChip(label: Text(q), onPressed: () => _run(q)),
        ]),
      ]);

  Widget _results(SearchOutcome o) {
    final chips = <Widget>[
      if (o.category != null) Chip(avatar: Icon(o.category!.icon, size: 16), label: Text(o.category!.name)),
      if (o.color != null) Chip(label: Text('Colour: ${o.color}')),
      if (o.maxPrice != null) Chip(label: Text('Under ${formatPrice(o.maxPrice!)}')),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (chips.isNotEmpty)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
            const Text('Understood:', style: TextStyle(color: AppColors.slate, fontSize: 13)),
            ...chips,
          ]),
        ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        child: Text('${o.results.length} matches', style: const TextStyle(color: AppColors.slate)),
      ),
      Expanded(
        child: o.results.isEmpty
            ? EmptyState(
                icon: Icons.search_off_rounded, title: 'No matches yet',
                message: 'Try a higher budget, a different colour, or a broader description.',
                actionLabel: 'Clear search',
                onAction: () { _ctrl.clear(); setState(() => _outcome = null); },
              )
            : ProductGrid(o.results),
      ),
    ]);
  }
}
