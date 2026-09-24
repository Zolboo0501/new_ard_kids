import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/avatar.dart';
import '../../../../app/routes.dart';
import '../../data/savings_projection.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../widgets/app_slider.dart';
import '../widgets/result_box.dart';
import '../widgets/slider_scale.dart';
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
      body: EntranceScope(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: EntranceItem.list([
            AppCard(
              radius: 24,
              color: Colors.white.withValues(alpha: 0.8),
              child: Row(
                children: [
                  MascotTile(
                    asset: Stickers.calculator,
                    size: 64,
                    background: AppColors.sky50,
                    label: 'Тооцоолуур барьсан маскот',
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
                    suffix: GestureDetector(
                      onTap: withHaptic(_initial.clear),
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
                        Expanded(
                          child: BalanceText(
                            _monthly,
                            animate: true,
                            size: 16,
                            space: false,
                            currencyColor: AppColors.emerald600,
                            decimals: false,
                          ),
                        ),
                        AppText('/ сар', size: 12, color: AppColors.slate400),
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
                  AppText(
                    'Нийт авах дүн:',
                    size: 12,
                    color: AppColors.slate400,
                  ),
                  const SizedBox(height: 2),
                  BalanceText(
                    result.total,
                    animate: true,
                    space: false,
                    size: 26,
                    weight: FontWeight.w600,
                  ),
                  const Divider(height: 24, color: AppColors.slate100),
                  Row(
                    children: [
                      Expanded(
                        child: ResultBox(
                          label: 'Таны хийсэн орлого:',
                          value: result.deposited,
                          background: AppColors.slate50,
                          border: AppColors.slate100,
                          labelColor: AppColors.slate500,
                          valueColor: AppColors.slate800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ResultBox(
                          label: 'Цэвэр хүүгийн өсөлт:',
                          value: result.interest,
                          sign: true,
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
                        MascotTile(
                          asset: Stickers.games,
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
                                'Шаардлагатай: ${formatMnt(_goalTarget, space: false)}',
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
              label: 'Энэ дүнгээр хадгаламж нээх',
              onPressed: () =>
                  context.pushReplacement(AppRoutes.savingsDeposit),
            ),
          ]),
        ),
      ),
    );
  }
}
