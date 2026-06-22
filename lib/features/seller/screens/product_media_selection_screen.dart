import 'package:buymarket_frontend/features/categories/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/selected_media.dart';
import '../widgets/selected_media_list.dart';
import 'media_preview_screen.dart';
import 'product_basic_info_screen.dart';

class ProductMediaSelectionScreen extends StatefulWidget {
  final CategoryModel selectedCategory;

  const ProductMediaSelectionScreen({
    super.key,
    required this.selectedCategory,
  });

  @override
  State<ProductMediaSelectionScreen> createState() =>
      _ProductMediaSelectionScreenState();
}

class _ProductMediaSelectionScreenState
    extends State<ProductMediaSelectionScreen> {
  final _picker = ImagePicker();
  final List<SelectedMedia> _selectedMedia = [];

  Future<void> _pickImage() async {
    final images = await _picker.pickMultiImage(imageQuality: 80);
    if (images.isEmpty) return;

    setState(() {
      _selectedMedia.addAll(
        images.map((file) => SelectedMedia(file: file, type: 'image')),
      );
    });
  }

  Future<void> _pickVideo() async {
    final video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video == null) return;

    setState(() {
      _selectedMedia.add(SelectedMedia(file: video, type: 'video'));
    });
  }

  void _previewMedia(SelectedMedia media) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaPreviewScreen(media: media),
      ),
    );
  }

  void _continueToProductForm() {
    if (_selectedMedia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos una imagen o video')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductBasicInfoScreen(
          selectedCategory: widget.selectedCategory,
          selectedMedia: List.unmodifiable(_selectedMedia),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFBF5FF),
      appBar: AppBar(
        title: const Text(
          'Agregar imagenes y videos',
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 7, 1, 172)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _label('Categoria'),
          _readOnlyValue(widget.selectedCategory.name),
          const SizedBox(height: 18),
          _label('Archivos del producto'),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('Agregar imagen'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickVideo,
                  icon: const Icon(Icons.video_call_outlined),
                  label: const Text('Agregar video'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SelectedMediaList(
            media: _selectedMedia,
            onPreview: _previewMedia,
            onRemove: (media) {
              setState(() => _selectedMedia.remove(media));
            },
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color.fromARGB(60, 35, 229, 255),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color.fromARGB(255, 41, 200, 240),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/signo-de-exclamacion.png",
                    height: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Antes de continuar, hace click sobre cada archivo para revisar que sean los correctos.',
                      style: TextStyle(
                        color: Color(0xff6B4E16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _continueToProductForm,
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
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
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
          color: Color.fromARGB(255, 7, 1, 174),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
