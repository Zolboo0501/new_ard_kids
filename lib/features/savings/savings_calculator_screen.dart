import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui.dart';
import '../../widgets/app_text.dart';

/// Projected savings with monthly compounding at [annualRate].
({int total, int deposited, int interest}) projectSavings({
  required int initial,
  required int monthly,
  required int months,
  double annualRate = 0.135,
}) {
  final r = annualRate / 12;
  var balance = initial.toDouble();
  for (var m = 0; m < months; m++) {
    balance = balance * (1 + r) + monthly;
  }
  final deposited = initial + monthly * months;
  final total = balance.round();
  return (total: total, deposited: deposited, interest: total - deposited);
}

/// "Хадгаламжийн тооцоолуур": interest calculator.
class SavingsCalculatorScreen extends StatefulWidget {
  const SavingsCalculatorScreen({super.key});

  @override
  State<SavingsCalculatorScreen> createState() =>
      _SavingsCalculatorScreenState();
}

class _SavingsCalculatorScreenState extends State<SavingsCalculatorScreen> {
  static const _terms = [3, 6, 12, 24];
  static const _goalTarget = 250000;

  final _initial = TextEditingController(text: '500,000');
  double _monthly = 50000;
  int _term = 12;

  @override
  void initState() {
    super.initState();
    _initial.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _initial.dispose();
    super.dispose();
  }

  int get _initialValue =>
      int.tryParse(_initial.text.replaceAll(RegExp(r'\D'), '')) ?? 0;

