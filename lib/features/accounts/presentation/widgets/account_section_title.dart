import 'package:flutter/material.dart';

import '../../../../widgets/app_text.dart';

/// A section heading on the accounts screens: 16 w700, nothing above it.
class AccountSectionTitle extends StatelessWidget {
  const AccountSectionTitle(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
      child: Row(
        children: [
          Expanded(
            child: AppText(title, size: 16, weight: FontWeight.w700),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
