import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../widgets/ui.dart';
import '../../widgets/app_text.dart';

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

  static const _designs = [
    ('Цагаан', [Colors.white, Color(0xFFD5D5D5), Color(0xFFF4F4F4)]),
    ('Тэнгэр', [AppColors.sky100, AppColors.sky300, AppColors.sky50]),
    ('Ягаан', [AppColors.pink50, AppColors.pink400, AppColors.pink100]),
    ('Гаа', [AppColors.emerald50, AppColors.emerald300, AppColors.emerald100]),
  ];

  final _name = TextEditingController(text: 'АНАР Б.');
  final _address = TextEditingController(
    text: 'Улаанбаатар, СБД, 1-р хороо, 24-р байр',
  );
  int _design = 0;
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
    showAppSnack(context, 'Карт захиалга эцэг эхийн зөвшөөрөлд илгээгдлээ ✨');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFFAF9FF);
    return Scaffold(
      backgroundColor: bg,
      appBar: const SubPageHeader(title: 'Карт захиалга', background: bg),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          KidsCardPreview(
            holder: _name.text.trim().isEmpty
                ? 'АНАР БАТБАЯР'
                : _name.text.trim().toUpperCase(),
            colors: _designs[_design].$2,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final (i, d) in _designs.indexed)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Semantics(
                    button: true,
                    selected: _design == i,
                    label: d.$1,
                    child: GestureDetector(
                      onTap: () => setState(() => _design = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: 34,
                        height: 34,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _design == i
                                ? AppColors.sky500
                                : AppColors.slate200,
                            width: 2,
                          ),
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: d.$2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Картын мэдээлэл',
            children: [
              const FieldLabel('Дээр бичигдэх нэр (Латинаар)'),
              AppTextField(
                controller: _name,
                textStyle: comfortaa(
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
                      child: const Icon(
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
                          AppText(
                            '${formatMnt(_balance, space: true)} (Хүрэлцээтэй)',
                            size: 10,
                            weight: FontWeight.w600,
                            color: AppColors.sky600,
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
                      price: formatMnt(_deliveryFee, space: true),
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
                  textStyle: comfortaa(size: 12, weight: FontWeight.w500),
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
              _PriceRow(
                'Карт хэвлэх хураамж',
                formatMnt(_printFee, space: true),
              ),
              _PriceRow(
                'Хүргэлтийн төлбөр',
                _homeDelivery ? formatMnt(_deliveryFee, space: true) : 'ҮНЭГҮЙ',
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
                  Text(
                    formatMnt(_balance, space: true),
                    style: moneyStyle(size: 12, color: AppColors.slate700),
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
            label: 'Карт захиалах ✨',
            height: 54,
            onPressed: _valid ? _submit : null,
          ),
        ],
      ),
    );
  }
}

/// Kids' debit card mock-up (1.586:1).
class KidsCardPreview extends StatelessWidget {
  const KidsCardPreview({
    super.key,
    required this.holder,
    required this.colors,
  });

  final String holder;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.58,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.sky100),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.slate900.withValues(alpha: 0.12),
              offset: const Offset(0, 12),
              blurRadius: 28,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset('assets/images/ard_logo.png', height: 22),
                const Spacer(),
                Icon(
                  Icons.contactless_outlined,
                  color: AppColors.slate700.withValues(alpha: 0.8),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 34,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFCCAA4A),
                        Color(0xFFF4F08D),
                        Color(0xFFD3AC3E),
                      ],
                    ),
                  ),
                  child: CustomPaint(painter: _ChipLinesPainter()),
                ),
                const Spacer(),
                Container(
                  width: 58,
                  height: 58,
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(child: Image.asset(Mascots.bearCard)),
                ),
              ],
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'ЭЗЭМШИГЧ',
                        size: 9,
                        weight: FontWeight.w700,
                        color: AppColors.slate700,
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
                AppText(
                  'VISA',
                  size: 20,
                  weight: FontWeight.w800,
                  color: Color(0xFF1A1F71),
                  fontStyle: FontStyle.italic,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0x55806020)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      p,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, 0),
      Offset(size.width * 0.35, size.height),
      p,
    );
    canvas.drawLine(
      Offset(size.width * 0.65, 0),
      Offset(size.width * 0.65, size.height),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
  final String price;
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
              Text(
                price,
                style: moneyStyle(
                  size: 11,
                  weight: FontWeight.w800,
                  color: selected ? AppColors.sky700 : AppColors.emerald600,
                ),
              ),
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
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: AppText(label, size: 12, color: AppColors.slate600)),
          Text(
            value,
            style: moneyStyle(
              size: 12,
              weight: FontWeight.w600,
              color: AppColors.slate800,
            ),
          ),
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
          Text(
            formatMnt(total, space: true),
            style: moneyStyle(
              size: 18,
              weight: FontWeight.w800,
              color: AppColors.sky700,
            ),
          ),
        ],
      ),
    );
  }
}
