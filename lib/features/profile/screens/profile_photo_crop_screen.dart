import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ProfilePhotoCropScreen extends StatefulWidget {
  final Uint8List imageBytes;

  const ProfilePhotoCropScreen({super.key, required this.imageBytes});

  @override
  State<ProfilePhotoCropScreen> createState() =>
      _ProfilePhotoCropScreenState();
}

class _ProfilePhotoCropScreenState extends State<ProfilePhotoCropScreen> {
  final _previewKey = GlobalKey();
  final _transformationController = TransformationController();
  double? _imageAspectRatio;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _readImageSize();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _readImageSize() async {
    final codec = await ui.instantiateImageCodec(widget.imageBytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final aspectRatio = image.width / image.height;
    image.dispose();
    codec.dispose();
    if (mounted) setState(() => _imageAspectRatio = aspectRatio);
  }

  Future<void> _confirmCrop() async {
    setState(() => _isSaving = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      final boundary = _previewKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) throw StateError('Vista de recorte no disponible');

      final pixelRatio = 512 / boundary.size.width;
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (byteData == null) throw StateError('No se pudo generar la imagen');

      final bytes = byteData.buffer.asUint8List();
      if (mounted) Navigator.pop(context, bytes);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar el recorte.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Ajustar foto'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _confirmCrop,
            child: Text(
              _isSaving ? 'Guardando...' : 'Usar foto',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Text(
                'Mové la foto y pellizcá para ampliar la parte que querés mostrar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, height: 1.35),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _buildEditor(),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.zoom_in, color: Colors.white70),
                  SizedBox(width: 8),
                  Text(
                    'Arrastrá y ajustá el zoom',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditor() {
    final aspectRatio = _imageAspectRatio;
    if (aspectRatio == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        final imageWidth = aspectRatio >= 1 ? size * aspectRatio : size;
        final imageHeight = aspectRatio >= 1 ? size : size / aspectRatio;

        return Stack(
          fit: StackFit.expand,
          children: [
            RepaintBoundary(
              key: _previewKey,
              child: ClipRect(
                child: ColoredBox(
                  color: Colors.black,
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    constrained: false,
                    minScale: 1,
                    maxScale: 5,
                    boundaryMargin: EdgeInsets.all(size * 2),
                    child: SizedBox(
                      width: imageWidth,
                      height: imageHeight,
                      child: Image.memory(widget.imageBytes, fit: BoxFit.fill),
                    ),
                  ),
                ),
              ),
            ),
            const Positioned.fill(
              child: IgnorePointer(child: CustomPaint(painter: _CropOverlay())),
            ),
          ],
        );
      },
    );
  }
}

class _CropOverlay extends CustomPainter {
  const _CropOverlay();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final circle = Path()
      ..addOval(Rect.fromCircle(center: rect.center, radius: size.width / 2));
    final outside = Path.combine(
      PathOperation.difference,
      Path()..addRect(rect),
      circle,
    );
    canvas.drawPath(outside, Paint()..color = Colors.black54);
    canvas.drawCircle(
      rect.center,
      size.width / 2 - 1,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
