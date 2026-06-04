import 'package:purenote/core/database/database.dart';

extension NoteTypeX on Note {
  bool get isTaskList => type == 1;
}
