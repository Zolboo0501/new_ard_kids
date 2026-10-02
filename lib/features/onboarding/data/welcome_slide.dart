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
    title: 'Код уншуулаад,\nтөлбөрөө төл.',
    description:
        'QR кодыг утсаараа уншуулаарай. Төлөх мөнгө, хүлээн авах хүний нэрийг шалгаад баталгаажуулаарай.',
    asset: 'assets/images/onboarding_qr.png',
  ),
  WelcomeSlide(
    title: 'Оноогоо\nцуглуулаарай.',
    description:
        'Хэдэн оноотой болсноо хараарай. Бас оноо авах ямар боломж байгааг олж мэдээрэй.',
    asset: 'assets/images/onboarding_rewards.png',
  ),
];
