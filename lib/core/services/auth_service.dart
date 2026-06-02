import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pointycastle/export.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _pinHashKey = 'app_pin_hash';
  static const _pinSaltKey = 'app_pin_salt';
  static const _lockMethodKey = 'app_lock_method';

  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> hasBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateBiometric() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Unlock purenote',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  Future<bool> isPinSet() async {
    final hash = await _storage.read(key: _pinHashKey);
    return hash != null && hash.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    final salt = _generateSalt();
    final hash = _hash(pin, salt);
    await _storage.write(key: _pinHashKey, value: hash);
    await _storage.write(key: _pinSaltKey, value: base64Encode(salt));
  }

  Future<bool> verifyPin(String pin) async {
    final storedHash = await _storage.read(key: _pinHashKey);
    final storedSalt = await _storage.read(key: _pinSaltKey);
    if (storedHash == null || storedSalt == null) return false;
    final salt = base64Decode(storedSalt);
    final hash = _hash(pin, salt);
    return hash == storedHash;
  }

  static String deriveKey(String password, List<int> salt, int keyLength) {
    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    derivator.init(Pbkdf2Parameters(Uint8List.fromList(salt), 100000, keyLength));
    final key = derivator.process(Uint8List.fromList(utf8.encode(password)));
    return base64Encode(key);
  }

  Future<String?> getLockMethod() async {
    return await _storage.read(key: _lockMethodKey);
  }

  Future<void> setLockMethod(String method) async {
    await _storage.write(key: _lockMethodKey, value: method);
  }

  Future<void> clearPin() async {
    await _storage.delete(key: _pinHashKey);
    await _storage.delete(key: _pinSaltKey);
    await _storage.delete(key: _lockMethodKey);
  }

  String _hash(String pin, List<int> salt) {
    return deriveKey(pin, salt, 32);
  }

  List<int> _generateSalt() {
    final random = Random.secure();
    return List.generate(32, (_) => random.nextInt(256));
  }
}
