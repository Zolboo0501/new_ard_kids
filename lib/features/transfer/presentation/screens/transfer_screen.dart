import 'package:flutter/material.dart';

import '../../../../app/accounts.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../app/kid_profile.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_tabs.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/input_formatters.dart';
import '../../../../widgets/pin_code_sheet.dart';
import '../../../../widgets/ui.dart';
import '../../data/known_account.dart';
import '../../data/transfer_contact.dart';
import '../../data/transfer_receipt.dart';
import '../widgets/account_search_sheet.dart';
import '../widgets/clear_button.dart';
import '../widgets/mode_tabs.dart';
import '../widgets/pin_summary.dart';
import '../widgets/search_button.dart';
import '../../../auth/presentation/widgets/submit_button.dart';
import '../widgets/transfer_contact_avatar.dart';
import '../widgets/transfer_label.dart';
import '../widgets/verified_name.dart';

enum TransferMode { friends, account, phone }

/// "Гүйлгээ хийх": send money to a saved contact, a bank account or a phone
/// number.
///
/// The amount is typed on [AppRoutes.transferAmount] (which checks it against
/// the balance and [Limits.leftToday]) and only shown here. The recipient
/// shown in the PIN sheet is always derived from the number in the field, so
/// the two can't disagree.
class TransferScreen extends StatefulWidget {
  const TransferScreen({
    super.key,
    this.initialMode = TransferMode.friends,
    this.initialAmount,
  });

  final TransferMode initialMode;

  /// The amount typed on [AppRoutes.transferAmount]; shown, not edited, here.
  final int? initialAmount;

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  static const _banks = ['Хаан банк', 'Голомт банк', 'ХХБ', 'Төрийн банк'];
  static const _contacts = TransferContact.saved;
  static const _purposes = ['Хоол', 'Тээвэр', 'Хувцас', 'Тоглоом/Апп', 'Бусад'];

  late TransferMode _mode = widget.initialMode;
  int _bank = 0;
  int? _purpose = 0;

  /// The saved-contact tab's account number. The contact it belongs to (if
  /// any) is looked up from it, never stored separately.
  final _recipient = TextEditingController(text: _contacts.first.account);

  /// The Дансаар tab's account number, as an IBAN; the search sheet fills it.
  final _iban = TextEditingController();
  final _phone = TextEditingController(text: _contacts.last.phone);
  final _note = TextEditingController(text: _purposes.first);

  /// Who holds the account the teen picked in the search sheet.
  String? _accountHolder;

