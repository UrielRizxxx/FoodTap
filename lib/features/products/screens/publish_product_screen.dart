import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../widgets/publish_product_form.dart';

class PublishProductScreen extends StatelessWidget {
  const PublishProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Publicar producto',
        ),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: PublishProductForm(),
        ),
      ),
    );
  }
}