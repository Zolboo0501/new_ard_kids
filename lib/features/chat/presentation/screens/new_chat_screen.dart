import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import '../../data/chat_thread.dart';
import '../widgets/chat_user_row.dart';

/// "Шинэ мессеж", opened from the Чат tab, DM style: a "Хэнд:" line that
/// searches Ard KIDS users by @username (chat stays inside the app), with
/// suggestions below while it's empty. A person opens the conversation in
/// this screen's place, so going back returns to the inbox.
class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final _query = TextEditingController();

  @override
  void initState() {
    super.initState();
    _query.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _open(ChatUser user) {
    final thread = chatThreadWith(user);
    context.pushReplacement(AppRoutes.chatThreadOf(thread.id));
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.surface;
    final query = _query.text.trim();
    final results = query.isEmpty ? mockChatUsers : searchChatUsers(query);
    return Scaffold(
      backgroundColor: bg,
      appBar: SubPageHeader(title: 'Шинэ мессеж', background: bg),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.line)),
            ),
            child: Row(
              children: [
                AppText(
                  'Хэнд:',
                  size: 15,
                  weight: FontWeight.w600,
                  color: AppColors.slate900,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _query,
                    autofocus: true,
                    onTapOutside: dismissKeyboard,
                    style: inter(size: 15, color: AppColors.slate900),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      hintText: '@username хайх',
                      hintStyle: inter(size: 15, color: AppColors.slate400),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AdaptiveListView(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                24 + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      LineIcon(
                        LineGlyph.shield,
                        size: 16,
                        color: AppColors.slate500,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: AppText(
                          'Зөвхөн Ard KIDS хэрэглэгчидтэй чатлана.',
                          size: 13,
                          color: AppColors.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (query.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: AppText(
                      'Санал болгох',
                      size: 16,
                      weight: FontWeight.w700,
                      color: AppColors.slate900,
                    ),
                  ),
                if (results.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: AppText(
                      '«$query» нэртэй Ard KIDS хэрэглэгч олдсонгүй.',
                      size: 14,
                      color: AppColors.slate500,
                      textAlign: TextAlign.center,
                    ),
                  ),
                for (final u in results)
                  ChatUserRow(user: u, onTap: () => _open(u)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
