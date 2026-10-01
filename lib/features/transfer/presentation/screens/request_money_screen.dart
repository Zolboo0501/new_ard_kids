import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/entrance.dart';
import '../../../../widgets/input_formatters.dart';
import '../../../../widgets/ui.dart';
import '../widgets/clear_button.dart';
import '../widgets/parent_card.dart';
import '../widgets/transfer_label.dart';

/// "Мөнгө хүсэх": ask a parent to top up the account.
class RequestMoneyScreen extends StatefulWidget {
  const RequestMoneyScreen({super.key});

  @override
  State<RequestMoneyScreen> createState() => _RequestMoneyScreenState();
}

class _RequestMoneyScreenState extends State<RequestMoneyScreen> {
  static const _parents = [
    ('Ээж', 'ЦС', 'Голомт • 1605******'),
    ('Аав', 'ДБ', 'Хаан • 5042******'),
  ];
  static const _types = ['Хоол', 'Тээвэр', 'Сургууль', 'Хувцас', 'Бусад'];

  final _amount = TextEditingController(text: '20,000');
  final _note = TextEditingController(text: 'Долоо хоногийн өдрийн хоол');
  int _parent = 0;
  int? _quick = 20000;
  int _type = 0;

  @override
  void initState() {
    super.initState();
    _amount.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  int get _value =>
      int.tryParse(_amount.text.replaceAll(RegExp(r'\D'), '')) ?? 0;

  void _submit() {
    FocusScope.of(context).unfocus();
    // TODO: send the request to the parent's app.
    showAppSnack(
      context,
      '${_parents[_parent].$1} руу ${formatMnt(_value)} хүсэлт илгээлээ',
    );
    context.pushReplacement(AppRoutes.requestList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: SubPageHeader(
        title: 'Мөнгө хүсэх',
        background: AppColors.surface,
        trailing: CircleIconButton(
          icon: Iconsax.clock_copy,
          label: 'Хүсэлтийн жагсаалт',
          onPressed: () => context.push(AppRoutes.requestList),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: EntranceScope(
              child: AdaptiveListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: EntranceItem.list([
                  AppText(
                    'Эцэг эхдээ хүсэлт илгээх',
                    size: 16,
                    weight: FontWeight.w700,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    'Зөвшөөрвөл мөнгө таны дансанд шууд орно.',
                    size: 13,
                    color: AppColors.slate500,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (final (i, p) in _parents.indexed) ...[
                        if (i > 0) const SizedBox(width: 10),
                        Expanded(
                          child: ParentCard(
                            name: p.$1,
                            initials: p.$2,
                            account: p.$3,
                            selected: _parent == i,
                            onTap: () => setState(() => _parent = i),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const TransferLabel('Дүн'),
                        AppTextField(
                          controller: _amount,
                          prefixText: '₮',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            ThousandsFormatter(),
                          ],
                          textStyle: moneyStyle(
                            size: 20,
                            color: AppColors.slate900,
                          ),
                          onChanged: (_) => setState(() => _quick = null),
                          suffix: ClearButton(onTap: _amount.clear),
                        ),
                        const SizedBox(height: 10),
                        QuickAmountChips(
                          amounts: const [5000, 10000, 20000, 50000],
                          selected: _quick,
                          onSelected: (v) {
                            _amount.text = formatMnt(v).substring(1);
                            setState(() => _quick = v);
                          },
                        ),
                        const SizedBox(height: 20),
                        const TransferLabel('Юунд хэрэгтэй вэ'),
                        AppTextField(
                          controller: _note,
                          hint: 'Жишээ нь: Сургуулийн аялал',
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final (i, t) in _types.indexed)
                              FilterChipPill(
                                label: t,
                                selected: _type == i,
                                onTap: () => setState(() => _type = i),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const InfoNote(
                    icon: Iconsax.notification_copy,
                    text:
                        'Хүсэлт эцэг эхийн утсанд мэдэгдлээр очно. Хариуг '
                        'Хүсэлтийн жагсаалтаас харна.',
                  ),
                ]),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              12 + MediaQuery.paddingOf(context).bottom,
            ),
            child: AdaptiveCenter(
              child: PrimaryButton(
                label: 'Хүсэлт илгээх',
                onPressed: _value > 0 ? _submit : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
