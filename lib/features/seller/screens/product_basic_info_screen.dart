import 'package:buymarket_frontend/features/categories/models/category_model.dart';
import 'package:flutter/material.dart';

import '../models/product_basic_info.dart';
import '../models/selected_media.dart';
import '../models/sub_category.dart';
import '../widgets/selected_media_list.dart';
import 'add_product_screen.dart';
import 'media_preview_screen.dart';

class ProductBasicInfoScreen extends StatefulWidget {
  final CategoryModel selectedCategory;
  final SubCategory selectedSubCategory;
  final List<SelectedMedia> selectedMedia;

  const ProductBasicInfoScreen({
    super.key,
    required this.selectedCategory,
    required this.selectedSubCategory,
    required this.selectedMedia,
  });

  @override
  State<ProductBasicInfoScreen> createState() => _ProductBasicInfoScreenState();
}

class _ProductBasicInfoScreenState extends State<ProductBasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _brandController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  void _previewMedia(SelectedMedia media) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MediaPreviewScreen(media: media)),
    );
  }

  void _continueToAttributes() {
    if (!_formKey.currentState!.validate()) return;

    final basicInfo = ProductBasicInfo(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      brand: _brandController.text.trim(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(
          selectedCategory: widget.selectedCategory,
          selectedSubCategory: widget.selectedSubCategory,
          initialMedia: widget.selectedMedia,
          basicInfo: basicInfo,
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
          'Datos del producto',
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _label('Categoria'),
            _readOnlyValue(widget.selectedCategory.name),
            const SizedBox(height: 18),
            _label('Subcategoria'),
            _readOnlyValue(widget.selectedSubCategory.name),
            const SizedBox(height: 18),
            _label('Imagenes y videos cargados'),
            SelectedMediaList(
              media: widget.selectedMedia,
              onPreview: _previewMedia,
            ),
            const SizedBox(height: 22),
            _label('Informacion basica'),
            _input(
              controller: _titleController,
              label: 'Titulo',
              hintText: 'Ej: Zapatillas urbanas',
              icon: Icons.title,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 14),
            _input(
              controller: _descriptionController,
              label: 'Descripcion',
              hintText: 'Conta detalles del producto',
              icon: Icons.description_outlined,
              maxLines: 3,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 14),
            _input(
              controller: _brandController,
              label: 'Marca (opcional)',
              hintText: 'Ej: RPM',
              icon: Icons.sell_outlined,
              validator: (_) => null,
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _continueToAttributes,
                icon: const Icon(Icons.arrow_forward),
                label: const Text(
                  'Continuar',
                  style: TextStyle(fontWeight: FontWeight.bold),
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
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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

  Widget _input({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo requerido';
    }
    return null;
  }
}
