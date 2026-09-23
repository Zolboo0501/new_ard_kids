import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_text.dart';
import 'date_range_sheet.dart';
import 'ui.dart';

/// The date filter above a transaction list: a plain-words title
/// ("Энэ сар", "8-р сар"), how many entries fall in the range, and the start
/// and end days in full. Tapping it opens [showDateRangeSheet] and reports
/// the new range through [onChanged].
///
/// The list owns the range (start it at [thisMonthRange]) and filters its
/// entries with [rangeContains].
class DateRangeFilterBar extends StatelessWidget {
  const DateRangeFilterBar({
    super.key,
    required this.range,
    required this.count,
    required this.onChanged,
    this.firstDate,
  });

  final DateTimeRange range;

  /// How many entries fall inside [range].
  final int count;
  final ValueChanged<DateTimeRange> onChanged;

  /// Earliest day the calendar allows; see [DateRangeSheet.firstDate].
  final DateTime? firstDate;

  Future<void> _open(BuildContext context) async {
    final picked = await showDateRangeSheet(
      context,
      initial: range,
      firstDate: firstDate,
    );
    if (picked != null && !sameRange(picked, range)) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final title = describeRange(range);
    final days = formatRangeFriendly(range);
    return Semantics(
      button: true,
      label: '$title, $days, $count гүйлгээ. Хугацаа өөрчлөх',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: withHaptic(() => _open(context)),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.sky100),
            boxShadow: [
              BoxShadow(
                color: AppColors.sky500.withValues(alpha: 0.08),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.sky50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      size: 22,
                      color: AppColors.sky600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ExcludeSemantics(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            title,
                            size: 14,
                            weight: FontWeight.w700,
                            color: AppColors.slate800,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          AppText(
                            count == 0 ? 'Гүйлгээ алга' : '$count гүйлгээ',
                            size: 11,
                            weight: FontWeight.w500,
                            color: AppColors.slate500,
                          ),
                        ],
                      ),
                    ),
                  ),
                  ExcludeSemantics(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 7, 8, 7),
                      decoration: BoxDecoration(
                        color: AppColors.sky50,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppText(
                            'Өөрчлөх',
                            size: 12,
                            weight: FontWeight.w700,
                            color: AppColors.sky700,
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: AppColors.sky600,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // The days get their own full-width strip so they never cut
              // off behind the buttons.
              ExcludeSemantics(child: _RangeDates(range: range)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Start → end, each as "6-р сарын 23" with its year and role above.
class _RangeDates extends StatelessWidget {
  const _RangeDates({required this.range});

  final DateTimeRange range;

  @override
  Widget build(BuildContext context) {
    Widget end(String role, DateTime d, CrossAxisAlignment align) => Expanded(
      child: Column(
        crossAxisAlignment: align,
        children: [
          AppText(
            '$role · ${d.year} он',
            size: 10,
            weight: FontWeight.w600,
            color: AppColors.slate400,
          ),
          const SizedBox(height: 2),
          AppText(
            '${d.month}-р сарын ${d.day}',
            size: 13,
            weight: FontWeight.w700,
            color: AppColors.slate800,
            textAlign: align == CrossAxisAlignment.end
                ? TextAlign.end
                : TextAlign.start,
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.sky50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          end('Эхлэх', range.start, CrossAxisAlignment.start),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: AppColors.sky500,
            ),
          ),
          end('Дуусах', range.end, CrossAxisAlignment.end),
        ],
      ),
    );
  }
}

/// Stands in for a transaction list when nothing falls in the picked range.
class DateRangeEmpty extends StatelessWidget {
  const DateRangeEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(vertical: 24),
      borderColor: AppColors.slate100,
      child: AppText(
        'Энэ хугацаанд гүйлгээ алга',
        size: 12,
        weight: FontWeight.w600,
        color: AppColors.slate400,
        textAlign: TextAlign.center,
      ),
    );
  }
}
