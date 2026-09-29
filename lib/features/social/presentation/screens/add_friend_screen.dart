import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/ui.dart';
import '../widgets/relation_button.dart';
import '../widgets/social_initials_avatar.dart';

/// "Найз нэмэх": save a friend or family member for quick transfers.
class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  static const _relations = [
    ('Найз', LineGlyph.profile),
    ('Ах дүү', LineGlyph.users),
    ('Эцэг эх', LineGlyph.home),
    ('Ангийнхан', LineGlyph.graduation),
  ];
  static const _banks = ['Хаан банк', 'Голомт банк', 'ХХБ', 'Төрийн банк'];

  /// (name, bank and masked account)
  static const _suggested = [
    ('Анар Болд', 'Хаан банк · 5042 ••••••'),
    ('Сарнай (эгч)', 'Голомт банк · 1605 ••••••'),
  ];

  final _nickname = TextEditingController();
  final _account = TextEditingController();
  final _phone = TextEditingController();
  int _relation = 0;
  int _bank = 0;
  final _added = <String>{};

  @override
  void initState() {
    super.initState();
    _nickname.addListener(() => setState(() {}));
    _account.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nickname.dispose();
    _account.dispose();
    _phone.dispose();
    super.dispose();
  }

  bool get _valid =>
      _nickname.text.trim().isNotEmpty && _account.text.length == 10;

  void _save() {
    // TODO: persist the saved friend.
    showAppSnack(context, '${_nickname.text.trim()} хадгалагдлаа');
    context.pop();
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
    child: AppText(
      title,
      size: 16,
      weight: FontWeight.w700,
      color: AppColors.slate900,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: SubPageHeader(
        title: 'Найз нэмэх',
        background: AppColors.surface,
        trailing: CircleIconButton(
          icon: Icons.qr_code_scanner_rounded,
          label: 'QR код уншуулах',
          onPressed: () => context.push(AppRoutes.qrScan),
        ),
      ),
      body: EntranceScope(
        child: AdaptiveListView(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: EntranceItem.list([
            _sectionTitle('Харилцаа'),
            Row(
              children: [
                for (final (i, r) in _relations.indexed) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: RelationButton(
                      label: r.$1,
                      glyph: r.$2,
                      selected: _relation == i,
                      onTap: () => setState(() => _relation = i),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FieldLabel('Нэр'),
                  AppTextField(controller: _nickname, hint: 'Жишээ нь: Анар'),
                  const SizedBox(height: 16),
                  const FieldLabel('Дансны дугаар'),
                  AppTextField(
                    controller: _account,
                    hint: '10 оронтой дугаар',
                    keyboardType: TextInputType.number,
                    textStyle: moneyStyle(size: 15, color: AppColors.slate900),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const FieldLabel('Банк'),
                  // Wraps instead of scrolling, so no bank name is cut off.
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final (i, b) in _banks.indexed)
                        FilterChipPill(
                          label: b,
                          selected: _bank == i,
                          onTap: () => setState(() => _bank = i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FieldLabel(
                    'Утасны дугаар',
                    trailing: AppText(
                      'Заавал биш',
                      size: 12,
                      color: AppColors.slate400,
                    ),
                  ),
                  AppTextField(
                    controller: _phone,
                    hint: '8 оронтой дугаар',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Утасны жагсаалтаас'),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (final (i, s) in _suggested.indexed) ...[
                    if (i > 0) Divider(height: 1, color: AppColors.line),
                    ListItemEntrance(
                      id: s,
                      index: i,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            SocialInitialsAvatar(name: s.$1),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    s.$1,
                                    size: 14,
                                    weight: FontWeight.w600,
                                    color: AppColors.slate900,
                                  ),
                                  const SizedBox(height: 2),
                                  AppText(
                                    s.$2,
                                    size: 13,
                                    color: AppColors.slate500,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            _addButton(s.$1),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            const InfoNote(
              text:
                  'Хадгалсан хүн рүүгээ дараа нь данс бичихгүйгээр шилжүүлэг '
                  'хийнэ. Энэ жагсаалт холбогдсон эцэг эхийн аппад харагдана.',
            ),
            const SizedBox(height: 20),
            PrimaryButton(label: 'Хадгалах', onPressed: _valid ? _save : null),
          ]),
        ),
      ),
    );
  }

  Widget _addButton(String name) {
    final added = _added.contains(name);
    final fg = added ? AppColors.emerald600 : AppColors.sky600;
    return SoftButton(
      label: added ? 'Нэмсэн' : 'Нэмэх',
      leading: LineIcon(
        added ? LineGlyph.check : LineGlyph.personAdd,
        size: 18,
        color: fg,
      ),
      height: 44,
      background: added ? AppColors.emerald50 : AppColors.sky50,
      foreground: fg,
      border: Colors.transparent,
      onPressed: added ? null : () => setState(() => _added.add(name)),
    );
  }
}
