import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';

/// "Эцэг эхийн холболт": send a link request to a parent/guardian.
class ParentLinkScreen extends StatefulWidget {
  const ParentLinkScreen({super.key});

  @override
  State<ParentLinkScreen> createState() => _ParentLinkScreenState();
}

class _ParentLinkScreenState extends State<ParentLinkScreen> {
  final _phone = TextEditingController();
  final _register = TextEditingController();
  int _role = 0;

  static const _roles = [
    ('Ээж', Mascots.catHeart),
    ('Аав', Mascots.owlBook),
    ('Бусад', Mascots.bearFamily),
  ];

  @override
  void initState() {
    super.initState();
    _phone.addListener(() => setState(() {}));
    _register.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phone.dispose();
    _register.dispose();
    super.dispose();
  }

  bool get _valid => _phone.text.length == 8 && _register.text.length == 10;

  void _goHome({required bool linked}) {
    context.go(linked ? AppRoutes.home : AppRoutes.homeUnlinked);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    // TODO: send the link request to the backend.
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const _SuccessSheet(),
    );
    if (mounted) _goHome(linked: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dsSurface,
      appBar: SubPageHeader(
        title: 'Эцэг эхийн холболт',
        background: AppColors.dsSurface,
        trailing: GestureDetector(
          onTap: () => _goHome(linked: false),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Алгасах',
              style: comfortaa(
                size: 11,
                weight: FontWeight.w600,
                color: AppColors.slate600,
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const Center(
            child: MascotImage(
              asset: Mascots.bearFamily,
              size: 140,
              background: AppColors.dsSurface,
              semanticLabel: 'Parent and baby bear',
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: StatusBadge(
              label: 'Эцэг эхтэйгээ холбогдох',
              icon: Icons.family_restroom_rounded,
            ),
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              text: 'Эцэг эхтэйгээ холбогдоод эрхээ ',
              children: [
                TextSpan(
                  text: '5 дахин',
                  style:
                      comfortaa(
                        size: 20,
                        weight: FontWeight.w800,
                        color: AppColors.sky500,
                      ).copyWith(
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.sky300,
                        decorationThickness: 2,
                      ),
                ),
                const TextSpan(text: ' нэмэгдүүлээрэй! ✨'),
              ],
            ),
            textAlign: TextAlign.center,
            style: comfortaa(size: 20, weight: FontWeight.w800, height: 1.4),
          ),
          const SizedBox(height: 16),
          _LimitCard(
            icon: Icons.lock_outline_rounded,
            title: 'Одоогийн эрх',
            subtitle: 'Холбогдоогүй',
            badge: const StatusBadge(
              label: 'Хязгаарлагдмал',
              tone: BadgeTone.slate,
              dot: true,
            ),
            muted: true,
            stats: const [
              ('Өдрийн зарцуулалт', '₮ 20,000', null),
              ('Өдрийн гүйлгээ', '2 удаа', null),
            ],
            footer: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: AppColors.slate500,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Зөвхөн бэлэн мөнгө зарцуулах анхан шатны эрхтэй',
                    style: comfortaa(size: 11, color: AppColors.slate500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _LimitCard(
            icon: Icons.verified_rounded,
            title: 'Эцэг эх холбогдсоны дараа',
            subtitle: 'Бүрэн боломж нээгдэнэ',
            badge: const StatusBadge(
              label: 'Бүрэн эрх',
              tone: BadgeTone.emerald,
              icon: Icons.bolt_rounded,
            ),
            muted: false,
            stats: const [
              ('Өдрийн зарцуулалт', '₮ 100,000+', BadgeTone.sky),
              ('Өдрийн гүйлгээ', 'Хязгааргүй', BadgeTone.emerald),
            ],
            footer: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.amber50.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.amber200.withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                children: [
                  const Text('🎁', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Хүүхдийн хадгаламж, койн, урамшуулал авах боломжтой болно!',
                      style: comfortaa(
                        size: 11,
                        weight: FontWeight.w600,
                        color: AppColors.amber800,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          AppCard(
            radius: 20,
            padding: const EdgeInsets.all(16),
            borderColor: AppColors.slate100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Холбогдох асран хамгаалагчаа сонгоно уу',
                  style: comfortaa(size: 13, weight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final (i, r) in _roles.indexed) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: _RoleButton(
                          label: r.$1,
                          asset: r.$2,
                          selected: _role == i,
                          onTap: () => setState(() => _role = i),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                const FieldLabel('Эцэг / Эхийн утасны дугаар'),
                AppTextField(
                  controller: _phone,
                  hint: '9909 ••••',
                  prefixText: '🇲🇳 +976',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  suffix: const Icon(
                    Icons.contacts_outlined,
                    size: 20,
                    color: AppColors.sky500,
                  ),
                ),
                const SizedBox(height: 12),
                const FieldLabel('Өөрийн регистрийн дугаар'),
                AppTextField(
                  controller: _register,
                  hint: 'УХ12345678',
                  prefixText: 'РД',
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                    _UpperCaseFormatter(),
                  ],
                  suffix: const Icon(
                    Icons.badge_outlined,
                    size: 20,
                    color: AppColors.slate400,
                  ),
                ),
                const SizedBox(height: 12),
                const InfoNote(
                  tone: BadgeTone.slate,
                  icon: Icons.notifications_active_outlined,
                  text:
                      'Таны хүсэлт аав, ээжийн апп дээр очих бөгөөд зөвшөөрснөөр дансны эрх автоматаар нэмэгдэнэ.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Эцэг эх рүү хүсэлт илгээх 🚀',
            height: 56,
            onPressed: _valid ? _submit : null,
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => _goHome(linked: false),
            icon: const Icon(
              Icons.schedule_rounded,
              size: 16,
              color: AppColors.slate500,
            ),
            label: Text(
              'Дараа холбох (Хязгаарлагдмал эрхээр орох)',
              style: comfortaa(
                size: 12,
                weight: FontWeight.w600,
                color: AppColors.slate500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}

class _LimitCard extends StatelessWidget {
  const _LimitCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.muted,
    required this.stats,
    required this.footer,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget badge;
  final bool muted;
  final List<(String, String, BadgeTone?)> stats;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: muted ? AppColors.slate100.withValues(alpha: 0.8) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: muted
              ? AppColors.slate200.withValues(alpha: 0.7)
              : AppColors.emerald200.withValues(alpha: 0.8),
        ),
        boxShadow: muted
            ? null
            : [
                BoxShadow(
                  color: AppColors.emerald500.withValues(alpha: 0.18),
                  offset: const Offset(0, 8),
                  blurRadius: 24,
                  spreadRadius: -8,
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: muted ? AppColors.slate200 : AppColors.emerald100,
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: muted ? AppColors.slate500 : AppColors.emerald600,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: comfortaa(size: 13, weight: FontWeight.w700),
                    ),
                    Text(
                      subtitle,
                      style: comfortaa(
                        size: 11,
                        weight: muted ? FontWeight.w500 : FontWeight.w700,
                        color: muted
                            ? AppColors.slate500
                            : AppColors.emerald600,
                      ),
                    ),
                  ],
                ),
              ),
              badge,
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final (i, s) in stats.indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _StatBox(label: s.$1, value: s.$2, tone: s.$3),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          footer,
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value, this.tone});

  final String label;
  final String value;
  final BadgeTone? tone;

  @override
  Widget build(BuildContext context) {
    final colors = tone?.colors;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors?.$1 ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors?.$3 ?? AppColors.slate100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: comfortaa(
              size: 11,
              weight: FontWeight.w500,
              color: colors?.$2 ?? AppColors.slate500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: moneyStyle(
              size: 14,
              weight: FontWeight.w800,
              color: colors?.$2 ?? AppColors.slate800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.label,
    required this.asset,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String asset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.sky50 : AppColors.slate100;
    return Semantics(
      button: true,
      selected: selected,
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 46,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.sky500 : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MascotImage(
                asset: asset,
                size: 26,
                background: bg,
                semanticLabel: '',
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: comfortaa(
                    size: 12,
                    weight: FontWeight.w700,
                    color: selected ? AppColors.sky700 : AppColors.slate600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessSheet extends StatelessWidget {
  const _SuccessSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.emerald100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 30,
                color: AppColors.emerald600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Хүсэлт амжилттай илгээгдлээ! ✨',
              textAlign: TextAlign.center,
              style: comfortaa(size: 16, weight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Таны сонгосон асран хамгаалагч руу мэдэгдэл илгээгдлээ. Зөвшөөрсний дараа таны эрх шууд 5 дахин нэмэгдэх болно.',
              textAlign: TextAlign.center,
              style: comfortaa(
                size: 12,
                color: AppColors.slate500,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Ойлголоо',
              height: 50,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
