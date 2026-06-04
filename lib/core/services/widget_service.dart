import 'package:home_widget/home_widget.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/core/database/daos/settings_dao.dart';
import 'package:purenote/core/database/daos/label_dao.dart';
import 'package:purenote/core/database/daos/note_dao.dart';
import 'package:purenote/core/error/error_logger.dart';
import 'package:purenote/core/utils/delta_utils.dart';

class WidgetService {
  static const titleKey = 'title';
  static const bodyKey = 'body';
  static const sourceKey = 'widgetSource';
  static const maxItemsKey = 'widgetMaxItems';
  static const themeKey = 'widgetTheme';
  static const widgetLabelKey = 'widgetLabel';

  static Future<void> updateWidgetData(
    NoteDao noteDao, {
    LabelDao? labelDao,
    String widgetSource = 'pinned',
    int widgetMaxItems = 5,
    String widgetTheme = 'match',
    String? widgetLabel,
  }) async {
    try {
      List<Note> notes;
      if (widgetSource == 'pinned') {
        notes = await noteDao.getAll();
        notes = notes.where((n) => n.isPinned).toList();
      } else if (widgetSource == 'label' && widgetLabel != null && labelDao != null) {
        notes = await noteDao.getAll();
        final labeledNoteIds = await labelDao.getNoteIdsForLabel(widgetLabel);
        notes = notes.where((n) => labeledNoteIds.contains(n.id)).toList();
      } else {
        notes = await noteDao.getAll();
      }
      final nonEmpty = notes.where((n) => n.content.isNotEmpty || n.title.isNotEmpty).toList();
      nonEmpty.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      final recent = nonEmpty.take(widgetMaxItems).toList();

      String title;
      String body;

      if (recent.isEmpty) {
        title = 'purenote';
        body = 'No notes yet';
      } else {
        final first = recent.first;
        title = first.title.isNotEmpty ? first.title : 'Untitled';
        final preview = stripQuillDelta(first.content).replaceAll('\n', ' ').trim();
        body = preview.isNotEmpty ? preview : '(empty)';

        if (recent.length > 1) {
          body += '\n+${recent.length - 1} more';
        }
      }

      await HomeWidget.saveWidgetData<String>(titleKey, title);
      await HomeWidget.saveWidgetData<String>(bodyKey, body);
      await HomeWidget.saveWidgetData<String>(sourceKey, widgetSource);
      await HomeWidget.saveWidgetData<String>(maxItemsKey, widgetMaxItems.toString());
      await HomeWidget.saveWidgetData<String>(themeKey, widgetTheme);
      await HomeWidget.updateWidget(
        androidName: 'PureNoteWidgetProvider',
        qualifiedAndroidName: 'com.purenote.purenote.PureNoteWidgetProvider',
      );
    } catch (e, s) {
      ErrorLogger.logError('Widget update failed', error: e, stackTrace: s);
    }
  }
}

@pragma('vm:entry-point')
Future<void> widgetBackgroundCallback(Uri? uri) async {
  final db = AppDatabase.noDb();
  try {
    await db.customStatement('SELECT 1');
    final dao = NoteDao(db);
    final labelDao = LabelDao(db);
    final settingsDao = SettingsDao(db);
    final source = await settingsDao.get(WidgetService.sourceKey) ?? 'pinned';
    final maxItems = int.tryParse(await settingsDao.get(WidgetService.maxItemsKey) ?? '') ?? 5;
    final theme = await settingsDao.get(WidgetService.themeKey) ?? 'match';
    final label = await settingsDao.get(WidgetService.widgetLabelKey);
    await WidgetService.updateWidgetData(
      dao,
      labelDao: labelDao,
      widgetSource: source,
      widgetMaxItems: maxItems,
      widgetTheme: theme,
      widgetLabel: label,
    );
  } catch (_) {
    final title = await HomeWidget.getWidgetData<String>(WidgetService.titleKey);
    final body = await HomeWidget.getWidgetData<String>(WidgetService.bodyKey);
    if (title != null) await HomeWidget.saveWidgetData<String>(WidgetService.titleKey, title);
    if (body != null) await HomeWidget.saveWidgetData<String>(WidgetService.bodyKey, body);
    await HomeWidget.updateWidget(
      androidName: 'PureNoteWidgetProvider',
      qualifiedAndroidName: 'com.purenote.purenote.PureNoteWidgetProvider',
    );
  } finally {
    await db.close();
  }
}
