import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/entrance.dart';
import '../../widgets/numeric_keypad.dart';
import '../../widgets/ui.dart';
import '../../widgets/app_text.dart';

/// "Хадгаламжид орлого хийх - Keypad UI": deposit into savings.
class SavingsDepositScreen extends StatefulWidget {
  const SavingsDepositScreen({super.key});

  @override
  State<SavingsDepositScreen> createState() => _SavingsDepositScreenState();
}

class _SavingsDepositScreenState extends State<SavingsDepositScreen> {
  static const _available = 567930;
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
    showAppSnack(
      context,
      '${formatMnt(_amount)} хадгаламжид орлоо',
      mascot: Mascots.bearConfetti,
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF8FAFF);
    const keyStyle = KeypadStyle(
      keyHeight: 48,
      // Fully rounded (pill-shaped) keys.
      radius: 999,
      gap: 10,
      fontSize: 18,
      border: AppColors.slate100,
    );

    return Scaffold(
      backgroundColor: bg,
      appBar: SubPageHeader(
        title: 'Хадгаламжид орлого хийх',
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
        child: EntranceScope(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Column(
                    children: EntranceItem.list([
                      const MascotImage(
                        asset: Mascots.puppyPiggy,
                        size: 96,
                        background: bg,
                        semanticLabel: 'Mascot',
                      ),
                      const SizedBox(height: 4),
                      const StatusBadge(
                        label: 'Орлого хийх дүнгээ оруулна уу',
                        icon: Icons.savings_outlined,
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        radius: 24,
                        padding: const EdgeInsets.all(20),
                        borderColor: AppColors.slate100,
                        child: Column(
                          children: [
                            AppText(
                              'ЦЭНЭГЛЭХ ДҮН',
                              size: 11,
                              weight: FontWeight.w600,
                              color: AppColors.slate400,
                              letterSpacing: 0.8,
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              child: BalanceText(
                                _amount,
                                animate: true,
                                size: 36,
                                weight: FontWeight.w600,
                                currencySize: 28,
                                color: _amount > _available
                                    ? AppColors.rose500
                                    : AppColors.slate800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text.rich(
                              TextSpan(
                                text: 'Боломжит үлдэгдэл: ',
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.baseline,
                                    baseline: TextBaseline.alphabetic,
                                    child: BalanceText(
                                      _available,
                                      size: 14,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              style: inter(
                                size: 11,
                                color: AppColors.slate400,
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
                              child: _QuickButton(
                                label: '${q ~/ 1000}k',
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
                        icon: Icons.arrow_forward_rounded,
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
    );
  }
}

class _QuickButton extends StatelessWidget {
  const _QuickButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const _duration = Duration(milliseconds: 220);

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : _duration;
    return Semantics(
      button: true,
      selected: selected,
      child: Pressable(
        onTap: onTap,
        scale: 0.94,
        // Fill, border and text colour ease to the selected look; the chip
        // also lifts slightly so the change reads as a selection.
        child: AnimatedScale(
          scale: selected ? 1.04 : 1,
          duration: duration,
          curve: appEmphasizedDecelerate,
          child: AnimatedContainer(
            duration: duration,
            curve: appEmphasizedDecelerate,
            padding: const EdgeInsets.symmetric(vertical: 9),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.sky50 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? AppColors.sky400
                    : AppColors.slate200.withValues(alpha: 0.8),
                width: selected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sky500.withValues(
                    alpha: selected ? 0.18 : 0,
                  ),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: AnimatedDefaultTextStyle(
              duration: duration,
              curve: appEmphasizedDecelerate,
              style: inter(
                size: 12,
                weight: FontWeight.w700,
                color: selected ? AppColors.sky700 : AppColors.slate600,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
