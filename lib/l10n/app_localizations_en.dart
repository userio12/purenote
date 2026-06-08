// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PureNote';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get ok => 'OK';

  @override
  String get retry => 'Retry';

  @override
  String get undo => 'Undo';

  @override
  String get add => 'Add';

  @override
  String get create => 'Create';

  @override
  String get rename => 'Rename';

  @override
  String get remove => 'Remove';

  @override
  String get close => 'Close';

  @override
  String get discard => 'Discard';

  @override
  String get restore => 'Restore';

  @override
  String get apply => 'Apply';

  @override
  String get continueBtn => 'Continue';

  @override
  String get confirm => 'Confirm';

  @override
  String get verify => 'Verify';

  @override
  String get setup => 'Set up';

  @override
  String get clear => 'Clear';

  @override
  String get repair => 'Repair';

  @override
  String get notes => 'Notes';

  @override
  String get tasks => 'Tasks';

  @override
  String get settings => 'Settings';

  @override
  String get labels => 'Labels';

  @override
  String get about => 'About';

  @override
  String get search => 'Search';

  @override
  String get share => 'Share';

  @override
  String get edit => 'Edit';

  @override
  String get color => 'Color';

  @override
  String get lock => 'Lock';

  @override
  String get unlock => 'Unlock';

  @override
  String get pin => 'Pin';

  @override
  String get save_verb => 'Save';

  @override
  String get stop => 'Stop';

  @override
  String get untitled => 'Untitled';

  @override
  String get empty => '(empty)';

  @override
  String get noNotesYet => 'No notes yet';

  @override
  String get noLabelsYet => 'No labels yet';

  @override
  String get noTaskListsYet => 'No task lists yet';

  @override
  String get noBackupsYet => 'No backups yet';

  @override
  String noResults(Object query) {
    return 'No results for \"$query\"';
  }

  @override
  String get noMatchingNotes => 'No matching notes';

  @override
  String get tryDifferentFilter => 'Try a different filter';

  @override
  String get tapToCreateFirstNote => 'Tap + to create your first note';

  @override
  String get createFirstTaskList => 'Create your first task list';

  @override
  String get noItemsYet => 'No items yet';

  @override
  String get emptyItem => 'Empty item';

  @override
  String get noLabelsinYet => 'No labels yet. Create one above.';

  @override
  String get selectLabel => 'Select a label';

  @override
  String get list => 'List';

  @override
  String get grid => 'Grid';

  @override
  String get all => 'All';

  @override
  String get others => 'Others';

  @override
  String get pinned => 'Pinned';

  @override
  String get locked => 'Locked';

  @override
  String get lockedNote => 'Locked note';

  @override
  String get unlocked => 'Not locked';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortModified => 'Modified';

  @override
  String get sortCreated => 'Created';

  @override
  String get sortTitle => 'Title';

  @override
  String get oldest => 'Oldest';

  @override
  String get latest => 'Latest';

  @override
  String get ascendingOrder => 'Ascending order';

  @override
  String get viewSection => 'View';

  @override
  String get viewMode => 'View mode';

  @override
  String get textSize => 'Text size';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get matchApp => 'Match app';

  @override
  String get securitySection => 'Security';

  @override
  String get appLock => 'App lock';

  @override
  String get pinIsSet => 'PIN is set';

  @override
  String get notSetUp => 'Not set up';

  @override
  String get lockMethod => 'Lock method';

  @override
  String get lockMethodPinOnly => 'PIN only';

  @override
  String get lockMethodBiometricOnly => 'Biometric only';

  @override
  String get lockMethodBoth => 'PIN or biometric';

  @override
  String get lockNewNotes => 'Lock new notes by default';

  @override
  String get lockNewNotesSubtitle => 'Newly created notes start locked';

  @override
  String get autoLockTimer => 'Auto-lock timer';

  @override
  String get autoLockImmediately => 'Immediately';

  @override
  String get autoLock15Seconds => '15 seconds';

  @override
  String get autoLock30Seconds => '30 seconds';

  @override
  String get autoLock1Minute => '1 minute';

  @override
  String get autoLock5Minutes => '5 minutes';

  @override
  String get autoLock15Minutes => '15 minutes';

  @override
  String get changePin => 'Change PIN';

  @override
  String get widgetSection => 'Widget';

  @override
  String get widgetSource => 'Source';

  @override
  String get widgetPinnedNotes => 'Pinned notes';

  @override
  String get widgetAllNotes => 'All notes';

  @override
  String get widgetSpecificLabel => 'Specific label';

  @override
  String get widgetLabel => 'Label';

  @override
  String get widgetMaxItems => 'Max items';

  @override
  String get widgetTheme => 'Theme';

  @override
  String get refreshWidget => 'Refresh widget';

  @override
  String get refreshWidgetSubtitle => 'Update the home screen widget data';

  @override
  String get widgetUpdated => 'Widget updated';

  @override
  String get dataSection => 'Data';

  @override
  String get autoBackup => 'Auto backup';

  @override
  String get autoBackupSubtitle => 'Back up notes automatically';

  @override
  String get backupInterval => 'Backup interval';

  @override
  String get backupDaily => 'Daily';

  @override
  String get backupWeekly => 'Weekly';

  @override
  String get backupMonthly => 'Monthly';

  @override
  String get manageLabels => 'Manage labels';

  @override
  String get manageLabelsSubtitle => 'Create, rename, delete labels';

  @override
  String get backupAndRestore => 'Backup & restore';

  @override
  String get backupAndRestoreSubtitle => 'Create and restore backups';

  @override
  String get importNotes => 'Import notes';

  @override
  String get importNotesSubtitle => 'From Keep, Evernote, or Quillpad';

  @override
  String get repairDatabase => 'Repair database';

  @override
  String get repairDatabaseSubtitle => 'Check and repair database integrity';

  @override
  String get clearAllData => 'Clear all data';

  @override
  String get clearAllDataSubtitle => 'Delete all notes and reset the app';

  @override
  String get aboutSection => 'About';

  @override
  String get aboutPureNote => 'About PureNote';

  @override
  String get appInfo => 'App Info';

  @override
  String get version => 'Version';

  @override
  String get links => 'Links';

  @override
  String get openSourceLicenses => 'Open source licenses';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get sendFeedback => 'Send feedback';

  @override
  String get deleteNotes => 'Delete notes';

  @override
  String deleteNotesConfirm(Object count) {
    return 'Delete $count note(s)?';
  }

  @override
  String get deleteNote => 'Delete note';

  @override
  String deleteNoteConfirm(Object title) {
    return 'Delete \"$title\"?';
  }

  @override
  String get deleteLabel => 'Delete label';

  @override
  String deleteLabelConfirm(Object name) {
    return 'Notes with label \"$name\" will be unlabeled.';
  }

  @override
  String get deleteLabelTitle => 'Delete label?';

  @override
  String get deleteRecording => 'Discard recording?';

  @override
  String get deleteRecordingContent =>
      'This recording will be permanently deleted.';

  @override
  String get pinAll => 'Pin all';

  @override
  String get unpin => 'Unpin';

  @override
  String get addLabel => 'Add label';

  @override
  String get deleteAll => 'Delete all';

  @override
  String get gridView => 'Grid view';

  @override
  String get listView => 'List view';

  @override
  String get searchNotes => 'Search notes';

  @override
  String get searchNotesHint => 'Search notes...';

  @override
  String get searchYourNotes => 'Search your notes';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get clearAll => 'Clear all';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get newNote => 'New note';

  @override
  String get noteColor => 'Note color';

  @override
  String get setReminder => 'Set reminder';

  @override
  String get removeReminder => 'Remove reminder';

  @override
  String get recordAudio => 'Record audio';

  @override
  String get saveFirst => 'Save the note first';

  @override
  String get titleHint => 'Title';

  @override
  String get startWriting => 'Start writing...';

  @override
  String get saved => 'Saved';

  @override
  String get saving => 'Saving...';

  @override
  String get unsavedChanges => 'Unsaved changes';

  @override
  String get noteDeleted => 'Note deleted';

  @override
  String get noteNotFound => 'Note not found';

  @override
  String createdLabel(Object date) {
    return 'Created: $date';
  }

  @override
  String updatedLabel(Object date) {
    return 'Updated: $date';
  }

  @override
  String reminderLabel(Object date) {
    return 'Reminder: $date';
  }

  @override
  String couldNotOpenFile(Object message) {
    return 'Could not open file: $message';
  }

  @override
  String get couldNotLoadNotes => 'Could not load notes';

  @override
  String get taskListTitle => 'Task list title';

  @override
  String get newTaskList => 'New task list';

  @override
  String get editTaskList => 'Edit Task List';

  @override
  String get newTaskItem => 'Task item';

  @override
  String get addItem => 'Add item';

  @override
  String get collapseSubtasks => 'Collapse subtasks';

  @override
  String get expandSubtasks => 'Expand subtasks';

  @override
  String get unindent => 'Unindent';

  @override
  String get indent => 'Indent';

  @override
  String get addSubtask => 'Add subtask';

  @override
  String get removeChecked => 'Remove checked';

  @override
  String get autoSort => 'Auto-sort';

  @override
  String taskProgress(Object checked, Object total) {
    return '$checked / $total done';
  }

  @override
  String get labelsTitle => 'Labels';

  @override
  String get createLabel => 'Create label';

  @override
  String get newLabel => 'New label';

  @override
  String get renameLabel => 'Rename label';

  @override
  String get labelName => 'Label name';

  @override
  String get newLabelName => 'New label name';

  @override
  String get discardChanges => 'Discard changes?';

  @override
  String get discardChangesContent =>
      'You have unsaved changes. Do you want to discard them?';

  @override
  String get recoverDraft => 'Recover draft?';

  @override
  String get recoverDraftContent =>
      'An unsaved draft was found from a previous session. Would you like to restore it?';

  @override
  String get tapToChangeOrRemove => 'Tap below to change or remove';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get yourPin => 'Your PIN';

  @override
  String get pinsDoNotMatch => 'PINs do not match';

  @override
  String get wrongPin => 'Wrong PIN';

  @override
  String tooManyAttempts(Object seconds) {
    return 'Too many attempts. Try again in $seconds seconds';
  }

  @override
  String get useBiometric => 'Use biometric';

  @override
  String get unlockApp => 'Unlock purenote';

  @override
  String get removePin => 'Remove PIN?';

  @override
  String get removePinContent => 'This will disable app lock.';

  @override
  String get setPinTitle => 'Set PIN';

  @override
  String get confirmPinTitle => 'Confirm PIN';

  @override
  String get enterSixDigitPin => 'Enter a 6-digit PIN';

  @override
  String get reenterPin => 'Re-enter your PIN';

  @override
  String get enterCurrentPin => 'Enter current PIN';

  @override
  String get enterNewPin => 'Enter new PIN';

  @override
  String get confirmNewPin => 'Confirm new PIN';

  @override
  String get viewModeGrid => 'Grid';

  @override
  String get viewModeList => 'List';

  @override
  String get autoLockLabel => 'Auto-lock timer';

  @override
  String get immediately => 'Immediately';

  @override
  String get sectionView => 'View';

  @override
  String get sectionSecurity => 'Security';

  @override
  String get sectionWidget => 'Widget';

  @override
  String get sectionData => 'Data';

  @override
  String get backupAndRestoreTitle => 'Backup & Restore';

  @override
  String get autoBackupSection => 'Auto-backup';

  @override
  String autoBackupEnabled(Object interval) {
    return 'Enabled ($interval)';
  }

  @override
  String get autoBackupDisabled => 'Disabled';

  @override
  String get includeAttachmentFiles => 'Include attachment files';

  @override
  String get includeAttachmentFilesSubtitle => 'Increases backup size';

  @override
  String get manualBackupSection => 'Manual backup';

  @override
  String get passwordProtectBackup => 'Password protect backup';

  @override
  String get passwordProtectBackupSubtitle =>
      'Enter a password when creating or restoring';

  @override
  String get backUpNow => 'Back up now';

  @override
  String get creating => 'Creating...';

  @override
  String get restoreFromBackup => 'Restore from backup';

  @override
  String get restoring => 'Restoring...';

  @override
  String get backupHistory => 'Backup history';

  @override
  String get backupSaved => 'Backup saved';

  @override
  String backupFailed(Object error) {
    return 'Backup failed: $error';
  }

  @override
  String get backupPassword => 'Backup password';

  @override
  String get enterBackupPassword => 'Enter backup password';

  @override
  String get restoreBackupConfirm => 'Restore backup?';

  @override
  String get restoreCompleted => 'Restore completed';

  @override
  String restoreFailed(Object error) {
    return 'Restore failed: $error';
  }

  @override
  String failedToLoadHistory(Object error) {
    return 'Failed to load history: $error';
  }

  @override
  String backupAt(Object date) {
    return 'Backup $date';
  }

  @override
  String get importNotesTitle => 'Import notes';

  @override
  String get chooseSourceFormat => 'Choose a source format';

  @override
  String get duplicatesLabel => 'Duplicates: ';

  @override
  String get skipExisting => 'Skip existing';

  @override
  String get importAll => 'Import all';

  @override
  String get googleKeep => 'Google Keep';

  @override
  String get googleKeepSubtitle => 'Import from Keep Takeout HTML files';

  @override
  String get evernote => 'Evernote';

  @override
  String get evernoteSubtitle => 'Import from ENEX export files';

  @override
  String get quillpad => 'Quillpad';

  @override
  String get quillpadSubtitle => 'Import from Quillpad JSON export';

  @override
  String get importComplete => 'Import complete';

  @override
  String importedCount(Object count) {
    return '$count imported';
  }

  @override
  String skippedCount(Object count) {
    return '$count skipped';
  }

  @override
  String failedCount(Object count) {
    return '$count failed';
  }

  @override
  String get errorsLabel => 'Errors:';

  @override
  String get startingImport => 'Starting import...';

  @override
  String importingKeepNote(Object number) {
    return 'Importing Keep note $number...';
  }

  @override
  String importingEvernoteNote(Object number) {
    return 'Importing Evernote note $number...';
  }

  @override
  String importingNote(Object number) {
    return 'Importing note $number...';
  }

  @override
  String importDone(Object failed, Object imported, Object skipped) {
    return 'Done: $imported imported, $skipped skipped, $failed failed';
  }

  @override
  String get recordAudioTitle => 'Record Audio';

  @override
  String get microphonePermissionRequired => 'Microphone permission required';

  @override
  String get failedToSaveRecording => 'Failed to save recording';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get remindersChannel => 'Reminders';

  @override
  String get remindersChannelDescription => 'Note reminder notifications';

  @override
  String get noteReminder => 'Note reminder';

  @override
  String get tapToOpenNote => 'Tap to open your note';

  @override
  String get noteHasBeenDeleted => 'This note has been deleted';

  @override
  String get widgetTitle => 'purenote';

  @override
  String get noNotesWidget => 'No notes yet';

  @override
  String get justNow => 'Just now';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get repairDatabaseTitle => 'Repair database';

  @override
  String get repairDatabaseContent =>
      'This will check and repair the database. May take a moment.';

  @override
  String get runningIntegrityCheck => 'Running integrity check...';

  @override
  String get integrityCheckPassed => 'Database integrity check passed';

  @override
  String integrityCheckIssues(Object status) {
    return 'Issues found: $status';
  }

  @override
  String integrityCheckFailed(Object error) {
    return 'Check failed: $error';
  }

  @override
  String get clearAllDataTitle => 'Clear all data?';

  @override
  String get clearAllDataContent =>
      'This will permanently delete all notes, labels, attachments, and settings. This cannot be undone.';

  @override
  String get clearDataButton => 'Clear data';

  @override
  String get areYouSure => 'Are you sure?';

  @override
  String get areYouSureContent =>
      'This action is irreversible. All your notes, attachments, and settings will be lost.';

  @override
  String get deleteEverything => 'Delete everything';

  @override
  String get allDataCleared => 'All data cleared';

  @override
  String failedToClearData(Object error) {
    return 'Failed to clear data: $error';
  }

  @override
  String get attachments => 'Attachments';

  @override
  String get attachmentAdd => 'Add';

  @override
  String get attachmentImage => 'Image';

  @override
  String get attachmentCamera => 'Camera';

  @override
  String get failedToUnlockNote => 'Failed to unlock note';

  @override
  String get failedToSaveNote => 'Failed to save note';

  @override
  String get failedToSaveTaskList => 'Failed to save task list';

  @override
  String get failedToAttachFile => 'Failed to attach file';

  @override
  String get reminder => 'Reminder';
}
