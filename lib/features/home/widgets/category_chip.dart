import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(title),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}