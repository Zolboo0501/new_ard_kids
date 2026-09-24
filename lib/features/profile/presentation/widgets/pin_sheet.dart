import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/numeric_keypad.dart';

/// Two-step PIN entry: new PIN then confirmation.
class PinSheet extends StatefulWidget {
  const PinSheet({super.key});

  @override
  State<PinSheet> createState() => _PinSheetState();
}

class _PinSheetState extends State<PinSheet> {
  String _first = '';
  String _pin = '';
  bool _mismatch = false;

  bool get _confirming => _first.isNotEmpty;

  void _digit(String d) {
    if (_pin.length == 4) return;
    setState(() {
      _mismatch = false;
      _pin += d;
    });
    if (_pin.length < 4) return;
    if (!_confirming) {
      setState(() {
        _first = _pin;
        _pin = '';
      });
    } else if (_pin == _first) {
      // TODO: send the new PIN with the parent's verification code.
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _mismatch = true;
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.slate200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 18),
            AppText(
              _confirming ? 'ПИН кодоо давтана уу' : 'Шинэ ПИН код оруулна уу',
              size: 16,
              weight: FontWeight.w700,
            ),
            const SizedBox(height: 6),
            AppText(
              _mismatch
                  ? 'Код таарахгүй байна. Дахин оролдоно уу.'
                  : '4 оронтой нууц код',
              size: 12,
              color: _mismatch ? AppColors.rose500 : AppColors.slate400,
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 4; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _pin.length
                          ? AppColors.sky500
                          : AppColors.slate100,
                      border: Border.all(
                        color: _mismatch
                            ? AppColors.rose400
                            : i < _pin.length
                            ? AppColors.sky500
                            : AppColors.slate200,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            NumericKeypad(
              style: const KeypadStyle(
                keyHeight: 52,
                radius: 16,
                gap: 10,
                fontSize: 20,
                border: AppColors.slate100,
              ),
              onDigit: _digit,
              onBackspace: () {
                if (_pin.isEmpty) return;
                setState(() => _pin = _pin.substring(0, _pin.length - 1));
              },
            ),
          ],
        ),
      ),
    );
  }
}
