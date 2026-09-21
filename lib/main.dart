import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app/routes.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ArdKidsApp());
}

class ArdKidsApp extends StatefulWidget {
  const ArdKidsApp({super.key});

  @override
  State<ArdKidsApp> createState() => _ArdKidsAppState();
}

class _ArdKidsAppState extends State<ArdKidsApp> {
  late final GoRouter _router = AppRoutes.createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ard Kids Wallet',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: _router,
    );
  }
}
