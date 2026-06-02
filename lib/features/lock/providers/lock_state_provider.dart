import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:purenote/core/services/auth_service.dart';
import 'package:purenote/core/providers/settings_provider.dart';

part 'lock_state_provider.g.dart';

@Riverpod(keepAlive: true)
class LockState extends _$LockState {
  final _auth = AuthService();
  DateTime _lastActiveTime = DateTime.now();

  @override
  bool build() => false;

  void markActive() {
    _lastActiveTime = DateTime.now();
  }

  Future<void> checkAndLock() async {
    final isPinSet = await _auth.isPinSet();
    if (!isPinSet) return;

    final settings = ref.read(settingsNotifierProvider);
    final autoLock = settings.autoLockSeconds;

    if (autoLock == 0) {
      state = true;
      return;
    }

    final elapsed = DateTime.now().difference(_lastActiveTime).inSeconds;
    if (elapsed >= autoLock) {
      state = true;
    } else {
      _lastActiveTime = DateTime.now();
    }
  }

  void unlock() {
    _lastActiveTime = DateTime.now();
    state = false;
  }

  void lock() {
    state = true;
  }
}
