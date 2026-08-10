import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:buymarket_frontend/features/profile/screens/profile_photo_crop_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('returns an adjusted square profile image', (tester) async {
    Uint8List? croppedImage;
    final sourceImage = await tester.runAsync(() async {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, 20, 20),
        Paint()..color = Colors.purple,
      );
      final image = await recorder.endRecording().toImage(20, 20);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      return data!.buffer.asUint8List();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () async {
                  croppedImage = await Navigator.push<Uint8List>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfilePhotoCropScreen(
                        imageBytes: sourceImage!,
                      ),
                    ),
                  );
                },
                child: const Text('Abrir editor'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir editor'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();

    expect(find.text('Ajustar foto'), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);

    await tester.tap(find.text('Usar foto'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();

    expect(croppedImage, isNotNull);
    expect(croppedImage, isNotEmpty);
  });
}
