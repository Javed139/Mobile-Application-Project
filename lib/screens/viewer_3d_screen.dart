import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../core/theme.dart';
import '../data/mock_data.dart';
import '../models/models.dart';

/// Interactive 3D viewer. Drag to rotate, pinch to zoom. Point [Product.modelUrl]
/// at any .glb / .gltf file (from your backend or assets) to show real models.
class Viewer3DScreen extends StatefulWidget {
  final Product product;
  const Viewer3DScreen({super.key, required this.product});
  @override
  State<Viewer3DScreen> createState() => _Viewer3DScreenState();
}

class _Viewer3DScreenState extends State<Viewer3DScreen> {
  bool _auto = true;
  int _reset = 0;

  @override
  Widget build(BuildContext context) {
    final src = widget.product.modelUrl ?? MockData.sample3d;
    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name, overflow: TextOverflow.ellipsis)),
      body: Column(children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpace.radiusLg),
              gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Color(0xFFF3EEE8), Color(0xFFE6DFD6)]),
            ),
            clipBehavior: Clip.antiAlias,
            child: ModelViewer(
              key: ValueKey('$_auto-$_reset'),
              src: src,
              alt: '3D model of ${widget.product.name}',
              autoRotate: _auto,
              cameraControls: true,
              disableZoom: false,
              backgroundColor: Colors.transparent,
              loading: Loading.eager,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Row(children: const [
            Icon(Icons.touch_app_rounded, size: 18, color: AppColors.slate),
            SizedBox(width: 8),
            Expanded(child: Text('Drag to rotate · pinch to zoom · two fingers to pan', style: TextStyle(color: AppColors.slate, fontSize: 13))),
          ]),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _auto = !_auto),
                  icon: Icon(_auto ? Icons.pause_rounded : Icons.play_arrow_rounded),
                  label: Text(_auto ? 'Pause spin' : 'Auto spin'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _reset++),
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('Reset view'),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
