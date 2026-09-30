/// One concept per introduction page, before account setup.
class WelcomeSlide {
  const WelcomeSlide({
    required this.title,
    required this.description,
    required this.asset,
  });
  final String title;
  final String description;
  final String asset;
}

const welcomeSlides = [
  WelcomeSlide(
    title: 'Мөнгөө\nцуглуулаарай.',
    description:
        'Шинэ чихэвч эсвэл дугуй авмаар байна уу? Авах зүйлээ сонгоод, мөнгөө бага багаар цуглуулаарай.',
    asset: 'assets/images/onboarding_goal.png',
  ),
  WelcomeSlide(
    title: 'Мөнгөө юунд\nзарцуулсан бэ?',
    description:
        'Хэдэн төгрөг авсан, юунд зарцуулснаа хараарай. Бас хэдэн төгрөг үлдсэнийг мэдэж болно.',
    asset: 'assets/images/onboarding_wallet.png',
  ),
  WelcomeSlide(
    title: 'Аав, ээжтэйгээ\nхамт эхэл.',
    description:
        'Аав, ээжтэйгээ апп дотор холбогдоорой. Мөнгө хэрэгтэй үедээ тэдэнд хүсэлт явуулж болно.',
    asset: 'assets/images/onboarding_connection.png',
  ),
];
