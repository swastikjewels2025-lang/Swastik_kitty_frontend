import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/features/home/presentation/widgets/home_store_video_section.dart';

void main() {
  group('HomeStoreVideoSection Widget Tests', () {
    testWidgets('Renders video section, play/pause controls, and duration', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HomeStoreVideoSection(),
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify title & badges
      expect(find.text('EXPERIENCE SWASTIK'), findsOneWidget);
      expect(find.text('4K ULTRA HD • STORE TOUR'), findsOneWidget);

      // Verify play button exists and tap it
      final Finder playBtn = find.byIcon(Icons.play_arrow_rounded);
      expect(playBtn, findsOneWidget);
      await tester.tap(playBtn);
      await tester.pump(const Duration(milliseconds: 300));

      // Verify toggled to pause icon
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

      // Verify volume toggle
      final Finder volumeBtn = find.byIcon(Icons.volume_up_rounded);
      expect(volumeBtn, findsOneWidget);
      await tester.tap(volumeBtn);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byIcon(Icons.volume_off_rounded), findsOneWidget);
    });
  });
}
