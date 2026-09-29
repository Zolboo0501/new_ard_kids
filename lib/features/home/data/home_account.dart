import '../../../app/accounts.dart';
import '../../../app/avatar.dart';

/// One of the kid's accounts as Home's carousel shows it.
class HomeAccount {
  const HomeAccount({
    required this.label,
    required this.kind,
    required this.note,
    required this.iban,
    required this.balance,
    required this.mascot,
  });

  final String label;

  /// The short product name in the card's badge ("Данс", "Шагнал"). Worded
  /// apart from the account rows under the carousel ("Хадгаламж",
  /// "Урамшуулал"), so the two don't read as the same button.
  final String kind;

  /// What the account is for, under the [label].
  final String note;
  final String iban;
  final int balance;

  /// The chosen companion's image for this account.
  final String mascot;
}

/// The accounts in Home's carousel, each with [avatar]'s image for it. Mock
/// balances until they come from the API.
List<HomeAccount> homeAccounts(AppAvatar avatar) => [
  HomeAccount(
    label: 'Харилцах данс',
    kind: 'Данс',
    note: 'Өдөр тутмын зарлага',
    iban: Accounts.main,
    balance: 567930,
    mascot: avatar.pick,
  ),
  HomeAccount(
    label: 'Хадгаламж данс',
    kind: 'Хуримтлал',
    note: 'Зорилгодоо хуримтлуулах',
    iban: Accounts.savings,
    balance: 1280000,
    mascot: avatar.savings,
  ),
  HomeAccount(
    label: 'Урамшууллын данс',
    kind: 'Шагнал',
    note: 'Даалгаврын шагнал',
    iban: Accounts.rewards,
    balance: 35000,
    mascot: avatar.rewards,
  ),
  HomeAccount(
    label: 'Ард койн данс',
    kind: 'Ард койн',
    note: 'Цуглуулсан койн',
    iban: Accounts.coin,
    balance: 50000,
    mascot: Stickers.coins,
  ),
];

/// The only account a kid has before a parent is linked: the main one, in
/// limited mode.
HomeAccount limitedHomeAccount(AppAvatar avatar) => HomeAccount(
  label: 'Харилцах данс',
  kind: 'Данс',
  note: 'Хязгаарлагдмал горим',
  iban: Accounts.main,
  balance: 20000,
  mascot: avatar.pick,
);
