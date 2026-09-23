import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../../widgets/app_text.dart';
import '../../widgets/entrance.dart';
import '../../app/avatar.dart';

/// "Шинэ зорилго үүсгэх": create a savings goal.
class NewGoalScreen extends StatefulWidget {
  const NewGoalScreen({super.key});

  @override
  State<NewGoalScreen> createState() => _NewGoalScreenState();
}

class _NewGoalScreenState extends State<NewGoalScreen> {
  static List<(String, String)> get _topics => [
    (Stickers.games, 'Тоглоом'),
    (Stickers.sports, 'Спорт'),
    (Stickers.lesson, 'Хичээл'),
    (Stickers.art, 'Урлаг'),
    (Stickers.travel, 'Аялал'),
  ];
  static List<(String, String)> get _icons => [
    ('Тоглоом', Stickers.games),
    ('Хуритмлал', Stickers.piggy),
    ('Аялал', Stickers.travel),
    ('Мөрөөдөл', Stickers.goal),
  ];

  final _name = TextEditingController(text: 'PlayStation 5 тоглоом');
  int _topic = 0;
  int _target = 250000;
  int? _lastQuick = 100000;
  double _monthly = 25000;
  int _icon = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dsSurface,
      appBar: const SubPageHeader(
        title: 'Зорилго нэмэх',
        background: AppColors.dsSurface,
      ),
      body: EntranceScope(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: EntranceItem.list([
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [AppColors.sky50, AppColors.amber50],
                ),
                border: Border.all(color: AppColors.sky100),
              ),
              child: Row(
                children: [
                  MascotImage(
                    asset: Stickers.goal,
                    size: 80,
                    background: AppColors.sky50,
                    semanticLabel: 'Зорилгодоо онилсон маскот',
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const StatusBadge(
                          label: 'Мөрөөдлөө биелүүлцгээе!',
                          tone: BadgeTone.amber,
                        ),
                        const SizedBox(height: 6),
                        AppText(
                          'Зорилгоо тодорхойлж, бага багаар хуримтлуулаад мөрөөдөлдөө хүрээрэй!',
                          size: 12,
                          weight: FontWeight.w500,
                          color: AppColors.slate600,
                          height: 1.5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _Section(
              dot: AppColors.sky500,
              title: 'Зорилгын нэр',
              children: [
                AppTextField(
                  controller: _name,
                  hint: 'Жишээ нь: Шинэ дугуй, LEGO тоглоом...',
                  suffix: _name.text.isEmpty
                      ? null
                      : GestureDetector(
                          onTap: withHaptic(_name.clear),
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.slate200,
                            child: Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: AppColors.slate500,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 10),
                AppText(
                  'Шуурхай сэдвүүд:',
                  size: 11,
                  weight: FontWeight.w600,
                  color: AppColors.slate400,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _topics.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => FilterChipPill(
                      label: _topics[i].$2,
                      mascot: _topics[i].$1,
                      selected: _topic == i,
                      onTap: () => setState(() => _topic = i),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Section(
              dot: AppColors.amber400,
              title: 'Хүрэх дүн',
              trailing: 'Төгрөгөөр',
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.slate50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: BalanceText(
                          _target,
                          animate: true,
                          size: 24,
                          weight: FontWeight.w600,
                          space: false,
                          currencyColor: AppColors.sky500,
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: 'Дүнг арилгах',
                        child: GestureDetector(
                          onTap: withHaptic(
                            () => setState(() {
                              _target = 0;
                              _lastQuick = null;
                            }),
                          ),
                          child: const CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.slate200,
                            child: Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: AppColors.slate600,
                            ),
                          ),
                        ),
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
            const SizedBox(height: 16),
            _Section(
              dot: AppColors.emerald400,
              title: 'Сар бүр хадгалах дүн',
              trailingWidget: StatusBadge(
                label: '${formatMnt(_monthly, space: false)} / сар',
              ),
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 10,
                    activeTrackColor: AppColors.sky500,
                    inactiveTrackColor: AppColors.slate100,
                    thumbColor: AppColors.sky500,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 13,
                    ),
                    tickMarkShape: SliderTickMarkShape.noTickMark,
                  ),
                  child: Slider(
                    value: _monthly,
                    min: 5000,
                    max: 100000,
                    divisions: 19,
                    onChanged: (v) => setState(() => _monthly = v),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final l in ['₮5,000', '₮50,000', '₮100,000'])
                        AppText(
                          l,
                          size: 10,
                          weight: FontWeight.w700,
                          color: AppColors.slate400,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.amber50.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.amber200.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MascotIcon(Stickers.calculator, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Санамж: ',
                                style: inter(
                                  size: 11.5,
                                  weight: FontWeight.w700,
                                  color: const Color(0xFF451A03),
                                ),
                              ),
                              const TextSpan(text: 'Сар бүр '),
                              TextSpan(
                                text: formatMnt(_monthly),
                                style: inter(
                                  size: 11.5,
                                  weight: FontWeight.w700,
                                  color: AppColors.sky600,
                                ),
                              ),
                              const TextSpan(text: ' хадгалбал '),
                              TextSpan(
                                text: '$_months сарын дараа',
                                style: inter(
                                  size: 11.5,
                                  weight: FontWeight.w700,
                                  color: const Color(0xFF451A03),
                                ),
                              ),
                              const TextSpan(text: ' зорилгодоо 100% хүрнэ!'),
                            ],
                          ),
                          style: inter(
                            size: 11.5,
                            weight: FontWeight.w500,
                            color: const Color(0xFF78350F),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Section(
              dot: AppColors.pink400,
              title: 'Зорилгын бэлгэдэл дүрс',
              trailing: 'Сонгох',
              children: [
                Row(
                  children: [
                    for (final (i, ic) in _icons.indexed) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(
                        child: _IconChoice(
                          label: ic.$1,
                          asset: ic.$2,
                          selected: _icon == i,
                          onTap: () => setState(() => _icon = i),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Зорилго үүсгэх',
              height: 56,
              onPressed: _valid ? _submit : null,
            ),
          ]),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.dot,
    required this.title,
    required this.children,
    this.trailing,
    this.trailingWidget,
  });

  final Color dot;
  final String title;
  final String? trailing;
  final Widget? trailingWidget;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 24,
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.slate100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: AppText(
                  title.toUpperCase(),
                  size: 12,
                  weight: FontWeight.w700,
                  color: AppColors.slate700,
                  letterSpacing: 0.4,
                ),
              ),
              if (trailingWidget != null)
                trailingWidget!
              else if (trailing != null)
                AppText(
                  trailing!,
                  size: 11,
                  weight: FontWeight.w600,
                  color: AppColors.slate400,
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.label,
    required this.asset,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String asset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.sky50.withValues(alpha: 0.8)
                    : AppColors.slate50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? AppColors.sky500 : AppColors.slate100,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(asset, fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    label,
                    size: 10,
                    weight: FontWeight.w700,
                    color: selected ? AppColors.sky600 : AppColors.slate600,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (selected)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.sky500,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 11,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
