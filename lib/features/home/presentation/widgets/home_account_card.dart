import 'package:flutter/material.dart';

import '../../../../app/accounts.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/common.dart';
import '../../../../widgets/ui.dart';
import '../../data/home_account.dart';

/// One account in Home's carousel: the companion's image for it, what kind
/// of account it is, and its number with the middle hidden. The balance and
/// the full number are shown under the carousel for the card in the centre.
class HomeAccountCard extends StatelessWidget {
  const HomeAccountCard({
    super.key,
    required this.account,
    required this.mascotName,
    this.shift = 0,
  });

  final HomeAccount account;
  final String mascotName;

  /// The card's distance from the centre of the carousel, in pages; the
  /// mascot drifts by it so it moves slower than the card (parallax).
  final double shift;

  static const height = 168.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, AppColors.sky50],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.sky100),
        boxShadow: [
          BoxShadow(
            color: AppColors.sky500.withValues(alpha: 0.10),
            offset: const Offset(0, 6),
            blurRadius: 14,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.sky100,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Transform.translate(
                  offset: Offset(8 * shift.clamp(-1.0, 1.0), 0),
                  child: Center(
                    child: MascotImage(
                      asset: account.mascot,
                      size: 38,
                      background: AppColors.sky100,
                      semanticLabel: mascotName,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              StatusBadge(label: account.kind),
            ],
          ),
          const Spacer(),
          AppText(
            account.label,
            size: 16,
            weight: FontWeight.w700,
            letterSpacing: -0.2,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          AppText(
            account.note,
            size: 12,
            weight: FontWeight.w500,
            color: AppColors.slate500,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Text(
            maskIban(account.iban),
            maxLines: 1,
            overflow: TextOverflow.clip,
            softWrap: false,
            style: moneyStyle(
              size: 13,
              weight: FontWeight.w600,
              color: AppColors.slate600,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
