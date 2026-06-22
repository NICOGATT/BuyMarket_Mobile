import 'package:buymarket_frontend/core/routes/app_routes.dart';
import 'package:buymarket_frontend/features/categories/models/category_model.dart';
import 'package:flutter/material.dart';

import '../../auth/services/auth_services_instance.dart';
import '../../home/services/product_service_instance.dart';
import '../models/product_basic_info.dart';
import '../models/selected_media.dart';
import '../models/sub_category.dart';
import '../models/sub_category_attribute.dart';
import '../services/product_media_service.dart';
import '../services/sub_category_attribute_service.dart';
import '../services/sub_category_service.dart';
import '../widgets/dynamic_attribute_fields.dart';
import '../widgets/selected_media_list.dart';
import 'media_preview_screen.dart';

class AddProductScreen extends StatefulWidget {
  final CategoryModel selectedCategory;
  final List<SelectedMedia> initialMedia;
  final ProductBasicInfo basicInfo;

  const AddProductScreen({
    super.key,
    required this.selectedCategory,
    required this.initialMedia,
    required this.basicInfo,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subCategoryService = SubCategoryService();
  final _attributeService = SubCategoryAttributeService();
  final _productMediaService = ProductMediaService();

  List<SelectedMedia> selectedMedia = [];
  List<SubCategory> _subCategories = [];
  List<SubCategoryAttribute> _dynamicAttributes = [];
  Map<String, dynamic> attributes = {};

  SubCategory? _selectedSubCategory;
  bool _isLoadingSubCategories = true;
  bool _isLoadingAttributes = false;
  bool _isPublishing = false;
  String? _subCategoryError;
  String? _attributeError;

  @override
  void initState() {
    super.initState();
    selectedMedia = List.of(widget.initialMedia);
    _loadSubCategories();
  }

  Future<void> _loadSubCategories() async {
    setState(() {
      _isLoadingSubCategories = true;
      _subCategoryError = null;
    });

    try {
      final result = await _subCategoryService.getByCategory(
        widget.selectedCategory.id,
      );
      if (!mounted) return;
      setState(() {
        _subCategories = result;
        _isLoadingSubCategories = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _subCategoryError = e.toString();
        _isLoadingSubCategories = false;
      });
    }
  }

  Future<void> _loadAttributes(SubCategory subCategory) async {
    setState(() {
      _selectedSubCategory = subCategory;
      _dynamicAttributes = [];
      attributes = {};
      _isLoadingAttributes = true;
      _attributeError = null;
    });

    try {
      final result = await _attributeService.getBySubCategory(subCategory.id);
      if (!mounted) return;
      setState(() {
        _dynamicAttributes = result;
        attributes = {
          for (final attribute in result)
            if (attribute.type == 'boolean') attribute.id: false,
        };
        _isLoadingAttributes = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _attributeError = e.toString();
        _isLoadingAttributes = false;
      });
    }
  }

  void _previewMedia(SelectedMedia media) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaPreviewScreen(media: media),
      ),
    );
  }

  void _setAttributeValue(
    SubCategoryAttribute attribute,
    dynamic value,
  ) {
    setState(() {
      attributes[attribute.id] = value;
    });
  }

  Future<void> _publishProduct() async {
    final token = authServices.token;
    final user = authServices.user;

    if (token == null || user == null) {
      _showSnackBar('Usuario no autenticado');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_selectedSubCategory == null) {
      _showSnackBar('Selecciona una subcategoria');
      return;
    }

    if (selectedMedia.isEmpty) {
      _showSnackBar('Agrega al menos una imagen o video');
      return;
    }

    setState(() => _isPublishing = true);

    try {
      final mediaIds = <String>[];
      for (var index = 0; index < selectedMedia.length; index++) {
        final media = selectedMedia[index];
        final uploadedIds = await _productMediaService.upload(
          media: media,
          token: token,
          order: index,
        );
        mediaIds.addAll(uploadedIds);
      }

      final product = await productService.createProduct(
        title: widget.basicInfo.title,
        description: widget.basicInfo.description,
        price: widget.basicInfo.price,
        stock: widget.basicInfo.stock,
        subCategoryId: _selectedSubCategory!.id,
        attributes: _buildAttributesPayload(),
        mediaIds: mediaIds,
        token: token,
        seller: user.id,
      );

      await productService.loadProducts();

      if (!mounted) return;
      _showSnackBar('Producto publicado correctamente');
      Navigator.pushNamed(context, AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
      }
    }
  }

  List<Map<String, dynamic>> _buildAttributesPayload() {
    return _dynamicAttributes
        .where((attribute) => _hasAttributeValue(attributes[attribute.id]))
        .map((attribute) {
      return {
        'attributeId': attribute.id,
        'value': attributes[attribute.id].toString(),
      };
    }).toList();
  }

  bool _hasAttributeValue(dynamic value) {
    if (value == null) return false;
    if (value is bool) return true;
    return value.toString().trim().isNotEmpty;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFBF5FF),
      appBar: AppBar(
        title: const Text(
          'Publicar producto',
          style: TextStyle(
            color: Color(0xff2D006B),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xff2D006B)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Categoria'),
              _readOnlyValue(widget.selectedCategory.name),
              const SizedBox(height: 18),
              _label('Imagenes y videos cargados'),
              SelectedMediaList(
                media: selectedMedia,
                onPreview: _previewMedia,
              ),
              const SizedBox(height: 22),
              _label('Datos del producto'),
              _productInfoSummary(),
              const SizedBox(height: 22),
              _label('Subcategoria'),
              _buildSubCategoryField(),
              const SizedBox(height: 22),
              _buildDynamicAttributesSection(),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _isPublishing ? null : _publishProduct,
                  icon: _isPublishing
                      ? const SizedBox.shrink()
                      : const Icon(Icons.publish_outlined),
                  label: _isPublishing
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Publicar producto',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff168BEE),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubCategoryField() {
    if (_isLoadingSubCategories) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_subCategoryError != null) {
      return _errorBox(_subCategoryError!, onRetry: _loadSubCategories);
    }

    if (_subCategories.isEmpty) {
      return _emptyBox(
        'No hay subcategorias disponibles para esta categoria',
        onRetry: _loadSubCategories,
      );
    }

    return DropdownButtonFormField<SubCategory>(
      initialValue: _selectedSubCategory,
      isExpanded: true,
      hint: const Text('Selecciona una subcategoria'),
      decoration: _decoration(
        label: 'Subcategoria',
        icon: Icons.category_outlined,
      ),
      items: _subCategories
          .map(
            (subCategory) => DropdownMenuItem(
              value: subCategory,
              child: Text(
                subCategory.name.isEmpty ? 'Sin nombre' : subCategory.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      validator: (value) => value == null ? 'Selecciona una subcategoria' : null,
      onChanged: _isPublishing
          ? null
          : (value) {
              if (value != null) {
                _loadAttributes(value);
              }
            },
    );
  }

  Widget _productInfoSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.basicInfo.title,
            style: const TextStyle(
              color: Color(0xff2D006B),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(widget.basicInfo.description),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _summaryChip(Icons.attach_money, widget.basicInfo.price),
              _summaryChip(
                Icons.inventory_2_outlined,
                'Stock: ${widget.basicInfo.stock}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xffF6F7FB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: const Color(0xff168BEE)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _emptyBox(String message, {required VoidCallback onRetry}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xff5E2CA5),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
          TextButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicAttributesSection() {
    if (_selectedSubCategory == null) {
      return const SizedBox.shrink();
    }

    if (_isLoadingAttributes) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_attributeError != null) {
      return _errorBox(
        _attributeError!,
        onRetry: () => _loadAttributes(_selectedSubCategory!),
      );
    }

    if (_dynamicAttributes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Caracteristicas'),
        DynamicAttributeFields(
          attributes: _dynamicAttributes,
          values: attributes,
          onChanged: _setAttributeValue,
        ),
      ],
    );
  }

  Widget _errorBox(String message, {required VoidCallback onRetry}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _readOnlyValue(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xff5E2CA5),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  InputDecoration _decoration({
    required String label,
    String? hintText,
    IconData? icon,
  }) {
    return InputDecoration(
      prefixIcon: icon == null ? null : Icon(icon),
      labelText: label,
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.withValues(alpha: 0.3),
        ),
      ),
    );
  }

}
