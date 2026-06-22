import 'package:flutter/material.dart';

import '../../cart/services/cart_services_instances.dart';
import '../../orders/services/order_service_instance.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../paymentMethods/service/payment_api_service.dart';
import '../../auth/services/auth_services_instance.dart';
class CheckoutScreen extends StatefulWidget{
  const CheckoutScreen({super.key}); 

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState(); 
}


class _CheckoutScreenState extends State<CheckoutScreen> {
  String deliveryMethod = "delivery"; 
  String paymentMethod = "mercado_pago"; 

  final addressController = TextEditingController(); 
  final notesController = TextEditingController(); 

  bool isLoading = false; 

  @override
  void dispose() {
    addressController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> confirmCheckout() async {
    if (deliveryMethod == 'delivery' &&
        addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresá una dirección de entrega')),
      );
      return;
    }

    final deliveryAddress = deliveryMethod == 'delivery'
        ? addressController.text.trim()
        : 'Retiro en tienda';

    setState(() => isLoading = true);

    final order = await orderService.checkout(
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      notes: notesController.text.trim().isEmpty
          ? null
          : notesController.text.trim(),
    );

    if (!mounted) return;


    if (order == null) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderService.error ?? 'Error al crear la orden'),
        ),
      );
      return;
    }

    if(paymentMethod == "mercado_pago") {
      final paymentApi = PaymentApiService();
      final initPoint = await paymentApi.createPreference(
        orderId: order.id, 
        token: authServices.token!,
      ); 

      await launchUrl(
        Uri.parse(initPoint),
        mode : LaunchMode.externalApplication,
      );
    }
    await cartService.loadCart();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Orden creada correctamente')),
    );

    Navigator.pop(context);
  }


  @override 
  Widget build(BuildContext context) {
    final total = cartService.total;

    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      appBar: AppBar(
        title: const Text(
          'Checkout', 
          style: TextStyle(
            color : Color.fromARGB(255, 21, 13, 239),
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 24, 21, 189)),
      ),
      body : AnimatedBuilder(
        animation: cartService,
        builder: (context, child) {
          return ListView(
            padding : const EdgeInsets.all(16),
            children: [
              _sectionTitle('Entrega'), 
              _optionCard(
                title : 'Envio a domicilio', 
                subtitle : 'Recibis el pedido en tu direccion', 
                value : 'delivery', 
                groupValue : deliveryMethod, 
                onChanged : (value) => {
                  setState(() => deliveryMethod = value!)
                }
              ), 
              _optionCard(
                title: 'Retiro en tienda',
                subtitle: 'Coordinás el retiro con el vendedor',
                value: 'pickup',
                groupValue: deliveryMethod,
                onChanged: (value) {
                  setState(() => deliveryMethod = value!);
                },
              ),

              if(deliveryMethod == "delivery") ...[
                const SizedBox(height: 12,), 
                TextField(
                  controller: addressController,
                  decoration: _inputDecoration('Direccion de entrega'),
                ),
              ], 
              const SizedBox(height: 24,), 
              _sectionTitle('Forma de pago'), 
              _optionCard(
                title: 'Mercado Pago',
                subtitle: 'Tarjeta, saldo o transferencia',
                value: 'mercado_pago',
                groupValue: paymentMethod,
                onChanged: (value) {
                  setState(() => paymentMethod = value!);
                },
              ),

              _optionCard(
                title: 'Efectivo',
                subtitle: 'Pagás al recibir o retirar',
                value: 'cash',
                groupValue: paymentMethod,
                onChanged: (value) {
                  setState(() => paymentMethod = value!);
                },
              ),

              const SizedBox(height: 24,),

              TextField(
                controller : notesController, 
                maxLines : 3,
                decoration: _inputDecoration('Aclaraciones para el vendedor'),
              ), 

              const SizedBox(height: 24),
              _sectionTitle('Resumen'),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    _resumeRow('Productos', '${cartService.badgeCount}'),
                    const SizedBox(height: 8),
                    _resumeRow(
                      'Total',
                      '\$${total.toStringAsFixed(2)}',
                      bold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : confirmCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff5E2CA5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Confirmar compra',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          );
        }
        ,
      )
    );
  }
    
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xff5E2CA5),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  Widget _optionCard({
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: _cardDecoration(),
      child: RadioListTile<String>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: const Color(0xff5E2CA5),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _resumeRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontSize: bold ? 18 : 14,
          ),
        ),
      ],
    );
  }
}

