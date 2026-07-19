import 'package:flutter/material.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
//import '../widgets/auth_divider.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_logo.dart';
//import '../widgets/social_login_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirectIfAuthenticated();
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _redirectIfAuthenticated() async {
    if (!mounted || !AuthService.instance.isLoggedIn) return;

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
    }
  }

  Future<void> _login() async {
  final email = emailController.text.trim();
  final password = passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Completa todos los campos.',
        ),
      ),
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    await AuthService.instance.signIn(
      email: email,
      password: password,
    );

    if (!mounted) return;

    await AuthService.instance.reloadUser();

    if (!mounted) return;

    if (AuthService.instance.isEmailVerified) {
      context.go('/home');
    } else {
      context.go('/verify-email');
    }
  } on FirebaseAuthException catch (e) {
    String message = 'Ha ocurrido un error.';

    switch (e.code) {
      case 'invalid-email':
        message = 'El correo electrónico no es válido.';
        break;

      case 'user-not-found':
        message = 'No existe una cuenta con ese correo.';
        break;

      case 'wrong-password':
      case 'invalid-credential':
        message = 'Correo o contraseña incorrectos.';
        break;

      case 'too-many-requests':
        message = 'Demasiados intentos. Inténtalo más tarde.';
        break;

      case 'network-request-failed':
        message = 'Sin conexión a Internet.';
        break;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  } catch (e) {
    debugPrint('LOGIN ERROR: $e');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          e.toString(),
        ),
      ),
    );
  }

  if (mounted) {
    setState(() {
      _isLoading = false;
    });
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
                obscureText: _obscurePassword,
                icon: Icons.lock_outline,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    context.go('/forgot-password');// TODO: Navegar a Recuperar Contraseña
                  },
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                  ),
                ),
              ),

              const SizedBox(height: 8),

              PrimaryButton(
                text: 'Iniciar sesión',
                isLoading: _isLoading,
                onPressed: () async {
                  await _login();
                },
              ),

              //const SizedBox(height: 20),

              //const AuthDivider(),

              //const SizedBox(height: 20),

              //SocialLoginButton(
                //text: 'Continuar con Google',
                //icon: SvgPicture.asset(
                  //'assets/icons/social/google.svg',
                  //width: 22,
                  //height: 22,
                //),
                //onPressed: () {
                  // TODO: Inicio de sesión con Google
                //},
              //),

              //const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No tienes cuenta?'),
                  TextButton(
                    onPressed: () {
                      context.go('/register');// TODO: Navegar a Registro
                    },
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
