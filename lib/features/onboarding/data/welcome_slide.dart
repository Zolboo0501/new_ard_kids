import '../../../theme/app_theme.dart';

/// One concept per introduction page, before account setup: a bean
/// character doing the thing.
class WelcomeSlide {
  const WelcomeSlide({
    required this.accent,
    required this.title,
    required this.highlight,
    required this.description,
    required this.character,
    required this.background,
  });

  /// The accent that matches the art's colours. It tints the highlighted
  /// word, the page dots and the button.
  final AppThemeChoice accent;

  final String title;

  /// The part of [title] drawn in the accent, the word that says what the
  /// slide is about.
  final String highlight;
  final String description;

  /// The bean character, a transparent cut-out drawn above the copy.
  final String character;

  /// The full-screen backdrop in the slide's colours: soft shapes in two
  /// corners around a plain middle, where the character and the copy sit.
  final String background;
}

const welcomeSlides = [
  WelcomeSlide(
    accent: AppThemeChoice.indigo,
    title: 'Мөнгөө\nцуглуулаарай.',
    highlight: 'цуглуулаарай',
    description:
        'Хүссэн зүйлээ сонгоод, түүндээ зориулж мөнгөө бага багаар хуримтлуулаарай.',
    character: 'assets/images/welcome/goal_bean.webp',
    background: 'assets/images/welcome/goal_bg.webp',
  ),
  WelcomeSlide(
    accent: AppThemeChoice.pink,
    title: 'Мөнгөө юунд\nзарцуулсан бэ?',
    highlight: 'зарцуулсан',
    description:
        'Хэдэн төгрөг орж, юунд зарцуулснаа, хэд үлдсэнийг нэг дороос хараарай.',
    character: 'assets/images/welcome/spending_bean.webp',
    background: 'assets/images/welcome/spending_bg.webp',
  ),
  WelcomeSlide(
    accent: AppThemeChoice.sky,
    title: 'Код уншуулаад,\nтөлбөрөө төл.',
    highlight: 'төлбөрөө',
    description:
        'QR кодыг уншуулаад, дүн болон хүлээн авагчийг шалгаад баталгаажуулаарай.',
    character: 'assets/images/welcome/qr_bean.webp',
    background: 'assets/images/welcome/qr_bg.webp',
  ),
  WelcomeSlide(
    accent: AppThemeChoice.lime,
    title: 'Оноогоо\nцуглуулаарай.',
    highlight: 'Оноогоо',
    description:
        'Хэдэн оноотой болсноо хараад, оноо авах шинэ боломжуудаа олоорой.',
    character: 'assets/images/welcome/rewards_bean.webp',
    background: 'assets/images/welcome/rewards_bg.webp',
  ),
];
