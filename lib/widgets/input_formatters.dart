import 'package:flutter/services.dart';

import '../app/accounts.dart';
import 'ui.dart';

/// Inserts thousands separators while typing (`15000` → `15,000`).
class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return const TextEditingValue();
    final text = formatMnt(int.parse(digits)).substring(1);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Keeps an IBAN as `MN` plus up to 18 digits in blocks of four
/// (`MN24 0005 0050 4982 1902`). Typing a digit first adds the `MN`, and a
/// pasted IBAN with or without spaces lands the same way.
class IbanFormatter extends TextInputFormatter {
  static String _digits(String text) {
    final compact = text.toUpperCase().replaceAll(RegExp(r'[^0-9A-Z]'), '');
    final body = compact.startsWith('MN') ? compact.substring(2) : compact;
    return body.replaceAll(RegExp(r'\D'), '');
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final oldDigits = _digits(oldValue.text);
    var digits = _digits(newValue.text);
    // Deleting a separator space removes the digit before it.
    if (newValue.text.length < oldValue.text.length &&
        digits == oldDigits &&
        digits.isNotEmpty) {
      digits = digits.substring(0, digits.length - 1);
    }
    if (digits.isEmpty) return const TextEditingValue();
    if (digits.length > 18) digits = digits.substring(0, 18);
    final text = formatIban('MN$digits');
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Groups digits with spaces (`[4, 4, 2]` → `5049 8219 02`).
class DigitGroupFormatter extends TextInputFormatter {
  DigitGroupFormatter(this.groups);

  final List<int> groups;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final max = groups.fold(0, (a, b) => a + b);
    final oldDigits = oldValue.text.replaceAll(RegExp(r'\D'), '');
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    // Deleting a separator space removes the digit before it.
    if (newValue.text.length < oldValue.text.length &&
        digits == oldDigits &&
        digits.isNotEmpty) {
      digits = digits.substring(0, digits.length - 1);
    }
    if (digits.length > max) digits = digits.substring(0, max);
    final buf = StringBuffer();
    var i = 0;
    for (final g in groups) {
      if (i >= digits.length) break;
      if (buf.isNotEmpty) buf.write(' ');
      final end = (i + g).clamp(0, digits.length);
      buf.write(digits.substring(i, end));
      i = end;
    }
    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
