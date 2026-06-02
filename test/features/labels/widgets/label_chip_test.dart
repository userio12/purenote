import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/features/labels/widgets/label_chip.dart';

Widget _wrap(Widget w) => MaterialApp(home: Scaffold(body: Center(child: w)));

void main() {
  group('LabelChip', () {
    final label = Label(id: 'l1', name: 'Work', color: null, orderIndex: 0);

    final coloredLabel = Label(id: 'l2', name: 'Personal', color: 0xFF4CAF50, orderIndex: 1);
    testWidgets('renders label name', (tester) async {
      await tester.pumpWidget(_wrap(LabelChip(label: label)));
      expect(find.text('Work'), findsOneWidget);
    });

    testWidgets('shows selected state', (tester) async {
      await tester.pumpWidget(_wrap(LabelChip(label: label, selected: true)));
      final chip = tester.widget<InputChip>(find.byType(InputChip));
      expect(chip.selected, isTrue);
    });

    testWidgets('fires onTap when pressed', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(LabelChip(label: label, onTap: () => tapped = true)));
      await tester.tap(find.text('Work'));
      expect(tapped, isTrue);
    });

    testWidgets('renders with color', (tester) async {
      await tester.pumpWidget(_wrap(LabelChip(label: coloredLabel)));
      expect(find.text('Personal'), findsOneWidget);
    });
  });
}
