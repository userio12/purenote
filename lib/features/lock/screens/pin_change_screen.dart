import 'package:flutter/material.dart';
import 'package:purenote/core/services/auth_service.dart';
import 'package:purenote/core/theme/app_colors.dart';
import 'package:purenote/l10n/app_localizations.dart';

class PinChangeScreen extends StatefulWidget {
  const PinChangeScreen({super.key});

  @override
  State<PinChangeScreen> createState() => _PinChangeScreenState();
}

class _PinChangeScreenState extends State<PinChangeScreen> {
  final _auth = AuthService();
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  int _step = 0; // 0: old PIN, 1: new PIN, 2: confirm
  String? _newPin;
  String? _errorKey;

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  String get _pin => _controllers.map((c) => c.text).join();

  void _onDigit(int digit) {
    setState(() => _errorKey = null);
    for (var i = 0; i < 6; i++) {
      if (_controllers[i].text.isEmpty) {
        _controllers[i].text = digit.toString();
        if (i < 5) _focusNodes[i + 1].requestFocus();
        break;
      }
    }
  }

  void _onDelete() {
    for (var i = 5; i >= 0; i--) {
      if (_controllers[i].text.isNotEmpty) {
        _controllers[i].clear();
        if (i > 0) _focusNodes[i - 1].requestFocus();
        break;
      }
    }
  }

  Future<void> _onSubmit() async {
    final pin = _pin;
    if (pin.length < 6) return;

    if (_step == 0) {
      if (await _auth.verifyPin(pin)) {
        setState(() {
          _step = 1;
          _clearInput();
        });
      } else {
        setState(() {
          _errorKey = 'wrongPin';
          _clearInput();
        });
      }
    } else if (_step == 1) {
      _newPin = pin;
      setState(() {
        _step = 2;
        _clearInput();
      });
    } else {
      if (pin == _newPin) {
        await _auth.setPin(pin);
        if (mounted) Navigator.of(context).pop();
      } else {
        setState(() {
          _errorKey = 'pinsDoNotMatch';
          _step = 1;
          _newPin = null;
          _clearInput();
        });
      }
    }
  }

  void _clearInput() {
    for (final c in _controllers) { c.clear(); }
    _focusNodes[0].requestFocus();
  }

  String _title(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (_step) {
      case 0: return l10n.enterCurrentPin;
      case 1: return l10n.enterNewPin;
      case 2: return l10n.confirmNewPin;
      default: return l10n.changePin;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.changePin)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_title(context), style: Theme.of(context).textTheme.titleMedium),
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
                    color: _controllers[i].text.isNotEmpty
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    _controllers[i].text.isNotEmpty ? '●' : '',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
            ),
          ),
          if (_errorKey != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorKey == 'wrongPin'
                  ? AppLocalizations.of(context)!.wrongPin
                  : AppLocalizations.of(context)!.pinsDoNotMatch,
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
          onPressed: _controllers.every((c) => c.text.isNotEmpty) ? _onSubmit : null,
          child: Text([AppLocalizations.of(context)!.verify, AppLocalizations.of(context)!.continueBtn, AppLocalizations.of(context)!.confirm][_step]),
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
