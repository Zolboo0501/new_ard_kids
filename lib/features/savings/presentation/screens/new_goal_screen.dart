import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../widgets/app_slider.dart';
import '../widgets/icon_choice.dart';
import '../widgets/new_goal_section.dart';
import '../widgets/slider_scale.dart';

/// "Шинэ зорилго": create a savings goal.
class NewGoalScreen extends StatefulWidget {
  const NewGoalScreen({super.key});

  @override
  State<NewGoalScreen> createState() => _NewGoalScreenState();
}

class _NewGoalScreenState extends State<NewGoalScreen> {
  static const _topics = ['Технологи', 'Спорт', 'Хичээл', 'Урлаг', 'Аялал'];

  /// (screen-reader label, glyph)
  static const _icons = [
    ('Зорилго', LineGlyph.target),
    ('Тоглоом', LineGlyph.gamepad),
    ('Аялал', LineGlyph.plane),
    ('Ном', LineGlyph.book),
    ('Цүнх', LineGlyph.bag),
    ('Хувцас', LineGlyph.shirt),
    ('Спорт', LineGlyph.ball),
    ('Утас', LineGlyph.phone),
  ];

  final _name = TextEditingController(text: 'PlayStation 5 Pro');
  int _topic = 0;
  int _target = 250000;
  int? _lastQuick = 100000;
  double _monthly = 25000;
  int _icon = 1;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  int get _months => _monthly <= 0 ? 0 : (_target / _monthly.round()).ceil();

  bool get _valid => _name.text.trim().isNotEmpty && _target > 0;

  void _submit() {
    // TODO: persist the goal.
    showAppSnack(context, '"${_name.text.trim()}" зорилго үүслээ');
    context.pop();
  }

  Widget _clearButton(String label, VoidCallback onTap) => Semantics(
    button: true,
    label: label,
    excludeSemantics: true,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: withHaptic(onTap),
      child: SizedBox.square(
        dimension: 44,
        child: Center(
          child: LineIcon(LineGlyph.close, size: 18, color: AppColors.slate500),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final strong = inter(
      size: 13,
      weight: FontWeight.w600,
      color: AppColors.slate900,
    );
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: SubPageHeader(
        title: 'Шинэ зорилго',
        background: AppColors.surface,
      ),
      body: EntranceScope(
        child: AdaptiveListView(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: EntranceItem.list([
            NewGoalSection(
              title: 'Зорилгын нэр',
              children: [
                AppTextField(
                  controller: _name,
                  hint: 'Жишээ нь: Шинэ дугуй, чихэвч',
                  suffix: _name.text.isEmpty
                      ? null
                      : _clearButton('Нэрийг арилгах', _name.clear),
                ),
                const SizedBox(height: 12),
                // Wraps to a second line instead of cutting chips off.
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (i, t) in _topics.indexed)
                      FilterChipPill(
                        label: t,
                        selected: _topic == i,
                        onTap: () => setState(() => _topic = i),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            NewGoalSection(
              title: 'Хүрэх дүн',
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 14),
                  decoration: BoxDecoration(
                    color: AppColors.slate50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: BalanceText(
                            _target,
                            animate: true,
                            size: 28,
                            weight: FontWeight.w600,
                            space: false,
                            color: AppColors.slate900,
                            currencyColor: AppColors.slate500,
                          ),
                        ),
                      ),
                      _clearButton(
                        'Дүнг арилгах',
                        () => setState(() {
                          _target = 0;
                          _lastQuick = null;
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                QuickAmountChips(
                  amounts: const [10000, 20000, 50000, 100000],
                  selected: _lastQuick,
                  onSelected: (v) => setState(() {
                    _target += v;
                    _lastQuick = v;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            NewGoalSection(
              title: 'Сар бүр хадгалах',
              trailingWidget: Text(
                '${formatMnt(_monthly, space: false)} / сар',
                style: moneyStyle(
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppColors.slate900,
                ),
              ),
              children: [
                AppSlider(
                  value: _monthly,
                  min: 5000,
                  max: 100000,
                  divisions: 19,
                  onChanged: (v) => setState(() => _monthly = v),
                ),
                const SliderScale(labels: ['₮5,000', '₮50,000', '₮100,000']),
                Divider(height: 28, color: AppColors.line),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Сар бүр '),
                      TextSpan(text: formatMnt(_monthly), style: strong),
                      const TextSpan(text: ' хадгалбал '),
                      TextSpan(
                        text: _target == 0 ? '—' : '$_months сарын дараа',
                        style: strong,
                      ),
                      const TextSpan(text: ' зорилгодоо хүрнэ.'),
                    ],
                  ),
                  style: inter(
                    size: 13,
                    color: AppColors.slate600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            NewGoalSection(
              title: 'Дүрс',
              children: [
                LayoutBuilder(
                  builder: (context, c) {
                    const perRow = 4, gap = 8.0;
                    final w = (c.maxWidth - gap * (perRow - 1)) / perRow;
                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        for (final (i, ic) in _icons.indexed)
                          SizedBox(
                            width: w,
                            child: IconChoice(
                              label: ic.$1,
                              glyph: ic.$2,
                              selected: _icon == i,
                              onTap: () => setState(() => _icon = i),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Зорилго үүсгэх',
              onPressed: _valid ? _submit : null,
            ),
          ]),
        ),
      ),
    );
  }
}
