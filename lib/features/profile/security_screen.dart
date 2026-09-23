import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/numeric_keypad.dart';
import '../../widgets/ui.dart';
import '../../widgets/app_text.dart';
import '../../widgets/entrance.dart';

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
      builder: (_) => const _PinSheet(),
    );
    if (changed == true && mounted) {
      showAppSnack(
        context,
        'ПИН код амжилттай шинэчлэгдлээ',
        mascot: FoxStickers.shield,
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
            const _GroupLabel('ПИН КОД & НУУЦЛАЛ', trailing: '4 оронтой'),
            _Group(
              children: [
                _SettingTile(
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
                _SettingTile(
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
            const _GroupLabel('БИОМЕТРИК НЭВТРЭЛТ'),
            _Group(
              children: [
                _SettingTile(
                  icon: Icons.face_retouching_natural_rounded,
                  tone: BadgeTone.sky,
                  title: 'Face ID нэвтрэх',
                  subtitle: 'Царай таньж шууд нэвтрэх',
                  trailing: AppSwitch(
                    value: _faceId,
                    onChanged: (v) => setState(() => _faceId = v),
                  ),
                ),
                _SettingTile(
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
            const _GroupLabel('ЭЦЭГ ЭХИЙН БАТАЛГААЖУУЛАЛТ'),
            _Group(
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
                _SettingTile(
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
            const _GroupLabel(
              'НЭВТЭРСЭН ТӨХӨӨРӨМЖҮҮД',
              trailing: '1 төхөөрөмж',
            ),
            _Group(
              children: [
                _SettingTile(
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

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text, {this.trailing});

  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              text,
              size: 12,
              weight: FontWeight.w700,
              color: AppColors.slate400,
              letterSpacing: 0.6,
            ),
          ),
          if (trailing != null)
            AppText(
              trailing!,
              size: 11,
              weight: FontWeight.w500,
              color: AppColors.sky600,
            ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 24,
      padding: const EdgeInsets.all(14),
      borderColor: AppColors.slate100,
      child: Column(
        children: [
          for (final (i, c) in children.indexed) ...[
            if (i > 0 && c is _SettingTile)
              const Divider(height: 20, color: AppColors.slate100),
            c,
          ],
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
    this.iconColor,
    this.iconBackground,
  });

  final IconData icon;
  final BadgeTone tone;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? iconBackground;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, _) = tone.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: withHaptic(onTap),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackground ?? bg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 20, color: iconColor ?? fg),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(title, size: 13, weight: FontWeight.w700),
                const SizedBox(height: 2),
                AppText(subtitle, size: 11, color: AppColors.slate400),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}

/// Two-step PIN entry: new PIN then confirmation.
class _PinSheet extends StatefulWidget {
  const _PinSheet();

  @override
  State<_PinSheet> createState() => _PinSheetState();
}

class _PinSheetState extends State<_PinSheet> {
  String _first = '';
  String _pin = '';
  bool _mismatch = false;

  bool get _confirming => _first.isNotEmpty;

  void _digit(String d) {
    if (_pin.length == 4) return;
    setState(() {
      _mismatch = false;
      _pin += d;
    });
    if (_pin.length < 4) return;
    if (!_confirming) {
      setState(() {
        _first = _pin;
        _pin = '';
      });
    } else if (_pin == _first) {
      // TODO: send the new PIN with the parent's verification code.
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _mismatch = true;
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.slate200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 18),
            AppText(
              _confirming ? 'ПИН кодоо давтана уу' : 'Шинэ ПИН код оруулна уу',
              size: 16,
              weight: FontWeight.w700,
            ),
            const SizedBox(height: 6),
            AppText(
              _mismatch
                  ? 'Код таарахгүй байна. Дахин оролдоно уу.'
                  : '4 оронтой нууц код',
              size: 12,
              color: _mismatch ? AppColors.rose500 : AppColors.slate400,
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 4; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _pin.length
                          ? AppColors.sky500
                          : AppColors.slate100,
                      border: Border.all(
                        color: _mismatch
                            ? AppColors.rose400
                            : i < _pin.length
                            ? AppColors.sky500
                            : AppColors.slate200,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            NumericKeypad(
              style: const KeypadStyle(
                keyHeight: 52,
                radius: 16,
                gap: 10,
                fontSize: 20,
                border: AppColors.slate100,
              ),
              onDigit: _digit,
              onBackspace: () {
                if (_pin.isEmpty) return;
                setState(() => _pin = _pin.substring(0, _pin.length - 1));
              },
            ),
          ],
        ),
      ),
    );
  }
}
