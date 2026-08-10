import 'package:flutter/material.dart';

import '../../auth/services/auth_services_instance.dart';
import '../../home/models/product.dart';
import '../../home/services/product_service_instance.dart';
import '../../home/widgets/product_grid.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  List<Product> products = [];
  final Set<String> deletingProductIds = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadMyProducts();
  }

  Future<void> deleteProduct(Product product) async {
    if (deletingProductIds.contains(product.id)) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text(
          '¿Querés eliminar "${product.title}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final token = authServices.token;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tenés que iniciar sesión nuevamente')),
      );
      return;
    }

    setState(() => deletingProductIds.add(product.id));

    try {
      await productService.deleteProduct(
        productId: product.id,
        token: token,
      );

      if (!mounted) return;
      setState(() => products.removeWhere((item) => item.id == product.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => deletingProductIds.remove(product.id));
      }
    }
  }

  Future<void> loadMyProducts() async {
    try {
      final token = authServices.token;

      if (token == null) {
        throw Exception("Usuario no autenticado");
      }

      final result = await productService.getMyProducts(token: token);

      if (!mounted) return;

      setState(() {
        products = result;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Mis productos',
          style: TextStyle(
            color: Color(0xff2D006B),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xff2D006B)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : products.isEmpty
          ? const Center(
              child: Text(
                'Todavía no publicaste productos',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : RefreshIndicator(
              onRefresh: loadMyProducts,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ProductGrid(products: products, onDelete: deleteProduct),
                ],
              ),
            ),
    );
  }
}
