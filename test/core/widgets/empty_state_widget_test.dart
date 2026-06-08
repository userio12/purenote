import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purenote/core/theme/app_colors.dart';
import 'package:purenote/core/widgets/empty_state_widget.dart';

Widget _wrap(Widget w) => MaterialApp(
  theme: ThemeData(extensions: [AppColors.dark()]),
  home: Scaffold(body: w),
);

void main() {
  group('EmptyStateWidget', () {
    testWidgets('renders title and subtitle', (tester) async {
      await tester.pumpWidget(_wrap(
        const EmptyStateWidget(title: 'No notes', subtitle: 'Create one'),
      ));
      expect(find.text('No notes'), findsOneWidget);
      expect(find.text('Create one'), findsOneWidget);
    });

    testWidgets('renders custom icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const EmptyStateWidget(
          title: 'Empty', subtitle: 'Nothing here',
          icon: Icons.folder_open,
        ),
      ));
      expect(find.byIcon(Icons.folder_open), findsOneWidget);
    });

    testWidgets('shows action button when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        EmptyStateWidget(
          title: 'Error', subtitle: 'Something went wrong',
          actionLabel: 'Retry',
          onAction: () {},
        ),
      ));
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('hides action button when not provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const EmptyStateWidget(title: 'Empty', subtitle: 'Nothing'),
      ));
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('fires onAction when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        EmptyStateWidget(
          title: 'Error', subtitle: 'Failed',
          actionLabel: 'Retry',
          onAction: () => tapped = true,
        ),
      ));
      await tester.tap(find.text('Retry'));
      expect(tapped, isTrue);
    });
  });
}
