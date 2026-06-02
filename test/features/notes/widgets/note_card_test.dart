import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/features/notes/widgets/note_card.dart';

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

Widget _wrap(Widget w) => MaterialApp(home: Scaffold(body: w));

void main() {
  group('NoteCard', () {
    testWidgets('renders title and preview', (tester) async {
      await tester.pumpWidget(_wrap(NoteCard(note: _baseNote, onTap: () {})));
      expect(find.text('Test Note'), findsOneWidget);
      expect(find.textContaining('Hello world'), findsOneWidget);
    });

    testWidgets('shows Untitled for empty title', (tester) async {
      final note = _baseNote.copyWith(title: '');
      await tester.pumpWidget(_wrap(NoteCard(note: note, onTap: () {})));
      expect(find.text('Untitled'), findsOneWidget);
    });

    testWidgets('shows pin icon when pinned', (tester) async {
      await tester.pumpWidget(_wrap(NoteCard(note: _pinnedNote, onTap: () {})));
      expect(find.byIcon(Icons.push_pin), findsOneWidget);
    });

    testWidgets('shows lock icon and locked label when locked', (tester) async {
      await tester.pumpWidget(_wrap(NoteCard(note: _lockedNote, onTap: () {})));
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.text('Locked note'), findsOneWidget);
    });

    testWidgets('hides preview when locked', (tester) async {
      await tester.pumpWidget(_wrap(NoteCard(note: _lockedNote, onTap: () {})));
      expect(find.text('Hello world'), findsNothing);
    });

    testWidgets('fires onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(NoteCard(note: _baseNote, onTap: () => tapped = true)));
      await tester.tap(find.text('Test Note'));
      expect(tapped, isTrue);
    });

    testWidgets('shows labels', (tester) async {
      final labels = [Label(id: 'l1', name: 'Work', color: null, orderIndex: 0)];
      await tester.pumpWidget(_wrap(NoteCard(note: _baseNote, onTap: () {}, labels: labels)));
      expect(find.text('Work'), findsOneWidget);
    });

    testWidgets('shows overflow count for >2 labels', (tester) async {
      final labels = [
        Label(id: 'l1', name: 'A', color: null, orderIndex: 0),
        Label(id: 'l2', name: 'B', color: null, orderIndex: 1),
        Label(id: 'l3', name: 'C', color: null, orderIndex: 2),
      ];
      await tester.pumpWidget(_wrap(NoteCard(note: _baseNote, onTap: () {}, labels: labels)));
      expect(find.text('+1'), findsOneWidget);
    });
  });

  group('NoteCardSkeleton', () {
    testWidgets('renders skeleton', (tester) async {
      await tester.pumpWidget(_wrap(const NoteCardSkeleton()));
      expect(find.byType(NoteCardSkeleton), findsOneWidget);
    });
  });
}
