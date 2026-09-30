import 'package:flutter/material.dart';

import '../../../../app/biometrics.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../widgets/group_label.dart';
import '../widgets/pin_sheet.dart';
import '../widgets/setting_tile.dart';
import '../widgets/settings_group.dart';

/// "Аюулгүй байдал": PIN, biometrics and device settings.
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
      showAppSnack(context, message);
    }
  }

  Future<void> _changePin() async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const PinSheet(),
    );
    if (changed == true && mounted) {
      showAppSnack(context, 'ПИН код шинэчлэгдлээ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.surface;
    return Scaffold(
      backgroundColor: bg,
      appBar: SubPageHeader(title: 'Аюулгүй байдал', background: bg),
      body: EntranceScope(
        child: AdaptiveListView(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: EntranceItem.list([
            const GroupLabel('ПИН код ба нууц үг'),
            SettingsGroup(
              children: [
                SettingTile(
                  glyph: LineGlyph.lock,
                  title: 'ПИН код солих',
                  onTap: _changePin,
                ),
                SettingTile(
                  glyph: LineGlyph.shield,
                  title: 'Нэвтрэх нууц үг',
                  onTap: () => showAppSnack(context, 'Нууц үг солих'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const GroupLabel('Биометр'),
            SettingsGroup(children: [_buildBiometricTile()]),
            const SizedBox(height: 24),
            const GroupLabel('Эцэг эхийн баталгаажуулалт'),
            SettingsGroup(
              children: [
                SettingTile(
                  glyph: LineGlyph.phone,
                  title: 'Шинэ төхөөрөмжөөс нэвтрэх',
                  trailing: AppSwitch(
                    value: _parentApproval,
                    onChanged: (v) => setState(() => _parentApproval = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const GroupLabel('Нэвтэрсэн төхөөрөмж', trailing: '1 төхөөрөмж'),
            const SettingsGroup(
              children: [
                SettingTile(
                  glyph: LineGlyph.phone,
                  title: 'iPhone 14 Pro · Энэ утас',
                  trailing: StatusBadge(
                    label: 'Идэвхтэй',
                    tone: BadgeTone.emerald,
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildBiometricTile() {
    final kind = _biometric;
    return SettingTile(
      glyph: kind == BiometricKind.face
          ? LineGlyph.faceId
          : LineGlyph.fingerprint,
      title: kind?.loginLabel ?? 'Биометрээр нэвтрэх',
      trailing: AppSwitch(
        value: kind != null && appBiometricLogin.value,
        // With a sensor but nothing enrolled the switch stays live: the scan
        // it asks for explains how to enrol.
        onChanged: !_hasSensor || _biometricBusy ? null : _setBiometric,
      ),
    );
  }
}
