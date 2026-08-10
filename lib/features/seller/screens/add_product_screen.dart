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
import '../services/brand_service.dart';
import '../services/sub_category_attribute_service.dart';
import '../widgets/dynamic_attribute_fields.dart';
import '../widgets/selected_media_list.dart';
import 'media_preview_screen.dart';
import 'seller_auth_required_screen.dart';

class AddProductScreen extends StatefulWidget {
  final CategoryModel selectedCategory;
  final SubCategory selectedSubCategory;
  final List<SelectedMedia> initialMedia;
  final ProductBasicInfo basicInfo;

  const AddProductScreen({
    super.key,
    required this.selectedCategory,
    required this.selectedSubCategory,
    required this.initialMedia,
    required this.basicInfo,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _attributeService = SubCategoryAttributeService();
  final _productMediaService = ProductMediaService();
  final _brandService = BrandService();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  List<SelectedMedia> selectedMedia = [];
  List<SubCategoryAttribute> _dynamicAttributes = [];
  final List<_VariantDraft> _variants = [];
  Map<String, dynamic> attributes = {};

  late SubCategory _selectedSubCategory;
  bool _isLoadingAttributes = false;
  bool _isPublishing = false;
  String? _attributeError;

  @override
  void initState() {
    super.initState();
    selectedMedia = List.of(widget.initialMedia);
    _selectedSubCategory = widget.selectedSubCategory;
    _loadAttributes(widget.selectedSubCategory);
  }

  @override
  void dispose() {
    _priceController.dispose();
    _stockController.dispose();
    for (final variant in _variants) {
      variant.dispose();
    }
    super.dispose();
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
          for (final attribute in result.where(
            (item) => item.isProductAttribute,
          ))
            if (attribute.type == 'boolean') attribute.id: false,
        };
        _resetVariants();
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

  void _resetVariants() {
    for (final variant in _variants) {
      variant.dispose();
    }
    _variants.clear();

    if (_sizeAttribute != null) {
      _variants.add(_newVariantDraft());
    }
  }

  _VariantDraft _newVariantDraft() {
    return _VariantDraft(variantAttributes: _variantAttributes);
  }

  void _previewMedia(SelectedMedia media) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MediaPreviewScreen(media: media)),
    );
  }

  void _setAttributeValue(SubCategoryAttribute attribute, dynamic value) {
    setState(() {
      attributes[attribute.id] = value;
    });
  }

  Future<void> _publishProduct() async {
    final token = authServices.token;
    final user = authServices.user;

    if (token == null || user == null) {
      await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const SellerAuthRequiredScreen()),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_selectedSubCategory.id.trim().isEmpty) {
      _showSnackBar('Seleccioná una subcategoría para publicar');
      return;
    }

    if (_variants.isNotEmpty && !_variants.any((variant) => variant.isActive)) {
      _showSnackBar('El producto debe tener al menos una variante activa');
      return;
    }

    if (selectedMedia.isEmpty) {
      _showSnackBar('Agrega al menos una imagen o video');
      return;
    }

    setState(() => _isPublishing = true);

    try {
      final brandId = await _brandService.resolveBrandId(
        widget.basicInfo.brand,
        token,
      );
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

      await productService.createProduct(
        title: widget.basicInfo.title,
        description: widget.basicInfo.description,
        price: _variants.isEmpty ? _priceController.text.trim() : null,
        stock: _variants.isEmpty
            ? int.parse(_stockController.text.trim())
            : null,
        subCategoryId: _selectedSubCategory.id,
        brandId: brandId,
        attributes: _buildAttributesPayload(),
        variants: _buildVariantsPayload(),
        mediaIds: mediaIds,
        token: token,
        seller: user.id,
      );

      await productService.loadProducts();

      if (!mounted) return;
      _showSnackBar('Producto publicado correctamente.');
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
    return _productAttributes
        .where((attribute) => _hasAttributeValue(attributes[attribute.id]))
        .map((attribute) {
          return {
            'attributeId': attribute.id,
            'value': _attributeValueToString(attributes[attribute.id]),
          };
        })
        .toList();
  }

  bool _hasAttributeValue(dynamic value) {
    if (value == null) return false;
    if (value is bool) return true;
    return value.toString().trim().isNotEmpty;
  }

  String _attributeValueToString(dynamic value) {
    if (value is bool) return value ? 'true' : 'false';
    return value?.toString() ?? '';
  }

  List<Map<String, dynamic>> _buildVariantsPayload() {
    return _variants
        .where((variant) => variant.hasAnyValue)
        .map(
          (variant) => {
            'size': variant.size ?? '',
            if (variant.color?.isNotEmpty == true) 'color': variant.color,
            'price': double.parse(variant.priceController.text.trim()),
            'stock': int.parse(variant.stockController.text.trim()),
            'isActive': variant.isActive,
            'attributes': _variantAttributes
                .where(
                  (attribute) =>
                      _hasAttributeValue(variant.attributeValues[attribute.id]),
                )
                .map(
                  (attribute) => {
                    'attributeId': attribute.id,
                    'value': _attributeValueToString(
                      variant.attributeValues[attribute.id],
                    ),
                  },
                )
                .toList(),
          },
        )
        .toList();
  }

  SubCategoryAttribute? get _sizeAttribute {
    for (final attribute in _dynamicAttributes) {
      if (attribute.isVariantSize) return attribute;
    }

    return null;
  }

  SubCategoryAttribute? get _colorAttribute {
    for (final attribute in _dynamicAttributes) {
      if (attribute.isVariantColor) return attribute;
    }

    return null;
  }

  List<SubCategoryAttribute> get _productAttributes {
    return _dynamicAttributes.where((attribute) {
      final normalizedName = attribute.name.trim().toLowerCase();
      final isBrandAttribute =
          normalizedName == 'marca' || normalizedName == 'brand';
      return attribute.isProductAttribute && !isBrandAttribute;
    }).toList();
  }

  List<SubCategoryAttribute> get _variantAttributes {
    return _dynamicAttributes.where((attribute) {
      return attribute.isVariantAttribute;
    }).toList();
  }

  void _addVariant() {
    setState(() {
      _variants.add(_newVariantDraft());
    });
  }

  void _removeVariant(int index) {
    setState(() {
      _variants.removeAt(index).dispose();
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
              SelectedMediaList(media: selectedMedia, onPreview: _previewMedia),
              const SizedBox(height: 22),
              _label('Datos del producto'),
              _productInfoSummary(),
              const SizedBox(height: 22),
              _label('Subcategoria'),
              _readOnlyValue(_selectedSubCategory.name),
              const SizedBox(height: 22),
              _buildDynamicAttributesSection(),
              _buildPricingSection(),
              _buildVariantsSection(),
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
          if (widget.basicInfo.brand.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Marca: ${widget.basicInfo.brand}'),
          ],
        ],
      ),
    );
  }

  Widget _buildDynamicAttributesSection() {
    if (_isLoadingAttributes) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_attributeError != null) {
      return _errorBox(
        _attributeError!,
        onRetry: () => _loadAttributes(_selectedSubCategory),
      );
    }

    final productAttributes = _productAttributes;

    if (productAttributes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Caracteristicas del producto'),
        DynamicAttributeFields(
          attributes: productAttributes,
          values: attributes,
          onChanged: _setAttributeValue,
        ),
      ],
    );
  }

  Widget _buildVariantsSection() {
    final sizeAttribute = _sizeAttribute;
    if (sizeAttribute == null) {
      return const SizedBox.shrink();
    }

    final colorAttribute = _colorAttribute;
    final variantAttributes = _variantAttributes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _label('Variantes'),
        ..._variants.asMap().entries.map((entry) {
          return _VariantFields(
            key: ValueKey(entry.value),
            index: entry.key,
            variant: entry.value,
            sizeAttribute: sizeAttribute,
            colorAttribute: colorAttribute,
            variantAttributes: variantAttributes,
            canRemove: _variants.length > 1,
            onRemove: () => _removeVariant(entry.key),
            onChanged: () => setState(() {}),
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _isPublishing ? null : _addVariant,
            icon: const Icon(Icons.add),
            label: const Text('Agregar variante'),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    if (_isLoadingAttributes || _attributeError != null) {
      return const SizedBox.shrink();
    }

    if (_variants.isNotEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 18, bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xffEAF5FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'El precio y el stock del producto se calculan automáticamente '
          'desde las variantes activas.',
          style: TextStyle(
            color: Color(0xff145A8D),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        _label('Precio y stock'),
        TextFormField(
          controller: _priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _baseFieldDecoration('Precio', Icons.attach_money),
          validator: (value) {
            final price = double.tryParse(value?.trim() ?? '');
            if (price == null || price <= 0) {
              return 'Ingresa un precio mayor a cero';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _stockController,
          keyboardType: TextInputType.number,
          decoration: _baseFieldDecoration('Stock', Icons.inventory_2_outlined),
          validator: (value) {
            final stock = int.tryParse(value?.trim() ?? '');
            if (stock == null || stock < 0) {
              return 'Ingresa un stock válido';
            }
            return null;
          },
        ),
      ],
    );
  }

  InputDecoration _baseFieldDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _VariantDraft {
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final Map<String, dynamic> attributeValues;

  String? size;
  String? color;
  bool isActive = true;

  _VariantDraft({required List<SubCategoryAttribute> variantAttributes})
    : attributeValues = {
        for (final attribute in variantAttributes)
          if (attribute.type == 'boolean') attribute.id: false,
      };

  bool get hasAnyValue {
    return size?.isNotEmpty == true ||
        color?.isNotEmpty == true ||
        priceController.text.trim().isNotEmpty ||
        stockController.text.trim().isNotEmpty ||
        attributeValues.values.any((value) {
          if (value == null) return false;
          if (value is bool) return value;
          return value.toString().trim().isNotEmpty;
        });
  }

  void dispose() {
    sizeController.dispose();
    colorController.dispose();
    priceController.dispose();
    stockController.dispose();
  }
}

class _VariantFields extends StatelessWidget {
  final int index;
  final _VariantDraft variant;
  final SubCategoryAttribute sizeAttribute;
  final SubCategoryAttribute? colorAttribute;
  final List<SubCategoryAttribute> variantAttributes;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _VariantFields({
    super.key,
    required this.index,
    required this.variant,
    required this.sizeAttribute,
    required this.colorAttribute,
    required this.variantAttributes,
    required this.canRemove,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Variante ${index + 1}',
                  style: const TextStyle(
                    color: Color(0xff2D006B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (canRemove)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          const SizedBox(height: 10),
          _VariantValueField(
            attribute: sizeAttribute,
            value: variant.size,
            controller: variant.sizeController,
            fallbackLabel: 'Talle',
            isRequired: true,
            requiredMessage: 'Selecciona un talle',
            onChanged: (value) {
              variant.size = value;
              onChanged();
            },
          ),
          if (colorAttribute != null) ...[
            const SizedBox(height: 12),
            _VariantValueField(
              attribute: colorAttribute!,
              value: variant.color,
              controller: variant.colorController,
              fallbackLabel: 'Color',
              isRequired: colorAttribute!.isRequired,
              requiredMessage: 'Selecciona un color',
              onChanged: (value) {
                variant.color = value;
                onChanged();
              },
            ),
          ],
          const SizedBox(height: 12),
          TextFormField(
            controller: variant.priceController,
            keyboardType: TextInputType.number,
            decoration: _decoration('Precio'),
            validator: (value) {
              final price = double.tryParse(value?.trim() ?? '');
              if (price == null || price <= 0) {
                return 'Ingresa un precio mayor a cero';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: variant.stockController,
            keyboardType: TextInputType.number,
            decoration: _decoration('Stock'),
            validator: (value) {
              final stock = int.tryParse(value?.trim() ?? '');
              if (stock == null || stock < 0) {
                return 'Ingresa un stock válido';
              }
              return null;
            },
          ),
          if (variantAttributes.isNotEmpty) ...[
            const SizedBox(height: 12),
            DynamicAttributeFields(
              attributes: variantAttributes,
              values: variant.attributeValues,
              onChanged: (attribute, value) {
                variant.attributeValues[attribute.id] = value;
                onChanged();
              },
            ),
          ],
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Activa'),
            value: variant.isActive,
            onChanged: (value) {
              variant.isActive = value;
              onChanged();
            },
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
      ),
    );
  }
}

class _VariantValueField extends StatelessWidget {
  final SubCategoryAttribute attribute;
  final String? value;
  final TextEditingController controller;
  final String fallbackLabel;
  final bool isRequired;
  final String requiredMessage;
  final ValueChanged<String?> onChanged;

  const _VariantValueField({
    required this.attribute,
    required this.value,
    required this.controller,
    required this.fallbackLabel,
    required this.isRequired,
    required this.requiredMessage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final label = attribute.name.isEmpty ? fallbackLabel : attribute.name;

    if (attribute.options.isNotEmpty) {
      return DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        decoration: _decoration(label),
        items: attribute.options
            .map(
              (option) => DropdownMenuItem(value: option, child: Text(option)),
            )
            .toList(),
        validator: (value) => isRequired && (value == null || value.isEmpty)
            ? requiredMessage
            : null,
        onChanged: onChanged,
      );
    }

    return TextFormField(
      controller: controller,
      decoration: _decoration(label),
      validator: (value) =>
          isRequired && (value == null || value.trim().isEmpty)
          ? requiredMessage
          : null,
      onChanged: (value) => onChanged(value.trim()),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
      ),
    );
  }
}
