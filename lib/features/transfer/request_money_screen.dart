import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../../widgets/app_text.dart';

/// "Мөнгө хүсэх": ask a parent to top up the account.
class RequestMoneyScreen extends StatefulWidget {
  const RequestMoneyScreen({super.key});

  @override
  State<RequestMoneyScreen> createState() => _RequestMoneyScreenState();
}

class _RequestMoneyScreenState extends State<RequestMoneyScreen> {
  static const _parents = [
    ('Ээж', 'Голомт • 1605******', Mascots.catHeart, AppColors.pink50),
    ('Аав', 'Хаан • 5042******', Mascots.owlBook, Color(0xFFEFF6FF)),
  ];
  static const _types = [
    '📚 Ном дэвтэр',
    '🎮 Тоглоом',
    '🍔 Өдрийн хоол',
    '🎨 Дугуйлан',
    '✨ Бусад',
  ];

  final _amount = TextEditingController(text: '20,000');
  final _note = TextEditingController(text: 'Зургийн дэвтэр, ном авах');
  int _parent = 0;
  int? _quick = 20000;
  int _type = 0;

  @override
  void initState() {
    super.initState();
    _amount.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  int get _value =>
      int.tryParse(_amount.text.replaceAll(RegExp(r'\D'), '')) ?? 0;

  void _submit() {
    FocusScope.of(context).unfocus();
    // TODO: send the request to the parent's app.
    showAppSnack(
      context,
      '${_parents[_parent].$1} руу ${formatMnt(_value)} хүсэлт илгээлээ',
    );
    context.pushReplacement(AppRoutes.requestList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: SubPageHeader(
        title: 'Мөнгө хүсэх',
        background: AppColors.slate50,
        trailing: CircleIconButton(
          icon: Icons.history_rounded,
          label: 'Хүсэлтийн жагсаалт',
          onPressed: () => context.push(AppRoutes.requestList),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          AppCard(
            radius: 26,
            padding: const EdgeInsets.all(16),
            borderColor: AppColors.slate100,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const StatusBadge(label: 'ЭЦЭГ ЭХЭЭС МӨНГӨ ХҮСЭХ'),
                      const SizedBox(height: 8),
                      AppText(
                        'Аав, ээждээ хүсэлт илгээж дансаа цэнэглүүлээрэй!',
                        size: 14,
                        weight: FontWeight.w700,
                        color: AppColors.slate900,
                        height: 1.4,
                      ),
                    ],
                  ),
                ),
                const MascotImage(
                  asset: Mascots.bearFamily,
                  size: 96,
                  background: Colors.white,
                  semanticLabel: 'Аав ээж бамбарууш',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Хэнд хүсэлт илгээх вэ?',
            padding: EdgeInsets.fromLTRB(4, 0, 4, 8),
          ),
          Row(
            children: [
              for (final (i, p) in _parents.indexed) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: _ParentCard(
                    name: p.$1,
                    account: p.$2,
                    asset: p.$3,
                    tint: p.$4,
                    selected: _parent == i,
                    onTap: () => setState(() => _parent = i),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            radius: 26,
            padding: const EdgeInsets.all(16),
            borderColor: AppColors.slate100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FieldLabel(
                  'Хүсэх дүн',
                  trailing: AppText(
                    'Данс руу орох',
                    size: 11,
                    weight: FontWeight.w600,
                    color: AppColors.sky600,
                  ),
                ),
                AppTextField(
                  controller: _amount,
                  prefixText: '₮',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _ThousandsFormatter(),
                  ],
                  textStyle: moneyStyle(size: 20, color: AppColors.slate900),
                  onChanged: (_) => setState(() => _quick = null),
                  suffix: GestureDetector(
                    onTap: _amount.clear,
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
                QuickAmountChips(
                  amounts: const [5000, 10000, 20000, 50000],
                  selected: _quick,
                  onSelected: (v) {
                    final text = formatMnt(v).substring(1);
                    _amount.text = text;
                    setState(() => _quick = v);
                  },
                ),
                const SizedBox(height: 16),
                const FieldLabel('Хүсэлтийн утга / Хэрэгцээ'),
                AppTextField(
                  controller: _note,
                  hint:
                      'Жишээ нь: Ном авах, сургалтын хэрэглэл, өдрийн хоол...',
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppText(
                      'Төрөл:',
                      size: 10,
                      weight: FontWeight.w600,
                      color: AppColors.slate400,
                    ),
                    for (final (i, t) in _types.indexed)
                      FilterChipPill(
                        label: t,
                        selected: _type == i,
                        onTap: () => setState(() => _type = i),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const InfoNote(
            tone: BadgeTone.amber,
            icon: Icons.mark_email_unread_outlined,
            text:
                'Таны хүсэлт аав ээжийн утсанд мэдэгдэл болон очно. Зөвшөөрснөөр таны дансанд шууд орно! 💌',
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Хүсэлт илгээх',
            leadingIcon: Icons.send_rounded,
            onPressed: _value > 0 ? _submit : null,
          ),
        ],
      ),
    );
  }
}

class _ParentCard extends StatelessWidget {
  const _ParentCard({
    required this.name,
    required this.account,
    required this.asset,
    required this.tint,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String account;
  final String asset;
  final Color tint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.sky500 : AppColors.slate200,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              MascotTile(asset: asset, size: 44, background: tint, radius: 12),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppText(
                            name,
                            size: 12,
                            weight: FontWeight.w700,
                            color: selected
                                ? AppColors.sky900
                                : AppColors.slate700,
                          ),
                        ),
                        if (selected)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.sky600,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      account,
                      size: 10,
                      color: AppColors.slate500,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return const TextEditingValue();
    final text = formatMnt(int.parse(digits)).substring(1);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
