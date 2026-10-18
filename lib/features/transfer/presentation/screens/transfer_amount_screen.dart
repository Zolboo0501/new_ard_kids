import 'package:flutter/material.dart';

import '../../../../app/avatar.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../app/kid_profile.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/numeric_keypad.dart';
import '../../../../widgets/ui.dart';
import '../../../savings/presentation/widgets/quick_button.dart';
import '../../../auth/presentation/widgets/submit_button.dart';
import '../../../../widgets/avatar_tour.dart';

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

class _TransferAmountScreenState extends State<TransferAmountScreen>
    with AvatarTourHost {
  /// What the first-visit tour points at.
  final _amountKey = GlobalKey();
  final _quickKey = GlobalKey();
  final _keypadKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // The first visit: the avatar walks the teen through this screen.
    startAvatarTour(widget.request ? 'request_amount' : 'transfer_amount', () {
      final name = appAvatar.value.name;
      return [
        AvatarTourStep(
          text: widget.request
              ? 'Би $name. Эцэг эхээсээ мөнгө хүсэх амархан, хамт хийцгээе!'
              : 'Би $name. Найз, эцэг эхдээ мөнгө илгээхийг хамт хийцгээе!',
        ),
        AvatarTourStep(
          target: _amountKey,
          text: widget.request
              ? 'Хүсэх дүн чинь энд харагдана.'
              : 'Илгээх дүн энд харагдана. Боломжит үлдэгдлээсээ хэтрүүлж болохгүй шүү.',
        ),
        AvatarTourStep(
          target: _quickKey,
          text: 'Түгээмэл дүнгээс нэг товшоод сонгож болно.',
        ),
        AvatarTourStep(
          target: _keypadKey,
          text: 'Эсвэл дүнгээ энэ товчлуураар бичээд, Үргэлжлүүлэх дараарай.',
        ),
      ];
    });
  }

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

  void _continue() {
    if (!_valid) return;
    context.push(
      widget.request ? AppRoutes.requestMoney : AppRoutes.transfer,
      extra: _amount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.surface;
    final error = _error;
    final request = widget.request;
    const keyStyle = KeypadStyle(
      keyHeight: 52,
      // Fully rounded (pill-shaped) keys.
      radius: 999,
      gap: 10,
      fontSize: 22,
    );

    return Scaffold(
      backgroundColor: bg,
      appBar: SubPageHeader(
        title: request ? 'Мөнгө хүсэх' : 'Гүйлгээний дүн',
        background: bg,
        // The requests already sent and their answers.
        trailing: request
            ? CircleIconButton(
                icon: Iconsax.clock_copy,
                label: 'Хүсэлтийн жагсаалт',
                onPressed: () => context.push(AppRoutes.requestList),
              )
            : null,
      ),
      body: SafeArea(
        top: false,
        // The amount and keypad stay a phone-width panel on wide windows.
        child: AdaptiveCenter(
          child: EntranceScope(
            child: Column(
              children: [
                // The amount, big and alone in the middle of the free space:
                // the one thing this step is about.
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: EntranceItem.list([
                          KeyedSubtree(
                            key: _amountKey,
                            child: _buildAmount(error),
                          ),
                          const SizedBox(height: 24),
                          KeyedSubtree(
                            key: _quickKey,
                            child: Row(
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
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),
                // The keypad rises in last, after the amount.
                EntranceItem(
                  index: 3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Column(
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 340),
                          child: KeyedSubtree(
                            key: _keypadKey,
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
                                  size: 20,
                                  weight: FontWeight.w700,
                                  color: AppColors.slate500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SubmitButton(
                          label: 'Үргэлжлүүлэх',
                          dimmed: !_valid,
                          onPressed: _continue,
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

  /// The label, the amount, and one line under it: what is wrong, or what
  /// can be sent (the balance, and for a transfer today's limit too).
  Widget _buildAmount(String? error) {
    final request = widget.request;
    final ink = error != null ? AppColors.rose600 : AppColors.slate900;
    final note = inter(size: 13, color: AppColors.slate500);
    final strong = moneyStyle(
      size: 13,
      weight: FontWeight.w600,
      color: AppColors.slate700,
    );
    return Column(
      children: [
        AppText(
          request ? 'Хүсэх дүн' : 'Илгээх дүн',
          size: 14,
          weight: FontWeight.w500,
          color: AppColors.slate500,
        ),
        const SizedBox(height: 6),
        FittedBox(
          child: BalanceText(
            _amount,
            size: 56,
            weight: FontWeight.w700,
            currencyWeight: FontWeight.w600,
            color: ink,
            currencyColor: error != null
                ? AppColors.rose600
                : AppColors.slate400,
          ),
        ),
        const SizedBox(height: 10),
        Semantics(
          liveRegion: true,
          child: error != null
              ? AppText(
                  error,
                  size: 13,
                  weight: FontWeight.w600,
                  color: AppColors.rose600,
                  textAlign: TextAlign.center,
                )
              : Text.rich(
                  TextSpan(
                    text: request ? 'Үндсэн данс ' : 'Боломжит үлдэгдэл ',
                    children: [
                      TextSpan(text: formatMnt(Balances.main), style: strong),
                      if (!request) ...[
                        // Its own line, so neither half wraps mid-phrase.
                        const TextSpan(text: '\nӨнөөдөр '),
                        TextSpan(
                          text: formatMnt(Limits.leftToday),
                          style: strong,
                        ),
                        const TextSpan(text: ' илгээж болно'),
                      ],
                    ],
                  ),
                  style: note.copyWith(height: 1.6),
                  textAlign: TextAlign.center,
                ),
        ),
      ],
    );
  }
}
