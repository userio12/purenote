import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:purenote/features/audio/screens/audio_recorder_screen.dart';
import 'package:purenote/features/notes/screens/notes_list_screen.dart';
import 'package:purenote/features/notes/screens/note_viewer_screen.dart';
import 'package:purenote/features/tasks/screens/task_lists_screen.dart';
import 'package:purenote/features/tasks/screens/task_list_editor_screen.dart';
import 'package:purenote/features/settings/screens/settings_screen.dart';
import 'package:purenote/features/editor/screens/note_editor_screen.dart';
import 'package:purenote/features/backup/screens/backup_screen.dart';
import 'package:purenote/features/import/screens/import_screen.dart';
import 'package:purenote/features/labels/screens/labels_management_screen.dart';
import 'package:purenote/features/search/screens/search_screen.dart';
import 'package:purenote/features/settings/screens/about_screen.dart';
import 'package:purenote/widgets/app_scaffold.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppScaffold(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const NotesListScreen(),
          ),
        ),
        GoRoute(
          path: '/tasks',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const TaskListsScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const SettingsScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/note/new',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const NoteEditorScreen(),
    ),
    GoRoute(
      path: '/note/:id',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return NoteEditorScreen(noteId: id);
      },
    ),
    GoRoute(
      path: '/note/:id/view',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return NoteViewerScreen(noteId: id);
      },
    ),
    GoRoute(
      path: '/task-list/new',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const TaskListEditorScreen(),
    ),
    GoRoute(
      path: '/task-list/:id',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TaskListEditorScreen(noteId: id);
      },
    ),
    GoRoute(
      path: '/audio/record/:noteId',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final noteId = state.pathParameters['noteId']!;
        return AudioRecorderScreen(noteId: noteId);
      },
    ),
    GoRoute(
      path: '/search',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/labels',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const LabelsManagementScreen(),
    ),
    GoRoute(
      path: '/backup',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const BackupScreen(),
    ),
    GoRoute(
      path: '/import',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ImportScreen(),
    ),
    GoRoute(
      path: '/about',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const AboutScreen(),
    ),
  ],
);
