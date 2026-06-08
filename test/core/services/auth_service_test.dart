import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:purenote/core/services/auth_service.dart';

void main() {
  group('AuthService.deriveKey (PBKDF2)', () {
    test('produces deterministic base64 output', () {
      final salt = List<int>.generate(32, (i) => i);
      final key1 = AuthService.deriveKey('password', salt, 32);
      final key2 = AuthService.deriveKey('password', salt, 32);
      expect(key1, equals(key2));
    });

    test('same password with different salts produces different keys', () {
      final salt1 = List<int>.generate(32, (i) => i);
      final salt2 = List<int>.generate(32, (i) => i + 32);
      final key1 = AuthService.deriveKey('password', salt1, 32);
      final key2 = AuthService.deriveKey('password', salt2, 32);
      expect(key1, isNot(equals(key2)));
    });

    test('different passwords with same salt produce different keys', () {
      final salt = List<int>.generate(32, (i) => i);
      final key1 = AuthService.deriveKey('password-a', salt, 32);
      final key2 = AuthService.deriveKey('password-b', salt, 32);
      expect(key1, isNot(equals(key2)));
    });

    test('output is valid base64', () {
      final salt = List<int>.generate(32, (i) => i);
      final key = AuthService.deriveKey('test', salt, 32);
      expect(() => base64Decode(key), returnsNormally);
    });

    test('respects requested key length', () {
      final salt = List<int>.generate(32, (i) => i);
      final key16 = AuthService.deriveKey('test', salt, 16);
      final key32 = AuthService.deriveKey('test', salt, 32);
      final key64 = AuthService.deriveKey('test', salt, 64);
      expect(base64Decode(key16).length, 16);
      expect(base64Decode(key32).length, 32);
      expect(base64Decode(key64).length, 64);
    });

    test('empty password produces valid key', () {
      final salt = List<int>.generate(32, (i) => i);
      final key = AuthService.deriveKey('', salt, 32);
      expect(key, isNotEmpty);
      expect(() => base64Decode(key), returnsNormally);
    });

    test('unicode password produces valid key', () {
      final salt = List<int>.generate(32, (i) => i);
      final key = AuthService.deriveKey('日本語パスワード', salt, 32);
      expect(key, isNotEmpty);
      expect(() => base64Decode(key), returnsNormally);
    });
  });

  group('PIN hashing behavior (via deriveKey)', () {
    test('hash length matches 32-byte key', () {
      final salt = List<int>.generate(32, (i) => i);
      final hash = AuthService.deriveKey('1234', salt, 32);
      expect(base64Decode(hash).length, 32);
    });

    test('short PIN still produces full-length hash', () {
      final salt = List<int>.generate(32, (i) => i);
      final hash = AuthService.deriveKey('1', salt, 32);
      expect(base64Decode(hash).length, 32);
    });

    test('6-digit PIN produces consistent hash', () {
      final salt = List<int>.generate(32, (i) => i);
      final hash = AuthService.deriveKey('123456', salt, 32);
      final decoded = base64Decode(hash);
      expect(decoded.length, 32);
      // Same input => same output
      expect(AuthService.deriveKey('123456', salt, 32), equals(hash));
    });
  });
}
