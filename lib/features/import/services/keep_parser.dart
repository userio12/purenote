import 'package:purenote/features/import/services/delta_converter.dart';

class KeepNote {
  final String title;
  final String content;
  final List<String> tags;
  final int createdAt;
  final int updatedAt;
  final bool isPinned;
  final int? color;

  KeepNote({
    required this.title,
    required this.content,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    required this.isPinned,
    this.color,
  });
}

class KeepParser {
  static List<KeepNote> parse(String htmlContent) {
    final notes = <KeepNote>[];

    final blocks = htmlContent.split(RegExp(r'</div>\s*<br>'));
    for (final block in blocks) {
      final titleMatch = RegExp(r'<title>([\s\S]*?)</title>', caseSensitive: false).firstMatch(block);
      final contentMatch = RegExp(r'<div[^>]*dir="ltr"[^>]*>([\s\S]*?)</div>', caseSensitive: false).firstMatch(block);
      if (contentMatch == null && titleMatch == null) continue;

      final tags = RegExp(r'<span class="[^"]*tag[^"]*"[^>]*>([\s\S]*?)</span>', caseSensitive: false)
          .allMatches(block)
          .map((m) => m.group(1)?.trim() ?? '')
          .where((t) => t.isNotEmpty)
          .toList();
      final createdMatch = RegExp(r'Created:\s*(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})', caseSensitive: false)
          .firstMatch(block);
      final updatedMatch = RegExp(r'Updated:\s*(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})', caseSensitive: false)
          .firstMatch(block);

      final title = _decodeHtml(_stripTags(titleMatch?.group(1)?.trim() ?? 'Untitled'));
      final body = _decodeHtml(contentMatch?.group(1)?.trim() ?? '');
      final createdAt = createdMatch != null
          ? DateTime.tryParse(createdMatch.group(1)!)?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch
          : DateTime.now().millisecondsSinceEpoch;
      final updatedAt = updatedMatch != null
          ? DateTime.tryParse(updatedMatch.group(1)!)?.millisecondsSinceEpoch ?? createdAt
          : createdAt;

      notes.add(KeepNote(
        title: title,
        content: body,
        tags: tags,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isPinned: block.contains('isPinned="true"') || block.contains('data-is-pinned="true"'),
      ));
    }

    if (notes.isEmpty) {
      final titleMatch = RegExp(r'<title>([\s\S]*?)</title>', caseSensitive: false).firstMatch(htmlContent);
      final contentMatch = RegExp(r'<div[^>]*dir="ltr"[^>]*>([\s\S]*?)</div>', caseSensitive: false).firstMatch(htmlContent);
      final tags = RegExp(r'<span class="[^"]*tag[^"]*"[^>]*>([\s\S]*?)</span>', caseSensitive: false)
          .allMatches(htmlContent)
          .map((m) => m.group(1)?.trim() ?? '')
          .where((t) => t.isNotEmpty)
          .toList();
      final createdMatch = RegExp(r'Created:\s*(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})', caseSensitive: false)
          .firstMatch(htmlContent);
      final updatedMatch = RegExp(r'Updated:\s*(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})', caseSensitive: false)
          .firstMatch(htmlContent);

      if (contentMatch != null || titleMatch != null) {
        notes.add(KeepNote(
          title: _decodeHtml(_stripTags(titleMatch?.group(1)?.trim() ?? 'Untitled')),
          content: _decodeHtml(contentMatch?.group(1)?.trim() ?? ''),
          tags: tags,
          createdAt: createdMatch != null
              ? DateTime.tryParse(createdMatch.group(1)!)?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch
              : DateTime.now().millisecondsSinceEpoch,
          updatedAt: updatedMatch != null
              ? DateTime.tryParse(updatedMatch.group(1)!)?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch
              : DateTime.now().millisecondsSinceEpoch,
          isPinned: htmlContent.contains('isPinned="true"') || htmlContent.contains('data-is-pinned="true"'),
        ));
      }
    }

    return notes;
  }

  static String _stripTags(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  static String _decodeHtml(String text) {
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');
  }

  static List<Map<String, dynamic>> keepToDelta(KeepNote note) {
    return htmlToDelta(note.content);
  }
}
