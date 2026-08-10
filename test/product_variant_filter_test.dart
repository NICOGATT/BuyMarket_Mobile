import 'package:buymarket_frontend/features/home/models/product.dart';
import 'package:buymarket_frontend/features/home/widgets/product_filter_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('crea filtros para talle, color y atributos extra de variante', () {
    final options = buildProductVariantFilterOptions([
      _product(
        id: 'product-1',
        variants: [
          _variant(
            id: 'variant-1',
            size: 'M',
            color: 'Rojo',
            material: 'Algodón',
          ),
        ],
      ),
    ]);

    expect(options.map((option) => option.label), [
      'Talle',
      'Color',
      'Material',
    ]);
    expect(options.last.values.values, contains('Algodón'));
  });

  test('combina los filtros dentro de una misma variante', () {
    final matchingProduct = _product(
      id: 'matching',
      variants: [
        _variant(id: 'matching-variant', size: 'M', color: 'Rojo'),
      ],
    );
    final splitProduct = _product(
      id: 'split',
      variants: [
        _variant(id: 'split-1', size: 'M', color: 'Azul'),
        _variant(id: 'split-2', size: 'L', color: 'Rojo'),
      ],
    );

    final result = filterProductsByVariants(
      [matchingProduct, splitProduct],
      {
        'talle': {'m'},
        'color': {'rojo'},
      },
    );

    expect(result.map((product) => product.id), ['matching']);
  });

  test('ordena por precio y puede mostrar solo envio gratis', () {
    final expensive = _product(
      id: 'Cama',
      price: '300',
      hasFreeShipping: true,
      variants: const [],
    );
    final cheap = _product(
      id: 'Abrigo',
      price: '100',
      variants: const [],
    );

    final sorted = applyProductFilters(
      [expensive, cheap],
      ProductFilterSelection(sortOption: ProductSortOption.priceLowToHigh),
    );
    final freeShipping = applyProductFilters(
      [expensive, cheap],
      ProductFilterSelection(freeShippingOnly: true),
    );

    expect(sorted.map((product) => product.id), ['Abrigo', 'Cama']);
    expect(freeShipping.map((product) => product.id), ['Cama']);
  });

  test('agrega y aplica categoria solamente cuando se solicita', () {
    final pets = _product(
      id: 'pets',
      category: 'Mascotas',
      variants: const [],
    );
    final technology = _product(
      id: 'technology',
      category: 'Tecnología',
      variants: const [],
    );

    final regularOptions = buildProductVariantFilterOptions([pets, technology]);
    final globalOptions = buildProductVariantFilterOptions(
      [pets, technology],
      includeCategory: true,
    );
    final filtered = filterProductsByVariants(
      [pets, technology],
      {
        'categoria': {'mascotas'},
      },
    );

    expect(regularOptions.any((option) => option.key == 'categoria'), isFalse);
    expect(globalOptions.first.key, 'categoria');
    expect(filtered.map((product) => product.id), ['pets']);
  });
}

Product _product({
  required String id,
  required List<ProductVariantModel> variants,
  String price = '100',
  bool hasFreeShipping = false,
  String category = 'Mascotas',
}) {
  return Product(
    id: id,
    title: id,
    description: '',
    category: category,
    price: price,
    imageUrl: '',
    media: const [],
    attributes: const [],
    variants: variants,
    stock: 1,
    hasFreeShipping: hasFreeShipping,
  );
}

ProductVariantModel _variant({
  required String id,
  required String size,
  required String color,
  String? material,
}) {
  return ProductVariantModel(
    id: id,
    size: size,
    color: color,
    price: 100,
    stock: 1,
    isActive: true,
    attributes: material == null
        ? const []
        : [
            ProductVariantAttributeModel(
              attributeId: 'material',
              name: 'Material',
              value: material,
            ),
          ],
  );
}
