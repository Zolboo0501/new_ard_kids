/// A bank an account can be in: its name, a short label for tight rows,
/// its logo and the 4-digit bank code that starts its IBAN's BBAN.
class Bank {
  const Bank({
    required this.name,
    required this.short,
    required this.logo,
    required this.code,
  });

  final String name;
  final String short;

  /// A square logo on white (`assets/images/banks/`).
  final String logo;
  final String code;

  static const all = [
    Bank(
      name: 'Хаан банк',
      short: 'Хаан',
      logo: 'assets/images/banks/khan.png',
      code: '0005',
    ),
    Bank(
      name: 'Голомт банк',
      short: 'Голомт',
      logo: 'assets/images/banks/golomt.png',
      code: '0015',
    ),
    Bank(
      name: 'ХХБ',
      short: 'ХХБ',
      logo: 'assets/images/banks/tdb.png',
      code: '0004',
    ),
    Bank(
      name: 'Төрийн банк',
      short: 'Төрийн',
      logo: 'assets/images/banks/state.png',
      code: '0034',
    ),
    Bank(
      name: 'Хас банк',
      short: 'Хас',
      logo: 'assets/images/banks/xac.png',
      code: '0032',
    ),
  ];
}
