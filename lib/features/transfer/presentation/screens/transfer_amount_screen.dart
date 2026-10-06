import 'package:flutter/material.dart';

import '../../../../app/accounts.dart';
import '../../../../app/avatar.dart';
import '../../../../widgets/avatar_card_art.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/kid_profile.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/numeric_keypad.dart';
import '../../../../widgets/ui.dart';
import '../../../savings/presentation/widgets/quick_button.dart';
import '../widgets/limit_note.dart';

/// "Гүйлгээний дүн": the first step of a transfer. The teen types the amount
/// on a keypad, then picks the recipient on [AppRoutes.transfer], which gets
/// the amount through `extra`.
///
/// The amount must fit both the balance and what is left of today's limit
/// ([Limits.leftToday]) before Үргэлжлүүлэх is enabled.
///
/// With [request] it is the first step of "Мөнгө хүсэх" instead
/// ([AppRoutes.requestAmount] → [AppRoutes.requestMoney]): money comes in, so
/// neither the balance nor the limit applies.
class TransferAmountScreen extends StatefulWidget {
  const TransferAmountScreen({super.key, this.request = false});

  final bool request;

  @override
  State<TransferAmountScreen> createState() => _TransferAmountScreenState();
}

class _TransferAmountScreenState extends State<TransferAmountScreen> {
  static const _maxDigits = 9;
  static const _quick = [5000, 10000, 20000, 50000];

  int _amount = 0;

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

  /// Why the amount can't be sent, shown under it.
  String? get _error {
    if (widget.request) return null;
    if (_amount > Balances.main) return 'Үлдэгдэл хүрэлцэхгүй байна';
    if (_amount > Limits.leftToday) {
      return 'Өнөөдрийн үлдэгдэл эрх ${formatMnt(Limits.leftToday)}';
    }
    return null;
  }

  bool get _valid => _amount > 0 && _error == null;

  void _continue() => context.push(
    widget.request ? AppRoutes.requestMoney : AppRoutes.transfer,
    extra: _amount,
  );

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.surface;
    final error = _error;
    final request = widget.request;
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
        title: request ? 'Мөнгө хүсэх' : 'Гүйлгээний дүн',
        subtitle: request ? 'Эцэг эхээсээ' : 'Үндсэн данс',
        background: bg,
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
                        AvatarCardArt(
                          sticker: request ? Stickers.coin : Stickers.transfer,
                          account: Accounts.main,
                          size: 80,
                          child: AppCard(
                            // The amount is centred in the space left of
                            // the sticker, not under it.
                            padding: EdgeInsets.fromLTRB(
                              20,
                              20,
                              Stickers.onCards ? 96 : 20,
                              20,
                            ),
                            child: Column(
                              children: [
                                AppText(
                                  request ? 'Хүсэх дүн' : 'Илгээх дүн',
                                  size: 13,
                                  weight: FontWeight.w500,
                                  color: AppColors.slate500,
                                ),
                                const SizedBox(height: 4),
                                FittedBox(
                                  child: BalanceText(
                                    _amount,
                                    size: 40,
                                    weight: FontWeight.w600,
                                    currencyWeight: FontWeight.w600,
                                    color: error != null
                                        ? AppColors.rose600
                                        : AppColors.slate900,
                                    currencyColor: error != null
                                        ? AppColors.rose600
                                        : AppColors.slate500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Semantics(
                                  liveRegion: true,
                                  child: error != null
                                      ? AppText(
                                          error,
                                          size: 13,
                                          weight: FontWeight.w500,
                                          color: AppColors.rose600,
                                          textAlign: TextAlign.center,
                                        )
                                      : Text.rich(
                                          TextSpan(
                                            text: request
                                                ? 'Үндсэн дансны үлдэгдэл '
                                                : 'Боломжит үлдэгдэл ',
                                            children: [
                                              WidgetSpan(
                                                alignment: PlaceholderAlignment
                                                    .baseline,
                                                baseline:
                                                    TextBaseline.alphabetic,
                                                child: BalanceText(
                                                  Balances.main,
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
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            for (final (i, q) in _quick.indexed) ...[
                              if (i > 0) const SizedBox(width: 8),
                              Expanded(
                                // Sets the amount (not adds to it); stays
                                // selected until the keypad changes it.
                                child: QuickButton(
                                  label: '₮${q ~/ 1000}k',
                                  selected: _amount == q,
                                  onTap: () => setState(() => _amount = q),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (!request) ...[
                          const SizedBox(height: 12),
                          AppCard(
                            padding: const EdgeInsets.all(16),
                            child: LimitNote(amount: _amount),
                          ),
                        ],
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
                          label: 'Үргэлжлүүлэх',
                          onPressed: _valid ? _continue : null,
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
