import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../services/ai_search_service.dart';
import '../services/voice_service.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class VoiceSearchScreen extends StatefulWidget {
  /// When true, pops with the recognised text instead of showing results here.
  final bool returnQuery;
  const VoiceSearchScreen({super.key, this.returnQuery = false});
  @override
  State<VoiceSearchScreen> createState() => _VoiceSearchScreenState();
}

class _VoiceSearchScreenState extends State<VoiceSearchScreen> with SingleTickerProviderStateMixin {
  final VoiceService _voice = MockVoiceService();
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
  StreamSubscription<String>? _sub;
  bool _listening = false;
  String _text = '';
  SearchOutcome? _outcome;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  void _start() {
    _sub?.cancel();
    setState(() { _listening = true; _text = ''; _outcome = null; });
    _pulse.repeat();
    _sub = _voice.listen().listen(
      (t) => setState(() => _text = t),
      onDone: _finish,
    );
  }

  void _stop() {
    _sub?.cancel();
    _finish();
  }

  void _finish() {
    if (!mounted) return;
    _pulse.stop();
    final s = context.read<AppState>();
    setState(() {
      _listening = false;
      if (_text.isNotEmpty) {
        s.remember(_text);
        _outcome = AiSearchService.search(s.products, s.categories, _text);
      }
    });
    if (widget.returnQuery && _text.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) Navigator.pop(context, _text);
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice search')),
      body: Column(children: [
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: Center(
            child: GestureDetector(
              onTap: _listening ? _stop : _start,
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) => Stack(alignment: Alignment.center, children: [
                  if (_listening)
                    for (final o in [0.0, 0.5])
                      Builder(builder: (_) {
                        final t = (_pulse.value + o) % 1.0;
                        return Container(
                          width: 84 + 110 * t, height: 84 + 110 * t,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.cobalt.withOpacity(0.22 * (1 - t))),
                        );
                      }),
                  Container(
                    width: 84, height: 84,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: _listening ? AppColors.cobalt : AppColors.ink),
                    child: Icon(_listening ? Icons.stop_rounded : Icons.mic_rounded, color: Colors.white, size: 38),
                  ),
                ]),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(children: [
            Text(_listening ? (_text.isEmpty ? 'Listening…' : 'Hearing you') : 'Tap the mic to speak',
                style: const TextStyle(color: AppColors.slate, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(_text.isEmpty ? '“Show me a black backpack under 5000”' : '“$_text”',
                  key: ValueKey(_text), textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800, color: _text.isEmpty ? AppColors.slate.withOpacity(0.6) : null)),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _outcome == null
              ? const SizedBox()
              : _outcome!.results.isEmpty
                  ? const EmptyState(icon: Icons.search_off_rounded, title: 'No matches',
                      message: 'Tap the mic and try describing it a different way.')
                  : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        child: Text('${_outcome!.results.length} matching products',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      ),
                      Expanded(child: ProductGrid(_outcome!.results)),
                    ]),
        ),
      ]),
    );
  }
}
