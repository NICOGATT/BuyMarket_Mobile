import 'package:buymarket_frontend/features/coupons/models/coupon_offer.dart';
import 'package:buymarket_frontend/features/coupons/screens/coupons_screen.dart';
import 'package:buymarket_frontend/features/home/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('groups products that use the same coupon', () {
    final coupons = buildCouponsFromProducts([
      _product(id: '1', title: 'Notebook', label: 'VUELTA20', discount: 20),
      _product(id: '2', title: 'Teclado', label: 'VUELTA20', discount: 20),
      _product(id: '3', title: 'Mouse', label: 'TECH10', discount: 10),
      _product(id: '4', title: 'Sin promoción'),
    ]);

    expect(coupons, hasLength(2));
    expect(coupons.first.title, 'VUELTA20');
    expect(coupons.first.products, hasLength(2));
  });

  testWidgets('shows the requested empty state when there are no coupons', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CouponsScreen(
          productLoader: () async => [
            _product(id: '1', title: 'Producto sin promoción'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('No hay cupones disponibles por el momento'),
      findsOneWidget,
    );
  });

  testWidgets('opens only the products for the selected coupon', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CouponsScreen(
          productLoader: () async => [
            _product(
              id: '1',
              title: 'Notebook en oferta',
              label: 'VUELTA20',
              discount: 20,
            ),
            _product(
              id: '2',
              title: 'Mouse promocionado',
              label: 'TECH10',
              discount: 10,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('VUELTA20'));
    await tester.pumpAndSettle();

    expect(find.text('Productos de la promoción'), findsOneWidget);
    expect(find.text('Notebook en oferta'), findsOneWidget);
    expect(find.text('Mouse promocionado'), findsNothing);
  });
}

Product _product({
  required String id,
  required String title,
  String label = '',
  int discount = 0,
}) {
  return Product(
    id: id,
    title: title,
    description: '',
    category: 'Tecnología',
    categoryId: 'technology',
    price: '100',
    imageUrl: '',
    media: const [],
    attributes: const [],
    stock: 2,
    promotionLabel: label,
    discountPercentage: discount,
  );
}
