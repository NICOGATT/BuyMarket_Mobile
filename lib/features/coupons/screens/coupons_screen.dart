import 'package:flutter/material.dart';

import '../../home/models/product.dart';
import '../../home/services/product_api_service.dart';
import '../models/coupon_offer.dart';
import 'coupon_products_screen.dart';

typedef CouponProductsLoader = Future<List<Product>> Function();

class CouponsScreen extends StatefulWidget {
  final CouponProductsLoader? productLoader;

  const CouponsScreen({super.key, this.productLoader});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  bool _isLoading = true;
  String? _error;
  List<CouponOffer> _coupons = const [];

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final products = await (widget.productLoader ??
          ProductApiService().getProducts)();
      if (!mounted) return;
      setState(() {
        _coupons = buildCouponsFromProducts(products);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar los cupones.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Cupones'),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xff2D006B),
        elevation: 0,
      ),
      body: SafeArea(top: false, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _CouponState(
        icon: Icons.cloud_off_outlined,
        message: _error!,
        actionLabel: 'Reintentar',
        onAction: _loadCoupons,
      );
    }

    if (_coupons.isEmpty) {
      return const _CouponState(
        icon: Icons.confirmation_number_outlined,
        message: 'No hay cupones disponibles por el momento',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCoupons,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        itemCount: _coupons.length + 1,
        separatorBuilder: (_, index) => SizedBox(height: index == 0 ? 18 : 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return const _CouponsHeader();
          }
          final coupon = _coupons[index - 1];
          return _CouponCard(
            coupon: coupon,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CouponProductsScreen(coupon: coupon),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CouponsHeader extends StatelessWidget {
  const _CouponsHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Elegí tu cupón',
          style: TextStyle(
            color: Color(0xff2D006B),
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Seleccioná una promoción para ver los productos donde podés usarla.',
          style: TextStyle(color: Colors.black54, height: 1.35),
        ),
      ],
    );
  }
}

class _CouponCard extends StatelessWidget {
  final CouponOffer coupon;
  final VoidCallback onTap;

  const _CouponCard({required this.coupon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xffF2F4F7),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        key: Key('coupon-${coupon.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xffEEE6FF),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.local_offer_outlined,
                  color: Color(0xff5E2CA5),
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coupon.title,
                      style: const TextStyle(
                        color: Color(0xff2D006B),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      coupon.benefitText,
                      style: const TextStyle(
                        color: Color(0xffF97316),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${coupon.products.length} productos disponibles',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}

class _CouponState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _CouponState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: Color(0xffEEE6FF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: const Color(0xff5E2CA5)),
            ),
            const SizedBox(height: 18),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xff2D006B),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
