import 'package:flutter/material.dart';

class CartItem {
  CartItem({
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
