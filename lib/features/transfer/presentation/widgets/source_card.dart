import 'package:flutter/material.dart';

import '../../../../app/accounts.dart';
import '../../../../app/avatar.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/common.dart';
import '../../../../widgets/ui.dart';
import 'transfer_collapse.dart';

class SourceCard extends StatelessWidget {
  const SourceCard({super.key, required this.showAccount});

  final bool showAccount;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 26,
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.slate100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'ШИЛЖҮҮЛЭХ ДАНС',
                  size: 11,
                  weight: FontWeight.w600,
                  color: AppColors.slate400,
                  letterSpacing: 0.6,
                ),
                const SizedBox(height: 10),
                AppText(
                  'Боломжит үлдэгдэл',
                  size: 11,
                  color: AppColors.slate500,
                ),
                const SizedBox(height: 2),
                const BalanceText(
                  567930,
                  size: 30,
                  color: AppColors.slate900,
                  weight: FontWeight.w600,
                  currencyWeight: FontWeight.w600,
                ),
                TransferCollapse(
                  visible: showAccount,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: AppText(
                      'Хаан банк · ${formatIban(Accounts.khanBank)}',
                      size: 11,
                      weight: FontWeight.w600,
                      color: AppColors.slate400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          MascotImage(
            asset: Stickers.payment,
            size: 110,
            background: Colors.white,
            semanticLabel: 'Гүйлгээ хийж буй маскот',
          ),
        ],
      ),
    );
  }
}
