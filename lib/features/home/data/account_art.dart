import '../../../app/accounts.dart';
import '../../../app/avatar.dart';

/// The chosen character's sticker for one of the teen's accounts on Home,
/// or null where the age has no stickers (14+ keeps the line icons).
String? accountSticker(String account) {
  if (!Stickers.forAge) return null;
  return Stickers.prefer(switch (account) {
    Accounts.main => const ['card', 'payment', 'transfer'],
    Accounts.savings => const ['piggy', 'coins', 'coin'],
    Accounts.stocks => const ['growth', 'report'],
    Accounts.rewards => const ['gift', 'success'],
    _ => const ['coins', 'coin'],
  });
}
