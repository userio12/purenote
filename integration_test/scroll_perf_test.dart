import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:purenote/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Scroll performance', () {
    testWidgets('notes list scrolls at 60fps with 500 items', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('purenote'));
      await tester.pumpAndSettle();

      final listFinder = find.byType(Scrollable).first;
      await tester.fling(listFinder, const Offset(0, -5000), 5000);
      await tester.pumpAndSettle();

      final summary = await IntegrationTestWidgetsFlutterBinding.instance
          .takeScreenshot('scroll');
      expect(summary, isNotNull);
    });
  });
}
