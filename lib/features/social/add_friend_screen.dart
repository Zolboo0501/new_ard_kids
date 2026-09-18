import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../../widgets/app_text.dart';

/// "Найз нэмэх": save a friend or family member for quick transfers.
class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  static const _relations = [
    ('Найз', Mascots.foxWave, AppColors.sky50),
    ('Дүү / Ах', Mascots.bunnyBattery, AppColors.amber50),
    ('Аав / Ээж', Mascots.bearFamily, AppColors.pink50),
    ('Ангийн', Mascots.penguinChecklist, AppColors.emerald50),
  ];
  static const _banks = ['Хаан банк', 'Голомт банк', 'ХХБ', 'Төрийн банк'];

  final _nickname = TextEditingController();
  final _account = TextEditingController();
  final _phone = TextEditingController();
  int _relation = 0;
  int _bank = 0;
  final _suggested = [
    (
      'Тэмүүлэн',
      'Хаан банк • 5042******',
      Mascots.bearSitting,
      AppColors.sky100,
    ),
    (
      'Сарнай (эгч)',
      'Голомт банк • 1605******',
      Mascots.catHeart,
      AppColors.amber100,
    ),
  ];
  final _added = <String>{};

  @override
  void initState() {
    super.initState();
    _nickname.addListener(() => setState(() {}));
    _account.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nickname.dispose();
    _account.dispose();
    _phone.dispose();
    super.dispose();
  }

  bool get _valid =>
      _nickname.text.trim().isNotEmpty && _account.text.length == 10;

  void _save() {
    // TODO: persist the saved friend.
    showAppSnack(context, '${_nickname.text.trim()} найзаар нэмэгдлээ 🎉');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: SubPageHeader(
        title: 'Найз нэмэх',
        background: AppColors.slate50,
        trailing: CircleIconButton(
          icon: Icons.qr_code_scanner_rounded,
          label: 'QR код уншуулах',
          onPressed: () => context.push(AppRoutes.qrScan),
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
            radius: 28,
            padding: const EdgeInsets.all(20),
            borderColor: AppColors.slate100,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const StatusBadge(label: 'ШИНЭ НАЙЗ НЭМЭХ', dot: true),
                      const SizedBox(height: 8),
                      AppText(
                        'Найз эсвэл гэр бүлийн гишүүнээ нэмээд шуурхай гүйлгээ хийгээрэй!',
                        size: 12,
                        weight: FontWeight.w500,
                        color: AppColors.slate500,
                        height: 1.6,
                      ),
                    ],
                  ),
                ),
                const MascotImage(
                  asset: Mascots.fox,
                  size: 96,
                  background: Colors.white,
                  semanticLabel: 'Cute fox mascot',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Харилцаа сонгох',
            padding: EdgeInsets.fromLTRB(4, 0, 4, 8),
          ),
          Row(
            children: [
              for (final (i, r) in _relations.indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _RelationButton(
                    label: r.$1,
                    asset: r.$2,
                    tint: r.$3,
                    selected: _relation == i,
                    onTap: () => setState(() => _relation = i),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            radius: 28,
            padding: const EdgeInsets.all(20),
            borderColor: AppColors.slate100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FieldLabel('Найзын нэр'),
                AppTextField(
                  controller: _nickname,
                  hint: 'Жишээ: Анар, Батаа...',
                  suffix: const Icon(
                    Icons.badge_outlined,
                    size: 20,
                    color: AppColors.sky600,
                  ),
                ),
                const SizedBox(height: 14),
                const FieldLabel('Дансны дугаар'),
                AppTextField(
                  controller: _account,
                  hint: 'Дансны 10 оронтой дугаар',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  suffix: const Icon(
                    Icons.account_balance_outlined,
                    size: 20,
                    color: AppColors.sky600,
                  ),
                ),
                const SizedBox(height: 10),
                AppText(
                  'Банк сонгох',
                  size: 11,
                  weight: FontWeight.w600,
                  color: AppColors.slate500,
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _banks.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => FilterChipPill(
                      label: _banks[i],
                      selected: _bank == i,
                      onTap: () => setState(() => _bank = i),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FieldLabel(
                  'Утасны дугаар',
                  trailing: AppText(
                    '(сонгох)',
                    size: 10,
                    weight: FontWeight.w600,
                    color: AppColors.slate400,
                  ),
                ),
                AppTextField(
                  controller: _phone,
                  hint: '88******, 99******',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  suffix: const Icon(
                    Icons.phone_iphone_rounded,
                    size: 20,
                    color: AppColors.sky600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Утасны жагсаалтаас санал болгох',
            action: 'Бүгд',
            padding: EdgeInsets.fromLTRB(4, 0, 4, 8),
          ),
          for (final s in _suggested) ...[
            AppCard(
              radius: 18,
              padding: const EdgeInsets.all(12),
              borderColor: AppColors.slate100,
              child: Row(
                children: [
                  MascotTile(asset: s.$3, background: s.$4, label: s.$1),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(s.$1, size: 12, weight: FontWeight.w700),
                        AppText(s.$2, size: 11, color: AppColors.slate400),
                      ],
                    ),
                  ),
                  SoftButton(
                    label: _added.contains(s.$1) ? 'Нэмсэн ✓' : 'Нэмэх',
                    height: 32,
                    background: _added.contains(s.$1)
                        ? AppColors.emerald50
                        : AppColors.sky50,
                    foreground: _added.contains(s.$1)
                        ? AppColors.emerald600
                        : AppColors.sky600,
                    onPressed: () => setState(() => _added.add(s.$1)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          const InfoNote(
            tone: BadgeTone.amber,
            icon: Icons.shield_outlined,
            title: 'Эцэг эхийн хяналттай',
            text:
                'Таны нэмсэн шинэ найзын мэдээлэл эцэг эхийн апп дээр автоматаар харагдаж хамгаалагдана.',
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Найз хадгалах',
            leadingIcon: Icons.person_add_alt_1_rounded,
            height: 56,
            onPressed: _valid ? _save : null,
          ),
        ],
      ),
    );
  }
}

class _RelationButton extends StatelessWidget {
  const _RelationButton({
    required this.label,
    required this.asset,
    required this.tint,
    required this.selected,
    required this.onTap,
  });

  final String label;
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.sky500 : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.sky500 : AppColors.slate200,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.sky500.withValues(alpha: 0.3),
                      offset: const Offset(0, 6),
                      blurRadius: 14,
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected ? Colors.white.withValues(alpha: 0.2) : tint,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(2),
                child: ClipOval(child: Image.asset(asset, fit: BoxFit.cover)),
              ),
              const SizedBox(height: 4),
              AppText(
                label,
                size: 11,
                weight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? Colors.white : AppColors.slate600,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
