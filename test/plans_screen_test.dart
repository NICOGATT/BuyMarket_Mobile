import 'package:buymarket_frontend/features/plans/screens/plans_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'selected_membership_plan': 'premium',
    });
  });

  testWidgets('shows the three plans and their prices', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PlansScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Free'), findsOneWidget);
    expect(find.text('Gratis'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('select-plan-plus')),
      300,
    );
    expect(find.text('Plus'), findsOneWidget);
    expect(find.text(r'$25.000'), findsWidgets);

    await tester.scrollUntilVisible(
      find.byKey(const Key('select-plan-premium')),
      300,
    );
    expect(find.text('Premium'), findsOneWidget);
    expect(find.text(r'$49.000'), findsWidgets);
  });

  testWidgets('shows Premium as the current six-month trial plan', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PlansScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Tu plan actual: Premium'), findsOneWidget);
    expect(
      find.text('Lo tenés gratis durante tus primeros 6 meses.'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('select-plan-premium')),
      300,
    );
    expect(find.text('Tu plan · 6 meses gratis'), findsOneWidget);
  });

  testWidgets('opens the purchase flow when Plus is selected', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PlansScreen()));
    await tester.pumpAndSettle();

    final plusButton = find.byKey(const Key('select-plan-plus'));
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(plusButton);
    await tester.pumpAndSettle();

    expect(find.text('Comprar Plus'), findsOneWidget);
    expect(find.text(r'$25.000'), findsOneWidget);
    expect(find.byKey(const Key('continue-plan-purchase')), findsOneWidget);
  });

  testWidgets('labels Free as Tu plan when it is the active plan', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'selected_membership_plan': 'free',
    });
    await tester.pumpWidget(const MaterialApp(home: PlansScreen()));
    await tester.pumpAndSettle();

    expect(find.text('¡Tenés Premium gratis por 6 meses!'), findsOneWidget);
    await tester.tap(find.text('Ahora no'));
    await tester.pumpAndSettle();

    expect(find.text('Tu plan'), findsNWidgets(2));
    expect(find.byKey(const Key('select-plan-free')), findsOneWidget);
  });

  testWidgets('activates Premium after claiming the six-month trial', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'selected_membership_plan': 'free',
    });
    await tester.pumpWidget(const MaterialApp(home: PlansScreen()));
    await tester.pumpAndSettle();

    expect(find.text('¡Tenés Premium gratis por 6 meses!'), findsOneWidget);
    await tester.tap(find.byKey(const Key('claim-premium-trial')));
    await tester.pumpAndSettle();

    expect(find.text('Tu plan actual: Premium'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('selected_membership_plan'), 'premium');
  });

  testWidgets('does not show the trial modal when Premium is already active', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PlansScreen()));
    await tester.pumpAndSettle();

    expect(find.text('¡Tenés Premium gratis por 6 meses!'), findsNothing);
    expect(find.text('Tu plan actual: Premium'), findsOneWidget);
  });

  testWidgets('shows the dismissed trial again on the next entry', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'selected_membership_plan': 'free',
    });
    await tester.pumpWidget(MaterialApp(home: PlansScreen(key: UniqueKey())));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ahora no'));
    await tester.pumpAndSettle();

    expect(find.text('¡Tenés Premium gratis por 6 meses!'), findsNothing);

    await tester.pumpWidget(MaterialApp(home: PlansScreen(key: UniqueKey())));
    await tester.pumpAndSettle();

    expect(find.text('¡Tenés Premium gratis por 6 meses!'), findsOneWidget);
  });
}
