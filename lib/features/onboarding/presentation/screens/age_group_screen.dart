import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/age_group.dart';
import '../../../../app/avatar.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../../../auth/presentation/widgets/header.dart';
import '../widgets/age_group_option.dart';

/// "Насаа сонгох" (registration step 3/7, right after the phone is
/// verified): under 10, 10–13 or 14–18. Saved as [appAgeGroup], which picks
/// the avatar art offered on the next step.
///
/// With [editing] (opened from Profile) it starts on the saved age, has no
/// step indicator, and saving returns to the previous screen.
class AgeGroupScreen extends StatefulWidget {
  const AgeGroupScreen({super.key, this.editing = false});

  final bool editing;

  @override
  State<AgeGroupScreen> createState() => _AgeGroupScreenState();
}

class _AgeGroupScreenState extends State<AgeGroupScreen> {
  late AgeGroup? _selected = widget.editing ? appAgeGroup.value : null;

  void _next() {
    final group = _selected;
    if (group == null) return;
    // TODO: send the age range with the registration once there is an API.
    appAgeGroup.value = group;
    AgeGroupStore.save(group);
    // The penguin is only in the kids' set and the cat only in the older.
    final avatar = appAvatar.value.inAge(group);
    if (avatar != appAvatar.value) {
      appAvatar.value = avatar;
      AvatarStore.save(avatar);
    }
    if (widget.editing) {
      showAppSnack(context, 'Нас хадгалагдлаа: ${group.label}');
      context.pop();
      return;
    }
    context.push(AppRoutes.avatarPicker);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: EntranceScope(
                child: AdaptiveListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: EntranceItem.list([
                    Header(step: widget.editing ? null : 'Алхам 3/7'),
                    const SizedBox(height: 20),
                    AppText(
                      'Хэдэн настай вэ?',
                      size: 28,
                      weight: FontWeight.w700,
                      color: AppColors.slate900,
                      height: 1.2,
                      letterSpacing: -0.6,
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      'Насаа сонгоорой. Дараа нь өөрийн дүрээ сонгоно.',
                      size: 15,
                      color: AppColors.slate500,
                      height: 1.45,
                    ),
                    const SizedBox(height: 32),
                    for (final (i, group) in AgeGroup.values.indexed) ...[
                      if (i > 0) const SizedBox(height: 12),
                      AgeGroupOption(
                        group: group,
                        selected: _selected == group,
                        onTap: () => setState(() => _selected = group),
                      ),
                    ],
                    const SizedBox(height: 24),
                    AppText(
                      'Насаа дараа нь Профайл хэсгээс засаж болно.',
                      size: 13,
                      height: 1.5,
                      color: AppColors.slate500,
                    ),
                  ]),
                ),
              ),
            ),
            AdaptiveCenter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: PrimaryButton(
                  label: widget.editing ? 'Хадгалах' : 'Үргэлжлүүлэх',
                  height: 56,
                  onPressed:
                      _selected == null ||
                          (widget.editing && _selected == appAgeGroup.value)
                      ? null
                      : _next,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
