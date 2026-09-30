import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/onboarding_store.dart';
import '../../../../app/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/adaptive.dart';
import '../../../../widgets/app_text.dart';
import '../../../../widgets/ui.dart';
import '../../data/welcome_slide.dart';
import '../widgets/welcome_slide_page.dart';

/// Optional, swipeable introduction. Remembered only on completion or skip.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _pages = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _continue({required bool register}) {
    unawaited(OnboardingStore.complete());
    context.go(register ? AppRoutes.register : AppRoutes.auth);
  }

  void _showPage(int index) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _pages.jumpToPage(index);
    } else {
      _pages.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == welcomeSlides.length - 1;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 16, 0),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/ard_logo.png',
                    height: 28,
                    fit: BoxFit.contain,
                    color: AppColors.slate900,
                    semanticLabel: 'Ard',
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _continue(register: true),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(88, 48),
                    ),
                    child: AppText(
                      'Алгасах',
                      size: 15,
                      weight: FontWeight.w600,
                      color: AppColors.slate600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pages,
                itemCount: welcomeSlides.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) =>
                    WelcomeSlidePage(slide: welcomeSlides[index]),
              ),
            ),
            AdaptiveCenter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < welcomeSlides.length; i++)
                          Semantics(
                            label: '${welcomeSlides.length} хуудасны ${i + 1}',
                            selected: _page == i,
                            button: true,
                            child: InkResponse(
                              onTap: () => _showPage(i),
                              radius: 22,
                              child: SizedBox(
                                width: 44,
                                height: 44,
                                child: Center(
                                  child: AnimatedContainer(
                                    duration: Duration(
                                      milliseconds:
                                          MediaQuery.disableAnimationsOf(
                                            context,
                                          )
                                          ? 0
                                          : 200,
                                    ),
                                    width: _page == i ? 24 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _page == i
                                          ? AppColors.sky500
                                          : AppColors.slate300,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    PrimaryButton(
                      label: last ? 'Эхлэх' : 'Дараах',
                      height: 56,
                      onPressed: () => last
                          ? _continue(register: true)
                          : _showPage(_page + 1),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () => _continue(register: false),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: AppText(
                        'Нэвтрэх',
                        size: 15,
                        weight: FontWeight.w600,
                        color: AppColors.sky700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
