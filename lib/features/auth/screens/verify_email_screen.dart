import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/widgets/primary_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_logo.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isLoading = false;

  Future<void> _checkVerification() async {
    setState(() {
      _isLoading = true;
    });

    await AuthService.instance.reloadUser();

    if (!mounted) return;

    if (AuthService.instance.isEmailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '¡Correo verificado correctamente!',
          ),
        ),
      );

      context.go('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tu correo aún no ha sido verificado.',
          ),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _resendEmail() async {
    try {
      await AuthService.instance.sendEmailVerification();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Se envió nuevamente el correo de verificación.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No fue posible reenviar el correo.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            26,
            20,
            26,
            20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: AuthLogo(
                  width: 220,
                ),
              ),

              const SizedBox(height: 20),

              const AuthHeader(
                title: 'Verifica tu correo',
                subtitle:
                    'Te hemos enviado un enlace de verificación a tu correo electrónico.',
              ),

              const SizedBox(height: 40),

              const Icon(
                Icons.mark_email_read_outlined,
                size: 100,
                color: Colors.green,
              ),

              const SizedBox(height: 30),

              PrimaryButton(
                text: 'Ya verifiqué mi cuenta',
                isLoading: _isLoading,
                onPressed: () async {
                  await _checkVerification();
                },
              ),

              const SizedBox(height: 16),

              OutlinedButton(
                onPressed: _resendEmail,
                child: const Text(
                  'Reenviar correo',
                ),
              ),

              const SizedBox(height: 24),

              TextButton(
                onPressed: () {
                  context.go('/login');
                },
                child: const Text(
                  'Volver al inicio de sesión',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}