# purenote

A minimal, offline-first note-taking app for Android.  
Inspired by NotallyX. No cloud, no ads, no tracking — all data stays on your device.

## Features

- **Rich text notes** — bold, italic, headers, lists, inline code (powered by flutter_quill)
- **Task lists** — checkable items with subtask support
- **Labels** — organize notes with color-coded labels
- **Search** — full-text search with keyword highlighting and recent searches
- **Lock & PIN** — biometric/PIN app lock + per-note encryption (AES-256-CBC)
- **Reminders** — per-note reminder notifications
- **Attachments** — images, audio recordings, files (up to 50MB each)
- **Home screen widget** — shows latest note on your home screen
- **Backup & restore** — ZIP-based backup with optional AES-256 password, auto-backup scheduler
- **Import** — from Google Keep (HTML), Evernote (ENEX), Quillpad (JSON)
- **Themes** — light, dark, system-follow
- **View modes** — list or grid, sort by title/created/modified, adjustable text size
- **Fully offline** — no internet permission, no accounts, no cloud sync

## Tech Stack

| Layer | Library |
|---|---|
| Framework | Flutter 3.41+ / Dart 3.11+ |
| State | Riverpod 2.x with codegen |
| Database | drift (SQLite, WAL mode, FTS5-ready) |
| Rich text | flutter_quill 11.5 (Quill Delta JSON) |
| Navigation | go_router + ShellRoute (bottom nav) |
| Encryption | AES-256-CBC (encrypt/pointycastle) |
| Auth | local_auth (biometric) + flutter_secure_storage |
| Widget | home_widget + Kotlin RemoteViews |
| CI | GitHub Actions (analyze → test → build) |

## Screenshots

*Screenshots go here — add them to `screenshots/` and reference them:*

| Notes list | Editor | Tasks | Settings |
|---|---|---|---|
| screenshot1.png | screenshot2.png | screenshot3.png | screenshot4.png |

## Build

```bash
# Install deps
flutter pub get

# Run codegen (after any provider/DAO change)
dart run build_runner build --delete-conflicting-outputs

# Static analysis
flutter analyze

# Tests
flutter test

# Debug APK
flutter build apk --debug --target-platform android-arm64

# Release AAB
flutter build appbundle --release --obfuscate \
  --split-debug-info=build/app/outputs/symbols
```

Debug symbols are written to `build/app/outputs/symbols/` for Sentry integration.

## Architecture

```
lib/
├── core/
│   ├── database/       # drift schema, DAOs, migrations
│   ├── error/          # Result<T> (Ok/Err), error handler
│   ├── providers/      # shared Riverpod providers
│   ├── routing/        # go_router config
│   ├── services/       # auth, encryption, backup, notifications, widget
│   ├── theme/          # light & dark themes
│   ├── utils/          # delta utils
│   └── widgets/        # shared widgets (EmptyStateWidget)
├── features/
│   ├── audio/          # audio recorder
│   ├── backup/         # backup/restore screen
│   ├── editor/         # note editor + attachments
│   ├── import/         # Keep/Evernote/Quillpad import
│   ├── labels/         # label management + picker
│   ├── lock/           # PIN/biometric lock screens
│   ├── notes/          # note list + card widgets
│   ├── search/         # search screen
│   ├── settings/       # settings + about screens
│   └── tasks/          # task list screens
├── widgets/            # app scaffold (bottom nav)
└── main.dart           # entry point with Sentry init
```

## Testing

Tests mirror the `lib/` structure under `test/`. DAO tests use in-memory SQLite via `NativeDatabase.memory()`.

```bash
flutter test
# 95 tests covering: DAOs, encryption, parsers, converters, widgets, providers, import enums, Result type
```

## License

MIT
