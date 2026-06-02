import 'package:flutter_test/flutter_test.dart';
import 'package:purenote/features/import/services/import_service.dart';

void main() {
  group('ImportService', () {
    test('DuplicateHandling enum has expected values', () {
      expect(DuplicateHandling.values, hasLength(2));
      expect(DuplicateHandling.skip, isNotNull);
      expect(DuplicateHandling.import, isNotNull);
    });

    test('ImportSource enum has expected values', () {
      expect(ImportSource.values, hasLength(3));
      expect(ImportSource.keep, isNotNull);
      expect(ImportSource.evernote, isNotNull);
      expect(ImportSource.quillpad, isNotNull);
    });

    test('ImportResult stores values correctly', () {
      final result = ImportResult(imported: 5, skipped: 2, failed: 1, errors: ['error1']);
      expect(result.imported, 5);
      expect(result.skipped, 2);
      expect(result.failed, 1);
      expect(result.errors, ['error1']);
    });

    test('ImportProgress stores values correctly', () {
      final progress = ImportProgress(current: 3, total: 10, message: 'Importing...');
      expect(progress.current, 3);
      expect(progress.total, 10);
      expect(progress.message, 'Importing...');
    });
  });
}
