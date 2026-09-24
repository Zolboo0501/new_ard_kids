import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../widgets/personal_info_row.dart';
import '../widgets/student_header_card.dart';

/// "Хувийн мэдээлэл": read-only student profile details.
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  bool _showRegister = false;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF4F8FC);
    return Scaffold(
      backgroundColor: bg,
      appBar: SubPageHeader(
        title: 'Хувийн мэдээлэл',
        subtitle: 'Сурагчийн бүртгэл ба тохиргоо',
        background: bg,
        trailing: CircleIconButton(
          icon: Icons.edit_outlined,
          label: 'Засах',
          color: AppColors.sky600,
          onPressed: () => context.push(AppRoutes.editPersonalInfo),
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
            const StudentHeaderCard(
              subtitle: '12 настай · 6-р анги',
              trailing: StatusBadge(
                label: 'Баталгаажсан',
                tone: BadgeTone.emerald,
                icon: Icons.verified_rounded,
              ),
              onlineDot: true,
            ),
            const SizedBox(height: 16),
            AppCard(
              radius: 24,
              padding: const EdgeInsets.all(16),
              borderColor: AppColors.slate100,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.sky50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.person_outline_rounded,
                          size: 18,
                          color: AppColors.sky500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppText(
                          'Үндсэн мэдээлэл',
                          size: 14,
                          weight: FontWeight.w700,
                        ),
                      ),
                      AppText(
                        'Албан ёсны',
                        size: 11,
                        weight: FontWeight.w600,
                        color: AppColors.slate400,
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.slate100),
                  const PersonalInfoRow(
                    icon: Icons.badge_outlined,
                    label: 'Бүтэн нэр',
                    value: Text('Бат-Ирээдүй Төмөрбаатар'),
                  ),
                  const PersonalInfoRow(
                    icon: Icons.cake_outlined,
                    label: 'Төрсөн огноо',
                    value: Text('2014 оны 05 сарын 18'),
                  ),
                  const PersonalInfoRow(
                    icon: Icons.wc_rounded,
                    label: 'Хүйс',
                    value: Text('Эрэгтэй'),
                  ),
                  PersonalInfoRow(
                    icon: Icons.fingerprint_rounded,
                    label: 'Регистрийн дугаар',
                    value: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_showRegister ? 'УХ14251812' : 'УХ••••••12'),
                        const SizedBox(width: 4),
                        Semantics(
                          button: true,
                          label: 'Харах эсэх',
                          child: GestureDetector(
                            onTap: withHaptic(
                              () => setState(
                                () => _showRegister = !_showRegister,
                              ),
                            ),
                            child: Icon(
                              _showRegister
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 16,
                              color: AppColors.slate400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PersonalInfoRow(
                    icon: Icons.phone_iphone_rounded,
                    label: 'Утасны дугаар',
                    value: Text('+976 9911 2345'),
                    last: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const InfoNote(
              icon: Icons.lock_outline_rounded,
              text:
                  'Хувийн мэдээллийг өөрчлөхөд эцэг эхийн зөвшөөрөл шаардлагатай.',
            ),
          ]),
        ),
      ),
    );
  }
}
