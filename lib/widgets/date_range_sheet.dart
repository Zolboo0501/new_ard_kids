import 'dart:math' as math;

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_text.dart';
import 'ui.dart';

/// Today with the time stripped.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// The range from [months] months before today up to today, e.g. 06.23–09.23.
DateTimeRange lastMonthsRange(int months, {DateTime? now}) {
  final today = dateOnly(now ?? DateTime.now());
  final m = DateTime(today.year, today.month - months);
  // Clamp so 05.31 minus 3 months is 02.28, not 03.03.
  final lastDay = DateTime(m.year, m.month + 1, 0).day;
  return DateTimeRange(
    start: DateTime(m.year, m.month, math.min(today.day, lastDay)),
    end: today,
  );
}

/// `Өнөөдөр`, `Өчигдөр`, else `09.10` (with the year when it isn't this
/// year's): how a list row says when it happened.
String dayLabel(DateTime date, {DateTime? now}) {
  final today = dateOnly(now ?? DateTime.now());
  final d = dateOnly(date);
  if (d == today) return 'Өнөөдөр';
  if (d == DateTime(today.year, today.month, today.day - 1)) return 'Өчигдөр';
  return formatDay(d, year: d.year != today.year);
}

/// The day [days] days before today, for mock data that should stay recent.
DateTime daysAgo(int days, {DateTime? now}) {
  final t = now ?? DateTime.now();
  return DateTime(t.year, t.month, t.day - days);
}

/// From the 1st of this month up to today: the default, unfiltered range.
DateTimeRange thisMonthRange({DateTime? now}) {
  final today = dateOnly(now ?? DateTime.now());
  return DateTimeRange(start: DateTime(today.year, today.month), end: today);
}

/// Whether [a] and [b] cover the same days.
bool sameRange(DateTimeRange a, DateTimeRange b) =>
    dateOnly(a.start) == dateOnly(b.start) &&
    dateOnly(a.end) == dateOnly(b.end);

/// Whether [date] falls on a day inside [range] (both ends inclusive).
bool rangeContains(DateTimeRange range, DateTime date) {
  final d = dateOnly(date);
  return !d.isBefore(dateOnly(range.start)) && !d.isAfter(dateOnly(range.end));
}

/// `2026.09.23`, or `09.23` with [year] false.
String formatDay(DateTime d, {bool year = true}) {
  String two(int v) => v.toString().padLeft(2, '0');
  final md = '${two(d.month)}.${two(d.day)}';
  return year ? '${d.year}.$md' : md;
}

/// `2026.06.23 – 09.23`: the year is written once when both ends share it.
String formatRange(DateTimeRange r) =>
    '${formatDay(r.start)} – '
    '${formatDay(r.end, year: r.start.year != r.end.year)}';

/// Reads like speech: `8-р сарын 1 – 31`, `6-р сарын 23 – 9-р сарын 23`,
/// and with years only when the range crosses one.
String formatRangeFriendly(DateTimeRange r) {
  final s = r.start, e = r.end;
  if (s.year != e.year) return formatRange(r);
  if (s.month == e.month) {
    return s.day == e.day
        ? '${s.month}-р сарын ${s.day}'
        : '${s.month}-р сарын ${s.day} – ${e.day}';
  }
  return '${s.month}-р сарын ${s.day} – ${e.month}-р сарын ${e.day}';
}

/// A short name for [r]: `Сүүлийн 2 сар`, `Энэ сар`, `8-р сар` for a whole
/// month, or `Сонгосон хугацаа` for anything else.
String describeRange(DateTimeRange r, {DateTime? now}) {
  final today = dateOnly(now ?? DateTime.now());
  final s = dateOnly(r.start), e = dateOnly(r.end);
  for (final n in const [1, 2, 3]) {
    final m = lastMonthsRange(n, now: today);
    if (s == m.start && e == m.end) return 'Сүүлийн $n сар';
  }
  if (sameRange(r, thisMonthRange(now: today))) return 'Энэ сар';
  final monthEnd = DateTime(s.year, s.month + 1, 0);
  if (s.day == 1 && e == monthEnd) {
    return s.year == today.year
        ? '${s.month}-р сар'
        : '${s.year} оны ${s.month}-р сар';
  }
  if (s == e) return s == today ? 'Өнөөдөр' : 'Нэг өдөр';
  return 'Сонгосон хугацаа';
}

/// Opens a [DateRangeSheet] and resolves the picked range, or `null` when
/// the kid closes it.
Future<DateTimeRange?> showDateRangeSheet(
  BuildContext context, {
  required DateTimeRange initial,
  DateTime? firstDate,
  String title = 'Хугацаагаар шүүх',
}) {
  return showModalBottomSheet<DateTimeRange>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) =>
        DateRangeSheet(initial: initial, firstDate: firstDate, title: title),
  );
}

/// Bottom-sheet range picker: shortcut chips (this month, the last 2 and 3 months)
/// over a Mongolian-labelled calendar. Days after today can't be picked.
class DateRangeSheet extends StatefulWidget {
  const DateRangeSheet({
    super.key,
    required this.initial,
    this.firstDate,
    this.title = 'Хугацаагаар шүүх',
  });

