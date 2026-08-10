import 'package:buymarket_frontend/features/categories/models/category_model.dart';
import 'package:flutter/material.dart';

import '../models/sub_category.dart';
import '../services/sub_category_service.dart';
import 'product_media_selection_screen.dart';

class SubCategorySelectionScreen extends StatefulWidget {
  final CategoryModel selectedCategory;

  const SubCategorySelectionScreen({
    super.key,
    required this.selectedCategory,
  });

  @override
  State<SubCategorySelectionScreen> createState() =>
      _SubCategorySelectionScreenState();
}

class _SubCategorySelectionScreenState
    extends State<SubCategorySelectionScreen> {
  final _subCategoryService = SubCategoryService();

  List<SubCategory> _subCategories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSubCategories();
  }

  Future<void> _loadSubCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _subCategoryService.getByCategory(
        widget.selectedCategory.id,
      );
      if (!mounted) return;
      setState(() {
        _subCategories = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _continueWith(SubCategory subCategory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductMediaSelectionScreen(
          selectedCategory: widget.selectedCategory,
          selectedSubCategory: subCategory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Seleccionar subcategoria',
          style: TextStyle(
            color: Color(0xff2D006B),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xff2D006B)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _loadSubCategories,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_subCategories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xff5E2CA5),
                size: 34,
              ),
              const SizedBox(height: 12),
              const Text(
                'No hay subcategorias disponibles para esta categoria',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _loadSubCategories,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final subCategory = _subCategories[index];
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _continueWith(subCategory),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      subCategory.name.isEmpty ? 'Sin nombre' : subCategory.name,
                      style: const TextStyle(
                        color: Color(0xff2D006B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemCount: _subCategories.length,
    );
  }
}
