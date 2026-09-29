import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';

/// A person without a photo: two initials on a neutral circle.
class SocialInitialsAvatar extends StatelessWidget {
  const SocialInitialsAvatar({super.key, required this.name, this.size = 44});

  /// Initials come from the first two words, or the first two letters of a
  /// single word.
  final String name;
  final double size;

  static String initialsOf(String name) {
    final words = name
        .replaceAll(RegExp(r'[().]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    final letters = words.length == 1
        ? words.first.characters.take(2).toString()
        : '${words[0].characters.first}${words[1].characters.first}';
    return letters.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.slate100,
          shape: BoxShape.circle,
        ),
        child: AppText(
          initialsOf(name),
          size: size * 0.32,
          weight: FontWeight.w600,
          color: AppColors.slate700,
        ),
      ),
    );
  }
}
