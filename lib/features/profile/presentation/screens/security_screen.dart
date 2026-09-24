import 'package:flutter/material.dart';

import '../../../../app/avatar.dart';
import '../../../../app/biometrics.dart';
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
  bool _parentApproval = true;

  /// The device's enrolled biometric, or null while checking or when there
  /// is none. [_hasSensor] tells "set one up in Settings" from "unsupported".
  BiometricKind? _biometric;
  bool _hasSensor = false;
  bool _biometricChecked = false;
  bool _biometricBusy = false;

  /// Re-checks when the app comes back, so a face or finger enrolled in the
  /// phone's settings meanwhile shows up without reopening the screen.
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onResume: _checkBiometric,
  );

  @override
  void initState() {
    super.initState();
    _lifecycle;
    _checkBiometric();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _checkBiometric() async {
    final biometrics = Biometrics.instance;
    final (kind, hasSensor) = await (
      biometrics.available(),
      biometrics.hasSensor(),
    ).wait;
    if (!mounted) return;
    setState(() {
      _biometric = kind;
      _hasSensor = kind != null || hasSensor;
      _biometricChecked = true;
    });
  }

  /// Turning biometric sign-in on needs one successful scan first, so it is
  /// only enabled for a finger or face the device actually recognises.
  Future<void> _setBiometric(bool enabled) async {
    if (!enabled) {
      BiometricStore.save(false);
      setState(() {});
      return;
    }
    setState(() => _biometricBusy = true);
    final result = await Biometrics.instance.authenticate(
      'Биометрээр нэвтрэхийг идэвхжүүлэх',
    );
    if (!mounted) return;
    if (result == BiometricResult.success) BiometricStore.save(true);
    setState(() => _biometricBusy = false);
    // A face or finger may have been enrolled since the last check.
    if (result == BiometricResult.notEnrolled) _checkBiometric();
    final message = result == BiometricResult.success
        ? '${(_biometric ?? BiometricKind.fingerprint).loginLabel} идэвхжлээ'
        : result.message;
    if (message != null) {
      showAppSnack(
        context,
        message,
        mascot: result == BiometricResult.success ? Stickers.shield : null,
      );
    }
  }

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
            SecurityGroup(children: [_buildBiometricTile()]),
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

  Widget _buildBiometricTile() {
    final kind = _biometric;
    return SettingTile(
      icon: kind?.icon ?? Icons.fingerprint_rounded,
      tone: BadgeTone.sky,
      title: kind?.loginLabel ?? 'Биометрээр нэвтрэх',
      subtitle:
          kind?.description ??
          switch ((_biometricChecked, _hasSensor)) {
            (false, _) => 'Төхөөрөмжийг шалгаж байна…',
            (true, true) => 'Эхлээд утасныхаа тохиргооноос бүртгүүлнэ үү',
            (true, false) => 'Энэ төхөөрөмж дэмжихгүй байна',
          },
      trailing: AppSwitch(
        value: kind != null && appBiometricLogin.value,
        // With a sensor but nothing enrolled the switch stays live: the scan
        // it asks for explains how to enrol.
        onChanged: !_hasSensor || _biometricBusy ? null : _setBiometric,
      ),
    );
  }
}
