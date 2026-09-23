import 'dart:async';

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
import '../../widgets/pin_code_sheet.dart';
import '../../widgets/value_switcher.dart';
import '../../app/avatar.dart';

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
  static List<(String, String, Color, String)> get _friends => [
    ('Анар (Дүү)', Stickers.siblings, AppColors.amber100, '5049 8219 02'),
    ('Мишээл', Stickers.love, AppColors.emerald100, '5049 7712 45'),
    ('Аав', Stickers.dad, const Color(0xFFDBEAFE), '5049 1102 33'),
    ('Ээж', Stickers.mom, AppColors.pink100, '5049 3321 08'),
  ];
  static List<(String, String, String, String)> get _phones => [
    ('Ээж (9911****)', Stickers.mom, '9911 2345', 'Б. Бат-Эрдэнэ'),
    ('Аав (9909****)', Stickers.dad, '9909 1188', 'Д. Ганбаатар'),
    ('Тэмүүлэн (8822****)', Stickers.friends, '8822 4411', 'Т. Тэмүүлэн'),
  ];
  static List<(String, String, String)> get _purposes => [
    (Stickers.books, 'Ном дэвтэр', 'Ном авсан'),
    (Stickers.snack, 'Амттан', 'Амттан'),
    (Stickers.games, 'Тоглоом', 'Тоглоом'),
    (Stickers.coin, 'Халаасны мөнгө', 'Халаасны мөнгө'),
  ];

  late TransferMode _mode = widget.initialMode;
  int _friend = 0;
  int _bank = 0;
  int _phonePick = 0;
  int? _quick = 10000;
  int _purpose = 0;

  final _recipient = TextEditingController(text: '5049 8219 02');

  /// The Дансаар tab's account number, as an IBAN; the search sheet fills it.
  final _iban = TextEditingController();
  final _phone = TextEditingController(text: '9911 2345');
  final _amount = TextEditingController(text: '15,000');
  final _note = TextEditingController(text: 'Ном авсан');

  /// Who holds the account the kid picked in the search sheet.
  String? _accountHolder;

  @override
  void initState() {
    super.initState();
    for (final c in [_recipient, _phone, _amount, _iban]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_recipient, _phone, _amount, _note, _iban]) {
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

  /// Opens the sheet that finds an account by its plain number; the one the
  /// kid picks there fills the IBAN field and becomes the recipient.
  Future<void> _searchAccount() async {
    FocusScope.of(context).unfocus();
    final account = await showModalBottomSheet<_KnownAccount>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const _AccountSearchSheet(),
    );
    if (account == null || !mounted) return;
    _iban.text = account.iban;
    setState(() {
      _accountHolder = account.holder;
      final bank = _banks.indexOf(account.bank);
      if (bank >= 0) _bank = bank;
    });
  }

  /// A new number or bank needs a new search.
  void _clearAccount() => setState(() => _accountHolder = null);

  String get _recipientName => switch (_mode) {
    TransferMode.friends => _friends[_friend].$1,
    TransferMode.account => _accountHolder ?? '',
    TransferMode.phone => _phones[_phonePick].$4,
  };

  bool get _valid {
    final amount = _amountValue;
    if (amount <= 0 || amount > _balance) return false;
    return switch (_mode) {
      TransferMode.phone =>
        _phone.text.replaceAll(RegExp(r'\D'), '').length == 8,
      TransferMode.account => _accountHolder != null,
      TransferMode.friends =>
        _recipient.text.replaceAll(RegExp(r'\D'), '').length == 10,
    };
  }

  /// Mock PIN until the backend checks it.
  static const _mockPin = '0000';

  Future<void> _confirm() async {
    FocusScope.of(context).unfocus();
    final ok = await showPinCodeSheet(
      context,
      title: 'Гүйлгээ баталгаажуулах',
      summary: _PinSummary(amount: _amountValue, recipient: _recipientName),
      // TODO: verify the PIN with the backend.
      onVerify: (pin) => Future.delayed(
        const Duration(milliseconds: 500),
        () => pin == _mockPin,
      ),
    );
    if (ok == true && mounted) _submit();
  }

  void _submit() {
    // TODO: call the transfer API.
    final receipt = TransferReceipt(
      amount: _amountValue,
      recipient: _recipientName,
      bank: _mode == TransferMode.account ? _banks[_bank] : 'Хаан банк',
      destination: switch (_mode) {
        TransferMode.friends => _recipient.text,
        TransferMode.account => _iban.text,
        TransferMode.phone => '${_phone.text} / 5049 8219 02',
      },
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
              onPressed: _valid ? _confirm : null,
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
        controller: showBanksBelow ? _recipient : _iban,
        hint: showBanksBelow
            ? '10 оронтой дансны дугаар оруулна уу'
            : 'MN00 0000 0000 0000 0000',
        keyboardType: TextInputType.number,
        inputFormatters: [
          showBanksBelow ? _GroupFormatter(const [4, 4, 2]) : _IbanFormatter(),
        ],
        // The IBAN is 24 characters, so it drops a size to fit next to Хайх.
        textStyle: showBanksBelow
            ? null
            : moneyStyle(
                size: 13,
                weight: FontWeight.w600,
                color: AppColors.slate900,
              ),
        onChanged: showBanksBelow ? null : (_) => _clearAccount(),
        // The Дансаар tab looks the number up; the friends tab keeps the
        // contacts icon.
        suffix: showBanksBelow
            ? Icon(Icons.contacts_outlined, size: 20, color: AppColors.sky600)
            : _SearchButton(onTap: _searchAccount),
      ),
      if (showBanksBelow) ...[
        const SizedBox(height: 10),
        _buildBankChips(),
      ] else if (_accountHolder != null)
        _VerifiedName(
          name: _accountHolder!,
          detail: '(Хүлээн авагч баталгаажсан)',
        )
      else
        Padding(
          padding: const EdgeInsets.only(top: 6, left: 4),
          child: AppText(
            'Хайх дарж дансны дугаараар хүлээн авагчаа олно уу',
            size: 11,
            color: AppColors.slate400,
          ),
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
          onTap: () {
            setState(() => _bank = i);
            if (_mode == TransferMode.account) _clearAccount();
          },
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
          MascotImage(
            asset: Stickers.payment,
            size: 110,
            background: Colors.white,
            semanticLabel: 'Гүйлгээ хийж буй маскот',
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

/// The Хайх pill at the end of the account number field.
class _SearchButton extends StatelessWidget {
  const _SearchButton({required this.onTap, this.loading = false});

  final bool loading;

  /// Null while the search can't run yet (too few digits).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Данс хайх',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: loading || onTap == null ? null : withHaptic(onTap!),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: onTap == null ? AppColors.slate300 : AppColors.sky500,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                const Icon(Icons.search_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 4),
              AppText(
                'Хайх',
                size: 12,
                weight: FontWeight.w700,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// An account the search sheet can find.
class _KnownAccount {
  const _KnownAccount({
    required this.holder,
    required this.bank,
    required this.iban,
  });

  final String holder;
  final String bank;

  /// Grouped for display: `MN24 0005 0050 4982 1902`.
  final String iban;
}

/// The bottom sheet Хайх opens: the kid types a plain account number (no
/// IBAN), searches, and sees whose account it is. Pops the account on Сонгох.
class _AccountSearchSheet extends StatefulWidget {
  const _AccountSearchSheet();

  /// Accounts by their 10-digit number, standing in for the lookup API.
  static const accounts = {
    '5049821902': _KnownAccount(
      holder: 'Б. Сүхбат',
      bank: 'Хаан банк',
      iban: 'MN24 0005 0050 4982 1902',
    ),
    '5049771245': _KnownAccount(
      holder: 'Г. Энхжин',
      bank: 'Хаан банк',
      iban: 'MN63 0005 0050 4977 1245',
    ),
    '5049110233': _KnownAccount(
      holder: 'Д. Мөнхбат',
      bank: 'Хаан банк',
      iban: 'MN66 0005 0050 4911 0233',
    ),
    '5752028915': _KnownAccount(
      holder: 'Н. Отгонбаяр',
      bank: 'Хаан банк',
      iban: 'MN21 0005 0057 5202 8915',
    ),
  };

  @override
  State<_AccountSearchSheet> createState() => _AccountSearchSheetState();
}

class _AccountSearchSheetState extends State<_AccountSearchSheet> {
  final _number = TextEditingController();
  Timer? _timer;
  bool _searching = false;
  _KnownAccount? _found;
  bool _notFound = false;

  String get _digits => _number.text.replaceAll(RegExp(r'\D'), '');

  @override
  void dispose() {
    _timer?.cancel();
    _number.dispose();
    super.dispose();
  }

  void _search() {
    FocusScope.of(context).unfocus();
    final number = _digits;
    setState(() {
      _searching = true;
      _found = null;
      _notFound = false;
    });
    // TODO: look the account up with the backend.
    _timer = Timer(const Duration(milliseconds: 500), () {
      final account = _AccountSearchSheet.accounts[number];
      setState(() {
        _searching = false;
        _found = account;
        _notFound = account == null;
      });
    });
  }

  /// Editing the number drops the last result.
  void _reset() {
    _timer?.cancel();
    setState(() {
      _searching = false;
      _found = null;
      _notFound = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final found = _found;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
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
              const SizedBox(height: 18),
              Center(
                child: AppText('Данс хайх', size: 16, weight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Center(
                child: AppText(
                  'IBAN-гүй дансны дугаараа оруулна уу',
                  size: 12,
                  color: AppColors.slate400,
                ),
              ),
              const SizedBox(height: 16),
              const _Label('Дансны дугаар'),
              AppTextField(
                controller: _number,
                hint: '10 оронтой дансны дугаар',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  _GroupFormatter(const [4, 4, 2]),
                ],
                onChanged: (_) => _reset(),
                suffix: _SearchButton(
                  loading: _searching,
                  onTap: _digits.length == 10 ? _search : null,
                ),
              ),
              if (_notFound)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: AppText(
                    'Данс олдсонгүй. Дугаараа шалгана уу.',
                    size: 11,
                    weight: FontWeight.w600,
                    color: AppColors.rose500,
                  ),
                ),
              if (found != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.emerald50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.emerald200),
                  ),
                  child: Column(
                    children: [
                      _SheetRow(label: 'Хүлээн авагч', value: found.holder),
                      const Divider(height: 1, color: AppColors.emerald100),
                      _SheetRow(label: 'Банк', value: found.bank),
                      const Divider(height: 1, color: AppColors.emerald100),
                      _SheetRow(label: 'IBAN', value: found.iban, money: true),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SoftButton(
                      label: 'Буцах',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Сонгох',
                      height: 48,
                      onPressed: found == null
                          ? null
                          : () => Navigator.of(context).pop(found),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.label,
    required this.value,
    this.money = false,
  });

  final String label;
  final String value;
  final bool money;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          AppText(label, size: 12, color: AppColors.slate500),
          const SizedBox(width: 12),
          Expanded(
            child: money
                ? Text(
                    value,
                    textAlign: TextAlign.end,
                    style: moneyStyle(size: 13, color: AppColors.slate900),
                  )
                : AppText(
                    value,
                    size: 13,
                    weight: FontWeight.w700,
                    color: AppColors.slate900,
                    textAlign: TextAlign.end,
                  ),
          ),
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

/// What the PIN confirms: the amount and who receives it.
class _PinSummary extends StatelessWidget {
  const _PinSummary({required this.amount, required this.recipient});

  final int amount;
  final String recipient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Column(
        children: [
          Text(
            formatMnt(amount),
            style: moneyStyle(size: 22, color: AppColors.slate900),
          ),
          const SizedBox(height: 2),
          AppText(
            '$recipient руу шилжүүлнэ',
            size: 12,
            weight: FontWeight.w600,
            color: AppColors.slate500,
          ),
        ],
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

/// Keeps an IBAN as `MN` plus up to 18 digits in blocks of four
/// (`MN24 0005 0050 4982 1902`). Typing a digit first adds the `MN`, and a
/// pasted IBAN with or without spaces lands the same way.
class _IbanFormatter extends TextInputFormatter {
  static String _digits(String text) {
    final compact = text.toUpperCase().replaceAll(RegExp(r'[^0-9A-Z]'), '');
    final body = compact.startsWith('MN') ? compact.substring(2) : compact;
    return body.replaceAll(RegExp(r'\D'), '');
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final oldDigits = _digits(oldValue.text);
    var digits = _digits(newValue.text);
    // Deleting a separator space removes the digit before it.
    if (newValue.text.length < oldValue.text.length &&
        digits == oldDigits &&
        digits.isNotEmpty) {
      digits = digits.substring(0, digits.length - 1);
    }
    if (digits.isEmpty) return const TextEditingValue();
    if (digits.length > 18) digits = digits.substring(0, 18);
    final text = formatIban('MN$digits');
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
