import 'package:flutter/material.dart';
import 'package:purenote/core/services/auth_service.dart';
import 'package:purenote/core/theme/app_colors.dart';
import 'package:purenote/l10n/app_localizations.dart';

class PinSetupScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const PinSetupScreen({super.key, required this.onComplete});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final _auth = AuthService();
  final _pinController = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  int _step = 0; // 0: enter PIN, 1: confirm PIN
  String? _firstPin;
  String? _error;

  @override
  void dispose() {
    for (final c in _pinController) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  void _onDigit(int digit) {
    if (_error != null) setState(() => _error = null);

    for (var i = 0; i < 6; i++) {
      if (_pinController[i].text.isEmpty) {
        _pinController[i].text = digit.toString();
        if (i < 5) _focusNodes[i + 1].requestFocus();
        break;
      }
    }
  }

  void _onDelete() {
    for (var i = 5; i >= 0; i--) {
      if (_pinController[i].text.isNotEmpty) {
        _pinController[i].clear();
        if (i > 0) _focusNodes[i - 1].requestFocus();
        break;
      }
    }
  }

  Future<void> _onSubmit() async {
    final pin = _pinController.map((c) => c.text).join();

    if (_step == 0) {
      _firstPin = pin;
      setState(() {
        _step = 1;
        for (final c in _pinController) { c.clear(); }
        _focusNodes[0].requestFocus();
      });
    } else {
      if (pin == _firstPin) {
        await _auth.setPin(pin);
        widget.onComplete();
      } else {
        setState(() {
          _error = 'pinsDoNotMatch';
          _step = 0;
          _firstPin = null;
          for (final c in _pinController) { c.clear(); }
          _focusNodes[0].requestFocus();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(title: Text(_step == 0 ? AppLocalizations.of(context)!.setPinTitle : AppLocalizations.of(context)!.confirmPinTitle)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _step == 0 ? AppLocalizations.of(context)!.enterSixDigitPin : AppLocalizations.of(context)!.reenterPin,
            style: Theme.of(context).textTheme.titleMedium,
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
                    color: _pinController[i].text.isNotEmpty
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    _pinController[i].text.isNotEmpty ? '●' : '',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error == 'pinsDoNotMatch' ? AppLocalizations.of(context)!.pinsDoNotMatch : _error!,
              style: TextStyle(color: colors.accentDanger),
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
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _pinController.every((c) => c.text.isNotEmpty) ? _onSubmit : null,
          child: Text(_step == 0 ? AppLocalizations.of(context)!.continueBtn : AppLocalizations.of(context)!.confirm),
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
        onPressed: () => _onDigit(digit),
        child: Text(
          digit.toString(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
