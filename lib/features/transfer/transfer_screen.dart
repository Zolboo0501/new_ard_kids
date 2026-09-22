import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/accounts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_tabs.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'transfer_success_screen.dart';
import '../../widgets/app_text.dart';
import '../../widgets/entrance.dart';
import '../../widgets/value_switcher.dart';

enum TransferMode { friends, account, phone }

/// "Гүйлгээ хийх": send money to a saved friend, a bank account or a phone
/// number. Covers the three Stitch variants (Playful Blue / Дансаар / Утсаар).
class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key, this.initialMode = TransferMode.friends});

  final TransferMode initialMode;

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  static const _balance = 567930;
  static const _banks = ['Хаан банк', 'Голомт банк', 'ХХБ', 'Төрийн банк'];
  static const _friends = [
    ('Анар (Дүү)', Mascots.foxPhone, AppColors.amber100, '5049 8219 02'),
    ('Мишээл', Mascots.bunnyBattery, AppColors.emerald100, '5049 7712 45'),
    ('Аав', Mascots.owlBook, Color(0xFFDBEAFE), '5049 1102 33'),
    ('Ээж', Mascots.catHeart, AppColors.pink100, '5049 3321 08'),
  ];
  static const _phones = [
    ('Ээж (9911****)', Mascots.catHeart, '9911 2345', 'Б. Бат-Эрдэнэ'),
    ('Аав (9909****)', Mascots.owlBook, '9909 1188', 'Д. Ганбаатар'),
    ('Тэмүүлэн (8822****)', Mascots.bearSitting, '8822 4411', 'Т. Тэмүүлэн'),
  ];
  static const _purposes = [
    (Mascots.bearBooks, 'Ном дэвтэр', 'Ном авсан'),
    (Mascots.pandaMilk, 'Амттан', 'Амттан'),
    (Mascots.puppyGamepad, 'Тоглоом', 'Тоглоом'),
    (Mascots.bunnyCoin, 'Халаасны мөнгө', 'Халаасны мөнгө'),
  ];

  late TransferMode _mode = widget.initialMode;
  int _friend = 0;
  int _bank = 0;
  int _phonePick = 0;
  int? _quick = 10000;
  int _purpose = 0;

  final _recipient = TextEditingController(text: '5049 8219 02');
  final _phone = TextEditingController(text: '9911 2345');
  final _amount = TextEditingController(text: '15,000');
  final _note = TextEditingController(text: 'Ном авсан');

  @override
  void initState() {
    super.initState();
    for (final c in [_recipient, _phone, _amount]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_recipient, _phone, _amount, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  int get _amountValue =>
      int.tryParse(_amount.text.replaceAll(RegExp(r'\D'), '')) ?? 0;

  void _setAmount(int v) {
    final text = formatMnt(v).substring(1);
    _amount.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  String get _recipientName => switch (_mode) {
    TransferMode.friends => _friends[_friend].$1,
    TransferMode.account => 'Б. Сүхбат',
    TransferMode.phone => _phones[_phonePick].$4,
  };

  bool get _valid {
    final amount = _amountValue;
    if (amount <= 0 || amount > _balance) return false;
    return switch (_mode) {
      TransferMode.phone =>
        _phone.text.replaceAll(RegExp(r'\D'), '').length == 8,
      _ => _recipient.text.replaceAll(RegExp(r'\D'), '').length == 10,
    };
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    // TODO: call the transfer API.
    final receipt = TransferReceipt(
      amount: _amountValue,
      recipient: _recipientName,
      bank: _mode == TransferMode.account ? _banks[_bank] : 'Хаан банк',
      destination: _mode == TransferMode.phone
          ? '${_phone.text} / 5049 8219 02'
          : _recipient.text,
      note: _note.text.trim().isEmpty ? '—' : _note.text.trim(),
      balanceAfter: _balance - _amountValue,
      time: DateTime.now(),
    );
    context.pushReplacement(AppRoutes.transferSuccess, extra: receipt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: SubPageHeader(
        title: 'Гүйлгээ хийх',
        background: AppColors.slate50,
        trailing: CircleIconButton(
          icon: Icons.qr_code_scanner_rounded,
          label: 'QR код уншуулах',
          onPressed: () => context.push(AppRoutes.qrScan),
        ),
      ),
      body: EntranceScope(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: EntranceItem.list([
            _SourceCard(showAccount: _mode != TransferMode.friends),
            const SizedBox(height: 16),
            _ModeTabs(mode: _mode, onChanged: (m) => setState(() => _mode = m)),
            const SizedBox(height: 16),
            // The saved-friends strip only belongs to the friends mode; it
            // folds open and closed rather than popping in and out.
            _Collapse(
              visible: _mode == TransferMode.friends,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildFriends(),
              ),
            ),
            AppCard(
              radius: 26,
              padding: const EdgeInsets.all(16),
              borderColor: AppColors.slate100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Each mode's recipient fields slide in along the tabs'
                  // direction, and the card eases to the new height.
                  AppTabView(
                    index: _mode.index,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: switch (_mode) {
                        TransferMode.friends => _buildAccountField(
                          label: 'Хүлээн авагч',
                          showBanksBelow: true,
                        ),
                        TransferMode.account => [
                          const _Label('Банк сонгох'),
                          _buildBankChips(),
                          const SizedBox(height: 14),
                          ..._buildAccountField(label: 'Дансны дугаар'),
                        ],
                        TransferMode.phone => _buildPhoneFields(),
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _Label('Гүйлгээний дүн'),
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
                    suffix: _ClearButton(onTap: () => _amount.clear()),
                  ),
                  if (_amountValue > _balance)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4),
                      child: AppText(
                        'Үлдэгдэл хүрэлцэхгүй байна',
                        size: 11,
                        weight: FontWeight.w600,
                        color: AppColors.rose500,
                      ),
                    ),
                  _Collapse(
                    visible: _mode != TransferMode.phone,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: QuickAmountChips(
                        amounts: const [5000, 10000, 20000, 50000],
                        selected: _quick,
                        onSelected: (v) {
                          _setAmount(_amountValue + v);
                          setState(() => _quick = v);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _Label('Гүйлгээний утга'),
                  AppTextField(
                    controller: _note,
                    hint: 'Жишээ нь: Номын мөнгө, хичээлийн хэрэгсэл',
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      AppText(
                        'Сонгох:',
                        size: 10,
                        weight: FontWeight.w600,
                        color: AppColors.slate400,
                      ),
                      for (final (i, p) in _purposes.indexed)
                        _SmallChip(
                          label: p.$2,
                          asset: p.$1,
                          selected: _purpose == i,
                          onTap: () {
                            setState(() => _purpose = i);
                            _note.text = p.$3;
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _LimitNote(),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Гүйлгээ хийх',
              leadingIcon: Icons.send_rounded,
              onPressed: _valid ? _submit : null,
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildFriends() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Хадгалсан найзууд',
          action: 'Бүгд',
          onAction: () => context.push(AppRoutes.addFriend),
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
        ),
        SizedBox(
          height: 86,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _FriendAvatar(
                label: 'Нэмэх',
                onTap: () => context.push(AppRoutes.addFriend),
              ),
              for (final (i, f) in _friends.indexed)
                _FriendAvatar(
                  label: f.$1,
                  asset: f.$2,
                  tint: f.$3,
                  selected: _friend == i,
                  onTap: () {
                    setState(() => _friend = i);
                    _recipient.text = f.$4;
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAccountField({
    required String label,
    bool showBanksBelow = false,
  }) {
    return [
      _Label(label),
      AppTextField(
        controller: _recipient,
        hint: '10 оронтой дансны дугаар оруулна уу',
        keyboardType: TextInputType.number,
        inputFormatters: [
          _GroupFormatter(const [4, 4, 2]),
        ],
        suffix: Icon(
          Icons.contacts_outlined,
          size: 20,
          color: AppColors.sky600,
        ),
      ),
      if (showBanksBelow) ...[
        const SizedBox(height: 10),
        _buildBankChips(),
      ] else
        _VerifiedName(
          name: 'Б. Сүхбат',
          detail: '(Хүлээн авагч баталгаажсан ✔)',
        ),
    ];
  }

  List<Widget> _buildPhoneFields() {
    return [
      const _Label('Хурдан сонгох'),
      SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _phones.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) => _SmallChip(
            label: _phones[i].$1,
            asset: _phones[i].$2,
            selected: _phonePick == i,
            large: true,
            onTap: () {
              setState(() => _phonePick = i);
              _phone.text = _phones[i].$3;
            },
          ),
        ),
      ),
      const SizedBox(height: 14),
      const _Label('Утасны дугаар'),
      AppTextField(
        controller: _phone,
        hint: '8 оронтой утасны дугаар оруулна уу',
        keyboardType: TextInputType.phone,
        inputFormatters: [
          _GroupFormatter(const [4, 4]),
        ],
        suffix: Icon(
          Icons.contact_phone_outlined,
          size: 20,
          color: AppColors.sky600,
        ),
      ),
      _VerifiedName(
        name: _phones[_phonePick].$4,
        detail: '(Хаан банк - 5049*****) ✔',
      ),
    ];
  }

  Widget _buildBankChips() {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _mode == TransferMode.account ? _banks.length : 3,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (_, i) => _SmallChip(
          label: _banks[i],
          selected: _bank == i,
          dot: _bank == i,
          onTap: () => setState(() => _bank = i),
        ),
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.showAccount});

  final bool showAccount;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 26,
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.slate100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'ШИЛЖҮҮЛЭХ ДАНС',
                  size: 11,
                  weight: FontWeight.w600,
                  color: AppColors.slate400,
                  letterSpacing: 0.6,
                ),
                const SizedBox(height: 10),
                AppText(
                  'Боломжит үлдэгдэл',
                  size: 11,
                  color: AppColors.slate500,
                ),
                const SizedBox(height: 2),
                const BalanceText(
                  567930,
                  size: 30,
                  color: AppColors.slate900,
                  weight: FontWeight.w600,
                  currencyWeight: FontWeight.w600,
                ),
                _Collapse(
                  visible: showAccount,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: AppText(
                      'Хаан банк · ${formatIban(Accounts.khanBank)}',
                      size: 11,
                      weight: FontWeight.w600,
                      color: AppColors.slate400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const MascotImage(
            asset: Mascots.sleepingCat,
            size: 110,
            background: Colors.white,
            semanticLabel: 'Sleeping cat mascot',
          ),
        ],
      ),
    );
  }
}

class _ModeTabs extends StatelessWidget {
  const _ModeTabs({required this.mode, required this.onChanged});

  final TransferMode mode;
  final ValueChanged<TransferMode> onChanged;

  static const _duration = Duration(milliseconds: 320);

  @override
  Widget build(BuildContext context) {
    const labels = ['Найзууд', 'Дансаар', 'Утсаар'];
    final count = TransferMode.values.length;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : _duration;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.slate100.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // One pill that slides to the selected tab, instead of each tab
          // painting its own and the highlight jumping.
          Positioned.fill(
            child: AnimatedAlign(
              duration: duration,
              curve: appEmphasizedDecelerate,
              alignment: Alignment(-1 + 2 * mode.index / (count - 1), 0),
              child: FractionallySizedBox(
                widthFactor: 1 / count,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [AppColors.sky500, AppColors.sky600],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sky500.withValues(alpha: 0.35),
                        offset: const Offset(0, 4),
                        blurRadius: 12,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (final m in TransferMode.values)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: m == mode,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: withHaptic(() => onChanged(m)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: duration,
                            curve: appEmphasizedDecelerate,
                            style: inter(
                              size: 12,
                              weight: m == mode
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: m == mode
                                  ? Colors.white
                                  : AppColors.slate500,
                            ),
                            child: Text(labels[m.index]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shows or hides [child] by folding it open/closed while it fades, so the
/// content below slides instead of jumping.
class _Collapse extends StatelessWidget {
  const _Collapse({required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueSwitcher(
      value: visible,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 300),
      switchInCurve: appEmphasizedDecelerate,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation, _) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          axisAlignment: -1,
          child: child,
        ),
      ),
      child: visible
          ? KeyedSubtree(key: const ValueKey(true), child: child)
          : const SizedBox(key: ValueKey(false), width: double.infinity),
    );
  }
}

class _FriendAvatar extends StatelessWidget {
  const _FriendAvatar({
    required this.label,
    required this.onTap,
    this.asset,
    this.tint,
    this.selected = false,
  });

  final String label;
  final String? asset;
  final Color? tint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = this.tint ?? AppColors.sky50;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: withHaptic(onTap),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 54,
                    height: 54,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: tint,
                      borderRadius: BorderRadius.circular(16),
                      border: asset == null
                          ? null
                          : Border.all(
                              color: selected
                                  ? AppColors.sky500
                                  : tint.withValues(alpha: 0.9),
                              width: selected ? 2 : 1,
                            ),
                    ),
                    child: asset == null
                        ? CustomPaint(
                            painter: _DashedBoxPainter(),
                            child: Center(
                              child: Icon(
                                Icons.add_rounded,
                                color: AppColors.sky600,
                              ),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: MascotImage(
                              asset: asset!,
                              size: 50,
                              background: Colors.white,
                              semanticLabel: label,
                            ),
                          ),
                  ),
                  if (selected)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.sky600,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 5),
              AppText(
                label,
                size: 11,
                weight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? AppColors.sky800 : AppColors.slate600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.sky300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14)),
      );
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 8) {
        canvas.drawPath(m.extractPath(d, d + 4), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: AppText(
        text,
        size: 12,
        weight: FontWeight.w700,
        color: AppColors.slate700,
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  const _SmallChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.dot = false,
    this.asset,
    this.large = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool dot;
  final String? asset;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: withHaptic(onTap),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            horizontal: large ? 10 : 10,
            vertical: large ? 5 : 6,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.sky50 : AppColors.slate50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.sky300 : AppColors.slate200,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dot || (large && selected)) ...[
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.emerald500,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
              ],
              if (asset != null) ...[
                ClipOval(child: Image.asset(asset!, width: 24, height: 24)),
                const SizedBox(width: 6),
              ],
              AppText(
                label,
                size: 11,
                weight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? AppColors.sky700 : AppColors.slate600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerifiedName extends StatelessWidget {
  const _VerifiedName({required this.name, required this.detail});

  final String name;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Wrap(
        spacing: 6,
        children: [
          AppText(
            name,
            size: 11,
            weight: FontWeight.w700,
            color: AppColors.emerald600,
          ),
          AppText(detail, size: 10, color: AppColors.slate400),
        ],
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Арилгах',
      child: GestureDetector(
        onTap: withHaptic(onTap),
        child: Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.slate200,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close_rounded,
            size: 14,
            color: AppColors.slate500,
          ),
        ),
      ),
    );
  }
}

class _LimitNote extends StatelessWidget {
  const _LimitNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.sky50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sky200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.sky100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.shield_outlined,
              size: 15,
              color: AppColors.sky600,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Энэ гүйлгээ нь аав ээжийн тохируулсан ',
                children: [
                  TextSpan(
                    text: 'өдрийн ₮100,000 лимитийн',
                    style: inter(
                      size: 11,
                      weight: FontWeight.w700,
                      color: AppColors.sky900,
                    ),
                  ),
                  const TextSpan(text: ' хүрээнд хамгаалагдсан байна.'),
                ],
              ),
              style: inter(
                size: 11,
                weight: FontWeight.w500,
                color: AppColors.sky700,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inserts thousands separators while typing (`15000` → `15,000`).
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

/// Groups digits with spaces (`[4, 4, 2]` → `5049 8219 02`).
class _GroupFormatter extends TextInputFormatter {
  _GroupFormatter(this.groups);

  final List<int> groups;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final max = groups.fold(0, (a, b) => a + b);
    final oldDigits = oldValue.text.replaceAll(RegExp(r'\D'), '');
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    // Deleting a separator space removes the digit before it.
    if (newValue.text.length < oldValue.text.length &&
        digits == oldDigits &&
        digits.isNotEmpty) {
      digits = digits.substring(0, digits.length - 1);
    }
    if (digits.length > max) digits = digits.substring(0, max);
    final buf = StringBuffer();
    var i = 0;
    for (final g in groups) {
      if (i >= digits.length) break;
      if (buf.isNotEmpty) buf.write(' ');
      final end = (i + g).clamp(0, digits.length);
      buf.write(digits.substring(i, end));
      i = end;
    }
    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
