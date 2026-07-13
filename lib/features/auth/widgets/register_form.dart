import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  //final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

    Future<void> _register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos.'),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden.'),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La contraseña debe tener al menos 6 caracteres.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.instance.register(
        name: name,
        email: email,
        password: password,
      );

      debugPrint('REGISTRO TERMINADO');

      if (!mounted) {
        debugPrint('NO MOUNTED');
        return;
      }

      debugPrint('ANTES DE NAVEGAR');

      context.go('/verify-email');

      debugPrint('DESPUES DE NAVEGAR');

    } on FirebaseAuthException catch (e) {
      String message = 'Ha ocurrido un error.';

      switch (e.code) {
        case 'email-already-in-use':
          message = 'Este correo ya está registrado.';
          break;

        case 'invalid-email':
          message = 'Correo electrónico inválido.';
          break;

        case 'weak-password':
          message = 'La contraseña es demasiado débil.';
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
    return Column(
      children: [
        CustomTextField(
          controller: nameController,
          label: 'Nombre completo',
          icon: Icons.person_outline,
        ),

        const SizedBox(height: 14),

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

        const SizedBox(height: 14),

        CustomTextField(
          controller: confirmPasswordController,
          label: 'Confirmar contraseña',
          obscureText: _obscureConfirmPassword,
          icon: Icons.lock_outline,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _obscureConfirmPassword =
                    !_obscureConfirmPassword;
              });
            },
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          ),
        ),

        const SizedBox(height: 24),

        PrimaryButton(
          text: 'Crear cuenta',
          isLoading: _isLoading,
          onPressed: () async {
            await _register();
          },
        ),

        const SizedBox(height: 20),

                Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '¿Ya tienes cuenta?',
            ),
            TextButton(
              onPressed: () {
                context.go('/login');
              },
              child: const Text(
                'Iniciar sesión',
              ),
            ),
          ],
        ),
      ],
    );
  }
}