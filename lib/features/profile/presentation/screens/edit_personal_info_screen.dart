import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/kid_profile.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../../data/profile_details.dart';
import '../widgets/gender_button.dart';

/// "Мэдээлэл засах": edit profile fields. Changes are sent to the parent
/// for approval before they are saved.
class EditPersonalInfoScreen extends StatefulWidget {
  const EditPersonalInfoScreen({super.key});

  @override
  State<EditPersonalInfoScreen> createState() => _EditPersonalInfoScreenState();
}

class _EditPersonalInfoScreenState extends State<EditPersonalInfoScreen> {
  final _name = TextEditingController(text: Kid.fullName);
  final _phone = TextEditingController(text: Kid.phone);
  final _register = TextEditingController(text: ProfileDetails.register);
  DateTime _birth = _parse(Kid.birthday);
  bool _male = ProfileDetails.gender == 'Эрэгтэй';

  static DateTime _parse(String date) {
    final p = date.split('.').map(int.parse).toList();
    return DateTime(p[0], p[1], p[2]);
  }

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _register.dispose();
    super.dispose();
  }

  String get _birthText =>
      '${_birth.year}.${_birth.month.toString().padLeft(2, '0')}.'
      '${_birth.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birth,
      firstDate: DateTime(2006),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birth = picked);
  }

  void _save() {
    // TODO: send the profile update for parent approval.
    showAppSnack(context, 'Өөрчлөлт эцэг эхийн зөвшөөрөлд илгээгдлээ');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.surface;
    return Scaffold(
      backgroundColor: bg,
      appBar: SubPageHeader(title: 'Мэдээлэл засах', background: bg),
      body: EntranceScope(
        child: AdaptiveListView(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: EntranceItem.list([
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FieldLabel('Бүтэн нэр'),
                  AppTextField(controller: _name),
                  const SizedBox(height: 16),
                  const FieldLabel('Төрсөн огноо'),
                  Semantics(
                    button: true,
                    label: 'Төрсөн огноо сонгох',
                    child: GestureDetector(
                      onTap: withHaptic(_pickDate),
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppColors.slate50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: AppText(
                                _birthText,
                                size: 15,
                                weight: FontWeight.w500,
                              ),
                            ),
                            LineIcon(
                              LineGlyph.calendar,
                              size: 20,
                              color: AppColors.slate500,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const FieldLabel('Хүйс'),
                  Row(
                    children: [
                      Expanded(
                        child: GenderButton(
                          label: 'Эрэгтэй',
                          selected: _male,
                          onTap: () => setState(() => _male = true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GenderButton(
                          label: 'Эмэгтэй',
                          selected: !_male,
                          onTap: () => setState(() => _male = false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const FieldLabel('Утасны дугаар'),
                  AppTextField(
                    controller: _phone,
                    prefixText: '+976',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d ]')),
                      LengthLimitingTextInputFormatter(9),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const FieldLabel('Регистрийн дугаар'),
                  AppTextField(
                    controller: _register,
                    enabled: false,
                    textStyle: inter(
                      size: 15,
                      weight: FontWeight.w500,
                      color: AppColors.slate500,
                    ),
                    suffix: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: LineIcon(
                        LineGlyph.lock,
                        size: 18,
                        color: AppColors.slate400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: AppText(
                      'Регистрийн дугаарыг зөвхөн захиргааны эрхээр өөрчилнө.',
                      size: 12,
                      color: AppColors.slate500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppText(
              'Өөрчлөлт эцэг эхийн зөвшөөрлийн дараа хадгалагдана.',
              size: 13,
              color: AppColors.slate500,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Хадгалах',
              height: 56,
              onPressed: _name.text.trim().isEmpty ? null : _save,
            ),
            const SizedBox(height: 10),
            SoftButton(
              label: 'Болих',
              height: 48,
              background: AppColors.slate50,
              foreground: AppColors.slate900,
              border: Colors.transparent,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ]),
        ),
      ),
    );
  }
}
