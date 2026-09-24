import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/common.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../../data/cart_item.dart';
import '../widgets/cart_tile.dart';

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
    CartItem(
      title: 'Зургийн дэвтэр, будгийн хэрэгсэл',
      store: 'ИНТЕРНОМ',
      price: 18500,
      asset: Mascots.catNotes,
      tint: AppColors.amber50,
    ),
    CartItem(
      title: 'Өдрийн амттан, сүү жимс',
      store: 'CU дэлгүүр',
      price: 2800,
      quantity: 2,
      asset: Mascots.pandaMilk,
      tint: AppColors.emerald50,
    ),
    CartItem(
      title: 'Хадгаламжийн зоосны хайрцаг',
      store: 'Хадгаламж & Хобби',
      price: 12000,
      asset: Mascots.hedgehogPiggy,
      tint: AppColors.amber50,
    ),
    CartItem(
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
                child: CartTile(
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
