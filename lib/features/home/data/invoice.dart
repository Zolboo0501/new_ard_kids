import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/date_range_sheet.dart';
import '../../../widgets/ui.dart';

/// Where an invoice stands: waiting on the parent, approved and ready to
/// pay, or paid.
enum InvoiceStatus { pending, approved, paid }

/// One invoice or money request, shared by Home's Нэхэмжлэх tab and
/// [InvoiceHistoryScreen] so both show the same list.
class Invoice {
  const Invoice({
    required this.title,
    required this.mascot,
    required this.amount,
    required this.date,
    required this.status,
    this.note,
  });

  final String title;
  final String mascot;
  final int amount;
  final DateTime date;
  final InvoiceStatus status;

  /// The line above the open invoice's button ("Ээжид мэдэгдэл илгээх").
  final String? note;

  bool get open => status != InvoiceStatus.paid;

  String get statusLabel => switch (status) {
    InvoiceStatus.pending => 'Хүлээгдэж буй',
    InvoiceStatus.approved => 'Зөвшөөрсөн / Төлөх',
    InvoiceStatus.paid => 'Батлагдсан',
  };

  Color get statusColor => switch (status) {
    InvoiceStatus.pending => AppColors.amber500,
    InvoiceStatus.approved => AppColors.emerald500,
    InvoiceStatus.paid => AppColors.sky500,
  };
}

/// Mock invoices, newest first and dated relative to today, so Home's
/// recent ones stay recent and the history reaches back three months.
// TODO: load from the invoices API.

List<Invoice> get mockInvoices => [
  Invoice(
    title: 'Ээжээс халаасны мөнгө',
    mascot: Mascots.catHeart,
    amount: 20000,
    date: daysAgo(0),
    status: InvoiceStatus.pending,
    note: 'Ээжид мэдэгдэл илгээх',
  ),
  Invoice(
    title: 'Ном, дэвтэр авах',
    mascot: Mascots.bearBooks,
    amount: 18500,
    date: daysAgo(1),
    status: InvoiceStatus.approved,
    note: 'Дэлгүүрийн нэхэмжлэх',
  ),
  Invoice(
    title: 'Ааваас даалгаврын урамшуулал',
    mascot: Mascots.owlBook,
    amount: 10000,
    date: _at(5, 18, 20),
    status: InvoiceStatus.paid,
  ),
  Invoice(
    title: 'Дугуй засварын төлбөр',
    mascot: Mascots.hedgehogPiggy,
    amount: 12000,
    date: _at(16, 12, 5),
    status: InvoiceStatus.paid,
  ),
  Invoice(
    title: 'Сургуулийн аялалын төлбөр',
    mascot: Mascots.bearBooks,
    amount: 25000,
    date: _at(35, 9, 40),
    status: InvoiceStatus.paid,
  ),
  Invoice(
    title: 'Тоглоомын дэлгүүрийн нэхэмжлэх',
    mascot: Mascots.puppyGamepad,
    amount: 15000,
    date: _at(41, 16, 15),
    status: InvoiceStatus.paid,
  ),
  Invoice(
    title: 'Хөгжмийн дугуйлангийн төлбөр',
    mascot: Mascots.owlMedal,
    amount: 30000,
    date: _at(63, 19, 0),
    status: InvoiceStatus.paid,
  ),
  Invoice(
    title: 'Эмээгээс төрсөн өдрийн бэлэг',
    mascot: Mascots.bearConfetti,
    amount: 50000,
    date: _at(88, 11, 30),
    status: InvoiceStatus.paid,
  ),
];

/// [days] days ago at [hour]:[minute], for when a mock invoice was paid.
DateTime _at(int days, int hour, int minute) {
  final d = daysAgo(days);
  return DateTime(d.year, d.month, d.day, hour, minute);
}

/// When a paid invoice went through, down to the minute: `Өнөөдөр, 14:30`,
/// `9-р сарын 18, 14:30`, or with the year when it isn't this year's.
String paidLabel(DateTime d) {
  final today = dateOnly(DateTime.now());
  final day = dateOnly(d);
  final time =
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  final date = switch (day) {
    _ when day == today => 'Өнөөдөр',
    _ when day == DateTime(today.year, today.month, today.day - 1) => 'Өчигдөр',
    _ when day.year == today.year => '${day.month}-р сарын ${day.day}',
    _ => formatDay(day),
  };
  return '$date, $time';
}

/// Label and test for each status chip (Бүгд / Хүлээгдэж буй / Төлөгдсөн).
const invoiceFilters = [
  ('Бүгд', _any),
  ('Хүлээгдэж буй', _isOpen),
  ('Төлөгдсөн', _isPaid),
];

bool _any(Invoice _) => true;

bool _isOpen(Invoice i) => i.open;

bool _isPaid(Invoice i) => !i.open;
