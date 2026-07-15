import 'package:buymarket_frontend/features/categories/screens/category_products_screen.dart';
import 'package:buymarket_frontend/features/home/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Product featured parsing', () {
    test('reads isFeatured from the API response', () {
      final product = Product.fromJson({
        'id': '1',
        'title': 'Notebook',
        'description': '',
        'price': 100,
        'stock': 2,
        'category': {'id': 'technology', 'name': 'Tecnología'},
        'isFeatured': true,
      });

      expect(product.isFeatured, isTrue);
    });

    test('defaults isFeatured to false when it is absent', () {
      final product = Product.fromJson({
        'id': '1',
        'title': 'Notebook',
        'description': '',
        'price': 100,
        'stock': 2,
        'category': {'id': 'technology', 'name': 'Tecnología'},
      });

      expect(product.isFeatured, isFalse);
    });
  });

  group('CategoryProductsScreen', () {
    testWidgets('shows featured and all category products', (tester) async {
      await _pumpScreen(
        tester,
        products: [
          _product(id: '1', title: 'Notebook', isFeatured: true),
          _product(id: '2', title: 'Teclado'),
        ],
      );

      expect(find.text('Tecnología'), findsWidgets);
      expect(find.byIcon(Icons.devices), findsOneWidget);
      final titleRow = tester.widget<Row>(
        find.ancestor(
          of: find.byKey(const Key('category-title-text')),
          matching: find.byType(Row),
        ),
      );
      expect(titleRow.mainAxisAlignment, MainAxisAlignment.center);
      expect(find.text('Productos destacados'), findsOneWidget);
      expect(find.text('Todos los productos'), findsOneWidget);
      expect(find.text('Notebook'), findsNWidgets(2));
      expect(find.text('Teclado'), findsOneWidget);
    });

    testWidgets('filters products without matching case', (tester) async {
      await _pumpScreen(
        tester,
        products: [
          _product(id: '1', title: 'Notebook'),
          _product(id: '2', title: 'Teclado'),
        ],
      );

      expect(find.text('Productos destacados'), findsNothing);
      await tester.enterText(find.byType(TextField), 'NOTE');
      await tester.pump();

      expect(find.text('Notebook'), findsOneWidget);
      expect(find.text('Teclado'), findsNothing);
    });

    testWidgets('shows empty and no-results states', (tester) async {
      await _pumpScreen(tester, products: const []);
      expect(find.byKey(const Key('category-title-text')), findsOneWidget);
      expect(find.byIcon(Icons.devices), findsOneWidget);
      expect(find.text('No hay productos para esa categoria'), findsOneWidget);

      await _pumpScreen(
        tester,
        products: [_product(id: '1', title: 'Notebook')],
      );
      await tester.enterText(find.byType(TextField), 'teléfono');
      await tester.pump();
      expect(
        find.text('No encontramos productos para tu búsqueda.'),
        findsOneWidget,
      );
      expect(find.text('No hay productos para esa categoria'), findsNothing);
    });

    testWidgets('uses a generic icon for an unknown category', (tester) async {
      await _pumpScreen(
        tester,
        products: const [],
        categoryName: 'Coleccionables',
      );

      expect(find.byIcon(Icons.category), findsOneWidget);
    });

    testWidgets('shows the pets image to the right of the category title', (
      tester,
    ) async {
      await _pumpScreen(
        tester,
        products: const [],
        categoryName: '  mAsCoTaS  ',
      );

      final title = find.byKey(const Key('category-title-text'));
      final petsImage = find.byKey(const Key('pets-category-image'));

      expect(petsImage, findsOneWidget);
      expect(find.byKey(const Key('category-title-icon')), findsNothing);
      expect(
        tester.getTopLeft(title).dx,
        lessThan(tester.getTopLeft(petsImage).dx),
      );

      final image = tester.widget<Image>(petsImage);
      expect(image.image, isA<AssetImage>());
      expect(
        (image.image as AssetImage).assetName,
        'assets/images/CategoriaMascotas.png',
      );
    });

    testWidgets('loads products with the selected category id', (tester) async {
      String? receivedCategoryId;

      await tester.pumpWidget(
        MaterialApp(
          home: CategoryProductsScreen(
            categoryId: 'selected-category',
            categoryName: 'Hogar',
            productLoader: (categoryId) async {
              receivedCategoryId = categoryId;
              return const [];
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(receivedCategoryId, 'selected-category');
      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('only shows products from the selected category', (
      tester,
    ) async {
      await _pumpScreen(
        tester,
        products: [
          _product(id: '1', title: 'Notebook'),
          _product(
            id: '2',
            title: 'Pelota',
            category: 'Deportes',
            categoryId: 'sports',
          ),
          _product(
            id: '3',
            title: 'Sin categoría',
            category: '',
            categoryId: null,
          ),
        ],
      );

      expect(find.text('Notebook'), findsOneWidget);
      expect(find.text('Pelota'), findsNothing);
      expect(find.text('Sin categoría'), findsNothing);
    });

    testWidgets('shows the empty state when no product matches the category', (
      tester,
    ) async {
      await _pumpScreen(
        tester,
        products: [
          _product(
            id: '1',
            title: 'Pelota',
            category: 'Deportes',
            categoryId: 'sports',
          ),
        ],
      );

      expect(find.text('Pelota'), findsNothing);
      expect(find.text('No hay productos para esa categoria'), findsOneWidget);
    });

    testWidgets('retries after a loading error', (tester) async {
      var attempts = 0;
      Future<List<Product>> loader(String _) async {
        attempts++;
        if (attempts == 1) throw Exception('network');
        return [_product(id: '1', title: 'Notebook')];
      }

      await tester.pumpWidget(
        MaterialApp(
          home: CategoryProductsScreen(
            categoryId: 'technology',
            categoryName: 'Tecnología',
            productLoader: loader,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reintentar'), findsOneWidget);
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(find.text('Notebook'), findsOneWidget);
      expect(attempts, 2);
    });
  });
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required List<Product> products,
  String categoryName = 'Tecnología',
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: CategoryProductsScreen(
        key: UniqueKey(),
        categoryId: 'technology',
        categoryName: categoryName,
        productLoader: (_) async => products,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Product _product({
  required String id,
  required String title,
  String category = 'Tecnología',
  String? categoryId = 'technology',
  bool isFeatured = false,
}) {
  return Product(
    id: id,
    title: title,
    description: '',
    category: category,
    categoryId: categoryId,
    price: '100',
    imageUrl: '',
    media: const [],
    attributes: const [],
    stock: 2,
    isFeatured: isFeatured,
  );
}
