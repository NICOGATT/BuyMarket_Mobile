import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../auth/services/auth_services_instance.dart';
import '../../cart/services/cart_services_instances.dart';
import '../../orders/services/order_service_instance.dart';
import '../../paymentMethods/models/user_payment_method.dart';
import '../../paymentMethods/service/payment_api_service.dart';
import '../../paymentMethods/service/user_payment_method_service_instance.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String deliveryMethod = 'delivery';
  String paymentMethod = 'mercado_pago';
  String? selectedPaymentMethodId;

  final addressController = TextEditingController();
  final notesController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await userPaymentMethodService.loadPaymentMethods();
      if (!mounted) return;
      _selectDefaultPaymentMethodIfNeeded();
    });
  }

  @override
  void dispose() {
    addressController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void _selectDefaultPaymentMethodIfNeeded() {
    final activeMethods = userPaymentMethodService.activePaymentMethods;
    if (activeMethods.isEmpty || selectedPaymentMethodId != null) return;

    UserPaymentMethod? defaultMethod;
    for (final paymentMethod in activeMethods) {
      if (paymentMethod.isDefault) {
        defaultMethod = paymentMethod;
        break;
      }
    }

    setState(() {
      selectedPaymentMethodId = (defaultMethod ?? activeMethods.first).id;
    });
  }

  Future<void> confirmCheckout() async {
    if (deliveryMethod == 'delivery' && addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa una direccion de entrega')),
      );
      return;
    }

    final activeMethods = userPaymentMethodService.activePaymentMethods;
    final selectedSavedPaymentMethod = _selectedPaymentMethod(activeMethods);

    if (activeMethods.isNotEmpty && selectedSavedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Elegi un metodo de pago')),
      );
      return;
    }

    final deliveryAddress = deliveryMethod == 'delivery'
        ? addressController.text.trim()
        : 'Retiro en tienda';

    setState(() => isLoading = true);

    final order = await orderService.checkout(
      deliveryAddress: deliveryAddress,
      paymentMethod: selectedSavedPaymentMethod == null ? paymentMethod : null,
      paymentMethodId: selectedSavedPaymentMethod?.id,
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

    final shouldOpenMercadoPago =
        selectedSavedPaymentMethod?.isMercadoPago ??
        paymentMethod == 'mercado_pago';

    if (shouldOpenMercadoPago) {
      final paymentApi = PaymentApiService();
      final initPoint = await paymentApi.createPreference(
        orderId: order.id,
        token: authServices.token!,
      );

      await launchUrl(
        Uri.parse(initPoint),
        mode: LaunchMode.externalApplication,
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Color.fromARGB(255, 21, 13, 239),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 24, 21, 189)),
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([cartService, userPaymentMethodService]),
        builder: (context, child) {
          final activePaymentMethods =
              userPaymentMethodService.activePaymentMethods;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionTitle('Entrega'),
              _optionCard(
                title: 'Envio a domicilio',
                subtitle: 'Recibis el pedido en tu direccion',
                value: 'delivery',
                groupValue: deliveryMethod,
                onChanged: (value) {
                  setState(() => deliveryMethod = value!);
                },
              ),
              _optionCard(
                title: 'Retiro en tienda',
                subtitle: 'Coordinas el retiro con el vendedor',
                value: 'pickup',
                groupValue: deliveryMethod,
                onChanged: (value) {
                  setState(() => deliveryMethod = value!);
                },
              ),
              if (deliveryMethod == 'delivery') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: _inputDecoration('Direccion de entrega'),
                ),
              ],
              const SizedBox(height: 24),
              _sectionTitle('Forma de pago'),
              if (userPaymentMethodService.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (activePaymentMethods.isNotEmpty) ...[
                ...activePaymentMethods.map(_savedPaymentCard),
                TextButton.icon(
                  onPressed: userPaymentMethodService.loadPaymentMethods,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Actualizar metodos'),
                ),
              ] else ...[
                if (userPaymentMethodService.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      userPaymentMethodService.error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
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
                  subtitle: 'Pagas al recibir o retirar',
                  value: 'cash',
                  groupValue: paymentMethod,
                  onChanged: (value) {
                    setState(() => paymentMethod = value!);
                  },
                ),
              ],
              const SizedBox(height: 24),
              TextField(
                controller: notesController,
                maxLines: 3,
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
        },
      ),
    );
  }

  UserPaymentMethod? _selectedPaymentMethod(
    List<UserPaymentMethod> activeMethods,
  ) {
    for (final paymentMethod in activeMethods) {
      if (paymentMethod.id == selectedPaymentMethodId) {
        return paymentMethod;
      }
    }

    return null;
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
    final isSelected = value == groupValue;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: _cardDecoration(),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected
                    ? const Color(0xff5E2CA5)
                    : Colors.black.withValues(alpha: 0.38),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _savedPaymentCard(UserPaymentMethod paymentMethod) {
    final detail = paymentMethod.isTransfer
        ? [
            paymentMethod.displayMethod,
            if (paymentMethod.senderAlias != null)
              'Alias: ${paymentMethod.senderAlias}',
            if (paymentMethod.senderCbu != null)
              'CBU/CVU: ${paymentMethod.senderCbu}',
          ].join(' - ')
        : 'Tarjeta, saldo o transferencia';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: _cardDecoration(),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedPaymentMethodId = paymentMethod.id;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                selectedPaymentMethodId == paymentMethod.id
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selectedPaymentMethodId == paymentMethod.id
                    ? const Color(0xff5E2CA5)
                    : Colors.black.withValues(alpha: 0.38),
              ),
              const SizedBox(width: 12),
              Icon(
                paymentMethod.isTransfer
                    ? Icons.swap_horiz
                    : Icons.account_balance_wallet_outlined,
                color: const Color(0xff5E2CA5),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            paymentMethod.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (paymentMethod.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xff5E2CA5,
                              ).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Default',
                              style: TextStyle(
                                color: Color(0xff5E2CA5),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
