import '../../../app/avatar.dart';
import '../../../widgets/ui.dart';

/// Savings goal shown on the savings screens.
class SavingsGoal {
  const SavingsGoal({
    required this.title,
    required this.category,
    required this.saved,
    required this.target,
    required this.asset,
    required this.tone,
  });

  final String title;
  final String category;
  final int saved;
  final int target;
  final String asset;
  final BadgeTone tone;

  double get progress => target == 0 ? 0 : saved / target;
}

/// Sample goals, pictured with the chosen companion's stickers.
List<SavingsGoal> get kSampleGoals => [
  SavingsGoal(
    title: 'PlayStation 5 тоглоом',
    category: 'Дижитал зугаа',
    saved: 180000,
    target: 250000,
    asset: Stickers.games,
    tone: BadgeTone.sky,
  ),
  SavingsGoal(
    title: 'Шинэ хичээлийн ном, дэвтэр',
    category: 'Хичээл & Хөгжил',
    saved: 95000,
    target: 100000,
    asset: Stickers.books,
    tone: BadgeTone.emerald,
  ),
  SavingsGoal(
    title: 'Зуны зуслан явах сан',
    category: 'Аялал, зуслан',
    saved: 450000,
    target: 800000,
    asset: Stickers.travel,
    tone: BadgeTone.amber,
  ),
];
