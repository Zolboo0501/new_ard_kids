/// Projected savings with monthly compounding at [annualRate].
({int total, int deposited, int interest}) projectSavings({
  required int initial,
  required int monthly,
  required int months,
  double annualRate = 0.135,
}) {
  final r = annualRate / 12;
  var balance = initial.toDouble();
  for (var m = 0; m < months; m++) {
    balance = balance * (1 + r) + monthly;
  }
  final deposited = initial + monthly * months;
  final total = balance.round();
  return (total: total, deposited: deposited, interest: total - deposited);
}
