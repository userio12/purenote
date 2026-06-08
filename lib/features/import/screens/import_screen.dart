import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:purenote/core/providers/database_provider.dart';
import 'package:purenote/core/services/attachment_service.dart';
import 'package:purenote/features/import/services/import_service.dart';
import 'package:purenote/core/theme/app_colors.dart';
import 'package:purenote/l10n/app_localizations.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  ImportSource? _selectedSource;
  ImportResult? _result;
  ImportProgress? _progress;
  DuplicateHandling _duplicateHandling = DuplicateHandling.skip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.importNotesTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(AppLocalizations.of(context)!.chooseSourceFormat, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(AppLocalizations.of(context)!.duplicatesLabel, style: theme.textTheme.bodyMedium),
              DropdownButton<DuplicateHandling>(
                value: _duplicateHandling,
                underline: const SizedBox(),
                items: [
                  DropdownMenuItem(value: DuplicateHandling.skip, child: Text(AppLocalizations.of(context)!.skipExisting)),
                  DropdownMenuItem(value: DuplicateHandling.import, child: Text(AppLocalizations.of(context)!.importAll)),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _duplicateHandling = v);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          _SourceCard(
            icon: Icons.language,
            title: AppLocalizations.of(context)!.googleKeep,
            subtitle: AppLocalizations.of(context)!.googleKeepSubtitle,
            selected: _selectedSource == ImportSource.keep,
            onTap: () => _pickFile(ImportSource.keep),
          ),
          const SizedBox(height: 8),
          _SourceCard(
            icon: Icons.note,
            title: AppLocalizations.of(context)!.evernote,
            subtitle: AppLocalizations.of(context)!.evernoteSubtitle,
            selected: _selectedSource == ImportSource.evernote,
            onTap: () => _pickFile(ImportSource.evernote),
          ),
          const SizedBox(height: 8),
          _SourceCard(
            icon: Icons.description,
            title: AppLocalizations.of(context)!.quillpad,
            subtitle: AppLocalizations.of(context)!.quillpadSubtitle,
            selected: _selectedSource == ImportSource.quillpad,
            onTap: () => _pickFile(ImportSource.quillpad),
          ),
          if (_progress != null) ...[
            const SizedBox(height: 24),
            LinearProgressIndicator(
              value: _progress!.total > 0 ? _progress!.current / _progress!.total : null,
            ),
            const SizedBox(height: 8),
            Text(_progress!.message, style: theme.textTheme.bodySmall),
          ],
          if (_result != null) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      _result!.failed > 0 ? Icons.warning_amber : Icons.check_circle,
                      color: _result!.failed > 0 ? colors.accentWarm : colors.accentSuccess,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(AppLocalizations.of(context)!.importComplete, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(AppLocalizations.of(context)!.importedCount(_result!.imported)),
                    if (_result!.skipped > 0) Text(AppLocalizations.of(context)!.skippedCount(_result!.skipped)),
                    if (_result!.failed > 0) Text(AppLocalizations.of(context)!.failedCount(_result!.failed)),
                    if (_result!.errors.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(AppLocalizations.of(context)!.errorsLabel, style: theme.textTheme.labelLarge),
                      ..._result!.errors.map((e) => Text(e, style: theme.textTheme.bodySmall)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickFile(ImportSource source) async {
    final extensions = switch (source) {
      ImportSource.keep => ['html', 'htm'],
      ImportSource.evernote => ['enex'],
      ImportSource.quillpad => ['json'],
    };

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
    );

    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) return;

    setState(() {
      _selectedSource = source;
      _result = null;
      _progress = ImportProgress(current: 0, total: 0, message: AppLocalizations.of(context)!.startingImport);
    });

    try {
      final noteDao = ref.read(noteDaoProvider);
      final labelDao = ref.read(labelDaoProvider);
      final attachmentDao = ref.read(attachmentDaoProvider);
      final attachmentService = AttachmentService(attachmentDao);
      final service = ImportService(noteDao, labelDao, attachmentService);

      await for (final progress in service.importFile(path, source, duplicateHandling: _duplicateHandling)) {
        if (!mounted) return;
        setState(() => _progress = progress);
      }

      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _result = ImportResult(imported: 0, skipped: 0, failed: 1, errors: ['$e']);
      });
    }
  }
}

class _SourceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _SourceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: selected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: selected
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 32, color: selected ? theme.colorScheme.primary : null),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall),
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
