import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    if (!AuthService.instance.isLoggedIn) {
      context.go('/login');
      return;
    }

    try {
      await AuthService.instance.reloadUser();

      if (!mounted) return;

      if (AuthService.instance.isEmailVerified) {
        context.go('/home');
      } else {
        context.go('/verify-email');
      }
    } catch (_) {
      await AuthService.instance.signOut();

      if (!mounted) return;

      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Image.asset(
          'assets/icons/foodtap_logo.png',
          width: 260,
        ),
      ),
    );
  }
}