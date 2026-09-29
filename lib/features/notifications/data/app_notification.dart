import 'package:flutter/painting.dart';

enum NotificationKind { transaction, request, goal }

/// What a notification is about, which picks its icon tile.
enum NotificationTopic { income, spending, security, reward, goal, system }

class AppNotification {
  AppNotification({
    required this.kind,
    required this.topic,
    required this.time,
    required this.title,
    required this.body,
    this.today = true,
    this.unread = false,
    this.progress,
    this.route,
  });

  final NotificationKind kind;
  final NotificationTopic topic;
  final String time;
  final String title;
  final InlineSpan body;
  final bool today;
  bool unread;

  /// A real progress value (a savings goal) drawn under the body.
  final double? progress;

  /// Screen opened when the card is tapped.
  final String? route;
}
