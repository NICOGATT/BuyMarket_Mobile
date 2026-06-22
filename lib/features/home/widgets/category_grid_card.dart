// import 'dart:ui';

import 'package:buymarket_frontend/core/config/api.config.dart';
import 'package:buymarket_frontend/features/categories/models/category_model.dart';
import 'package:flutter/material.dart';

class CategoryGridCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const CategoryGridCard({
    super.key,
    required this.category,
    required this.onTap,
  });
  String? getCategoryImageUrl() {
    final image = category.banner ?? category.icon;

    if (image == null || image.isEmpty) return null;

    if (image.startsWith('http://localhost:3000')) {
      return image.replaceFirst(
        'http://localhost:3000',
        ApiConfig.baseUrl,
      );
    }

    if (image.startsWith('http')) {
      return image;
    }

    return '${ApiConfig.baseUrl}$image';
  }
  @override
  Widget build(BuildContext context) {
    final imageUrl = getCategoryImageUrl();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 120,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: imageUrl == null
                    ? const Icon(Icons.category, size: 50)
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Text(
                category.name,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}