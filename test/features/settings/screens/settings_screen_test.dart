import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/core/providers/database_provider.dart';
import 'package:purenote/features/settings/screens/settings_screen.dart';
import 'package:purenote/l10n/app_localizations.dart';

Widget _wrap(Widget w) => MaterialApp(
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [Locale('en')],
  home: Scaffold(body: w),
);

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  ProviderScope scope(Widget child) => ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
    ],
    child: _wrap(child),
  );

  group('SettingsScreen', () {
    testWidgets('renders with Settings title', (tester) async {
      await tester.pumpWidget(scope(const SettingsScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows View section header', (tester) async {
      await tester.pumpWidget(scope(const SettingsScreen()));
      await tester.pumpAndSettle();
      expect(find.text('View'), findsOneWidget);
    });

    testWidgets('shows Security section header', (tester) async {
      await tester.pumpWidget(scope(const SettingsScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Security'), findsOneWidget);
    });

    testWidgets('shows Widget section header', (tester) async {
      await tester.pumpWidget(scope(const SettingsScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Widget'), 100);
      expect(find.text('Widget'), findsOneWidget);
    });

    testWidgets('shows Data section header', (tester) async {
      await tester.pumpWidget(scope(const SettingsScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Data'), 100);
      expect(find.text('Data'), findsOneWidget);
    });

    testWidgets('shows About section header', (tester) async {
      await tester.pumpWidget(scope(const SettingsScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('About'), 100);
      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(scope(const SettingsScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
