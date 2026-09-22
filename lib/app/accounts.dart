/// The kid's accounts as IBANs, shared by every screen that shows one so the
/// numbers agree. Mock data: the bank code `0460` stands in for Ard's until
/// the accounts come from the API.
///
/// A Mongolian IBAN is 20 characters: `MN`, two check digits, a 4-digit bank
/// code and a 12-digit account number. Each one here passes the mod-97 check.
abstract final class Accounts {
  /// Халаасны үндсэн данс, the everyday account.
  static const main = 'MN320460005049821900';
  static const savings = 'MN050460005049821901';
  static const stocks = 'MN750460005049821902';
  static const rewards = 'MN480460005049821903';
  static const coin = 'MN210460005049821904';

  /// The linked Хаан банк account (bank code 0005) money is sent from.
  static const khanBank = 'MN630005005049013384';
}

/// The IBAN with only the country, check digits and last four showing, for
/// when the eye button hides it: `MN32 •••• •••• •••• 1900`.
String maskIban(String iban) {
  final compact = iban.replaceAll(' ', '');
  return '${compact.substring(0, 4)} •••• •••• •••• '
      '${compact.substring(compact.length - 4)}';
}

/// Groups an IBAN into blocks of four, the way it is printed on statements:
/// `MN320460005049821900` → `MN32 0460 0050 4982 1900`. Copy the ungrouped
/// form to the clipboard.
String formatIban(String iban) {
  final compact = iban.replaceAll(' ', '');
  final buf = StringBuffer();
  for (var i = 0; i < compact.length; i += 4) {
    if (i > 0) buf.write(' ');
    buf.write(compact.substring(i, (i + 4).clamp(0, compact.length)));
  }
  return buf.toString();
}
