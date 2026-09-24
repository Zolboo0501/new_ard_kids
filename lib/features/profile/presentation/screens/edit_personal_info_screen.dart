import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../widgets/student_header_card.dart';
import '../widgets/gender_button.dart';

/// "Хувийн мэдээлэл засах": edit profile fields (sent for parent approval).
class EditPersonalInfoScreen extends StatefulWidget {
  const EditPersonalInfoScreen({super.key});

  @override
  State<EditPersonalInfoScreen> createState() => _EditPersonalInfoScreenState();
}

class _EditPersonalInfoScreenState extends State<EditPersonalInfoScreen> {
  final _name = TextEditingController(text: 'Бат-Ирээдүй Төмөрбаатар');
  final _phone = TextEditingController(text: '9911 2345');
  DateTime _birth = DateTime(2014, 5, 18);
  bool _male = true;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  String get _birthText =>
      '${_birth.year} оны ${_birth.month.toString().padLeft(2, '0')} сарын '
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
    const bg = Color(0xFFF4F8FC);
    return Scaffold(
      backgroundColor: bg,
      appBar: SubPageHeader(
        title: 'Мэдээлэл засах',
        subtitle: 'Хувийн мэдээллээ шинэчлэх',
        background: bg,
        trailing: CircleIconButton(
          icon: Icons.help_outline_rounded,
          label: 'Тусламж',
          onPressed: () => showAppSnack(
            context,
            'Өөрчлөлт бүр эцэг эхийн зөвшөөрлөөр хадгалагдана',
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
            StudentHeaderCard(
              subtitle: 'Зураг шинэчлэх боломжтой',
              avatarBadge: Semantics(
                button: true,
                label: 'Зураг солих',
                child: GestureDetector(
                  onTap: withHaptic(
                    () => showAppSnack(context, 'Зургийн сан нээгдэнэ'),
                  ),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.sky500,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.photo_camera_outlined,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_outlined, size: 12, color: AppColors.sky500),
                  const SizedBox(width: 2),
                  AppText(
                    'Засварлах',
                    size: 11,
                    weight: FontWeight.w700,
                    color: AppColors.sky500,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              radius: 24,
              padding: const EdgeInsets.all(20),
              borderColor: AppColors.slate100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        'Засвар',
                        size: 11,
                        weight: FontWeight.w600,
                        color: AppColors.sky600,
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.slate100),
                  const FieldLabel('Бүтэн нэр'),
                  AppTextField(
                    controller: _name,
                    prefixIcon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 14),
                  const FieldLabel('Төрсөн огноо'),
                  GestureDetector(
                    onTap: withHaptic(_pickDate),
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.cake_outlined,
                            size: 20,
                            color: AppColors.slate400,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AppText(
                              _birthText,
                              size: 14,
                              weight: FontWeight.w700,
                            ),
                          ),
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 20,
                            color: AppColors.sky500,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
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
                  const SizedBox(height: 14),
                  const FieldLabel('Утасны дугаар'),
                  AppTextField(
                    controller: _phone,
                    prefixIcon: Icons.phone_iphone_rounded,
                    prefixText: '+976',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d ]')),
                      LengthLimitingTextInputFormatter(9),
                    ],
                  ),
                  const SizedBox(height: 14),
                  FieldLabel(
                    'Регистрийн дугаар',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          size: 12,
                          color: AppColors.amber600,
                        ),
                        const SizedBox(width: 2),
                        AppText(
                          'Түгжигдсэн',
                          size: 10,
                          weight: FontWeight.w600,
                          color: AppColors.amber600,
                        ),
                      ],
                    ),
                  ),
                  AppTextField(
                    controller: TextEditingController(text: 'УХ14251812'),
                    prefixIcon: Icons.fingerprint_rounded,
                    enabled: false,
                    textStyle: inter(
                      size: 14,
                      weight: FontWeight.w700,
                      color: AppColors.slate400,
                    ),
                    suffix: const Icon(
                      Icons.lock_outline_rounded,
                      size: 18,
                      color: AppColors.slate400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: AppText(
                      'Регистрийн дугаарыг зөвхөн захиргааны эрхээр өөрчлөх боломжтой.',
                      size: 10,
                      color: AppColors.slate400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Хадгалах & Хүсэлт илгээх',
              height: 56,
              onPressed: _name.text.trim().isEmpty ? null : _save,
            ),
            const SizedBox(height: 10),
            SoftButton(
              label: 'Цуцлах ба буцах',
              height: 48,
              background: Colors.white,
              foreground: AppColors.slate600,
              border: AppColors.slate200,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ]),
        ),
      ),
    );
  }
}
