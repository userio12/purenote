import 'package:flutter_test/flutter_test.dart';
import 'package:purenote/core/error/app_error.dart';
import 'package:purenote/core/error/result.dart';

void main() {
  group('Ok', () {
    test('holds a value', () {
      final result = Ok(42);
      expect(result.value, 42);
    });

    test('is a subtype of Result', () {
      final Result<int> result = Ok(42);
      expect(result, isA<Ok<int>>());
    });

    test('supports String values', () {
      final result = Ok('hello');
      expect(result.value, 'hello');
    });
  });

  group('Err', () {
    test('holds an error', () {
      final error = DatabaseError('test error');
      final result = Err<int>(error);
      expect(result.error, error);
      expect(result.error.userMessage, 'A database error occurred. Please try again.');
    });

    test('is a subtype of Result', () {
      final Result<int> result = Err(DatabaseError('test'));
      expect(result, isA<Err<int>>());
    });

    test('supports EncryptionError', () {
      final error = EncryptionError('encrypt failed');
      final result = Err<String>(error);
      expect(result.error.userMessage, 'Could not secure your note. Please try again.');
    });

    test('supports FileSystemError', () {
      final error = FileSystemError('file not found');
      final result = Err<List<int>>(error);
      expect(result.error.userMessage, 'Could not access the file. Please try again.');
    });

    test('supports ImportError', () {
      final error = ImportError('invalid file');
      final result = Err<void>(error);
      expect(result.error.userMessage, 'Could not import notes. The file may be invalid.');
    });

    test('supports ValidationError', () {
      final error = ValidationError('Invalid input');
      final result = Err<bool>(error);
      expect(result.error.userMessage, 'Invalid input');
    });

    test('supports UnexpectedError', () {
      final error = UnexpectedError();
      final result = Err<double>(error);
      expect(result.error.userMessage, 'Something unexpected happened. Please try again.');
    });
  });

  group('Result pattern matching', () {
    test('Ok can be matched with is', () {
      final Result<int> result = Ok(42);
      if (result is Ok<int>) {
        expect(result.value, 42);
      } else {
        fail('Expected Ok');
      }
    });

    test('Err can be matched with is', () {
      final Result<int> result = Err(DatabaseError('fail'));
      if (result is Err<int>) {
        expect(result.error, isA<DatabaseError>());
      } else {
        fail('Expected Err');
      }
    });
  });
}
