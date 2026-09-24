enum RequestStatus { pending, approved, declined }

class MoneyRequest {
  MoneyRequest({
    required this.from,
    required this.when,
    required this.title,
    required this.amount,
    required String Function() sticker,
    required this.status,
    this.tag,
    this.reply,
    this.reason,
  }) : _sticker = sticker;

  final String from;
  final String when;
  final String title;
  final int amount;
  final RequestStatus status;

  /// Read on each build, so the picture follows the chosen companion while
  /// the list (kept in state, since requests can be cancelled) stays put.
  final String Function() _sticker;
  String get asset => _sticker();
  final String? tag;
  final String? reply;
  final String? reason;

  /// Genitive / dative forms for the parent names used in copy.
  String get fromGenitive => from == 'Аав' ? 'Аавын' : '$fromийн';
  String get fromDative => from == 'Ээж' ? 'Ээжид' : '$fromд';
}
