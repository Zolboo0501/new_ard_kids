import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/kid_profile.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../../data/cart_item.dart';
import '../widgets/account_glyph_tile.dart';
import '../widgets/account_section_title.dart';
import '../widgets/cart_tile.dart';
import '../widgets/price_row.dart';
import '../widgets/total_box.dart';

/// "Миний сагс": shopping cart pending parent approval.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const _balance = Balances.main;

  final _items = [
    CartItem(
      title: 'Зургийн дэвтэр, будаг',
      store: 'Интерном',
      price: 18500,
      glyph: LineGlyph.book,
    ),
    CartItem(
      title: 'Сүү, жимс',
      store: 'CU дэлгүүр',
      price: 2800,
      quantity: 2,
      glyph: LineGlyph.food,
    ),
    CartItem(
      title: 'Зоосны хайрцаг',
      store: 'Хадгаламж & Хобби',
      price: 12000,
      glyph: LineGlyph.piggy,
    ),
    CartItem(
      title: 'PlayStation эрхийн карт',
      store: 'Дижитал дэлгүүр',
      price: 25000,
      glyph: LineGlyph.gamepad,
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
    return Scaffold(
      backgroundColor: kPageBackground,
      appBar: SubPageHeader(
        title: 'Миний сагс',
        subtitle: '${_items.length} бараа сонгогдсон',
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
        child: AdaptiveListView(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: EntranceItem.list([
            const AccountSectionTitle('Бараа'),
            if (_items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    AccountGlyphTile(LineGlyph.bag, size: 56),
                    const SizedBox(height: 12),
                    AppText(
                      'Сагс хоосон байна',
                      size: 15,
                      weight: FontWeight.w600,
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppText(
                    'Төлбөрийн задаргаа',
                    size: 16,
                    weight: FontWeight.w700,
                  ),
                  const SizedBox(height: 12),
                  PriceRow('Барааны нийт дүн', _subtotal),
                  const PriceRow('Хүргэлтийн төлбөр', 'Үнэгүй'),
                  PriceRow('Боломжит үлдэгдэл', _balance),
                  if (_subtotal > _balance) ...[
                    const SizedBox(height: 4),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: StatusBadge(
                        label: 'Үлдэгдэл хүрэлцэхгүй',
                        tone: BadgeTone.rose,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TotalBox(
                    label: 'Нийт төлөх дүн',
                    sub: 'НӨАТ орсон',
                    total: _subtotal,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const InfoNote(
              text:
                  'Аав ээж зөвшөөрсний дараа төлбөр халаасны данснаас суутгагдана.',
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
}
