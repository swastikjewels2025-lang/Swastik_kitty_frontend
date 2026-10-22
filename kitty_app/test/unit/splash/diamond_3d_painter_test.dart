import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/features/splash/presentation/widgets/diamond_3d_painter.dart';

void main() {
  group('Diamond3DPainter Unit Tests', () {
    test('Diamond3DPainter instantiates without error and initializes geometry', () {
      final Diamond3DPainter painter = Diamond3DPainter(
        rotationY: 0.0,
        scaleFactor: 1.0,
        opacity: 1.0,
      );

      expect(painter.rotationY, 0.0);
      expect(painter.scaleFactor, 1.0);
      expect(painter.opacity, 1.0);
    });

    test('shouldRepaint returns true when parameters change', () {
      final Diamond3DPainter painter1 = Diamond3DPainter(
        rotationY: 0.0,
        scaleFactor: 1.0,
        opacity: 1.0,
      );
      final Diamond3DPainter painter2 = Diamond3DPainter(
        rotationY: 1.5,
        scaleFactor: 1.0,
        opacity: 1.0,
      );
      final Diamond3DPainter painter3 = Diamond3DPainter(
        rotationY: 0.0,
        scaleFactor: 2.0,
        opacity: 1.0,
      );
      final Diamond3DPainter painter4 = Diamond3DPainter(
        rotationY: 0.0,
        scaleFactor: 1.0,
        opacity: 0.5,
      );
      final Diamond3DPainter painterSame = Diamond3DPainter(
        rotationY: 0.0,
        scaleFactor: 1.0,
        opacity: 1.0,
      );

      expect(painter2.shouldRepaint(painter1), isTrue);
      expect(painter3.shouldRepaint(painter1), isTrue);
      expect(painter4.shouldRepaint(painter1), isTrue);
      expect(painterSame.shouldRepaint(painter1), isFalse);
    });

    test('Paint executes safely on canvas across full 360 rotation & various scales', () {
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      const Size size = Size(400, 800);

      final List<double> angles = <double>[0.0, 1.57, 3.14, 4.71, 6.28];
      final List<double> scales = <double>[0.5, 1.0, 5.0, 15.0];

      for (final double angle in angles) {
        for (final double scale in scales) {
          final Diamond3DPainter painter = Diamond3DPainter(
            rotationY: angle,
            scaleFactor: scale,
            opacity: 0.9,
          );
          expect(() => painter.paint(canvas, size), returnsNormally);
        }
      }

      // Zero opacity returns early safely
      final Diamond3DPainter zeroOpacity = Diamond3DPainter(
        rotationY: 0.0,
        scaleFactor: 1.0,
        opacity: 0.0,
      );
      expect(() => zeroOpacity.paint(canvas, size), returnsNormally);
    });
  });
}
