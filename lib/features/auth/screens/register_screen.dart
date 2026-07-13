import 'package:flutter/material.dart';

import '../widgets/auth_header.dart';
import '../widgets/auth_logo.dart';
import '../widgets/register_form.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
            children: const [
              SizedBox(height: 4),

              Center(
                child: AuthLogo(
                  width: 260,
                ),
              ),

              SizedBox(height: 8),

              AuthHeader(
                title: 'Crear cuenta',
                subtitle: 'Regístrate para comenzar',
              ),

              SizedBox(height: 24),

              RegisterForm(),
            ],
          ),
        ),
      ),
    );
  }
}