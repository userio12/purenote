import 'package:home_widget/home_widget.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/core/database/daos/label_dao.dart';
import 'package:purenote/core/database/daos/note_dao.dart';
import 'package:purenote/core/utils/delta_utils.dart';

class WidgetService {
  static const _titleKey = 'title';
  static const _bodyKey = 'body';
  static const _sourceKey = 'widgetSource';
  static const _maxItemsKey = 'widgetMaxItems';
  static const _themeKey = 'widgetTheme';

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

      await HomeWidget.saveWidgetData<String>(_titleKey, title);
      await HomeWidget.saveWidgetData<String>(_bodyKey, body);
      await HomeWidget.saveWidgetData<String>(_sourceKey, widgetSource);
      await HomeWidget.saveWidgetData<String>(_maxItemsKey, widgetMaxItems.toString());
      await HomeWidget.saveWidgetData<String>(_themeKey, widgetTheme);
      await HomeWidget.updateWidget(
        androidName: 'PureNoteWidgetProvider',
        qualifiedAndroidName: 'com.purenote.purenote.PureNoteWidgetProvider',
      );
    } catch (_) {}
  }
}

@pragma('vm:entry-point')
Future<void> widgetBackgroundCallback(Uri? uri) async {
  try {
    await _refreshFromSavedData();
  } catch (_) {}
}

Future<void> _refreshFromSavedData() async {
  const titleKey = 'title';
  const bodyKey = 'body';
  final title = await HomeWidget.getWidgetData<String>(titleKey);
  final body = await HomeWidget.getWidgetData<String>(bodyKey);
  if (title != null) {
    await HomeWidget.saveWidgetData(titleKey, title);
  }
  if (body != null) {
    await HomeWidget.saveWidgetData(bodyKey, body);
  }
  await HomeWidget.updateWidget(
    androidName: 'PureNoteWidgetProvider',
    qualifiedAndroidName: 'com.purenote.purenote.PureNoteWidgetProvider',
  );
}
