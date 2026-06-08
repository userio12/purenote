import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'PureNote'**
  String get appTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @setup.
  ///
  /// In en, this message translates to:
  /// **'Set up'**
  String get setup;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @repair.
  ///
  /// In en, this message translates to:
  /// **'Repair'**
  String get repair;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @labels.
  ///
  /// In en, this message translates to:
  /// **'Labels'**
  String get labels;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @lock.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get lock;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get pin;

  /// No description provided for @save_verb.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save_verb;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'(empty)'**
  String get empty;

  /// No description provided for @noNotesYet.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get noNotesYet;

  /// No description provided for @noLabelsYet.
  ///
  /// In en, this message translates to:
  /// **'No labels yet'**
  String get noLabelsYet;

  /// No description provided for @noTaskListsYet.
  ///
  /// In en, this message translates to:
  /// **'No task lists yet'**
  String get noTaskListsYet;

  /// No description provided for @noBackupsYet.
  ///
  /// In en, this message translates to:
  /// **'No backups yet'**
  String get noBackupsYet;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String noResults(Object query);

  /// No description provided for @noMatchingNotes.
  ///
  /// In en, this message translates to:
  /// **'No matching notes'**
  String get noMatchingNotes;

  /// No description provided for @tryDifferentFilter.
  ///
  /// In en, this message translates to:
  /// **'Try a different filter'**
  String get tryDifferentFilter;

  /// No description provided for @tapToCreateFirstNote.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create your first note'**
  String get tapToCreateFirstNote;

  /// No description provided for @createFirstTaskList.
  ///
  /// In en, this message translates to:
  /// **'Create your first task list'**
  String get createFirstTaskList;

  /// No description provided for @noItemsYet.
  ///
  /// In en, this message translates to:
  /// **'No items yet'**
  String get noItemsYet;

  /// No description provided for @emptyItem.
  ///
  /// In en, this message translates to:
  /// **'Empty item'**
  String get emptyItem;

  /// No description provided for @noLabelsinYet.
  ///
  /// In en, this message translates to:
  /// **'No labels yet. Create one above.'**
  String get noLabelsinYet;

  /// No description provided for @selectLabel.
  ///
  /// In en, this message translates to:
  /// **'Select a label'**
  String get selectLabel;

  /// No description provided for @list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get list;

  /// No description provided for @grid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get grid;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @others.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get others;

  /// No description provided for @pinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get pinned;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @lockedNote.
  ///
  /// In en, this message translates to:
  /// **'Locked note'**
  String get lockedNote;

  /// No description provided for @unlocked.
  ///
  /// In en, this message translates to:
  /// **'Not locked'**
  String get unlocked;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortModified.
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get sortModified;

  /// No description provided for @sortCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get sortCreated;

  /// No description provided for @sortTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get sortTitle;

  /// No description provided for @oldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get oldest;

  /// No description provided for @latest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latest;

  /// No description provided for @ascendingOrder.
  ///
  /// In en, this message translates to:
  /// **'Ascending order'**
  String get ascendingOrder;

  /// No description provided for @viewSection.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewSection;

  /// No description provided for @viewMode.
  ///
  /// In en, this message translates to:
  /// **'View mode'**
  String get viewMode;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSize;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @matchApp.
  ///
  /// In en, this message translates to:
  /// **'Match app'**
  String get matchApp;

  /// No description provided for @securitySection.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securitySection;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get appLock;

  /// No description provided for @pinIsSet.
  ///
  /// In en, this message translates to:
  /// **'PIN is set'**
  String get pinIsSet;

  /// No description provided for @notSetUp.
  ///
  /// In en, this message translates to:
  /// **'Not set up'**
  String get notSetUp;

  /// No description provided for @lockMethod.
  ///
  /// In en, this message translates to:
  /// **'Lock method'**
  String get lockMethod;

  /// No description provided for @lockMethodPinOnly.
  ///
  /// In en, this message translates to:
  /// **'PIN only'**
  String get lockMethodPinOnly;

  /// No description provided for @lockMethodBiometricOnly.
  ///
  /// In en, this message translates to:
  /// **'Biometric only'**
  String get lockMethodBiometricOnly;

  /// No description provided for @lockMethodBoth.
  ///
  /// In en, this message translates to:
  /// **'PIN or biometric'**
  String get lockMethodBoth;

  /// No description provided for @lockNewNotes.
  ///
  /// In en, this message translates to:
  /// **'Lock new notes by default'**
  String get lockNewNotes;

  /// No description provided for @lockNewNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Newly created notes start locked'**
  String get lockNewNotesSubtitle;

  /// No description provided for @autoLockTimer.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock timer'**
  String get autoLockTimer;

  /// No description provided for @autoLockImmediately.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get autoLockImmediately;

  /// No description provided for @autoLock15Seconds.
  ///
  /// In en, this message translates to:
  /// **'15 seconds'**
  String get autoLock15Seconds;

  /// No description provided for @autoLock30Seconds.
  ///
  /// In en, this message translates to:
  /// **'30 seconds'**
  String get autoLock30Seconds;

  /// No description provided for @autoLock1Minute.
  ///
  /// In en, this message translates to:
  /// **'1 minute'**
  String get autoLock1Minute;

  /// No description provided for @autoLock5Minutes.
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get autoLock5Minutes;

  /// No description provided for @autoLock15Minutes.
  ///
  /// In en, this message translates to:
  /// **'15 minutes'**
  String get autoLock15Minutes;

  /// No description provided for @changePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// No description provided for @widgetSection.
  ///
  /// In en, this message translates to:
  /// **'Widget'**
  String get widgetSection;

  /// No description provided for @widgetSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get widgetSource;

  /// No description provided for @widgetPinnedNotes.
  ///
  /// In en, this message translates to:
  /// **'Pinned notes'**
  String get widgetPinnedNotes;

  /// No description provided for @widgetAllNotes.
  ///
  /// In en, this message translates to:
  /// **'All notes'**
  String get widgetAllNotes;

  /// No description provided for @widgetSpecificLabel.
  ///
  /// In en, this message translates to:
  /// **'Specific label'**
  String get widgetSpecificLabel;

  /// No description provided for @widgetLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get widgetLabel;

  /// No description provided for @widgetMaxItems.
  ///
  /// In en, this message translates to:
  /// **'Max items'**
  String get widgetMaxItems;

  /// No description provided for @widgetTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get widgetTheme;

  /// No description provided for @refreshWidget.
  ///
  /// In en, this message translates to:
  /// **'Refresh widget'**
  String get refreshWidget;

  /// No description provided for @refreshWidgetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update the home screen widget data'**
  String get refreshWidgetSubtitle;

  /// No description provided for @widgetUpdated.
  ///
  /// In en, this message translates to:
  /// **'Widget updated'**
  String get widgetUpdated;

  /// No description provided for @dataSection.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get dataSection;

  /// No description provided for @autoBackup.
  ///
  /// In en, this message translates to:
  /// **'Auto backup'**
  String get autoBackup;

  /// No description provided for @autoBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Back up notes automatically'**
  String get autoBackupSubtitle;

  /// No description provided for @backupInterval.
  ///
  /// In en, this message translates to:
  /// **'Backup interval'**
  String get backupInterval;

  /// No description provided for @backupDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get backupDaily;

  /// No description provided for @backupWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get backupWeekly;

  /// No description provided for @backupMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get backupMonthly;

  /// No description provided for @manageLabels.
  ///
  /// In en, this message translates to:
  /// **'Manage labels'**
  String get manageLabels;

  /// No description provided for @manageLabelsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create, rename, delete labels'**
  String get manageLabelsSubtitle;

  /// No description provided for @backupAndRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get backupAndRestore;

  /// No description provided for @backupAndRestoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create and restore backups'**
  String get backupAndRestoreSubtitle;

  /// No description provided for @importNotes.
  ///
  /// In en, this message translates to:
  /// **'Import notes'**
  String get importNotes;

  /// No description provided for @importNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'From Keep, Evernote, or Quillpad'**
  String get importNotesSubtitle;

  /// No description provided for @repairDatabase.
  ///
  /// In en, this message translates to:
  /// **'Repair database'**
  String get repairDatabase;

  /// No description provided for @repairDatabaseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check and repair database integrity'**
  String get repairDatabaseSubtitle;

  /// No description provided for @clearAllData.
  ///
  /// In en, this message translates to:
  /// **'Clear all data'**
  String get clearAllData;

  /// No description provided for @clearAllDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all notes and reset the app'**
  String get clearAllDataSubtitle;

  /// No description provided for @aboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSection;

  /// No description provided for @aboutPureNote.
  ///
  /// In en, this message translates to:
  /// **'About PureNote'**
  String get aboutPureNote;

  /// No description provided for @appInfo.
  ///
  /// In en, this message translates to:
  /// **'App Info'**
  String get appInfo;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @links.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get links;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open source licenses'**
  String get openSourceLicenses;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get sendFeedback;

  /// No description provided for @deleteNotes.
  ///
  /// In en, this message translates to:
  /// **'Delete notes'**
  String get deleteNotes;

  /// No description provided for @deleteNotesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} note(s)?'**
  String deleteNotesConfirm(Object count);

  /// No description provided for @deleteNote.
  ///
  /// In en, this message translates to:
  /// **'Delete note'**
  String get deleteNote;

  /// No description provided for @deleteNoteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?'**
  String deleteNoteConfirm(Object title);

  /// No description provided for @deleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete label'**
  String get deleteLabel;

  /// No description provided for @deleteLabelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Notes with label \"{name}\" will be unlabeled.'**
  String deleteLabelConfirm(Object name);

  /// No description provided for @deleteLabelTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete label?'**
  String get deleteLabelTitle;

  /// No description provided for @deleteRecording.
  ///
  /// In en, this message translates to:
  /// **'Discard recording?'**
  String get deleteRecording;

  /// No description provided for @deleteRecordingContent.
  ///
  /// In en, this message translates to:
  /// **'This recording will be permanently deleted.'**
  String get deleteRecordingContent;

  /// No description provided for @pinAll.
  ///
  /// In en, this message translates to:
  /// **'Pin all'**
  String get pinAll;

  /// No description provided for @unpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get unpin;

  /// No description provided for @addLabel.
  ///
  /// In en, this message translates to:
  /// **'Add label'**
  String get addLabel;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get deleteAll;

  /// No description provided for @gridView.
  ///
  /// In en, this message translates to:
  /// **'Grid view'**
  String get gridView;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get listView;

  /// No description provided for @searchNotes.
  ///
  /// In en, this message translates to:
  /// **'Search notes'**
  String get searchNotes;

  /// No description provided for @searchNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Search notes...'**
  String get searchNotesHint;

  /// No description provided for @searchYourNotes.
  ///
  /// In en, this message translates to:
  /// **'Search your notes'**
  String get searchYourNotes;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @newNote.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get newNote;

  /// No description provided for @noteColor.
  ///
  /// In en, this message translates to:
  /// **'Note color'**
  String get noteColor;

  /// No description provided for @setReminder.
  ///
  /// In en, this message translates to:
  /// **'Set reminder'**
  String get setReminder;

  /// No description provided for @removeReminder.
  ///
  /// In en, this message translates to:
  /// **'Remove reminder'**
  String get removeReminder;

  /// No description provided for @recordAudio.
  ///
  /// In en, this message translates to:
  /// **'Record audio'**
  String get recordAudio;

  /// No description provided for @saveFirst.
  ///
  /// In en, this message translates to:
  /// **'Save the note first'**
  String get saveFirst;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleHint;

  /// No description provided for @startWriting.
  ///
  /// In en, this message translates to:
  /// **'Start writing...'**
  String get startWriting;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @unsavedChanges.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes'**
  String get unsavedChanges;

  /// No description provided for @noteDeleted.
  ///
  /// In en, this message translates to:
  /// **'Note deleted'**
  String get noteDeleted;

  /// No description provided for @noteNotFound.
  ///
  /// In en, this message translates to:
  /// **'Note not found'**
  String get noteNotFound;

  /// No description provided for @createdLabel.
  ///
  /// In en, this message translates to:
  /// **'Created: {date}'**
  String createdLabel(Object date);

  /// No description provided for @updatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Updated: {date}'**
  String updatedLabel(Object date);

  /// No description provided for @reminderLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder: {date}'**
  String reminderLabel(Object date);

  /// No description provided for @couldNotOpenFile.
  ///
  /// In en, this message translates to:
  /// **'Could not open file: {message}'**
  String couldNotOpenFile(Object message);

  /// No description provided for @couldNotLoadNotes.
  ///
  /// In en, this message translates to:
  /// **'Could not load notes'**
  String get couldNotLoadNotes;

  /// No description provided for @taskListTitle.
  ///
  /// In en, this message translates to:
  /// **'Task list title'**
  String get taskListTitle;

  /// No description provided for @newTaskList.
  ///
  /// In en, this message translates to:
  /// **'New task list'**
  String get newTaskList;

  /// No description provided for @editTaskList.
  ///
  /// In en, this message translates to:
  /// **'Edit Task List'**
  String get editTaskList;

  /// No description provided for @newTaskItem.
  ///
  /// In en, this message translates to:
  /// **'Task item'**
  String get newTaskItem;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItem;

  /// No description provided for @collapseSubtasks.
  ///
  /// In en, this message translates to:
  /// **'Collapse subtasks'**
  String get collapseSubtasks;

  /// No description provided for @expandSubtasks.
  ///
  /// In en, this message translates to:
  /// **'Expand subtasks'**
  String get expandSubtasks;

  /// No description provided for @unindent.
  ///
  /// In en, this message translates to:
  /// **'Unindent'**
  String get unindent;

  /// No description provided for @indent.
  ///
  /// In en, this message translates to:
  /// **'Indent'**
  String get indent;

  /// No description provided for @addSubtask.
  ///
  /// In en, this message translates to:
  /// **'Add subtask'**
  String get addSubtask;

  /// No description provided for @removeChecked.
  ///
  /// In en, this message translates to:
  /// **'Remove checked'**
  String get removeChecked;

  /// No description provided for @autoSort.
  ///
  /// In en, this message translates to:
  /// **'Auto-sort'**
  String get autoSort;

  /// No description provided for @taskProgress.
  ///
  /// In en, this message translates to:
  /// **'{checked} / {total} done'**
  String taskProgress(Object checked, Object total);

  /// No description provided for @labelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Labels'**
  String get labelsTitle;

  /// No description provided for @createLabel.
  ///
  /// In en, this message translates to:
  /// **'Create label'**
  String get createLabel;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'New label'**
  String get newLabel;

  /// No description provided for @renameLabel.
  ///
  /// In en, this message translates to:
  /// **'Rename label'**
  String get renameLabel;

  /// No description provided for @labelName.
  ///
  /// In en, this message translates to:
  /// **'Label name'**
  String get labelName;

  /// No description provided for @newLabelName.
  ///
  /// In en, this message translates to:
  /// **'New label name'**
  String get newLabelName;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChanges;

  /// No description provided for @discardChangesContent.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Do you want to discard them?'**
  String get discardChangesContent;

  /// No description provided for @recoverDraft.
  ///
  /// In en, this message translates to:
  /// **'Recover draft?'**
  String get recoverDraft;

  /// No description provided for @recoverDraftContent.
  ///
  /// In en, this message translates to:
  /// **'An unsaved draft was found from a previous session. Would you like to restore it?'**
  String get recoverDraftContent;

  /// No description provided for @tapToChangeOrRemove.
  ///
  /// In en, this message translates to:
  /// **'Tap below to change or remove'**
  String get tapToChangeOrRemove;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;

  /// No description provided for @yourPin.
  ///
  /// In en, this message translates to:
  /// **'Your PIN'**
  String get yourPin;

  /// No description provided for @pinsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match'**
  String get pinsDoNotMatch;

  /// No description provided for @wrongPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN'**
  String get wrongPin;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in {seconds} seconds'**
  String tooManyAttempts(Object seconds);

  /// No description provided for @useBiometric.
  ///
  /// In en, this message translates to:
  /// **'Use biometric'**
  String get useBiometric;

  /// No description provided for @unlockApp.
  ///
  /// In en, this message translates to:
  /// **'Unlock purenote'**
  String get unlockApp;

  /// No description provided for @removePin.
  ///
  /// In en, this message translates to:
  /// **'Remove PIN?'**
  String get removePin;

  /// No description provided for @removePinContent.
  ///
  /// In en, this message translates to:
  /// **'This will disable app lock.'**
  String get removePinContent;

  /// No description provided for @setPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Set PIN'**
  String get setPinTitle;

  /// No description provided for @confirmPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPinTitle;

  /// No description provided for @enterSixDigitPin.
  ///
  /// In en, this message translates to:
  /// **'Enter a 6-digit PIN'**
  String get enterSixDigitPin;

  /// No description provided for @reenterPin.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your PIN'**
  String get reenterPin;

  /// No description provided for @enterCurrentPin.
  ///
  /// In en, this message translates to:
  /// **'Enter current PIN'**
  String get enterCurrentPin;

  /// No description provided for @enterNewPin.
  ///
  /// In en, this message translates to:
  /// **'Enter new PIN'**
  String get enterNewPin;

  /// No description provided for @confirmNewPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm new PIN'**
  String get confirmNewPin;

  /// No description provided for @viewModeGrid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get viewModeGrid;

  /// No description provided for @viewModeList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get viewModeList;

  /// No description provided for @autoLockLabel.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock timer'**
  String get autoLockLabel;

  /// No description provided for @immediately.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get immediately;

  /// No description provided for @sectionView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get sectionView;

  /// No description provided for @sectionSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get sectionSecurity;

  /// No description provided for @sectionWidget.
  ///
  /// In en, this message translates to:
  /// **'Widget'**
  String get sectionWidget;

  /// No description provided for @sectionData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get sectionData;

  /// No description provided for @backupAndRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupAndRestoreTitle;

  /// No description provided for @autoBackupSection.
  ///
  /// In en, this message translates to:
  /// **'Auto-backup'**
  String get autoBackupSection;

  /// No description provided for @autoBackupEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled ({interval})'**
  String autoBackupEnabled(Object interval);

  /// No description provided for @autoBackupDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get autoBackupDisabled;

  /// No description provided for @includeAttachmentFiles.
  ///
  /// In en, this message translates to:
  /// **'Include attachment files'**
  String get includeAttachmentFiles;

  /// No description provided for @includeAttachmentFilesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Increases backup size'**
  String get includeAttachmentFilesSubtitle;

  /// No description provided for @manualBackupSection.
  ///
  /// In en, this message translates to:
  /// **'Manual backup'**
  String get manualBackupSection;

  /// No description provided for @passwordProtectBackup.
  ///
  /// In en, this message translates to:
  /// **'Password protect backup'**
  String get passwordProtectBackup;

  /// No description provided for @passwordProtectBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a password when creating or restoring'**
  String get passwordProtectBackupSubtitle;

  /// No description provided for @backUpNow.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get backUpNow;

  /// No description provided for @creating.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get creating;

  /// No description provided for @restoreFromBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get restoreFromBackup;

  /// No description provided for @restoring.
  ///
  /// In en, this message translates to:
  /// **'Restoring...'**
  String get restoring;

  /// No description provided for @backupHistory.
  ///
  /// In en, this message translates to:
  /// **'Backup history'**
  String get backupHistory;

  /// No description provided for @backupSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved'**
  String get backupSaved;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String backupFailed(Object error);

  /// No description provided for @backupPassword.
  ///
  /// In en, this message translates to:
  /// **'Backup password'**
  String get backupPassword;

  /// No description provided for @enterBackupPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter backup password'**
  String get enterBackupPassword;

  /// No description provided for @restoreBackupConfirm.
  ///
  /// In en, this message translates to:
  /// **'Restore backup?'**
  String get restoreBackupConfirm;

  /// No description provided for @restoreCompleted.
  ///
  /// In en, this message translates to:
  /// **'Restore completed'**
  String get restoreCompleted;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String restoreFailed(Object error);

  /// No description provided for @failedToLoadHistory.
  ///
  /// In en, this message translates to:
  /// **'Failed to load history: {error}'**
  String failedToLoadHistory(Object error);

  /// No description provided for @backupAt.
  ///
  /// In en, this message translates to:
  /// **'Backup {date}'**
  String backupAt(Object date);

  /// No description provided for @importNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Import notes'**
  String get importNotesTitle;

  /// No description provided for @chooseSourceFormat.
  ///
  /// In en, this message translates to:
  /// **'Choose a source format'**
  String get chooseSourceFormat;

  /// No description provided for @duplicatesLabel.
  ///
  /// In en, this message translates to:
  /// **'Duplicates: '**
  String get duplicatesLabel;

  /// No description provided for @skipExisting.
  ///
  /// In en, this message translates to:
  /// **'Skip existing'**
  String get skipExisting;

  /// No description provided for @importAll.
  ///
  /// In en, this message translates to:
  /// **'Import all'**
  String get importAll;

  /// No description provided for @googleKeep.
  ///
  /// In en, this message translates to:
  /// **'Google Keep'**
  String get googleKeep;

  /// No description provided for @googleKeepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import from Keep Takeout HTML files'**
  String get googleKeepSubtitle;

  /// No description provided for @evernote.
  ///
  /// In en, this message translates to:
  /// **'Evernote'**
  String get evernote;

  /// No description provided for @evernoteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import from ENEX export files'**
  String get evernoteSubtitle;

  /// No description provided for @quillpad.
  ///
  /// In en, this message translates to:
  /// **'Quillpad'**
  String get quillpad;

  /// No description provided for @quillpadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import from Quillpad JSON export'**
  String get quillpadSubtitle;

  /// No description provided for @importComplete.
  ///
  /// In en, this message translates to:
  /// **'Import complete'**
  String get importComplete;

  /// No description provided for @importedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} imported'**
  String importedCount(Object count);

  /// No description provided for @skippedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} skipped'**
  String skippedCount(Object count);

  /// No description provided for @failedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} failed'**
  String failedCount(Object count);

  /// No description provided for @errorsLabel.
  ///
  /// In en, this message translates to:
  /// **'Errors:'**
  String get errorsLabel;

  /// No description provided for @startingImport.
  ///
  /// In en, this message translates to:
  /// **'Starting import...'**
  String get startingImport;

  /// No description provided for @importingKeepNote.
  ///
  /// In en, this message translates to:
  /// **'Importing Keep note {number}...'**
  String importingKeepNote(Object number);

  /// No description provided for @importingEvernoteNote.
  ///
  /// In en, this message translates to:
  /// **'Importing Evernote note {number}...'**
  String importingEvernoteNote(Object number);

  /// No description provided for @importingNote.
  ///
  /// In en, this message translates to:
  /// **'Importing note {number}...'**
  String importingNote(Object number);

  /// No description provided for @importDone.
  ///
  /// In en, this message translates to:
  /// **'Done: {imported} imported, {skipped} skipped, {failed} failed'**
  String importDone(Object failed, Object imported, Object skipped);

  /// No description provided for @recordAudioTitle.
  ///
  /// In en, this message translates to:
  /// **'Record Audio'**
  String get recordAudioTitle;

  /// No description provided for @microphonePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission required'**
  String get microphonePermissionRequired;

  /// No description provided for @failedToSaveRecording.
  ///
  /// In en, this message translates to:
  /// **'Failed to save recording'**
  String get failedToSaveRecording;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @remindersChannel.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersChannel;

  /// No description provided for @remindersChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Note reminder notifications'**
  String get remindersChannelDescription;

  /// No description provided for @noteReminder.
  ///
  /// In en, this message translates to:
  /// **'Note reminder'**
  String get noteReminder;

  /// No description provided for @tapToOpenNote.
  ///
  /// In en, this message translates to:
  /// **'Tap to open your note'**
  String get tapToOpenNote;

  /// No description provided for @noteHasBeenDeleted.
  ///
  /// In en, this message translates to:
  /// **'This note has been deleted'**
  String get noteHasBeenDeleted;

  /// No description provided for @widgetTitle.
  ///
  /// In en, this message translates to:
  /// **'purenote'**
  String get widgetTitle;

  /// No description provided for @noNotesWidget.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get noNotesWidget;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @repairDatabaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Repair database'**
  String get repairDatabaseTitle;

  /// No description provided for @repairDatabaseContent.
  ///
  /// In en, this message translates to:
  /// **'This will check and repair the database. May take a moment.'**
  String get repairDatabaseContent;

  /// No description provided for @runningIntegrityCheck.
  ///
  /// In en, this message translates to:
  /// **'Running integrity check...'**
  String get runningIntegrityCheck;

  /// No description provided for @integrityCheckPassed.
  ///
  /// In en, this message translates to:
  /// **'Database integrity check passed'**
  String get integrityCheckPassed;

  /// No description provided for @integrityCheckIssues.
  ///
  /// In en, this message translates to:
  /// **'Issues found: {status}'**
  String integrityCheckIssues(Object status);

  /// No description provided for @integrityCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Check failed: {error}'**
  String integrityCheckFailed(Object error);

  /// No description provided for @clearAllDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all data?'**
  String get clearAllDataTitle;

  /// No description provided for @clearAllDataContent.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all notes, labels, attachments, and settings. This cannot be undone.'**
  String get clearAllDataContent;

  /// No description provided for @clearDataButton.
  ///
  /// In en, this message translates to:
  /// **'Clear data'**
  String get clearDataButton;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @areYouSureContent.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible. All your notes, attachments, and settings will be lost.'**
  String get areYouSureContent;

  /// No description provided for @deleteEverything.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get deleteEverything;

  /// No description provided for @allDataCleared.
  ///
  /// In en, this message translates to:
  /// **'All data cleared'**
  String get allDataCleared;

  /// No description provided for @failedToClearData.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear data: {error}'**
  String failedToClearData(Object error);

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @attachmentAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get attachmentAdd;

  /// No description provided for @attachmentImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get attachmentImage;

  /// No description provided for @attachmentCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get attachmentCamera;

  /// No description provided for @failedToUnlockNote.
  ///
  /// In en, this message translates to:
  /// **'Failed to unlock note'**
  String get failedToUnlockNote;

  /// No description provided for @failedToSaveNote.
  ///
  /// In en, this message translates to:
  /// **'Failed to save note'**
  String get failedToSaveNote;

  /// No description provided for @failedToSaveTaskList.
  ///
  /// In en, this message translates to:
  /// **'Failed to save task list'**
  String get failedToSaveTaskList;

  /// No description provided for @failedToAttachFile.
  ///
  /// In en, this message translates to:
  /// **'Failed to attach file'**
  String get failedToAttachFile;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
