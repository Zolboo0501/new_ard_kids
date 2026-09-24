import 'package:flutter/material.dart';

import '../../../../app/avatar.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../widgets/group_label.dart';
import '../widgets/pin_sheet.dart';
import '../widgets/security_group.dart';
import '../widgets/setting_tile.dart';

/// "Аюулгүй байдал & ПИН код": PIN, biometrics and device settings.
class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _faceId = true;
  bool _fingerprint = true;
  bool _parentApproval = true;

  Future<void> _changePin() async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const PinSheet(),
    );
    if (changed == true && mounted) {
      showAppSnack(
        context,
        'ПИН код амжилттай шинэчлэгдлээ',
        mascot: Stickers.shield,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF5F8FD);
    return Scaffold(
      backgroundColor: bg,
      appBar: SubPageHeader(
        title: 'Аюулгүй байдал',
        background: bg,
        trailing: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.sky50,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.sky100),
          ),
          child: Icon(
            Icons.verified_user_outlined,
            size: 20,
            color: AppColors.sky600,
          ),
        ),
      ),
      body: EntranceScope(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: EntranceItem.list([
            const GroupLabel('ПИН КОД & НУУЦЛАЛ', trailing: '4 оронтой'),
            SecurityGroup(
              children: [
                SettingTile(
                  icon: Icons.pin_outlined,
                  tone: BadgeTone.sky,
                  title: 'ПИН код солих',
                  subtitle: 'Гүйлгээний 4 оронтой нууц код',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText(
                        '••••',
                        size: 12,
                        weight: FontWeight.w700,
                        color: AppColors.slate300,
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.slate300,
                      ),
                    ],
                  ),
                  onTap: _changePin,
                ),
                SettingTile(
                  icon: Icons.password_rounded,
                  tone: BadgeTone.slate,
                  iconColor: AppColors.indigo500,
                  iconBackground: AppColors.indigo50,
                  title: 'Апп руу нэвтрэх нууц үг',
                  subtitle: 'Сүүлд 14 хоногийн өмнө шинэчилсэн',
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.slate300,
                  ),
                  onTap: () => showAppSnack(context, 'Нууц үг солих'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const GroupLabel('БИОМЕТРИК НЭВТРЭЛТ'),
            SecurityGroup(
              children: [
                SettingTile(
                  icon: Icons.face_retouching_natural_rounded,
                  tone: BadgeTone.sky,
                  title: 'Face ID нэвтрэх',
                  subtitle: 'Царай таньж шууд нэвтрэх',
                  trailing: AppSwitch(
                    value: _faceId,
                    onChanged: (v) => setState(() => _faceId = v),
                  ),
                ),
                SettingTile(
                  icon: Icons.fingerprint_rounded,
                  tone: BadgeTone.emerald,
                  title: 'Хурууны хээ ашиглах',
                  subtitle: 'Түргэн баталгаажуулалт',
                  trailing: AppSwitch(
                    value: _fingerprint,
                    onChanged: (v) => setState(() => _fingerprint = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const GroupLabel('ЭЦЭГ ЭХИЙН БАТАЛГААЖУУЛАЛТ'),
            SecurityGroup(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InfoNote(
                    tone: BadgeTone.amber,
                    icon: Icons.sms_outlined,
                    text:
                        'ПИН код шинэчлэхэд таны асран хамгаалагч Ээж (Б. Саруул)-ийн утсанд 6 оронтой баталгаажуулах код очно.',
                  ),
                ),
                SettingTile(
                  icon: Icons.phonelink_lock_rounded,
                  tone: BadgeTone.amber,
                  title: 'Шинэ төхөөрөмжөөс нэвтрэх зөвшөөрөл',
                  subtitle: 'Эцэг эхийн аппаас зөвшөөрөл шаардана',
                  trailing: AppSwitch(
                    value: _parentApproval,
                    onChanged: (v) => setState(() => _parentApproval = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const GroupLabel('НЭВТЭРСЭН ТӨХӨӨРӨМЖҮҮД', trailing: '1 төхөөрөмж'),
            SecurityGroup(
              children: [
                SettingTile(
                  icon: Icons.phone_iphone_rounded,
                  tone: BadgeTone.slate,
                  title: 'iPhone 14 Pro (Энэ утас)',
                  subtitle: 'Улаанбаатар · Яг одоо идэвхтэй',
                  trailing: const StatusBadge(label: 'Идэвхтэй'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'ПИН кодоо шинэчлэх',
              leadingIcon: Icons.lock_reset_rounded,
              onPressed: _changePin,
            ),
          ]),
        ),
      ),
    );
  }
}
