import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/input_formatters.dart';
import '../../../../widgets/ui.dart';
import '../../data/bank.dart';
import '../../data/known_account.dart';
import 'bank_picker.dart';
import 'search_button.dart';
import 'transfer_label.dart';

/// The bottom sheet Хайх opens: the kid picks the bank by its logo, types a
/// plain account number (no IBAN), searches, and sees whose account it is.
/// Pops the account on Сонгох.
///
/// Every search succeeds: a number in [accounts] shows its holder, any other
/// number gets a mock holder ([lookup]) until the backend does the lookup.
class AccountSearchSheet extends StatefulWidget {
  const AccountSearchSheet({super.key});

  /// Accounts by their 10-digit number, standing in for the lookup API.
  static const accounts = {
    '5049821902': KnownAccount(
      holder: 'Б. Сүхбат',
      bank: 'Хаан банк',
      iban: 'MN24 0005 0050 4982 1902',
    ),
    '5049771245': KnownAccount(
      holder: 'Г. Энхжин',
      bank: 'Хаан банк',
      iban: 'MN63 0005 0050 4977 1245',
    ),
    '5049110233': KnownAccount(
      holder: 'Д. Мөнхбат',
      bank: 'Хаан банк',
      iban: 'MN66 0005 0050 4911 0233',
    ),
    '5752028915': KnownAccount(
      holder: 'Н. Отгонбаяр',
      bank: 'Хаан банк',
      iban: 'MN21 0005 0057 5202 8915',
    ),
  };

  /// Mock holders for numbers not in [accounts].
  static const _holders = [
    'Б. Тэмүүлэн',
    'О. Номин',
    'Э. Билгүүн',
    'С. Ану',
    'Ц. Батзориг',
  ];

  /// The account behind [number] (any digits) at [bank] (Хаан банк by
  /// default): a known one, or a mock account with a valid IBAN, its holder
  /// picked from the number so the same number always finds the same person.
  static KnownAccount lookup(String number, {Bank? bank}) {
    bank ??= Bank.all.first;
    final known = accounts[number];
    if (known != null && known.bank == bank.name) return known;
    final digits = number.padLeft(10, '0');
    final account = digits.substring(digits.length - 10);
    final bban = '${bank.code}00$account';
    final iban = 'MN${_checkDigits(bban)}$bban';
    final seed = account.codeUnits.fold(0, (a, c) => a + c);
    return KnownAccount(
      holder: _holders[seed % _holders.length],
      bank: bank.name,
      iban: [
        for (var i = 0; i < iban.length; i += 4)
          iban.substring(i, (i + 4).clamp(0, iban.length)),
      ].join(' '),
    );
  }

  /// The two IBAN check digits for an MN [bban] (ISO 13616 mod-97).
  static String _checkDigits(String bban) {
    // M = 22, N = 23; the check digits start as 00.
    final rearranged = '${bban}222300';
    var rest = 0;
    for (final c in rearranged.codeUnits) {
      rest = (rest * 10 + c - 48) % 97;
    }
    return '${98 - rest}'.padLeft(2, '0');
  }

  @override
  State<AccountSearchSheet> createState() => _AccountSearchSheetState();
}

class _AccountSearchSheetState extends State<AccountSearchSheet> {
  final _number = TextEditingController();

  /// Index into [Bank.all].
  int _bank = 0;
  Timer? _timer;
  bool _searching = false;
  KnownAccount? _found;

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
    });
    // TODO: look the account up with the backend.
    _timer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searching = false;
        _found = AccountSearchSheet.lookup(number, bank: Bank.all[_bank]);
      });
    });
  }

  /// Editing the number drops the last result.
  void _reset() {
    _timer?.cancel();
    setState(() {
      _searching = false;
      _found = null;
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
              const TransferLabel('Банк'),
              BankPicker(
                selected: _bank,
                onChanged: (i) {
                  // Another bank needs a new search.
                  _reset();
                  setState(() => _bank = i);
                },
              ),
              const SizedBox(height: 14),
              const TransferLabel('Дансны дугаар'),
              AppTextField(
                controller: _number,
                hint: '10 оронтой дансны дугаар',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  DigitGroupFormatter(const [4, 4, 2]),
                ],
                onChanged: (_) => _reset(),
                suffix: SearchButton(
                  loading: _searching,
                  onTap: _digits.isEmpty ? null : _search,
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
                    color: AppColors.slate50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _SheetRow(label: 'Хүлээн авагч', value: found.holder),
                      Divider(height: 1, color: AppColors.line),
                      _SheetRow(label: 'Банк', value: found.bank),
                      Divider(height: 1, color: AppColors.line),
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
