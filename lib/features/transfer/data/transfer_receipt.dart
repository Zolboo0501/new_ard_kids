/// Result of a completed transfer shown on the receipt screen.
class TransferReceipt {
  const TransferReceipt({
    required this.amount,
    required this.recipient,
    required this.bank,
    required this.destination,
    required this.note,
    required this.balanceAfter,
    required this.time,
  });

  final int amount;
  final String recipient;
  final String bank;
  final String destination;
  final String note;
  final int balanceAfter;
  final DateTime time;
}
