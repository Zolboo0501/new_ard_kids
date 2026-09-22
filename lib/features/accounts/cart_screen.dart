import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../../widgets/app_text.dart';
import '../../widgets/entrance.dart';

class _CartItem {
  _CartItem({
    required this.title,
    required this.store,
    required this.price,
    required this.asset,
    required this.tint,
    this.quantity = 1,
  });

  final String title;
  final String store;
  final int price;
  final String asset;
  final Color tint;
  int quantity;
}

/// "Миний сагс - Авсаархан загвар": shopping cart pending parent approval.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const _balance = 567930;
  static const _deliveryFee = 3000;

  final _items = [
    _CartItem(
      title: 'Зургийн дэвтэр, будгийн хэрэгсэл',
      store: 'ИНТЕРНОМ',
      price: 18500,
      asset: Mascots.catNotes,
      tint: AppColors.amber50,
    ),
    _CartItem(
      title: 'Өдрийн амттан, сүү жимс',
      store: 'CU дэлгүүр',
      price: 2800,
      quantity: 2,
      asset: Mascots.pandaMilk,
      tint: AppColors.emerald50,
    ),
    _CartItem(
      title: 'Хадгаламжийн зоосны хайрцаг',
      store: 'Хадгаламж & Хобби',
      price: 12000,
      asset: Mascots.hedgehogPiggy,
      tint: AppColors.amber50,
    ),
    _CartItem(
      title: 'Тоглоомын эрхийн карт (PS)',
      store: 'Дижитал зугаа',
      price: 25000,
      asset: Mascots.puppyGamepad,
      tint: AppColors.indigo50,
    ),
  ];

  int get _subtotal => _items.fold(0, (a, e) => a + e.price * e.quantity);

  void _submit() {
    // TODO: send the order for parent approval.
    showAppSnack(context, 'Захиалга аав ээж рүү илгээгдлээ');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFFAF9FF);
    return Scaffold(
      backgroundColor: bg,
      appBar: SubPageHeader(
        title: 'Миний сагс',
        subtitle: '${_items.length} бараа сонгогдсон',
        background: bg,
        trailing: _items.isEmpty
            ? null
            : CircleIconButton(
                icon: Icons.delete_outline_rounded,
                label: 'Хоослох',
                color: AppColors.rose500,
                onPressed: () => setState(_items.clear),
              ),
      ),
      body: EntranceScope(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: EntranceItem.list([
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [AppColors.sky50, AppColors.indigo50],
                ),
                border: Border.all(color: AppColors.sky100),
              ),
              child: Row(
                children: [
                  MascotImage(
                    asset: Mascots.pandaPiggy,
                    size: 56,
                    background: AppColors.sky50,
                    semanticLabel: 'Хөөрхөн панда сагстай дэлгүүр хэсэж буй',
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const StatusBadge(
                          label: 'Аав ээжийн зөвшөөрөлтэй',
                          icon: Icons.verified_user_outlined,
                        ),
                        const SizedBox(height: 4),
                        AppText(
                          'Захиалгаа шалгаарай',
                          size: 12,
                          weight: FontWeight.w700,
                        ),
                        AppText(
                          'Сагсанд буй барааг шалгаад баталгаажуулаарай!',
                          size: 10,
                          color: AppColors.slate600,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Expanded(
                    child: AppText(
                      'СОНГОСОН БҮТЭЭГДЭХҮҮНҮҮД',
                      size: 11,
                      weight: FontWeight.w700,
                      color: AppColors.slate600,
                      letterSpacing: 0.6,
                    ),
                  ),
                  if (_items.isNotEmpty) const StatusBadge(label: 'Бүгд бэлэн'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (_items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    const MascotImage(
                      asset: Mascots.sleepingCat,
                      size: 120,
                      background: bg,
                      semanticLabel: '',
                    ),
                    AppText(
                      'Сагс хоосон байна',
                      size: 14,
                      weight: FontWeight.w700,
                    ),
                  ],
                ),
              ),
            for (final (i, item) in _items.indexed) ...[
              ListItemEntrance(
                id: item,
                index: i,
                child: _CartTile(
                  item: item,
                  onRemove: () => setState(() => _items.remove(item)),
                  onChanged: (q) => setState(() => item.quantity = q),
                ),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 6),
            AppCard(
              radius: 18,
              padding: const EdgeInsets.all(14),
              borderColor: AppColors.slate100,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          'Төлбөрийн задаргаа',
                          size: 12,
                          weight: FontWeight.w700,
                          color: AppColors.slate900,
                        ),
                      ),
                      const StatusBadge(
                        label: 'Хүргэлт үнэгүй',
                        tone: BadgeTone.emerald,
                        dot: true,
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: AppColors.slate100),
                  _row(
                    'Барааны нийт дүн',
                    BalanceText(
                      _subtotal,
                      animate: true,
                      space: false,
                      size: 11,
                      weight: FontWeight.w600,
                    ),
                  ),
                  _row(
                    'Хүргэлтийн төлбөр',
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BalanceText(
                          _deliveryFee,
                          space: false,
                          size: 10,
                          weight: FontWeight.w400,
                          color: AppColors.slate400,
                          decoration: TextDecoration.lineThrough,
                        ),
                        const SizedBox(width: 4),
                        AppText(
                          'ҮНЭГҮЙ',
                          size: 11,
                          weight: FontWeight.w700,
                          color: AppColors.emerald600,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 14, color: AppColors.slate100),
                  _row(
                    'Боломжит үлдэгдэл',
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BalanceText(
                          _balance,
                          space: false,
                          size: 11,
                          color: AppColors.slate700,
                        ),
                        const SizedBox(width: 4),
                        StatusBadge(
                          label: _subtotal <= _balance
                              ? 'Хүрэлцээтэй ✓'
                              : 'Хүрэлцэхгүй',
                          tone: _subtotal <= _balance
                              ? BadgeTone.sky
                              : BadgeTone.rose,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.sky50.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                'Нийт төлөх дүн',
                                size: 10,
                                weight: FontWeight.w500,
                                color: AppColors.sky900,
                              ),
                              AppText(
                                'НӨАТ орсон дүн',
                                size: 9,
                                color: AppColors.sky600,
                              ),
                            ],
                          ),
                        ),
                        BalanceText(
                          _subtotal,
                          animate: true,
                          space: false,
                          size: 16,
                          weight: FontWeight.w800,
                          color: AppColors.sky700,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const InfoNote(
              tone: BadgeTone.amber,
              icon: Icons.family_restroom_rounded,
              title: 'Эцэг эхийн баталгаажуулалт:',
              text:
                  'Таны захиалга аав ээжийн зөвшөөрлөөр данснаас суутгагдана.',
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Захиалга илгээх',
              onPressed: _items.isEmpty || _subtotal > _balance
                  ? null
                  : _submit,
            ),
          ]),
        ),
      ),
    );
  }

  Widget _row(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: AppText(label, size: 11, color: AppColors.slate600)),
          value,
        ],
      ),
    );
  }
}

