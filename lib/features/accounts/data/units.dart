/// Ард койн and reward points are not money, so they are counted in their
/// own units rather than with `₮`: `50,000 койн`, `+5,000 оноо`.
library;

/// The coin unit. 1 койн is worth ₮1.
const coinUnit = 'койн';

/// The reward point unit. 1 оноо is worth ₮1 when turned into money.
const pointUnit = 'оноо';

/// [amount] with thousands separators and no currency sign, e.g.
/// `formatCount(50000)` → `50,000`, `formatCount(-1500, sign: true)` →
/// `-1,500`.
String formatCount(num amount, {bool sign = false}) {
  final negative = amount < 0;
  final digits = amount.abs().round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return '${negative ? '-' : (sign ? '+' : '')}$buf';
}

/// [amount] followed by its [unit]: `formatUnits(5000, pointUnit)` →
/// `5,000 оноо`.
String formatUnits(num amount, String unit, {bool sign = false}) =>
    '${formatCount(amount, sign: sign)} $unit';
