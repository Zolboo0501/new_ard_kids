import 'package:flutter/material.dart';

enum NotificationKind { transaction, request, goal }

class AppNotification {
  AppNotification({
    required this.kind,
    required this.time,
    required this.title,
    required this.body,
    required this.asset,
    required this.tint,
    this.today = true,
    this.unread = false,
    this.progress,
    this.action,
    this.route,
  });

  final NotificationKind kind;
  final String time;
  final String title;
  final InlineSpan body;
  final String asset;
  final Color tint;
  final bool today;
  bool unread;
  final double? progress;
  final (String, String)? action;

  /// Screen opened when the card is tapped.
  final String? route;
}