class _CartTile extends StatelessWidget {
  const _CartTile({
    required this.item,
    required this.onRemove,
    required this.onChanged,
  });

  final _CartItem item;
  final VoidCallback onRemove;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 14,
      padding: const EdgeInsets.all(10),
      borderColor: AppColors.slate100,
      child: Row(
        children: [
          MascotTile(
            asset: item.asset,
            size: 56,
            background: item.tint,
            radius: 12,
            label: item.title,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusBadge(label: item.store, tone: BadgeTone.slate),
                const SizedBox(height: 3),
                AppText(
                  item.title,
                  size: 12,
                  weight: FontWeight.w700,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                BalanceText(
                  item.price * item.quantity,
                  animate: true,
                  space: false,
                  size: 12,
                  weight: FontWeight.w800,
                  color: AppColors.slate900,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Semantics(
                button: true,
                label: 'Хасах',
                child: GestureDetector(
                  onTap: withHaptic(onRemove),
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: AppColors.slate400,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _QtyButton(
                      icon: Icons.remove_rounded,
                      label: 'Хасах',
                      onTap: item.quantity > 1
                          ? () => onChanged(item.quantity - 1)
                          : null,
                    ),
                    SizedBox(
                      width: 22,
                      child: AppText(
                        '${item.quantity}',
                        size: 12,
                        weight: FontWeight.w700,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    _QtyButton(
                      icon: Icons.add_rounded,
                      label: 'Нэмэх',
                      onTap: () => onChanged(item.quantity + 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: withHaptic(onTap),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 14,
            color: onTap == null ? AppColors.slate300 : AppColors.slate600,
          ),
        ),
      ),
    );
  }
}
