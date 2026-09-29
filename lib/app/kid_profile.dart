/// The signed-in teen, their balances and limits: mock data shared by every
/// screen so the name, the numbers and the limits agree everywhere. Comes
/// from the API once there is one.
abstract final class Kid {
  static const firstName = 'Тэмүүлэн';
  static const lastName = 'Батбаяр';

  /// Surname initial first, the way Mongolian names are shortened.
  static const shortName = 'Б. Тэмүүлэн';
  static const fullName = 'Батбаяр Тэмүүлэн';

  /// As embossed on the card, in Latin capitals.
  static const cardName = 'TEMUULEN BATBAYAR';
  static const handle = '@temuulen';
  static const initials = 'ТБ';
  static const phone = '8811 2233';
  static const birthday = '2012.03.14';
  static const school = '12-р сургууль';
  static const grade = '8-р анги';
}

/// Account balances in ₮. Ард койн and points are not money, so they have
/// their own units: 1 койн is worth ₮1, points are just points.
abstract final class Balances {
  static const main = 567930;
  static const savings = 1280000;
  static const stocks = 142500;
  static const rewards = 35000;
  static const coins = 50000;
}

/// Spending limits set with the parent. Linking a parent raises the daily
/// limit five times, from [unlinkedDaily] to [dailyTransfer].
abstract final class Limits {
  static const dailyTransfer = 100000;
  static const unlinkedDaily = 20000;

  /// Already sent today, so [leftToday] is what a transfer may still use.
  static const spentToday = 35000;
  static const leftToday = dailyTransfer - spentToday;

  static const monthlyCard = 300000;

  /// What both friends get when an invite code is used.
  static const inviteBonus = 5000;
}
