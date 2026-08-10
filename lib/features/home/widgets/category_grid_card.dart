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
      return image.replaceFirst('http://localhost:3000', ApiConfig.baseUrl);
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
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: imageUrl == null
                    ? const Center(child: Icon(Icons.category, size: 50))
                    : SizedBox.expand(
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.category, size: 50),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
