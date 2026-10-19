import 'package:flutter/foundation.dart';

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

/// The teen's money requests, newest first. Shared, so a request sent on
/// "Мөнгө хүсэх" is on "Хүсэлтийн жагсаалт" straight away, as pending.
// TODO: load the requests from, and send them to, the backend.
abstract final class MoneyRequests {
  static final List<MoneyRequest> all = [..._mock];

  static void add(MoneyRequest request) => all.insert(0, request);

  static void remove(MoneyRequest request) => all.remove(request);

  /// Back to the mock list; tests share this state.
  @visibleForTesting
  static void reset() => all
    ..clear()
    ..addAll(_mock);

  static const _mock = [
    MoneyRequest(
      from: 'Ээж',
      when: 'Өнөөдөр, 14:20',
      title: 'Сургуулийн аялал',
      amount: 20000,
      glyph: LineGlyph.bus,
      status: RequestStatus.pending,
    ),
    MoneyRequest(
      from: 'Аав',
      when: 'Өчигдөр, 18:45',
      title: 'Чихэвч',
      amount: 45000,
      glyph: LineGlyph.bag,
      status: RequestStatus.approved,
      reply: 'Аав: "Хадгалж хэрэглээрэй"',
    ),
    MoneyRequest(
      from: 'Ээж',
      when: '2026.09.09',
      title: 'Долоо хоногийн өдрийн хоол',
      amount: 10000,
      glyph: LineGlyph.food,
      status: RequestStatus.approved,
    ),
    MoneyRequest(
      from: 'Аав',
      when: '2026.09.05',
      title: 'Шинэ пүүз',
      amount: 80000,
      glyph: LineGlyph.shirt,
      status: RequestStatus.declined,
      reason: 'Энэ сарын төсөв хүрэхгүй',
    ),
  ];
}
