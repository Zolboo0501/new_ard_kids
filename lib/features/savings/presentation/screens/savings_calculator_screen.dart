import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../widgets/adaptive.dart';
import '../../data/savings_projection.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../widgets/app_slider.dart';
import '../widgets/slider_scale.dart';
import '../widgets/stat_strip.dart';
import '../widgets/term_button.dart';

/// "Хадгаламжийн тооцоолуур": interest calculator.
class SavingsCalculatorScreen extends StatefulWidget {
  const SavingsCalculatorScreen({super.key});

  @override
  State<SavingsCalculatorScreen> createState() =>
      _SavingsCalculatorScreenState();
}

class _SavingsCalculatorScreenState extends State<SavingsCalculatorScreen> {
  static const _terms = [3, 6, 12, 24];

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

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: SubPageHeader(
        title: 'Хадгаламжийн тооцоолуур',
        background: AppColors.surface,
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
      body: EntranceScope(
        child: AdaptiveListView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: EntranceItem.list([
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FieldLabel('Эхний хадгаламжийн дүн'),
                  AppTextField(
                    controller: _initial,
                    prefixText: '₮',
                    textStyle: moneyStyle(size: 16, weight: FontWeight.w600),
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
                    suffix: Semantics(
                      button: true,
                      label: 'Дүнг арилгах',
                      excludeSemantics: true,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: withHaptic(_initial.clear),
                        child: SizedBox.square(
                          dimension: 44,
                          child: Center(
                            child: LineIcon(
                              LineGlyph.close,
                              size: 18,
                              color: AppColors.slate400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
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
                  Divider(height: 32, color: AppColors.line),
                  const FieldLabel('Сар бүр тогтмол нэмэх дүн'),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: BalanceText(
                            _monthly,
                            animate: true,
                            size: 16,
                            space: false,
                            currencyColor: AppColors.slate500,
                            decimals: false,
                          ),
                        ),
                        AppText('/ сар', size: 13, color: AppColors.slate500),
                      ],
                    ),
                  ),
                  AppSlider(
                    value: _monthly,
                    min: 10000,
                    max: 200000,
                    divisions: 19,
                    onChanged: (v) => setState(() => _monthly = v),
                  ),
                  const SliderScale(
                    labels: ['₮10,000', '₮100,000', '₮200,000'],
                  ),
                  Divider(height: 32, color: AppColors.line),
                  FieldLabel(
                    'Хадгаламжийн хугацаа',
                    trailing: AppText(
                      'Жилийн хүү 13.5%',
                      size: 12,
                      weight: FontWeight.w600,
                      color: AppColors.slate500,
                    ),
                  ),
                  Row(
                    children: [
                      for (final (i, t) in _terms.indexed) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(
                          child: TermButton(
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          'Тооцоолсон дүн',
                          size: 16,
                          weight: FontWeight.w700,
                          color: AppColors.slate900,
                        ),
                      ),
                      AppText(
                        '$_term сарын дараа',
                        size: 13,
                        color: AppColors.slate500,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: BalanceText(
                      result.total,
                      animate: true,
                      space: false,
                      size: 36,
                      weight: FontWeight.w600,
                      color: AppColors.slate900,
                    ),
                  ),
                  Divider(height: 32, color: AppColors.line),
                  StatStrip(
                    items: [
                      (
                        'Таны хийх орлого',
                        formatMnt(result.deposited, space: false),
                        AppColors.slate900,
                      ),
                      ('Хүүгийн орлого', result.interest, AppColors.emerald600),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Орлого хийх',
              onPressed: () =>
                  context.pushReplacement(AppRoutes.savingsDeposit),
            ),
          ]),
        ),
      ),
    );
  }
}
