# Changelog

## [1.0.0] - 2026-06-02

### Added
- Rich text notes with bold, italic, underline, headers, lists, inline code (Quill Delta)
- Task lists with checkable items, subtasks, auto-sort checked to bottom
- Label management with color-coded labels and drag-to-reorder
- Full-text search with keyword highlighting and recent searches
- Biometric and PIN app lock with auto-lock timer
- Lock method selector (PIN only / Biometric only / PIN or biometric)
- Per-note AES-256-CBC encryption (independent from app lock)
- Reminder notifications per note
- Image (gallery + camera), audio (record + playback with waveform), and file attachments (up to 50 MB)
- Home screen widget with configurable source (pinned/all), max items (3/5/10), and theme (match/light/dark)
- Backup and restore with optional AES-256 password and auto-backup scheduler
- Pre-restore safety net backup
- Import from Google Keep (HTML), Evernote (ENEX with resource extraction), and Quillpad (JSON)
- Duplicate detection (skip/import all) during import
- Light, dark, system-follow, and AMOLED themes
- List and grid view modes with animated cross-fade toggle
- Sort by title, created, or modified date; swipe-to-delete with undo, swipe-to-pin with haptic feedback
- Adjustable text size (70%–150%)
- Audio recording with waveform visualization, pause/resume, playback preview
- Draft recovery for unsaved notes
- About screen with version info and OSS licenses
- Widget auto-refresh on note changes

### Changed
- Production hardening: DB indexes for query performance, orphan cleanup on start, ProGuard rules
- Migration to schema v2: labels table gains orderIndex for reorder support

### Fixed
- Notification scheduling uses absolute time via zonedSchedule
- PIN hashing upgraded to PBKDF2 (SHA-256, 100K iterations)
- Encryption key derivation uses PBKDF2 with proper salt
- Notification tap opens viewer, not editor
- Auto-lock timer uses proper lastActiveTime comparison

### Security
- PIN stored as PBKDF2 hash via flutter_secure_storage
- Note content encrypted with AES-256-CBC and random IV
- No internet permission, no cloud, no tracking
