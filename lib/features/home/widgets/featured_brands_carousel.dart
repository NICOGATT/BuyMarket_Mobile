import 'package:flutter/material.dart';

import '../../products/screens/brand_products_screen.dart';

class FeaturedBrandsCarousel extends StatelessWidget {
  const FeaturedBrandsCarousel({super.key});

  static const _brands = [
    _FeaturedBrand(
      'RPM',
      'RP',
      Color(0xffE51B23),
      imageAsset: 'assets/images/rpm_logo_white.png',
    ),
    _FeaturedBrand('Adidas', 'AD', Color(0xff12B8B0)),
    _FeaturedBrand('Samsung', 'SA', Color(0xff2878F0)),
    _FeaturedBrand('Apple', 'AP', Color(0xff6D5CE7)),
    _FeaturedBrand('Purina', 'PU', Color(0xffF59E0B)),
    _FeaturedBrand('L’Oréal', 'LO', Color(0xffE83E78)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Marcas destacadas',
          style: TextStyle(
            color: Color(0xff2D006B),
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _brands.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) => _BrandLogo(
              brand: _brands[index],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BrandProductsScreen(
                    brandName: _brands[index].name,
                    imageAsset: _brands[index].imageAsset,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BrandLogo extends StatelessWidget {
  final _FeaturedBrand brand;
  final VoidCallback onTap;

  const _BrandLogo({required this.brand, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 76,
          child: Column(
            children: [
              Container(
                width: 68,
                height: 68,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      brand.color.withValues(alpha: 0.68),
                      brand.color,
                    ],
                  ),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x262D006B),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: brand.imageAsset == null
                    ? Text(
                        brand.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      )
                    : ClipOval(
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.white,
                          padding: const EdgeInsets.all(5),
                          child: Image.asset(
                            brand.imageAsset!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 7),
              Text(
                brand.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xff190A35),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedBrand {
  final String name;
  final String initials;
  final Color color;
  final String? imageAsset;

  const _FeaturedBrand(
    this.name,
    this.initials,
    this.color, {
    this.imageAsset,
  });
}