  @override
  void initState() {
    super.initState();
    for (final c in [_recipient, _phone, _iban]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_recipient, _phone, _note, _iban]) {
      c.dispose();
    }
    super.dispose();
  }

  static String _digits(String s) => s.replaceAll(RegExp(r'\D'), '');

  int get _amountValue => widget.initialAmount ?? 15000;

  /// The saved contact whose account is in the field, if any.
  TransferContact? get _contact {
    final digits = _digits(_recipient.text);
    for (final c in _contacts) {
      if (_digits(c.account) == digits) return c;
    }
    return null;
  }

  /// The saved contact whose phone is in the field, if any.
  TransferContact? get _phoneContact {
    final digits = _digits(_phone.text);
    for (final c in _contacts) {
      if (_digits(c.phone) == digits) return c;
    }
    return null;
  }

  /// Opens the sheet that finds an account by its plain number; the one the
  /// teen picks there fills the IBAN field and becomes the recipient.
  Future<void> _searchAccount() async {
    FocusScope.of(context).unfocus();
    final account = await showModalBottomSheet<KnownAccount>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
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
    TransferMode.friends => _contact?.name ?? '${_recipient.text} данс',
    TransferMode.account => _accountHolder ?? '',
    TransferMode.phone => _phoneContact?.name ?? '',
  };

  bool get _valid {
    // The amount screen already checks these; kept as a last guard.
    final amount = _amountValue;
    if (amount <= 0 || amount > Balances.main || amount > Limits.leftToday) {
      return false;
    }
    return switch (_mode) {
      TransferMode.phone => _phoneContact != null,
      TransferMode.account => _accountHolder != null,
      TransferMode.friends => _digits(_recipient.text).length == 10,
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
    final phoneContact = _phoneContact;
    final receipt = TransferReceipt(
      amount: _amountValue,
      recipient: _recipientName,
      bank: switch (_mode) {
        TransferMode.friends => _contact?.bank ?? _banks[_bank],
        TransferMode.account => _banks[_bank],
        TransferMode.phone => phoneContact?.bank ?? _banks.first,
      },
      destination: switch (_mode) {
        TransferMode.friends => _recipient.text,
        TransferMode.account => _iban.text,
        TransferMode.phone => '${_phone.text} / ${phoneContact?.account}',
      },
      note: _note.text.trim().isEmpty ? '—' : _note.text.trim(),
      balanceAfter: Balances.main - _amountValue,
      time: DateTime.now(),
    );
    context.pushReplacement(AppRoutes.transferSuccess, extra: receipt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: SubPageHeader(
        title: 'Гүйлгээ хийх',
        background: AppColors.surface,
        trailing: CircleIconButton(
          icon: Iconsax.scan_barcode_copy,
          label: 'QR код уншуулах',
          onPressed: () => context.go(AppRoutes.qrScan),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: EntranceScope(
              child: AdaptiveListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: EntranceItem.list([
                  _buildAmountSummary(),
                  const SizedBox(height: 20),
                  ModeTabs(
                    mode: _mode,
                    onChanged: (m) => setState(() => _mode = m),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    // Each mode's recipient fields slide in along the tabs'
                    // direction, and the card eases to the new height.
                    child: AppTabView(
                      index: _mode.index,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: switch (_mode) {
                          TransferMode.friends => _buildContacts(),
                          TransferMode.account => _buildAccount(),
                          TransferMode.phone => _buildPhone(),
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildNote(),
                ]),
              ),
            ),
          ),
          // The action stays in reach however far the form scrolls.
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              12 + MediaQuery.paddingOf(context).bottom,
            ),
            child: AdaptiveCenter(
              child: SubmitButton(
                label: 'Гүйлгээ хийх',
                dimmed: !_valid,
                onPressed: () {
                  if (_valid) _confirm();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The amount from the first step, with a way back to change it.
  Widget _buildAmountSummary() {
    final iban = Accounts.main;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Илгээх дүн · Үндсэн данс ••${iban.substring(iban.length - 4)}',
                size: 13,
                color: AppColors.slate500,
              ),
              const SizedBox(height: 2),
              BalanceText(
                _amountValue,
                size: 34,
                weight: FontWeight.w700,
                currencyWeight: FontWeight.w600,
                color: AppColors.slate900,
                currencyColor: AppColors.slate400,
              ),
            ],
          ),
        ),
        SoftButton(
          label: 'Өөрчлөх',
          height: 40,
          onPressed: () => context.pop(),
        ),
      ],
    );
  }

  /// What the money is for: a tap on a common purpose, or Бусад to write
  /// one.
  Widget _buildNote() {
    final other = _purpose == _purposes.length - 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TransferLabel('Гүйлгээний утга'),
        _chipRow(
          count: _purposes.length,
          label: (i) => _purposes[i],
          selected: (i) => _purpose == i,
          onTap: (i) {
            setState(() => _purpose = i);
            // Бусад leaves the note for the teen to write.
            _note.text = i == _purposes.length - 1 ? '' : _purposes[i];
          },
        ),
        // Only Бусад needs typing; the chips cover the rest.
        AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: appEmphasizedDecelerate,
          alignment: Alignment.topCenter,
          child: other
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: AppTextField(
                    controller: _note,
                    hint: 'Жишээ нь: Төрсөн өдрийн бэлэг',
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  /// A horizontal row of neutral chips.
  Widget _chipRow({
    required int count,
    required String Function(int) label,
    required bool Function(int) selected,
    required void Function(int) onTap,
  }) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => Center(
          child: FilterChipPill(
            label: label(i),
            selected: selected(i),
            onTap: () => onTap(i),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContacts() {
    final contact = _contact;
    return [
      AppText('Хүлээн авагч', size: 16, weight: FontWeight.w700),
      const SizedBox(height: 12),
      SizedBox(
        height: 80,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            TransferContactAvatar(
              label: 'Нэмэх',
              onTap: () => context.push(AppRoutes.addFriend),
            ),
            for (final c in _contacts)
              TransferContactAvatar(
                label: c.name,
                initials: c.initials,
                selected: identical(contact, c),
                onTap: () => _recipient.text = c.account,
              ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      const TransferLabel('Дансны дугаар'),
      AppTextField(
        controller: _recipient,
        hint: '10 оронтой дансны дугаар',
        keyboardType: TextInputType.number,
        inputFormatters: [
          DigitGroupFormatter(const [4, 4, 2]),
        ],
        suffix: _recipient.text.isEmpty
            ? null
            : ClearButton(onTap: () => _recipient.clear()),
      ),
      // A saved contact's account shows its verified holder.
      if (contact != null)
        VerifiedName(name: contact.holder, detail: contact.bank),
    ];
  }

  List<Widget> _buildAccount() {
    return [
      const TransferLabel('Дансны дугаар'),
      AppTextField(
        controller: _iban,
        hint: 'MN00 0000 0000 0000 0000',
        keyboardType: TextInputType.number,
        inputFormatters: [IbanFormatter()],
        // The IBAN is 24 characters, so it drops a size to fit next to Хайх.
        textStyle: moneyStyle(
          size: 13,
          weight: FontWeight.w600,
          color: AppColors.slate900,
        ),
        onChanged: (_) => _clearAccount(),
        suffix: SearchButton(onTap: _searchAccount),
      ),
      if (_accountHolder != null)
        VerifiedName(name: _accountHolder!, detail: 'Хүлээн авагч баталгаажсан')
      else
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 4),
          child: AppText(
            'Хайх дарж дансны дугаараар хүлээн авагчаа олно уу',
            size: 12,
            color: AppColors.slate500,
          ),
        ),
    ];
  }

  List<Widget> _buildPhone() {
    final contact = _phoneContact;
    final complete = _digits(_phone.text).length == 8;
    return [
      const TransferLabel('Хадгалсан дугаар'),
      _chipRow(
        count: _contacts.length,
        label: (i) => _contacts[i].name,
        selected: (i) => identical(contact, _contacts[i]),
        onTap: (i) => _phone.text = _contacts[i].phone,
      ),
      const SizedBox(height: 14),
      const TransferLabel('Утасны дугаар'),
      AppTextField(
        controller: _phone,
        hint: '8 оронтой утасны дугаар',
        keyboardType: TextInputType.phone,
        inputFormatters: [
          DigitGroupFormatter(const [4, 4]),
        ],
        suffix: _phone.text.isEmpty
            ? null
            : ClearButton(onTap: () => _phone.clear()),
      ),
      if (contact != null)
        VerifiedName(
          name: contact.holder,
          detail: '${contact.bank} · ${contact.maskedPhone}',
        )
      else if (complete)
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 4),
          child: AppText(
            'Энэ дугаартай данс олдсонгүй',
            size: 12,
            weight: FontWeight.w500,
            color: AppColors.rose600,
          ),
        ),
    ];
  }
}
