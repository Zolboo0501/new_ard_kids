import '../../../widgets/ui.dart';

class CartItem {
  CartItem({
    required this.title,
    required this.store,
    required this.price,
    required this.glyph,
    this.quantity = 1,
  });

  final String title;
  final String store;
  final int price;

  /// The item's category, drawn in the row's tile.
  final LineGlyph glyph;
  int quantity;
}
