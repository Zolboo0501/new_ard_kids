/// An account the search sheet can find.
class KnownAccount {
  const KnownAccount({
    required this.holder,
    required this.bank,
    required this.iban,
  });

  final String holder;
  final String bank;

  /// Grouped for display: `MN24 0005 0050 4982 1902`.
  final String iban;
}
