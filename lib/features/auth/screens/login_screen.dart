import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_logo.dart';
import '../widgets/social_login_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            26,
            4,
            26,
            20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 4),

              const Center(
                child: AuthLogo(
                  width: 260,
                ),
              ),

              const SizedBox(height: 8),

              const AuthHeader(
                title: 'Bienvenido',
                subtitle: 'Inicia sesión para continuar',
              ),

              const SizedBox(height: 20),

              CustomTextField(
                controller: emailController,
                label: 'Correo electrónico',
                keyboardType: TextInputType.emailAddress,
                icon: Icons.email_outlined,
              ),

              const SizedBox(height: 14),

              CustomTextField(
                controller: passwordController,
                label: 'Contraseña',
                obscureText: true,
                icon: Icons.lock_outline,
              ),

              const SizedBox(height: 6),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                  ),
                ),
              ),

              const SizedBox(height: 8),

              PrimaryButton(
                text: 'Iniciar sesión',
                onPressed: () {},
              ),

              const SizedBox(height: 20),

              const AuthDivider(),

              const SizedBox(height: 20),

              SocialLoginButton(
                text: 'Continuar con Google',
                icon: SvgPicture.asset(
                  'assets/icons/social/google.svg',
                  width: 22,
                  height: 22,
                ),
                onPressed: () {},
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No tienes cuenta?'),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Crear cuenta'),
                  ),
                ],
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}