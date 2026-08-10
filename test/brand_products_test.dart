import 'package:buymarket_frontend/features/home/models/product.dart';
import 'package:buymarket_frontend/features/products/screens/brand_products_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Product brand parsing', () {
    test('reads the optional Marca product attribute', () {
      final product = Product.fromJson({
        'id': 'product-with-brand',
        'title': 'Buzo',
        'description': '',
        'price': 100,
        'stock': 1,
        'category': {'id': 'pets', 'name': 'Mascotas'},
        'attributeValues': [
          {
            'value': 'RPM',
            'attribute': {'id': 'brand', 'name': 'Marca'},
          },
        ],
      });

      expect(product.brand, 'RPM');
      expect(product.matchesBrand(' rpm '), isTrue);
    });

    test('assigns RPM only to the known legacy publications', () {
      final legacyProduct = Product.fromJson({
        'id': 'feaaf6dd-86f0-4be4-a530-010be5c3f12d',
        'title': 'Buzo',
        'description': '',
        'price': 100,
        'stock': 1,
        'category': {'id': 'pets', 'name': 'Mascotas'},
      });
      final unbrandedProduct = Product.fromJson({
        'id': 'future-unbranded-product',
        'title': 'Producto sin marca',
        'description': '',
        'price': 100,
        'stock': 1,
        'category': {'id': 'pets', 'name': 'Mascotas'},
      });

      expect(legacyProduct.brand, 'RPM');
      expect(unbrandedProduct.brand, isEmpty);
    });
  });

  testWidgets('shows only products matching the selected brand', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BrandProductsScreen(
          brandName: 'RPM',
          productLoader: () async => [
            _product(id: 'rpm', title: 'Producto RPM', brand: 'RPM'),
            _product(id: 'other', title: 'Producto Adidas', brand: 'Adidas'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Productos de RPM'), findsOneWidget);
    expect(find.text('Producto RPM'), findsOneWidget);
    expect(find.text('Producto Adidas'), findsNothing);
  });
}

Product _product({
  required String id,
  required String title,
  required String brand,
}) {
  return Product(
    id: id,
    title: title,
    brand: brand,
    description: '',
    category: 'Mascotas',
    categoryId: 'pets',
    price: '100',
    imageUrl: '',
    media: const [],
    attributes: const [],
    stock: 1,
  );
}
