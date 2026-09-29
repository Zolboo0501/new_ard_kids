import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/kid_profile.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/numeric_keypad.dart';
import '../../../../widgets/ui.dart';
import '../widgets/quick_button.dart';

/// "Хадгаламжид орлого хийх - Keypad UI": deposit into savings.
class SavingsDepositScreen extends StatefulWidget {
  const SavingsDepositScreen({super.key});

  @override
  State<SavingsDepositScreen> createState() => _SavingsDepositScreenState();
}

class _SavingsDepositScreenState extends State<SavingsDepositScreen> {
  static const _available = Balances.main;
  static const _maxDigits = 9;
  static const _quick = [10000, 20000, 50000, 100000];

  int _amount = 50000;

  void _digit(String d) {
    final next = '${_amount == 0 ? '' : _amount}$d';
    if (next.length > _maxDigits) return;
    setState(() => _amount = int.parse(next));
  }

  void _backspace() {
    final s = '$_amount';
    setState(
      () =>
          _amount = s.length <= 1 ? 0 : int.parse(s.substring(0, s.length - 1)),
    );
  }

  bool get _valid => _amount > 0 && _amount <= _available;

  void _submit() {
    // TODO: call the savings deposit API.
    showAppSnack(context, '${formatMnt(_amount)} хадгаламжид орлоо');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.surface;
    const keyStyle = KeypadStyle(
      keyHeight: 48,
      // Fully rounded (pill-shaped) keys.
      radius: 999,
      gap: 10,
      fontSize: 18,
    );

    return Scaffold(
      backgroundColor: bg,
      appBar: SubPageHeader(
        title: 'Орлого хийх',
        subtitle: 'Хадгаламжийн данс',
        background: bg,
        trailing: CircleIconButton(
          icon: Icons.info_outline_rounded,
          label: 'Мэдээлэл',
          onPressed: () => showAppSnack(
            context,
            'Орлого хийсэн мөнгө жилийн 13.5% хүүтэй хадгалагдана',
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        // The amount and keypad stay a phone-width panel on wide windows.
        child: AdaptiveCenter(
          child: EntranceScope(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Column(
                      children: EntranceItem.list([
                        AppCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              AppText(
                                'Дүн',
                                size: 13,
                                weight: FontWeight.w500,
                                color: AppColors.slate500,
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                // Like the Home balance card: rolls in from ₮0
                                // when the screen opens, then rolls between
                                // values as the keypad changes it.
                                child: BalanceText(
                                  _amount,
                                  animateFrom: 0,
                                  size: 40,
                                  weight: FontWeight.w600,
                                  currencyWeight: FontWeight.w600,
                                  color: _amount > _available
                                      ? AppColors.rose600
                                      : AppColors.slate900,
                                  currencyColor: _amount > _available
                                      ? AppColors.rose600
                                      : AppColors.slate500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text.rich(
                                TextSpan(
                                  text: 'Үндсэн дансны үлдэгдэл ',
                                  children: [
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.baseline,
                                      baseline: TextBaseline.alphabetic,
                                      child: BalanceText(
                                        _available,
                                        size: 13,
                                        weight: FontWeight.w600,
                                        color: AppColors.slate700,
                                      ),
                                    ),
                                  ],
                                ),
                                style: inter(
                                  size: 13,
                                  color: AppColors.slate500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            for (final (i, q) in _quick.indexed) ...[
                              if (i > 0) const SizedBox(width: 8),
                              Expanded(
                                // Sets the amount (not adds to it); stays selected
                                // until the keypad changes the amount.
                                child: QuickButton(
                                  label: '₮${q ~/ 1000}k',
                                  selected: _amount == q,
                                  onTap: () => setState(() => _amount = q),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ]),
                    ),
                  ),
                ),
                // The keypad panel rises in last, after the amount card.
                EntranceItem(
                  index: 4,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Column(
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 340),
                          child: NumericKeypad(
                            style: keyStyle,
                            onDigit: _digit,
                            onBackspace: _backspace,
                            bottomLeft: KeypadKey(
                              style: keyStyle,
                              background: AppColors.slate50,
                              semanticLabel: 'Цэвэрлэх',
                              onTap: () => setState(() => _amount = 0),
                              child: AppText(
                                'C',
                                size: 18,
                                weight: FontWeight.w700,
                                color: AppColors.slate500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        PrimaryButton(
                          label: 'Орлого хийх',
                          onPressed: _valid ? _submit : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