  final DateTimeRange initial;

  /// Earliest selectable day; defaults to one year before today.
  final DateTime? firstDate;
  final String title;

  @override
  State<DateRangeSheet> createState() => _DateRangeSheetState();
}

class _DateRangeSheetState extends State<DateRangeSheet> {
  static const _weekdays = ['Ня', 'Да', 'Мя', 'Лх', 'Пү', 'Ба', 'Бя'];

  late final DateTime _today = dateOnly(DateTime.now());
  late List<DateTime?> _value = [widget.initial.start, widget.initial.end];

  /// Label and range of each shortcut chip.
  late final _presets = [
    ('Энэ сар', thisMonthRange(now: _today)),
    for (final n in const [2, 3])
      ('Сүүлийн $n сар', lastMonthsRange(n, now: _today)),
  ];

  DateTimeRange? get _picked {
    if (_value.length < 2 || _value[0] == null || _value[1] == null) {
      return null;
    }
    return DateTimeRange(start: _value[0]!, end: _value[1]!);
  }

  bool _isPreset(DateTimeRange r) {
    final p = _picked;
    return p != null && sameRange(p, r);
  }

  /// A filter is on when the applied range or the one being picked isn't
  /// this month; only then is there something for Цэвэрлэх to clear.
  bool get _filtered {
    final month = thisMonthRange(now: _today);
    final p = _picked;
    return !sameRange(widget.initial, month) ||
        (_value.firstOrNull != null && (p == null || !sameRange(p, month)));
  }

  @override
  Widget build(BuildContext context) {
    final picked = _picked;
    final firstDate =
        widget.firstDate ?? DateTime(_today.year - 1, _today.month, _today.day);
    final dayStyle = inter(
      size: 13,
      weight: FontWeight.w600,
      color: AppColors.slate700,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slate200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppText(
              widget.title,
              size: 16,
              weight: FontWeight.w700,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              children: [
                for (final (label, range) in _presets)
                  FilterChipPill(
                    label: label,
                    selected: _isPreset(range),
                    onTap: () =>
                        setState(() => _value = [range.start, range.end]),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            CalendarDatePicker2(
              // Re-key on preset taps so the calendar jumps to the new start.
              key: ValueKey(_value.firstOrNull),
              value: _value,
              displayedMonthDate: _value.firstOrNull,
              onValueChanged: (v) => setState(() => _value = v),
              config: CalendarDatePicker2Config(
                calendarType: CalendarDatePicker2Type.range,
                firstDate: firstDate,
                lastDate: _today,
                currentDate: _today,
                firstDayOfWeek: 1,
                weekdayLabels: _weekdays,
                weekdayLabelTextStyle: inter(
                  size: 11,
                  weight: FontWeight.w700,
                  color: AppColors.slate400,
                ),
                // One "2026 оны 9-р сар" label instead of separate month and
                // year pickers; the arrows page between months.
                disableModePicker: true,
                disableMonthPicker: true,
                centerAlignModePicker: true,
                modePickerTextHandler: ({required monthDate, isMonthPicker}) =>
                    '${monthDate.year} оны ${monthDate.month}-р сар',
                controlsTextStyle: inter(
                  size: 14,
                  weight: FontWeight.w700,
                  color: AppColors.slate800,
                ),
                lastMonthIcon: Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.sky600,
                ),
                nextMonthIcon: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.sky600,
                ),
                dayTextStyle: dayStyle,
                todayTextStyle: dayStyle.copyWith(color: AppColors.sky600),
                disabledDayTextStyle: dayStyle.copyWith(
                  color: AppColors.slate200,
                ),
                selectedDayTextStyle: dayStyle.copyWith(color: Colors.white),
                selectedRangeDayTextStyle: dayStyle.copyWith(
                  color: AppColors.sky800,
                ),
                selectedDayHighlightColor: AppColors.sky500,
                selectedRangeHighlightColor: AppColors.sky100,
                dayBorderRadius: BorderRadius.circular(12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppText(
                picked == null
                    ? 'Дуусах өдрөө сонгоно уу'
                    : formatRangeFriendly(picked),
                size: 12,
                weight: FontWeight.w600,
                color: picked == null ? AppColors.slate400 : AppColors.slate600,
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              children: [
                // Drops the filter: back to this month and closes the sheet.
                if (_filtered) ...[
                  Expanded(
                    child: SoftButton(
                      label: 'Цэвэрлэх',
                      icon: Icons.restart_alt_rounded,
                      height: 52,
                      onPressed: () => Navigator.of(
                        context,
                      ).pop(thisMonthRange(now: _today)),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: PrimaryButton(
                    label: 'Шүүх',
                    onPressed: picked == null
                        ? null
                        : () => Navigator.of(context).pop(
                            DateTimeRange(
                              start: dateOnly(picked.start),
                              end: dateOnly(picked.end),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
