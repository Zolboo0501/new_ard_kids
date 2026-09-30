import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:new_ard_kids/app/accounts.dart';
import 'package:new_ard_kids/app/age_group.dart';
import 'package:new_ard_kids/app/avatar.dart';
import 'package:new_ard_kids/features/home/data/card_art.dart';

void main() {
  tearDown(() {
    appAgeGroup.value = AgeGroup.tween;
    appAvatar.value = AppAvatar.fox;
  });

  test('10–13 fox uses its own sheet, and the kids set for the rest', () {
    appAvatar.value = AppAvatar.fox;
    appAgeGroup.value = AgeGroup.tween;
    expect(Stickers.piggy, 'assets/images/teenegars/fox/fox_piggy.png');
    expect(Stickers.shopping, 'assets/images/teenegars/fox/fox_shopping.png');
    // Not on the teen sheet: the kids' sticker stands in.
    expect(Stickers.dad, 'assets/images/kids/fox/fox_dad.png');
  });

  test('Under 10, and the other companions, keep the kids set', () {
    appAvatar.value = AppAvatar.fox;
    appAgeGroup.value = AgeGroup.under10;
    expect(Stickers.piggy, 'assets/images/kids/fox/fox_piggy.png');
    expect(Stickers.shopping, Stickers.payment);

    appAgeGroup.value = AgeGroup.teen;
    appAvatar.value = AppAvatar.cat;
    expect(Stickers.piggy, 'assets/images/kids/penguin/penguin_piggy.png');
  });

  test('10–13 cat uses its own sheet, not the penguin it borrows from', () {
    appAvatar.value = AppAvatar.cat;
    appAgeGroup.value = AgeGroup.tween;
    expect(Stickers.love, 'assets/images/teenegars/cat/cat_love.png');
    expect(Stickers.books, 'assets/images/teenegars/cat/cat_books.png');
    expect(
      Stickers.named('fish', fallback: Stickers.snack),
      'assets/images/teenegars/cat/cat_fish.png',
    );
    // Not on the cat's sheet: the kids' set it borrows stands in.
    expect(Stickers.piggy, 'assets/images/kids/penguin/penguin_piggy.png');
  });

  test('10–13 rabbit uses its own sheet', () {
    appAvatar.value = AppAvatar.bunny;
    appAgeGroup.value = AgeGroup.tween;
    expect(Stickers.love, 'assets/images/teenegars/rabbit/rabbit_love.png');
    expect(Stickers.cool, 'assets/images/teenegars/rabbit/rabbit_cool.png');
    expect(Stickers.games, 'assets/images/teenegars/rabbit/rabbit_games.png');
    // Not on the rabbit's sheet: its kids' sticker stands in.
    expect(Stickers.piggy, 'assets/images/kids/rabbit/rabbit_piggy.png');
  });

  test('10–13 bear uses its own sheet', () {
    appAvatar.value = AppAvatar.bear;
    appAgeGroup.value = AgeGroup.tween;
    expect(Stickers.piggy, 'assets/images/teenegars/bear/bear_piggy.png');
    expect(Stickers.games, 'assets/images/teenegars/bear/bear_games.png');
    expect(Stickers.drink, 'assets/images/teenegars/bear/bear_drink.png');
    // The fox-only extras fall back to the bear's closest sticker.
    expect(Stickers.peace, Stickers.friends);
    expect(Stickers.dad, 'assets/images/kids/bear/bear_dad.png');
  });

  test('Every 10–13 sticker file exists', () {
    for (final set in ['fox', 'bear', 'rabbit', 'cat']) {
      final dir = Directory('assets/images/teenegars/$set');
      // Finder drops .DS_Store files into folders that are opened.
      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) => !f.uri.pathSegments.last.startsWith('.'))
          .toList();
      expect(files, isNotEmpty, reason: set);
      for (final f in files) {
        expect(f.path, endsWith('.png'));
      }
    }
  });

  test('Every sticker a 10–13 fox can resolve exists on disk', () {
    appAvatar.value = AppAvatar.fox;
    appAgeGroup.value = AgeGroup.tween;
    final paths = [
      Stickers.avatar, Stickers.calculator, Stickers.card, Stickers.cart,
      Stickers.coin, Stickers.coins, Stickers.edit, Stickers.friends,
      Stickers.gift, Stickers.goal, Stickers.growth, Stickers.home,
      Stickers.lesson, Stickers.lock, Stickers.love, Stickers.notification,
      Stickers.payment, Stickers.peace, Stickers.piggy, Stickers.profile,
      Stickers.qr, Stickers.report, Stickers.send, Stickers.shield,
      Stickers.shopping, Stickers.study, Stickers.success, Stickers.transfer,
      // Fallbacks to the kids set.
      Stickers.dad, Stickers.mom, Stickers.games, Stickers.travel,
    ];
    for (final path in paths) {
      expect(File(path).existsSync(), isTrue, reason: path);
    }
    expect(paths.where((p) => p.contains('teenegars')), hasLength(28));
  });

  test('Home card art: every 10–13 character, one per account', () {
    appAgeGroup.value = AgeGroup.tween;
    for (final avatar in [
      AppAvatar.fox,
      AppAvatar.bunny,
      AppAvatar.bear,
      AppAvatar.cat,
    ]) {
      appAvatar.value = avatar;
      for (final account in [
        Accounts.main,
        Accounts.savings,
        Accounts.stocks,
        Accounts.rewards,
        Accounts.coin,
      ]) {
        final art = accountCardArt(account);
        expect(art, isNotNull, reason: account);
        expect(File(art!).existsSync(), isTrue, reason: art);
      }
    }
    appAvatar.value = AppAvatar.bunny;
    expect(
      accountCardArt(Accounts.savings),
      'assets/images/teenegars/rabbit/cards/savings.webp',
    );

    // Under 10, every cartoon has card art.
    appAgeGroup.value = AgeGroup.under10;
    for (final (avatar, set) in [
      (AppAvatar.fox, 'fox'),
      (AppAvatar.bear, 'bear'),
      (AppAvatar.bunny, 'rabbit'),
      (AppAvatar.penguin, 'penguin'),
    ]) {
      for (final account in [
        Accounts.main,
        Accounts.savings,
        Accounts.stocks,
        Accounts.rewards,
        Accounts.coin,
      ]) {
        appAvatar.value = avatar;
        final art = accountCardArt(account);
        expect(art, startsWith('assets/images/kids/$set/cards/'));
        expect(File(art!).existsSync(), isTrue, reason: art);
      }
    }
    // Row banners: every under-10 and 10–13 character's three, none at 14+.
    for (final age in [AgeGroup.under10, AgeGroup.tween]) {
      appAgeGroup.value = age;
      for (final avatar in AppAvatar.forAge(age)) {
        appAvatar.value = avatar;
        for (final account in [
          Accounts.savings,
          Accounts.stocks,
          Accounts.rewards,
        ]) {
          final art = accountRowArt(account);
          expect(art, isNotNull, reason: '$age $avatar $account');
          expect(File(art!.asset).existsSync(), isTrue, reason: art.asset);
        }
        expect(accountRowArt(Accounts.main), isNull);
      }
    }
    appAvatar.value = AppAvatar.bunny;
    appAgeGroup.value = AgeGroup.teen;
    expect(accountRowArt(Accounts.savings), isNull);
    appAgeGroup.value = AgeGroup.tween;

    // The penguin is kids-only, so above 10 it has no card art.
    appAvatar.value = AppAvatar.penguin;
    expect(accountCardArt(Accounts.main), isNull);
    appAvatar.value = AppAvatar.fox;
    appAgeGroup.value = AgeGroup.teen;
    expect(accountCardArt(Accounts.main), isNull);
  });
}
