import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/accounts.dart';
import '../../app/avatar.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_text.dart';
import '../../widgets/entrance.dart';
import '../../widgets/ui.dart';
import 'account_widgets.dart';
import 'card_order_screen.dart';

/// "Миний карт": the kid's active Junior Card, opened from Home's Карт tab.
/// Shows the card, its details and daily limit, lets the kid freeze it, and
/// lists recent card payments.
class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  // Mock card until it comes from the API.
  static const _number = '4000123456785521';
  static const _holder = 'ТЭМҮҮЛЭН Б.';
  static const _expiry = '08/28';
  static const _spentToday = 35000;
  static const _dailyLimit = 100000;

  static List<TxItem> get _payments {
    final today = DateTime.now();
    return [
      TxItem(
        title: 'Номын дэлгүүр',
        subtitle: 'Картаар',
        date: today,
        amount: -12000,
        asset: Stickers.books,
      ),
      TxItem(
        title: 'Амттан',
        subtitle: 'Контактгүй',
        date: today.subtract(const Duration(days: 1)),
        amount: -4500,
        asset: Stickers.snack,
      ),
      TxItem(
        title: 'Тоглоомын төв',
        subtitle: 'Картаар',
        date: today.subtract(const Duration(days: 3)),
        amount: -18500,
        asset: Stickers.games,
      ),
    ];
  }

  bool _showNumber = false;
  bool _frozen = false;

  String get _printedNumber {
    if (!_showNumber) return '•••• •••• •••• ${_number.substring(12)}';
    return [
      for (var i = 0; i < _number.length; i += 4) _number.substring(i, i + 4),
    ].join(' ');
  }

  void _toggleFrozen() {
    // TODO: freeze / unfreeze the card with the backend.
    setState(() => _frozen = !_frozen);
    showAppSnack(context, _frozen ? 'Карт түр хаагдлаа' : 'Карт нээгдлээ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPageBackground,
      appBar: const SubPageHeader(title: 'Миний карт'),
      body: EntranceScope(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: EntranceItem.list([
            _FrozenCard(
              frozen: _frozen,
              child: KidsCardPreview(holder: _holder, number: _printedNumber),
            ),
            const SizedBox(height: 16),
            _Summary(frozen: _frozen),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _ActionTile(
                    icon: _showNumber
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    label: _showNumber ? 'Дугаар нуух' : 'Дугаар харах',
                    onTap: () => setState(() => _showNumber = !_showNumber),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionTile(
                    icon: _frozen
                        ? Icons.lock_open_rounded
                        : Icons.ac_unit_rounded,
                    label: _frozen ? 'Карт нээх' : 'Түр хаах',
                    highlighted: _frozen,
                    onTap: _toggleFrozen,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionTile(
                    icon: Icons.content_copy_rounded,
                    label: 'Дугаар хуулах',
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: _number));
                      showAppSnack(context, 'Картын дугаар хуулагдлаа');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Картын мэдээлэл',
              children: [
                _InfoRow(label: 'Картын дугаар', value: _printedNumber),
                const _InfoRow(label: 'Дуусах хугацаа', value: _expiry),
                const _InfoRow(label: 'Эзэмшигч', value: _holder),
                _InfoRow(
                  label: 'Холбосон данс',
                  value: maskIban(Accounts.main),
                  last: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Өдрийн лимит',
              trailing: AppText(
                'Аав ээж тохируулсан',
                size: 10,
                weight: FontWeight.w600,
                color: AppColors.slate400,
              ),
              children: [
                Row(
                  children: [
                    BalanceText(
                      _spentToday,
                      size: 18,
                      weight: FontWeight.w700,
                      decimals: false,
                    ),
                    AppText(
                      ' / ${formatMnt(_dailyLimit)}',
                      size: 12,
                      weight: FontWeight.w600,
                      color: AppColors.slate400,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const ProgressTrack(value: _spentToday / _dailyLimit),
                const SizedBox(height: 8),
                AppText(
                  'Өнөөдөр ${formatMnt(_dailyLimit - _spentToday)} зарцуулах боломжтой',
                  size: 11,
                  color: AppColors.slate500,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const SectionHeader(title: 'Сүүлийн гүйлгээ'),
            for (final item in _payments) ...[
              TransactionTile(item: item),
              const SizedBox(height: 8),
            ],
          ]),
        ),
      ),
    );
  }
}

/// Greys the card out and stamps it "Түр хаасан" while it's frozen.
class _FrozenCard extends StatelessWidget {
  const _FrozenCard({required this.frozen, required this.child});

  final bool frozen;
  final Widget child;

  static const _grey = ColorFilter.matrix([
    0.33, 0.33, 0.33, 0, 0, //
    0.33, 0.33, 0.33, 0, 0,
    0.33, 0.33, 0.33, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  static const _none = ColorFilter.matrix([
    1, 0, 0, 0, 0, //
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ColorFiltered(colorFilter: frozen ? _grey : _none, child: child),
        IgnorePointer(
          child: AnimatedScale(
            scale: frozen ? 1 : 0.8,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              opacity: frozen ? 1 : 0,
              duration: const Duration(milliseconds: 160),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.slate900.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.ac_unit_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    AppText(
                      'Түр хаасан',
                      size: 12,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The card's name, status and the account it spends from.
class _Summary extends StatelessWidget {
  const _Summary({required this.frozen});

  final bool frozen;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('Junior Card', size: 18, weight: FontWeight.w700),
              const SizedBox(height: 2),
              AppText(
                'Халаасны үндсэн данс',
                size: 11,
                weight: FontWeight.w500,
                color: AppColors.slate500,
              ),
            ],
          ),
        ),
        frozen
            ? const StatusBadge(
                label: 'Түр хаасан',
                tone: BadgeTone.amber,
                icon: Icons.ac_unit_rounded,
              )
            : const StatusBadge(label: 'Идэвхтэй', tone: BadgeTone.emerald),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: AppCard(
        onTap: withHaptic(onTap),
        radius: 18,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        color: highlighted ? AppColors.sky500 : Colors.white,
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: highlighted
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppColors.sky50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 18,
                color: highlighted ? Colors.white : AppColors.sky600,
              ),
            ),
            const SizedBox(height: 6),
            AppText(
              label,
              size: 11,
              weight: FontWeight.w700,
              color: highlighted ? Colors.white : AppColors.slate700,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children, this.trailing});

  final String title;
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 22,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(title, size: 14, weight: FontWeight.w700),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.last = false});

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: AppColors.slate100)),
      ),
      child: Row(
        children: [
          AppText(label, size: 12, color: AppColors.slate500),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: moneyStyle(size: 13, color: AppColors.slate900),
            ),
          ),
        ],
      ),
    );
  }
}
