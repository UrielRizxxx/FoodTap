import 'package:flutter/material.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({
    super.key,
    this.width = 180,
  });

  final double width;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/foodtap_logo.png',
      width: width,
      fit: BoxFit.contain,
    );
  }
}