  void _addInitial(int v) {
    _initial.text = formatMnt(_initialValue + v).substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final result = projectSavings(
      initial: _initialValue,
      monthly: _monthly.round(),
      months: _term,
    );
    final goalProgress = (result.interest / _goalTarget).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.dsSurface,
      appBar: SubPageHeader(
        title: 'Хадгаламжийн тооцоолуур',
        background: AppColors.dsSurface,
        trailing: CircleIconButton(
          icon: Icons.refresh_rounded,
          label: 'Шинэчлэх',
          color: AppColors.sky600,
          onPressed: () => setState(() {
            _initial.text = '500,000';
            _monthly = 50000;
            _term = 12;
          }),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          AppCard(
            radius: 24,
            color: Colors.white.withValues(alpha: 0.8),
            child: Row(
              children: [
                const MascotTile(
                  asset: Mascots.owlAbacus,
                  size: 64,
                  background: AppColors.sky50,
                  label: 'Ухаалаг шар шувуу',
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const StatusBadge(label: 'Ухаалаг тооцоолол'),
                      const SizedBox(height: 4),
                      AppText(
                        'Мөнгөө хүүгээр өсгөж зорилгодоо илүү хурдан хүрээрэй!',
                        size: 12,
                        weight: FontWeight.w700,
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        'Хадгаламжийн хүү өдөр бүр танд ажиллана',
                        size: 10,
                        color: AppColors.slate400,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            radius: 24,
            padding: const EdgeInsets.all(16),
            borderColor: AppColors.slate100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FieldLabel(
                  'Эхний хадгаламжийн дүн',
                  trailing: AppText(
                    'Хуримтлал',
                    size: 11,
                    weight: FontWeight.w600,
                    color: AppColors.sky600,
                  ),
                ),
                AppTextField(
                  controller: _initial,
                  prefixText: '₮',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    TextInputFormatter.withFunction((o, n) {
                      if (n.text.isEmpty) return n;
                      final t = formatMnt(int.parse(n.text)).substring(1);
                      return TextEditingValue(
                        text: t,
                        selection: TextSelection.collapsed(offset: t.length),
                      );
                    }),
                  ],
                  suffix: GestureDetector(
                    onTap: _initial.clear,
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: AppColors.slate400,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    for (final (label, v) in [
                      ('+₮50k', 50000),
                      ('+₮100k', 100000),
                      ('+₮500k', 500000),
                      ('+₮1M', 1000000),
                    ])
                      FilterChipPill(
                        label: label,
                        selected: false,
                        onTap: () => _addInitial(v),
                      ),
                  ],
                ),
                const Divider(height: 28, color: AppColors.slate100),
                const FieldLabel('Сар бүр тогтмол нэмэх дүн'),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.slate50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Row(
                    children: [
                      AppText(
                        '₮',
                        size: 18,
                        weight: FontWeight.w700,
                        color: AppColors.emerald600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          formatMnt(_monthly).substring(1),
                          style: moneyStyle(size: 16),
                        ),
                      ),
                      AppText('/ сар', size: 12, color: AppColors.slate400),
                    ],
                  ),
                ),
                _AppSlider(
                  value: _monthly,
                  min: 10000,
                  max: 200000,
                  divisions: 19,
                  onChanged: (v) => setState(() => _monthly = v),
                ),
                const _SliderScale(labels: ['₮10,000', '₮100,000', '₮200,000']),
                const Divider(height: 28, color: AppColors.slate100),
                FieldLabel(
                  'Хадгаламжийн хугацаа',
                  trailing: AppText(
                    'Жилийн хүү: 13.5%',
                    size: 11,
                    weight: FontWeight.w700,
                    color: AppColors.sky600,
                  ),
                ),
                Row(
                  children: [
                    for (final (i, t) in _terms.indexed) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: _TermButton(
                          label: '$t сар',
                          selected: _term == t,
                          onTap: () => setState(() => _term = t),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            radius: 24,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'ТООЦООЛЛЫН ҮР ДҮН ($_term САР)',
                  size: 11,
                  weight: FontWeight.w700,
                  color: AppColors.slate500,
                  letterSpacing: 0.6,
                ),
                const SizedBox(height: 10),
                AppText('Нийт авах дүн:', size: 12, color: AppColors.slate400),
                const SizedBox(height: 2),
                Text(
                  formatMnt(result.total, space: true),
                  style: moneyStyle(size: 26, weight: FontWeight.w600),
                ),
                const Divider(height: 24, color: AppColors.slate100),
                Row(
                  children: [
                    Expanded(
                      child: _ResultBox(
                        label: 'Таны хийсэн орлого:',
                        value: formatMnt(result.deposited, space: true),
                        background: AppColors.slate50,
                        border: AppColors.slate100,
                        labelColor: AppColors.slate500,
                        valueColor: AppColors.slate800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ResultBox(
                        label: '✨ Цэвэр хүүгийн өсөлт:',
                        value: '+${formatMnt(result.interest, space: true)}',
                        background: AppColors.sky50.withValues(alpha: 0.6),
                        border: AppColors.sky100,
                        labelColor: AppColors.sky600,
                        valueColor: AppColors.sky500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            radius: 24,
            padding: const EdgeInsets.all(16),
            borderColor: AppColors.slate100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppText(
                  'Энэ өсөлтөөр биелэх зорилго:',
                  size: 12,
                  weight: FontWeight.w700,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.slate50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.slate100),
                  ),
                  child: Row(
                    children: [
                      const MascotTile(
                        asset: Mascots.puppyGamepad,
                        background: AppColors.sky50,
                        radius: 12,
                        label: 'PlayStation 5 тоглоом',
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: AppText(
                                    'PlayStation 5 тоглоом',
                                    size: 12,
                                    weight: FontWeight.w700,
                                  ),
                                ),
                                AppText(
                                  goalProgress >= 1
                                      ? '100% Бэлэн!'
                                      : '${(goalProgress * 100).round()}%',
                                  size: 10,
                                  weight: FontWeight.w700,
                                  color: goalProgress >= 1
                                      ? AppColors.emerald600
                                      : AppColors.sky600,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            AppText(
                              'Шаардлагатай: ${formatMnt(_goalTarget, space: true)}',
                              size: 11,
                              color: AppColors.slate500,
                            ),
                            const SizedBox(height: 6),
                            ProgressTrack(
                              value: goalProgress,
                              height: 6,
                              color: goalProgress >= 1
                                  ? AppColors.emerald500
                                  : AppColors.sky500,
                              track: AppColors.slate200,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: '✨ Энэ дүнгээр хадгаламж нээх',
            onPressed: () => context.pushReplacement(AppRoutes.savingsDeposit),
          ),
        ],
      ),
    );
  }
}

class _AppSlider extends StatelessWidget {
  const _AppSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
  });

  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 6,
        activeTrackColor: AppColors.sky500,
        inactiveTrackColor: AppColors.slate200,
        thumbColor: AppColors.sky500,
        overlayColor: AppColors.sky500.withValues(alpha: 0.12),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 11),
        showValueIndicator: ShowValueIndicator.never,
        tickMarkShape: SliderTickMarkShape.noTickMark,
      ),
      child: Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }
}

class _SliderScale extends StatelessWidget {
  const _SliderScale({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final l in labels)
            AppText(
              l,
              size: 10,
              weight: FontWeight.w600,
              color: AppColors.slate400,
            ),
        ],
      ),
    );
  }
}

class _TermButton extends StatelessWidget {
  const _TermButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.sky50 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.sky500 : AppColors.slate200,
              width: selected ? 2 : 1,
            ),
          ),
          child: AppText(
            label,
            size: 12,
            weight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? AppColors.sky700 : AppColors.slate600,
          ),
        ),
      ),
    );
  }
}

class _ResultBox extends StatelessWidget {
  const _ResultBox({
    required this.label,
    required this.value,
    required this.background,
    required this.border,
    required this.labelColor,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color background;
  final Color border;
  final Color labelColor;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(label, size: 10, weight: FontWeight.w600, color: labelColor),
          const SizedBox(height: 2),
          FittedBox(
            child: Text(value, style: moneyStyle(size: 14, color: valueColor)),
          ),
        ],
      ),
    );
  }
}
