import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/accounts.dart';
import '../../../../app/avatar.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../widgets/transaction_tile.dart';
import '../../data/tx_item.dart';
import '../widgets/kids_card_preview.dart';
import '../widgets/action_tile.dart';
import '../widgets/card_section.dart';
import '../widgets/card_summary.dart';
import '../widgets/frozen_card.dart';
import '../widgets/info_row.dart';

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
        // Split on wide windows: the card and its actions beside the details.
        child: AdaptiveSplit(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          gap: 16,
          leading: [
            FrozenCard(
              frozen: _frozen,
              child: KidsCardPreview(holder: _holder, number: _printedNumber),
            ),
            const SizedBox(height: 16),
            CardSummary(frozen: _frozen),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ActionTile(
                    icon: _showNumber
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    label: _showNumber ? 'Дугаар нуух' : 'Дугаар харах',
                    onTap: () => setState(() => _showNumber = !_showNumber),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ActionTile(
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
                  child: ActionTile(
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
          ],
          trailing: [
            CardSection(
              title: 'Картын мэдээлэл',
              children: [
                InfoRow(label: 'Картын дугаар', value: _printedNumber),
                const InfoRow(label: 'Дуусах хугацаа', value: _expiry),
                const InfoRow(label: 'Эзэмшигч', value: _holder),
                InfoRow(
                  label: 'Холбосон данс',
                  value: maskIban(Accounts.main),
                  last: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            CardSection(
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
          ],
        ),
      ),
    );
  }
}
