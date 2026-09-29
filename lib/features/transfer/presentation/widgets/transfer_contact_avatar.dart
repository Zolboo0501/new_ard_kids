import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import 'transfer_initials.dart';

/// One saved contact in the transfer screen's strip: initials over a name,
/// ringed in the accent while it is the recipient. With no [initials] it is
/// the add button.
class TransferContactAvatar extends StatelessWidget {
  const TransferContactAvatar({
    super.key,
    required this.label,
    required this.onTap,
    this.initials,
    this.selected = false,
  });

  final String label;
  final String? initials;
  final bool selected;
  final VoidCallback onTap;

  static const _size = 48.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: withHaptic(onTap),
        child: SizedBox(
          width: 68,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: _size + 6,
                height: _size + 6,
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.sky500 : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: initials == null
                    ? Container(
                        decoration: BoxDecoration(
                          color: AppColors.slate50,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.line),
                        ),
                        alignment: Alignment.center,
                        child: LineIcon(
                          LineGlyph.plus,
                          size: 20,
                          color: AppColors.slate800,
                        ),
                      )
                    : TransferInitials(initials!, size: _size),
              ),
              const SizedBox(height: 4),
              AppText(
                label,
                size: 12,
                weight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? AppColors.slate900 : AppColors.slate500,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
