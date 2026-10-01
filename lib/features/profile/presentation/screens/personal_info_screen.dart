import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../app/kid_profile.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../../data/profile_details.dart';
import '../widgets/group_label.dart';
import '../widgets/personal_info_row.dart';
import '../widgets/profile_identity_card.dart';
import '../widgets/settings_group.dart';

/// "Хувийн мэдээлэл": read-only profile details.
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  bool _showRegister = false;

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.surface;
    return Scaffold(
      backgroundColor: bg,
      appBar: SubPageHeader(
        title: 'Хувийн мэдээлэл',
        background: bg,
        trailing: Semantics(
          button: true,
          label: 'Засах',
          child: Pressable(
            onTap: () => context.push(AppRoutes.editPersonalInfo),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.card,
                shape: BoxShape.circle,
              ),
              child: LineIcon(
                LineGlyph.edit,
                size: 20,
                color: AppColors.slate800,
              ),
            ),
          ),
        ),
      ),
      body: EntranceScope(
        child: AdaptiveListView(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: EntranceItem.list([
            const ProfileIdentityCard(
              name: Kid.fullName,
              subtitle: '${Kid.school} · ${Kid.grade}',
              status: 'Баталгаажсан',
            ),
            const SizedBox(height: 24),
            const GroupLabel('Үндсэн мэдээлэл'),
            SettingsGroup(
              indent: 16,
              children: [
                const PersonalInfoRow(label: 'Бүтэн нэр', value: Kid.fullName),
                const PersonalInfoRow(
                  label: 'Төрсөн огноо',
                  value: Kid.birthday,
                ),
                const PersonalInfoRow(
                  label: 'Хүйс',
                  value: ProfileDetails.gender,
                ),
                const PersonalInfoRow(label: 'Сургууль', value: Kid.school),
                const PersonalInfoRow(label: 'Анги', value: Kid.grade),
                PersonalInfoRow(
                  label: 'Регистрийн дугаар',
                  value: _showRegister
                      ? ProfileDetails.register
                      : ProfileDetails.maskedRegister,
                  trailing: Semantics(
                    button: true,
                    label: _showRegister ? 'Нуух' : 'Харах',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: withHaptic(
                        () => setState(() => _showRegister = !_showRegister),
                      ),
                      child: SizedBox.square(
                        dimension: 44,
                        child: Center(
                          child: LineIcon(
                            _showRegister ? LineGlyph.eyeOff : LineGlyph.eye,
                            size: 20,
                            color: AppColors.slate500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const PersonalInfoRow(
                  label: 'Утасны дугаар',
                  value: '+976 ${Kid.phone}',
                ),
              ],
            ),
            const SizedBox(height: 16),
            const InfoNote(
              icon: Iconsax.lock_copy,
              text:
                  'Хувийн мэдээллийг өөрчлөхөд эцэг эхийн зөвшөөрөл шаардлагатай.',
            ),
          ]),
        ),
      ),
    );
  }
}
