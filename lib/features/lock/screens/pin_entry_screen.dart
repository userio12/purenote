import 'dart:async';
import 'package:flutter/material.dart';
import 'package:purenote/core/services/auth_service.dart';
import 'package:purenote/l10n/app_localizations.dart';

class PinEntryScreen extends StatefulWidget {
  final VoidCallback onUnlock;
  const PinEntryScreen({super.key, required this.onUnlock});

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  final _auth = AuthService();
  final _pin = List.generate(6, (_) => '');
  int _attempts = 0;
  int? _lockoutEnd;
  Timer? _lockoutTimer;

  @override
  void initState() {
    super.initState();
    _tryBiometric();
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _tryBiometric() async {
    final method = await _auth.getLockMethod();
    if (method == 'biometric' || method == 'both') {
      final success = await _auth.authenticateBiometric();
      if (success && mounted) widget.onUnlock();
    }
  }

  void _onDigit(int digit) {
    if (_isLockedOut()) return;

    for (var i = 0; i < 6; i++) {
      if (_pin[i].isEmpty) {
        setState(() => _pin[i] = digit.toString());
        if (i == 5) _verifyPin();
        break;
      }
    }
  }

  void _onDelete() {
    for (var i = 5; i >= 0; i--) {
      if (_pin[i].isNotEmpty) {
        setState(() => _pin[i] = '');
        break;
      }
    }
  }

  bool _isLockedOut() {
    if (_lockoutEnd == null) return false;
    final remaining = _lockoutEnd! - DateTime.now().millisecondsSinceEpoch;
    if (remaining <= 0) {
      _lockoutEnd = null;
      return false;
    }
    return true;
  }

  Future<void> _verifyPin() async {
    final pin = _pin.join();
    final valid = await _auth.verifyPin(pin);

    if (valid && mounted) {
      widget.onUnlock();
      return;
    }

    _attempts++;
    if (_attempts >= 3) {
      _lockoutEnd = DateTime.now().millisecondsSinceEpoch + 30000;
      _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
        if (!_isLockedOut() && mounted) {
          _lockoutTimer?.cancel();
          setState(() {
            _attempts = 0;
            for (var i = 0; i < 6; i++) { _pin[i] = ''; }
          });
        }
      });
    }

    if (mounted) {
      setState(() {
        for (var i = 0; i < 6; i++) { _pin[i] = ''; }
      });
    }
  }

  String _lockoutText(BuildContext context) {
    if (_lockoutEnd == null) return '';
    final remaining = _lockoutEnd! - DateTime.now().millisecondsSinceEpoch;
    if (remaining <= 0) return '';
    final seconds = (remaining / 1000).ceil();
    return AppLocalizations.of(context)!.tooManyAttempts(seconds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
            Text(
            AppLocalizations.of(context)!.enterPin,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              6,
              (i) => Container(
                width: 48,
                height: 56,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _pin[i].isNotEmpty
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    _pin[i].isNotEmpty ? '●' : '',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
            ),
          ),
          if (_isLockedOut()) ...[
            const SizedBox(height: 16),
            Text(_lockoutText(context), style: const TextStyle(color: Colors.red, fontSize: 13)),
          ] else ...[
            const SizedBox(height: 16),
            FutureBuilder<bool>(
              future: _auth.hasBiometrics(),
              builder: (context, snapshot) {
                if (snapshot.data != true) return const SizedBox.shrink();
                return TextButton.icon(
                  onPressed: _tryBiometric,
                  icon: const Icon(Icons.fingerprint),
                  label: Text(AppLocalizations.of(context)!.useBiometric),
                );
              },
            ),
          ],
          const SizedBox(height: 32),
          _buildNumpad(),
        ],
      ),
    );
  }

  Widget _buildNumpad() {
    return Column(
      children: [
        _numpadRow([1, 2, 3]),
        _numpadRow([4, 5, 6]),
        _numpadRow([7, 8, 9]),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            children: [
              const Spacer(),
              _numpadButton(0),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.backspace_outlined),
                onPressed: _onDelete,
                iconSize: 28,
              ),
              const Spacer(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _numpadRow(List<int> digits) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
      child: Row(
        children: digits.map((d) => Expanded(child: _numpadButton(d))).toList(),
      ),
    );
  }

  Widget _numpadButton(int digit) {
    return SizedBox(
      height: 64,
      child: TextButton(
        onPressed: _isLockedOut() ? null : () => _onDigit(digit),
        child: Text(
          digit.toString(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
