import 'package:flutter/material.dart';

import '../../categories/models/category_model.dart';
import '../../categories/services/category_service_instace.dart';
import 'category_chip.dart';

class CategoryNavigationBar extends StatelessWidget {
  final String? selectedCategoryId;
  final bool showHome;
  final VoidCallback? onHomeTap;
  final ValueChanged<CategoryModel> onCategoryTap;
  final VoidCallback onViewMoreTap;

  const CategoryNavigationBar({
    super.key,
    this.selectedCategoryId,
    this.showHome = false,
    this.onHomeTap,
    required this.onCategoryTap,
    required this.onViewMoreTap,
  });

  static const _categoryLabels = [
    'TECNO',
    'MASCOTAS',
    'COMPUTACIÓN',
    'INDUMENTARIA',
    'BELLEZA',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff2D006B),
      height: 52,
      child: AnimatedBuilder(
        animation: categoryService,
        builder: (context, _) {
          final categories = _visibleCategories;

          if (categoryService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categories.length + (showHome ? 2 : 1),
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              if (showHome && index == 0) {
                return CategoryChip(
                  title: 'INICIO',
                  isSelected: false,
                  onTap: onHomeTap ?? () {},
                );
              }

              final categoryIndex = index - (showHome ? 1 : 0);
              if (categoryIndex == categories.length) {
                return CategoryChip(
                  title: 'VER MÁS',
                  isSelected: false,
                  onTap: onViewMoreTap,
                );
              }

              final item = categories[categoryIndex];
              return CategoryChip(
                title: item.label,
                isSelected: selectedCategoryId == item.category.id,
                onTap: () => onCategoryTap(item.category),
              );
            },
          );
        },
      ),
    );
  }

  List<({CategoryModel category, String label})> get _visibleCategories {
    final availableCategories = categoryService.categories;

    return _categoryLabels
        .map((label) {
          for (final category in availableCategories) {
            if (_matchesCategory(category.name, label)) {
              return (category: category, label: label);
            }
          }
          return null;
        })
        .whereType<({CategoryModel category, String label})>()
        .toList();
  }

  bool _matchesCategory(String categoryName, String label) {
    final normalizedName = _normalizeCategoryName(categoryName);
    final normalizedLabel = _normalizeCategoryName(label);

    if (normalizedLabel == 'tecno') {
      return normalizedName == 'tecno' || normalizedName == 'tecnologia';
    }

    return normalizedName == normalizedLabel;
  }

  String _normalizeCategoryName(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u');
  }
}
