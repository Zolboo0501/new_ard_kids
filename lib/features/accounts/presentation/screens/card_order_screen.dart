import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../widgets/card_order_section.dart';
import '../widgets/delivery_option.dart';
import '../widgets/kids_card_preview.dart';
import '../widgets/price_row.dart';
import '../widgets/total_box.dart';

/// "Карт захиалга": order a physical kids' card.
class CardOrderScreen extends StatefulWidget {
  const CardOrderScreen({super.key});

  @override
  State<CardOrderScreen> createState() => _CardOrderScreenState();
}

class _CardOrderScreenState extends State<CardOrderScreen> {
  static const _printFee = 10000;
  static const _deliveryFee = 5000;
  static const _balance = 567930;

  final _name = TextEditingController(text: 'АНАР Б.');
  final _address = TextEditingController(
    text: 'Улаанбаатар, СБД, 1-р хороо, 24-р байр',
  );
  bool _homeDelivery = true;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
    _address.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    super.dispose();
  }

  int get _total => _printFee + (_homeDelivery ? _deliveryFee : 0);

  bool get _valid =>
      _name.text.trim().isNotEmpty &&
      (!_homeDelivery || _address.text.trim().isNotEmpty);

  void _submit() {
    // TODO: submit the card order for parent approval.
    showAppSnack(context, 'Карт захиалга эцэг эхийн зөвшөөрөлд илгээгдлээ');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFFAF9FF);
    return Scaffold(
      backgroundColor: bg,
      appBar: const SubPageHeader(title: 'Карт захиалга', background: bg),
      body: EntranceScope(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: EntranceItem.list([
            KidsCardPreview(
              holder: _name.text.trim().isEmpty
                  ? 'АНАР БАТБАЯР'
                  : _name.text.trim().toUpperCase(),
            ),
            const SizedBox(height: 16),
            CardOrderSection(
              title: 'Картын мэдээлэл',
              children: [
                const FieldLabel('Дээр бичигдэх нэр (Латинаар)'),
                AppTextField(
                  controller: _name,
                  textStyle: inter(
                    size: 13,
                    weight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                  suffix: _name.text.trim().isEmpty
                      ? null
                      : const Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: AppColors.emerald500,
                        ),
                ),
                const SizedBox(height: 6),
                AppText(
                  'Картын нүүрэн талд энэ нэр сийлэгдэж хэвлэгдэнэ.',
                  size: 10,
                  color: AppColors.slate400,
                ),
                const SizedBox(height: 14),
                const FieldLabel('Холбогдох данс'),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.sky50.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.sky100),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.sky100),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 18,
                          color: AppColors.sky600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              'Үндсэн халаасны данс',
                              size: 12,
                              weight: FontWeight.w700,
                            ),
                            Row(
                              children: [
                                BalanceText(
                                  _balance,
                                  space: false,
                                  size: 10,
                                  weight: FontWeight.w500,
                                  color: AppColors.sky500,
                                ),
                                Flexible(
                                  child: AppText(
                                    ' (Хүрэлцээтэй)',
                                    size: 10,
                                    weight: FontWeight.w600,
                                    color: AppColors.sky600,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      AppText(
                        'Сонгосон ✓',
                        size: 11,
                        weight: FontWeight.w700,
                        color: AppColors.slate400,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            CardOrderSection(
              title: 'Хүргэлтийн хэлбэр',
              trailing: AppText(
                '2-3 хоногт',
                size: 10,
                weight: FontWeight.w600,
                color: AppColors.slate500,
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DeliveryOption(
                        title: 'Салбараас',
                        subtitle: 'Төв салбар дээр очиж авах',
                        price: 'ҮНЭГҮЙ',
                        selected: !_homeDelivery,
                        onTap: () => setState(() => _homeDelivery = false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DeliveryOption(
                        title: 'Гэртээ хүргүүлэх',
                        subtitle: 'Шуудангаар хүргэж өгнө',
                        price: _deliveryFee,
                        selected: _homeDelivery,
                        onTap: () => setState(() => _homeDelivery = true),
                      ),
                    ),
                  ],
                ),
                if (_homeDelivery) ...[
                  const SizedBox(height: 12),
                  const FieldLabel('Хүргэлтийн хаяг'),
                  AppTextField(
                    controller: _address,
                    hint: 'Дүүрэг, хороо, байр, орцны дугаар...',
                    prefixIcon: Icons.location_on_outlined,
                    textStyle: inter(size: 12, weight: FontWeight.w500),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            CardOrderSection(
              title: 'Төлбөрийн мэдээлэл',
              trailing: const StatusBadge(
                label: 'Данснаас суутгана',
                tone: BadgeTone.emerald,
                dot: true,
              ),
              children: [
                PriceRow('Карт хэвлэх хураамж', _printFee),
                PriceRow(
                  'Хүргэлтийн төлбөр',
                  _homeDelivery ? _deliveryFee : 'ҮНЭГҮЙ',
                ),
                const Divider(height: 16, color: AppColors.slate100),
                Row(
                  children: [
                    Expanded(
                      child: AppText(
                        'Боломжит үлдэгдэл',
                        size: 12,
                        color: AppColors.slate500,
                      ),
                    ),
                    BalanceText(
                      _balance,
                      space: false,
                      size: 12,
                      color: AppColors.slate700,
                    ),
                    const SizedBox(width: 6),
                    const StatusBadge(label: 'Хүрэлцээтэй ✓'),
                  ],
                ),
                const SizedBox(height: 12),
                TotalBox(
                  label: 'Нийт төлөх дүн',
                  sub: 'Карт + Хүргэлт',
                  total: _total,
                ),
              ],
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Карт захиалах',
              height: 54,
              onPressed: _valid ? _submit : null,
            ),
          ]),
        ),
      ),
    );
  }
}
