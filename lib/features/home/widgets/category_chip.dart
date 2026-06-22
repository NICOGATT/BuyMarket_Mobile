import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(title),
      onPressed: onTap,
      backgroundColor: isSelected
          ? const Color(0xff5E2CA5)
          : Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
