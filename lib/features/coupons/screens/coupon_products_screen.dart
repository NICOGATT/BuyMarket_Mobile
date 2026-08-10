import 'package:flutter/material.dart';

import '../../home/widgets/product_filter_section.dart';
import '../models/coupon_offer.dart';

class CouponProductsScreen extends StatelessWidget {
  final CouponOffer coupon;

  const CouponProductsScreen({super.key, required this.coupon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Productos de la promoción'),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xff2D006B),
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SelectedCouponHeader(coupon: coupon),
              const SizedBox(height: 22),
              ProductFilterSection(
                title: 'Productos disponibles',
                products: coupon.products,
                includeCategoryFilter: true,
                titleStyle: const TextStyle(
                  color: Color(0xff2D006B),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedCouponHeader extends StatelessWidget {
  final CouponOffer coupon;

  const _SelectedCouponHeader({required this.coupon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff5E2CA5), Color(0xff2D006B)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.confirmation_number_outlined,
            color: Colors.white,
            size: 42,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coupon.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${coupon.benefitText} · ${coupon.products.length} productos',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
