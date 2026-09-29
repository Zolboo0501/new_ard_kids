import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/kid_profile.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../widgets/card_order_section.dart';
import '../widgets/delivery_option.dart';
import '../widgets/ard_card_preview.dart';
import '../widgets/price_row.dart';
import '../widgets/total_box.dart';

/// "Карт захиалга": order a physical Ard Card.
class CardOrderScreen extends StatefulWidget {
  const CardOrderScreen({super.key});

  @override
  State<CardOrderScreen> createState() => _CardOrderScreenState();
}

class _CardOrderScreenState extends State<CardOrderScreen> {
  static const _printFee = 10000;
  static const _deliveryFee = 5000;
  static const _balance = Balances.main;

  final _name = TextEditingController(text: Kid.cardName);
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
    return Scaffold(
      backgroundColor: kPageBackground,
      appBar: const SubPageHeader(title: 'Карт захиалга'),
      body: EntranceScope(
        child: AdaptiveListView(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: EntranceItem.list([
            ArdCardPreview(
              holder: _name.text.trim().isEmpty
                  ? Kid.cardName
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
                    size: 15,
                    weight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                  suffix: _name.text.trim().isEmpty
                      ? null
                      : LineIcon(
                          LineGlyph.check,
                          size: 18,
                          color: AppColors.emerald600,
                        ),
                ),
                const SizedBox(height: 6),
                AppText(
                  'Картын нүүрэн талд энэ нэр хэвлэгдэнэ.',
                  size: 12,
                  color: AppColors.slate500,
                ),
                const SizedBox(height: 14),
                const FieldLabel('Холбогдох данс'),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.slate50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      LineIcon(
                        LineGlyph.pocket,
                        size: 22,
                        color: AppColors.slate800,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppText(
                          'Халаасны данс',
                          size: 14,
                          weight: FontWeight.w600,
                        ),
                      ),
                      BalanceText(
                        _balance,
                        size: 14,
                        weight: FontWeight.w500,
                        color: AppColors.slate600,
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
                size: 12,
                color: AppColors.slate500,
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DeliveryOption(
                        title: 'Салбараас',
                        subtitle: 'Төв салбар дээр очиж авах',
                        price: 'Үнэгүй',
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
                    hint: 'Дүүрэг, хороо, байр, орц',
                                        textStyle: inter(size: 14, weight: FontWeight.w500),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            CardOrderSection(
              title: 'Төлбөрийн мэдээлэл',
              children: [
                PriceRow('Карт хэвлэх хураамж', _printFee),
                PriceRow(
                  'Хүргэлтийн төлбөр',
                  _homeDelivery ? _deliveryFee : 'Үнэгүй',
                ),
                PriceRow('Боломжит үлдэгдэл', _balance),
                const SizedBox(height: 12),
                TotalBox(
                  label: 'Нийт төлөх дүн',
                  sub: 'Халаасны данснаас суутгана',
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
