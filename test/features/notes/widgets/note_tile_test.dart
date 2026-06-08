import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/features/notes/widgets/note_tile.dart';
import 'package:purenote/l10n/app_localizations.dart';

final _baseNote = Note(
  id: 'test1', type: 0, title: 'Test Note',
  content: '[{"insert":"Hello world\\n"}]',
  color: null, isPinned: false, isLocked: false,
  isArchived: false, reminderAt: null,
  createdAt: DateTime.now().millisecondsSinceEpoch,
  updatedAt: DateTime.now().millisecondsSinceEpoch,
  orderIndex: 0,
);

final _pinnedNote = _baseNote.copyWith(isPinned: true);
final _lockedNote = _baseNote.copyWith(isLocked: true, content: '');

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
  group('NoteTile', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(_wrap(
        NoteTile(note: _baseNote, onTap: () {}),
      ));
      expect(find.text('Test Note'), findsOneWidget);
    });

    testWidgets('shows Untitled for empty title', (tester) async {
      final note = _baseNote.copyWith(title: '');
      await tester.pumpWidget(_wrap(
        NoteTile(note: note, onTap: () {}),
      ));
      expect(find.text('Untitled'), findsOneWidget);
    });

    testWidgets('shows lock icon when locked', (tester) async {
      await tester.pumpWidget(_wrap(
        NoteTile(note: _lockedNote, onTap: () {}),
      ));
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.text('Locked note'), findsOneWidget);
    });

    testWidgets('shows pin icon when pinned', (tester) async {
      await tester.pumpWidget(_wrap(
        NoteTile(note: _pinnedNote, onTap: () {}),
      ));
      expect(find.byIcon(Icons.push_pin), findsOneWidget);
    });

    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(
        NoteTile(note: _baseNote, onTap: () {}),
      ));
      expect(find.byType(NoteTile), findsOneWidget);
    });
  });
}
