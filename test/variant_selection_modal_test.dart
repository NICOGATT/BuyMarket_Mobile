import 'package:buymarket_frontend/features/home/models/product.dart';
import 'package:buymarket_frontend/features/home/widgets/variant_selection_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('selects an available variant from the modal', (tester) async {
    ProductVariantModel? selectedVariant;
    final product = Product(
      id: 'product-1',
      title: 'Buzo para mascota',
      description: '',
      category: 'Mascotas',
      price: '100',
      imageUrl: '',
      media: const [],
      attributes: const [],
      stock: 3,
      variants: const [
        ProductVariantModel(
          id: 'small-red',
          size: 'S',
          color: 'Rojo',
          colorHex: '#FF0000',
          price: 100,
          stock: 0,
          isActive: true,
          attributes: [],
        ),
        ProductVariantModel(
          id: 'medium-blue',
          size: 'M',
          color: 'Azul',
          colorHex: '#0000FF',
          price: 120,
          stock: 3,
          isActive: true,
          attributes: [],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                selectedVariant = await showVariantSelectionModal(
                  context,
                  product,
                );
              },
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Seleccioná una variante'), findsOneWidget);
    expect(
      tester
          .widget<InkWell>(
            find.byKey(const Key('variant-option-small-red')),
          )
          .onTap,
      isNull,
    );

    await tester.tap(find.byKey(const Key('confirm-variant-add')));
    await tester.pumpAndSettle();

    expect(selectedVariant?.id, 'medium-blue');
  });
}
