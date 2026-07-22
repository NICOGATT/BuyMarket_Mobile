import 'package:buymarket_frontend/features/home/models/product.dart';
import 'package:buymarket_frontend/features/products/screens/producto_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductVariantModel', () {
    test('parses color data, stock and active state from the API', () {
      final product = Product.fromJson({
        'id': 'product-1',
        'title': 'Remera',
        'description': '',
        'price': 100,
        'stock': 2,
        'category': 'Ropa',
        'variants': [
          {
            'id': 'variant-1',
            'size': 'M',
            'color': 'Negro',
            'colorHex': '#000000',
            'price': 120,
            'stock': 2,
            'isActive': false,
          },
        ],
      });

      final variant = product.variants.single;
      expect(variant.color, 'Negro');
      expect(variant.colorHex, '#000000');
      expect(variant.stock, 2);
      expect(variant.isActive, isFalse);
      expect(variant.isAvailable, isFalse);
    });

    test('also accepts the snake_case color hex key', () {
      final product = Product.fromJson({
        'id': 'product-1',
        'title': 'Remera',
        'description': '',
        'price': 100,
        'stock': 1,
        'category': 'Ropa',
        'variants': [
          {
            'id': 'variant-1',
            'color': 'Rojo',
            'color_hex': '#FF0000',
            'price': 100,
            'stock': 1,
          },
        ],
      });

      expect(product.variants.single.colorHex, '#FF0000');
    });
  });

  group('ProductDetailScreen variant selection', () {
    testWidgets(
      'preselects an available variant and disables sold out colors',
      (tester) async {
        final product = _product([
          _variant(
            id: 'black-m',
            size: 'M',
            color: 'Negro',
            colorHex: '#000000',
            price: 110,
            stock: 0,
          ),
          _variant(
            id: 'red-m',
            size: 'M',
            color: 'Rojo',
            colorHex: '#FF0000',
            price: 120,
            stock: 3,
            attributes: const [
              ProductVariantAttributeModel(
                attributeId: 'material',
                name: 'Material',
                value: 'Algodon',
              ),
            ],
          ),
        ]);

        await _pumpDetail(tester, product);

        final redChip = tester.widget<ChoiceChip>(
          find.byKey(const Key('variant-color-Rojo')),
        );
        final blackChip = tester.widget<ChoiceChip>(
          find.byKey(const Key('variant-color-Negro')),
        );
        expect(redChip.selected, isTrue);
        expect(redChip.onSelected, isNotNull);
        expect(blackChip.onSelected, isNull);
        expect(
          find.byKey(const Key('variant-color-swatch-Rojo')),
          findsOneWidget,
        );
        expect(find.text(r'$120'), findsOneWidget);
        expect(find.text('Stock: 3'), findsOneWidget);
        expect(
          find.text('Caracteristicas de la variante seleccionada'),
          findsOneWidget,
        );
        expect(find.text('Algodon'), findsOneWidget);
      },
    );

    testWidgets('keeps a color when it is available for the new size', (
      tester,
    ) async {
      final product = _product([
        _variant(id: 'red-m', size: 'M', color: 'Rojo', price: 120),
        _variant(id: 'red-l', size: 'L', color: 'Rojo', price: 130),
        _variant(id: 'blue-l', size: 'L', color: 'Azul', price: 140),
      ]);

      await _pumpDetail(tester, product);
      await _tapVisible(tester, find.byKey(const Key('variant-size-L')));
      await tester.pump();

      expect(
        tester
            .widget<ChoiceChip>(find.byKey(const Key('variant-color-Rojo')))
            .selected,
        isTrue,
      );
      expect(find.text(r'$130'), findsOneWidget);
    });

    testWidgets('supports products with only color or only size variants', (
      tester,
    ) async {
      await _pumpDetail(
        tester,
        _product([_variant(id: 'green', color: 'Verde', colorHex: '#00FF00')]),
      );

      expect(find.byKey(const Key('variant-color-Verde')), findsOneWidget);
      expect(find.text('Talle'), findsNothing);

      await _pumpDetail(tester, _product([_variant(id: 'medium', size: 'M')]));

      expect(find.byKey(const Key('variant-size-M')), findsOneWidget);
      expect(find.text('Color'), findsNothing);
    });

    testWidgets('uses text fallback for an invalid or missing color hex', (
      tester,
    ) async {
      final product = _product([
        _variant(id: 'brown', color: 'Marron', colorHex: 'brown'),
      ]);

      await _pumpDetail(tester, product);

      expect(find.byKey(const Key('variant-color-Marron')), findsOneWidget);
      expect(
        find.byKey(const Key('variant-color-swatch-Marron')),
        findsNothing,
      );
    });

    testWidgets('selects colorHex-only circles and adds the exact variant', (
      tester,
    ) async {
      final product = _product([
        _variant(id: 'gray-s', size: 'S', colorHex: '#9b9ea1', price: 100),
        _variant(id: 'pink-s', size: 'S', colorHex: '#e2699a', price: 150),
        _variant(
          id: 'black-s',
          size: 'S',
          colorHex: '#000000',
          price: 130,
          stock: 0,
        ),
      ]);
      String? addedProductId;
      String? addedVariantId;

      await _pumpDetail(
        tester,
        product,
        cartAdder: (productId, {variantId}) async {
          addedProductId = productId;
          addedVariantId = variantId;
        },
      );
      expect(
        find.byKey(const Key('variant-color-swatch-#9B9EA1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('variant-color-swatch-#E2699A')),
        findsOneWidget,
      );
      expect(find.text('#9B9EA1'), findsNothing);
      expect(
        tester
            .widget<ChoiceChip>(find.byKey(const Key('variant-color-#000000')))
            .onSelected,
        isNull,
      );

      await _tapVisible(tester, find.byKey(const Key('variant-color-#E2699A')));
      await tester.pump();
      await tester.tap(find.text('Agregar al carrito'));
      await tester.pump();

      expect(find.text(r'$150'), findsOneWidget);
      expect(addedProductId, product.id);
      expect(addedVariantId, 'pink-s');
    });
  });
}

Future<void> _pumpDetail(
  WidgetTester tester,
  Product product, {
  ProductCartAdder? cartAdder,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ProductDetailScreen(
        key: UniqueKey(),
        product: product,
        productLoader: (_) async => product,
        cartAdder: cartAdder ?? (_, {variantId}) async {},
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

Product _product(List<ProductVariantModel> variants) {
  return Product(
    id: 'product-1',
    title: 'Remera',
    description: 'Descripcion',
    category: 'Ropa',
    price: '100',
    imageUrl: '',
    media: const [],
    attributes: const [],
    variants: variants,
    stock: variants.fold(0, (total, variant) => total + variant.stock),
  );
}

ProductVariantModel _variant({
  required String id,
  String? size,
  String? color,
  String? colorHex,
  double price = 100,
  int stock = 1,
  bool isActive = true,
  List<ProductVariantAttributeModel> attributes = const [],
}) {
  return ProductVariantModel(
    id: id,
    size: size,
    color: color,
    colorHex: colorHex,
    price: price,
    stock: stock,
    isActive: isActive,
    attributes: attributes,
  );
}
