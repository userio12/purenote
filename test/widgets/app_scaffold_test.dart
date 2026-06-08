import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:purenote/l10n/app_localizations.dart';
import 'package:purenote/widgets/app_scaffold.dart';

Widget _wrap(Widget w) => MaterialApp.router(
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [Locale('en')],
  routerConfig: GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, _) => const SizedBox()),
          GoRoute(path: '/tasks', builder: (_, _) => const SizedBox()),
          GoRoute(path: '/settings', builder: (_, _) => const SizedBox()),
        ],
      ),
    ],
  ),
);

void main() {
  group('AppScaffold', () {
    testWidgets('renders NavigationBar with 3 destinations', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(3));
    });

    testWidgets('shows Notes label', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      await tester.pumpAndSettle();
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('shows Tasks label', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      await tester.pumpAndSettle();
      expect(find.text('Tasks'), findsOneWidget);
    });

    testWidgets('shows Settings label', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      await tester.pumpAndSettle();
      expect(find.byType(AppScaffold), findsOneWidget);
    });
  });
}
