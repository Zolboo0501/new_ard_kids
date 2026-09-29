import '../../../widgets/ui.dart';

/// Savings goal shown on the savings screens.
class SavingsGoal {
  const SavingsGoal({
    required this.title,
    required this.category,
    required this.saved,
    required this.target,
    required this.glyph,
    required this.tone,
  });

  final String title;
  final String category;
  final int saved;
  final int target;

  /// The line icon on the goal's tile.
  final LineGlyph glyph;

  /// Tints the goal's tile.
  final BadgeTone tone;

  double get progress => target == 0 ? 0 : (saved / target).clamp(0.0, 1.0);
}

/// Sample goals.
const kSampleGoals = [
  SavingsGoal(
    title: 'PlayStation 5 Pro',
    category: 'Технологи',
    saved: 180000,
    target: 250000,
    glyph: LineGlyph.gamepad,
    tone: BadgeTone.sky,
  ),
  SavingsGoal(
    title: 'Хичээлийн ном, дэвтэр',
    category: 'Хичээл',
    saved: 95000,
    target: 100000,
    glyph: LineGlyph.book,
    tone: BadgeTone.emerald,
  ),
  SavingsGoal(
    title: 'Зуны аялал',
    category: 'Аялал',
    saved: 450000,
    target: 800000,
    glyph: LineGlyph.plane,
    tone: BadgeTone.amber,
  ),
];
