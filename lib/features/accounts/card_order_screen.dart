import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../widgets/ui.dart';
import '../../widgets/app_text.dart';
import '../../widgets/entrance.dart';

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
            _Section(
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
            _Section(
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
                      child: _DeliveryOption(
                        title: 'Салбараас',
                        subtitle: 'Төв салбар дээр очиж авах',
                        price: 'ҮНЭГҮЙ',
                        selected: !_homeDelivery,
                        onTap: () => setState(() => _homeDelivery = false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DeliveryOption(
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
            _Section(
              title: 'Төлбөрийн мэдээлэл',
              trailing: const StatusBadge(
                label: 'Данснаас суутгана',
                tone: BadgeTone.emerald,
                dot: true,
              ),
              children: [
                _PriceRow('Карт хэвлэх хураамж', _printFee),
                _PriceRow(
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
                _TotalBox(
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

/// The kids' card, drawn from [asset] (a white card with a chip and
/// emblem), with the holder's name printed on it.
class KidsCardPreview extends StatelessWidget {
  const KidsCardPreview({super.key, required this.holder, this.number});

  final String holder;

  /// The card number printed above the holder, e.g. `•••• •••• •••• 5521`;
  /// a card still being ordered has none.
  final String? number;

  static const asset = 'assets/svg/card-white.svg';

  /// The artwork's size (its viewBox); the card keeps these proportions.
  static const _artWidth = 243.78;
  static const _artHeight = 153.07;
  static const _artRadius = 9.05;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _artWidth / _artHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Everything on the card scales with its width, like the artwork.
          final scale = constraints.maxWidth / _artWidth;
          final radius = BorderRadius.circular(_artRadius * scale);
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: AppColors.slate900.withValues(alpha: 0.12),
                  offset: const Offset(0, 12),
                  blurRadius: 28,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SvgPicture.asset(
                    asset,
                    fit: BoxFit.fill,
                    semanticsLabel: 'Хүүхдийн карт',
                  ),
                  Positioned(
                    left: 28 * scale,
                    right: 28 * scale,
                    bottom: 16 * scale,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (number != null) ...[
                          Text(
                            number!,
                            style: moneyStyle(
                              size: 11 * scale,
                              weight: FontWeight.w700,
                              color: AppColors.slate700,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: 8 * scale),
                        ],
                        AppText(
                          'ЭЗЭМШИГЧ',
                          size: 9,
                          weight: FontWeight.w700,
                          color: AppColors.slate500,
                          letterSpacing: 2,
                        ),
                        AppText(
                          holder,
                          size: 14,
                          weight: FontWeight.w800,
                          color: AppColors.slate900,
                          letterSpacing: 1.2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
      radius: 24,
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.slate100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  title,
                  size: 14,
                  weight: FontWeight.w700,
                  color: AppColors.slate900,
                ),
              ),
              ?trailing,
            ],
          ),
          const Divider(height: 22, color: AppColors.slate100),
          ...children,
        ],
      ),
    );
  }
}

class _DeliveryOption extends StatelessWidget {
  const _DeliveryOption({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;

  /// An amount (shown with [BalanceText]) or text such as `ҮНЭГҮЙ`.
  final Object price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected ? AppColors.sky50 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.sky500 : AppColors.slate200,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppText(
                      title,
                      size: 12,
                      weight: FontWeight.w700,
                      color: selected ? AppColors.sky900 : AppColors.slate700,
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? AppColors.sky500 : Colors.white,
                      border: selected
                          ? null
                          : Border.all(color: AppColors.slate300),
                    ),
                    child: selected
                        ? const Icon(
                            Icons.check_rounded,
                            size: 11,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              AppText(subtitle, size: 10, color: AppColors.slate500),
              const SizedBox(height: 4),
              switch (price) {
                final num amount => BalanceText(
                  amount,
                  space: false,
                  size: 11,
                  weight: FontWeight.w800,
                  color: selected ? AppColors.sky700 : AppColors.emerald600,
                ),
                _ => Text(
                  '$price',
                  style: moneyStyle(
                    size: 11,
                    weight: FontWeight.w800,
                    color: selected ? AppColors.sky700 : AppColors.emerald600,
                  ),
                ),
              },
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow(this.label, this.value);

  final String label;

  /// An amount (shown with [BalanceText]) or text such as `ҮНЭГҮЙ`.
  final Object value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: AppText(label, size: 12, color: AppColors.slate600)),
          switch (value) {
            final num amount => BalanceText(
              amount,
              space: false,
              size: 12,
              weight: FontWeight.w600,
            ),
            _ => Text(
              '$value',
              style: moneyStyle(
                size: 12,
                weight: FontWeight.w600,
                color: AppColors.slate800,
              ),
            ),
          },
        ],
      ),
    );
  }
}

class _TotalBox extends StatelessWidget {
  const _TotalBox({
    required this.label,
    required this.sub,
    required this.total,
  });

  final String label;
  final String sub;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.sky50.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  size: 11,
                  weight: FontWeight.w500,
                  color: AppColors.sky900,
                ),
                AppText(sub, size: 9, color: AppColors.sky600),
              ],
            ),
          ),
          BalanceText(
            total,
            animate: true,
            space: false,
            size: 18,
            weight: FontWeight.w600,
            color: AppColors.sky700,
          ),
        ],
      ),
    );
  }
}
