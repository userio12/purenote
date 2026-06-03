import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:pointycastle/export.dart';

class EncryptionService {
  static enc.IV _generateIV() {
    final random = Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));
    return enc.IV(Uint8List.fromList(bytes));
  }

  static enc.Key _deriveKey(String password, List<int> salt) {
    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    derivator.init(Pbkdf2Parameters(Uint8List.fromList(salt), 100000, 32));
    final keyBytes = derivator.process(Uint8List.fromList(utf8.encode(password)));
    return enc.Key(Uint8List.fromList(keyBytes));
  }

  static String encrypt(String plaintext, String password) {
    final salt = List.generate(32, (_) => Random.secure().nextInt(256));
    final key = _deriveKey(password, salt);
    final iv = _generateIV();
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);

    final result = {
      'salt': base64Encode(salt),
      'iv': iv.base64,
      'data': encrypted.base64,
    };

    final output = base64Encode(utf8.encode(jsonEncode(result)));

    _zeroKey(key);
    _zeroIv(iv);

    return output;
  }

  static String decrypt(String ciphertext, String password) {
    try {
      final payload = jsonDecode(utf8.decode(base64Decode(ciphertext))) as Map<String, dynamic>;
      final salt = base64Decode(payload['salt'] as String);
      final iv = enc.IV.fromBase64(payload['iv'] as String);
      final key = _deriveKey(password, salt);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      final output = encrypter.decrypt64(payload['data'] as String, iv: iv);

      _zeroKey(key);
      _zeroIv(iv);

      return output;
    } catch (_) {
      throw Exception('Decryption failed');
    }
  }

  static void _zeroKey(enc.Key key) {
    final bytes = key.bytes;
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = 0;
    }
  }

  static void _zeroIv(enc.IV iv) {
    final bytes = iv.bytes;
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = 0;
    }
  }
}
