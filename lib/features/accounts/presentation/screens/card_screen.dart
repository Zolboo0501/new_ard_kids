import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/accounts.dart';
import '../../../../app/kid_profile.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../../data/tx_item.dart';
import '../widgets/account_section_title.dart';
import '../widgets/ard_card_preview.dart';
import '../widgets/card_action_tile.dart';
import '../widgets/card_section.dart';
import '../widgets/card_summary.dart';
import '../widgets/frozen_card.dart';
import '../widgets/info_row.dart';
import '../widgets/transaction_list.dart';

/// "Миний карт": the teen's active Ard Card, opened from Home's Карт tab.
/// Shows the card, its details and limits, lets them freeze it, and lists
/// recent card payments.
class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  // Mock card until it comes from the API.
  static const _number = '4000123456785521';
  static const _holder = Kid.cardName;
  static const _expiry = '08/28';

  static List<TxItem> get _payments {
    final today = DateTime.now();
    return [
      TxItem(
        title: 'Интерном',
        subtitle: 'Бусад',
        date: today,
        amount: -12000,
        glyph: LineGlyph.book,
      ),
      TxItem(
        title: 'CU дэлгүүр',
        subtitle: 'Хоол · Контактгүй',
        date: today.subtract(const Duration(days: 1)),
        amount: -4500,
        glyph: LineGlyph.food,
      ),
      TxItem(
        title: 'Тоглоомын төв',
        subtitle: 'Тоглоом/Апп',
        date: today.subtract(const Duration(days: 3)),
        amount: -18500,
        glyph: LineGlyph.gamepad,
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
              child: ArdCardPreview(holder: _holder, number: _printedNumber),
            ),
            const SizedBox(height: 16),
            CardSummary(frozen: _frozen),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: CardActionTile(
                    glyph: _showNumber ? LineGlyph.eyeOff : LineGlyph.eye,
                    label: _showNumber ? 'Дугаар нуух' : 'Дугаар харах',
                    onTap: () => setState(() => _showNumber = !_showNumber),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CardActionTile(
                    glyph: _frozen ? LineGlyph.lock : LineGlyph.snowflake,
                    label: _frozen ? 'Карт нээх' : 'Түр хаах',
                    highlighted: _frozen,
                    onTap: _toggleFrozen,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CardActionTile(
                    glyph: LineGlyph.copy,
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
                size: 12,
                color: AppColors.slate500,
              ),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    BalanceText(
                      Limits.spentToday,
                      size: 20,
                      weight: FontWeight.w600,
                    ),
                    AppText(
                      ' / ${formatMnt(Limits.dailyTransfer)}',
                      size: 13,
                      weight: FontWeight.w500,
                      color: AppColors.slate500,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const ProgressTrack(
                  value: Limits.spentToday / Limits.dailyTransfer,
                ),
                const SizedBox(height: 8),
                AppText(
                  'Өнөөдөр ${formatMnt(Limits.leftToday)} зарцуулах боломжтой',
                  size: 13,
                  color: AppColors.slate500,
                ),
                const SizedBox(height: 4),
                InfoRow(
                  label: 'Сарын лимит',
                  value: formatMnt(Limits.monthlyCard),
                  last: true,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const AccountSectionTitle('Сүүлийн гүйлгээ'),
            TransactionList(items: _payments),
          ],
        ),
      ),
    );
  }
}
