import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';

class PlanPurchaseScreen extends StatelessWidget {
  final String planName;
  final int price;
  final String assetPath;
  final Color color;

  const PlanPurchaseScreen({
    super.key,
    required this.planName,
    required this.price,
    required this.assetPath,
    required this.color,
  });

  String get _formattedPrice {
    final value = price.toString();
    return '\$${value.substring(0, value.length - 3)}.${value.substring(value.length - 3)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Comprar $planName'),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xff2D006B),
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: color.withValues(alpha: 0.45)),
              ),
              child: Column(
                children: [
                  Image.asset(assetPath, width: 150, height: 150),
                  const SizedBox(height: 12),
                  Text(
                    'Plan $planName',
                    style: const TextStyle(
                      color: Color(0xff2D006B),
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formattedPrice,
                    style: TextStyle(
                      color: color,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Medio de pago',
              style: TextStyle(
                color: Color(0xff2D006B),
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Elegí o agregá el medio de pago que querés usar para completar la compra.',
              style: TextStyle(color: Colors.black54, height: 1.35),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              key: const Key('continue-plan-purchase'),
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.paymentMethods,
              ),
              icon: const Icon(Icons.credit_card),
              label: const Text('Elegir medio de pago'),
              style: FilledButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'El cobro se confirmará antes de activar el nuevo plan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black45, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
