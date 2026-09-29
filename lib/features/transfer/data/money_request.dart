import '../../../widgets/ui.dart';

enum RequestStatus { pending, approved, declined }

class MoneyRequest {
  const MoneyRequest({
    required this.from,
    required this.when,
    required this.title,
    required this.amount,
    required this.glyph,
    required this.status,
    this.reply,
    this.reason,
  });

  final String from;
  final String when;
  final String title;
  final int amount;
  final RequestStatus status;

  /// The request's category, drawn in the row's tile.
  final LineGlyph glyph;
  final String? reply;
  final String? reason;

  /// Genitive / dative forms for the parent names used in copy.
  String get fromGenitive => from == 'Аав' ? 'Аавын' : '$fromийн';
  String get fromDative => from == 'Ээж' ? 'Ээжид' : '$fromд';
}
