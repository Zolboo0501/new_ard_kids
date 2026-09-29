/// Someone the teen has sent money to before: a saved account, and the
/// phone number it is reachable by. Mock data until the API has contacts.
class TransferContact {
  const TransferContact({
    required this.name,
    required this.holder,
    required this.initials,
    required this.bank,
    required this.account,
    required this.phone,
  });

  /// How the teen saved them ("Ээж", "Анар (Дүү)").
  final String name;

  /// The account holder's registered name, confirmed by the bank.
  final String holder;
  final String initials;
  final String bank;

  /// 10-digit account number, grouped `5049 8219 02`.
  final String account;

  /// 8-digit phone number, grouped `9911 2345`.
  final String phone;

  String get maskedPhone => '${phone.substring(0, 4)}****';

  static const saved = [
    TransferContact(
      name: 'Анар (Дүү)',
      holder: 'Б. Анар',
      initials: 'БА',
      bank: 'Хаан банк',
      account: '5049 8219 02',
      phone: '8822 4411',
    ),
    TransferContact(
      name: 'Мишээл',
      holder: 'Г. Мишээл',
      initials: 'ГМ',
      bank: 'Голомт банк',
      account: '5049 7712 45',
      phone: '8810 5566',
    ),
    TransferContact(
      name: 'Аав',
      holder: 'Д. Батбаяр',
      initials: 'ДБ',
      bank: 'Хаан банк',
      account: '5049 1102 33',
      phone: '9909 1188',
    ),
    TransferContact(
      name: 'Ээж',
      holder: 'Ц. Сарантуяа',
      initials: 'ЦС',
      bank: 'Хаан банк',
      account: '5049 3321 08',
      phone: '9911 2345',
    ),
  ];
}
