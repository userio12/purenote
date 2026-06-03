import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pointycastle/export.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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

  Future<bool> authenticateWithContext(BuildContext context) async {
    final method = await getLockMethod();
    Sentry.addBreadcrumb(Breadcrumb(
      message: 'Auth attempt',
      category: 'auth',
      level: SentryLevel.info,
      data: {'method': method ?? 'none'},
    ));
    switch (method) {
      case 'biometric':
        return authenticateBiometric();
      case 'both':
        final bio = await authenticateBiometric();
        if (bio) return true;
        return _showPinDialog(context);
      case 'pin':
        return _showPinDialog(context);
      default:
        return true;
    }
  }

  Future<bool> _showPinDialog(BuildContext context) async {
    final controller = TextEditingController();
    try {
      final pin = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Enter PIN'),
          content: TextField(
            controller: controller,
            obscureText: true,
            maxLength: 6,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'PIN',
              counterText: '',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text),
              child: const Text('Unlock'),
            ),
          ],
        ),
      );
      if (pin == null || pin.isEmpty) return false;
      return await verifyPin(pin);
    } finally {
      controller.dispose();
    }
  }

  String _hash(String pin, List<int> salt) {
    return deriveKey(pin, salt, 32);
  }

  List<int> _generateSalt() {
    final random = Random.secure();
    return List.generate(32, (_) => random.nextInt(256));
  }
}
