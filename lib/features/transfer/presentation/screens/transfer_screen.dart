import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/avatar.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_tabs.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/input_formatters.dart';
import '../../../../widgets/pin_code_sheet.dart';
import '../../../../widgets/ui.dart';
import '../../data/known_account.dart';
import '../../data/transfer_receipt.dart';
import '../widgets/account_search_sheet.dart';
import '../widgets/clear_button.dart';
import '../widgets/friend_avatar.dart';
import '../widgets/limit_note.dart';
import '../widgets/mode_tabs.dart';
import '../widgets/pin_summary.dart';
import '../widgets/search_button.dart';
import '../widgets/small_chip.dart';
import '../widgets/source_card.dart';
import '../widgets/transfer_collapse.dart';
import '../widgets/transfer_label.dart';
import '../widgets/verified_name.dart';

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
    final account = await showModalBottomSheet<KnownAccount>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const AccountSearchSheet(),
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
      summary: PinSummary(amount: _amountValue, recipient: _recipientName),
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
            SourceCard(showAccount: _mode != TransferMode.friends),
            const SizedBox(height: 16),
            ModeTabs(mode: _mode, onChanged: (m) => setState(() => _mode = m)),
            const SizedBox(height: 16),
            // The saved-friends strip only belongs to the friends mode; it
            // folds open and closed rather than popping in and out.
            TransferCollapse(
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
                          const TransferLabel('Банк сонгох'),
                          _buildBankChips(),
                          const SizedBox(height: 14),
                          ..._buildAccountField(label: 'Дансны дугаар'),
                        ],
                        TransferMode.phone => _buildPhoneFields(),
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const TransferLabel('Гүйлгээний дүн'),
                  AppTextField(
                    controller: _amount,
                    prefixText: '₮',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      ThousandsFormatter(),
                    ],
                    textStyle: moneyStyle(size: 20, color: AppColors.slate900),
                    onChanged: (_) => setState(() => _quick = null),
                    suffix: ClearButton(onTap: () => _amount.clear()),
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
                  TransferCollapse(
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
                  const TransferLabel('Гүйлгээний утга'),
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
                        SmallChip(
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
            const LimitNote(),
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
              FriendAvatar(
                label: 'Нэмэх',
                onTap: () => context.push(AppRoutes.addFriend),
              ),
              for (final (i, f) in _friends.indexed)
                FriendAvatar(
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
      TransferLabel(label),
      AppTextField(
        controller: showBanksBelow ? _recipient : _iban,
        hint: showBanksBelow
            ? '10 оронтой дансны дугаар оруулна уу'
            : 'MN00 0000 0000 0000 0000',
        keyboardType: TextInputType.number,
        inputFormatters: [
          showBanksBelow
              ? DigitGroupFormatter(const [4, 4, 2])
              : IbanFormatter(),
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
            : SearchButton(onTap: _searchAccount),
      ),
      if (showBanksBelow) ...[
        const SizedBox(height: 10),
        _buildBankChips(),
      ] else if (_accountHolder != null)
        VerifiedName(
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
      const TransferLabel('Хурдан сонгох'),
      SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _phones.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) => SmallChip(
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
      const TransferLabel('Утасны дугаар'),
      AppTextField(
        controller: _phone,
        hint: '8 оронтой утасны дугаар оруулна уу',
        keyboardType: TextInputType.phone,
        inputFormatters: [
          DigitGroupFormatter(const [4, 4]),
        ],
        suffix: Icon(
          Icons.contact_phone_outlined,
          size: 20,
          color: AppColors.sky600,
        ),
      ),
      VerifiedName(
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
        itemBuilder: (_, i) => SmallChip(
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
