import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../models/user_payment_method.dart';
import '../service/user_payment_method_service_instance.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  static const Color _primaryColor = Color(0xff2D006B);
  static const Color _accentColor = Color(0xff168BEE);
  static const Color _softColor = Color(0xffF2F4F7);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userPaymentMethodService.loadPaymentMethods();
    });
  }

  Future<void> _openForm([UserPaymentMethod? paymentMethod]) async {
    final changed = await Navigator.pushNamed(
      context,
      AppRoutes.paymentMethodForm,
      arguments: paymentMethod,
    );

    if (changed == true) {
      await userPaymentMethodService.loadPaymentMethods();
    }
  }

  Future<void> _setDefaultPaymentMethod(UserPaymentMethod paymentMethod) async {
    try {
      await userPaymentMethodService.setDefaultPaymentMethod(paymentMethod.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Metodo predeterminado actualizado')),
      );
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _deletePaymentMethod(UserPaymentMethod paymentMethod) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar metodo'),
          content: Text('Queres eliminar "${paymentMethod.label}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await userPaymentMethodService.deletePaymentMethod(paymentMethod.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Metodo eliminado')));
    } catch (error) {
      _showError(error);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;

    final message = error.toString().replaceFirst('Exception: ', '');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Metodos de pago'),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: _primaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: userPaymentMethodService,
          builder: (context, child) {
            final paymentMethods = userPaymentMethodService.paymentMethods;

            return RefreshIndicator(
              onRefresh: userPaymentMethodService.loadPaymentMethods,
              color: _primaryColor,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                children: [
                  _Header(onAddPressed: () => _openForm()),
                  const SizedBox(height: 18),
                  if (userPaymentMethodService.error != null)
                    _ErrorBanner(message: userPaymentMethodService.error!),
                  if (userPaymentMethodService.error != null)
                    const SizedBox(height: 14),
                  if (userPaymentMethodService.isLoading)
                    const _LoadingState()
                  else if (paymentMethods.isEmpty)
                    _EmptyState(onAddPressed: () => _openForm())
                  else
                    ...paymentMethods.map(
                      (paymentMethod) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PaymentMethodCard(
                          paymentMethod: paymentMethod,
                          onSetDefault: paymentMethod.isDefault
                              ? null
                              : () => _setDefaultPaymentMethod(paymentMethod),
                          onEdit: () => _openForm(paymentMethod),
                          onDelete: () => _deletePaymentMethod(paymentMethod),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onAddPressed;

  const _Header({required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _PaymentMethodsScreenState._primaryColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.credit_card, color: Colors.white, size: 34),
          const SizedBox(height: 14),
          const Text(
            'Mis metodos de pago',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Guarda opciones para elegirlas al finalizar tus compras.',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add_card),
              label: const Text('Agregar metodo'),
              style: FilledButton.styleFrom(
                backgroundColor: _PaymentMethodsScreenState._accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final UserPaymentMethod paymentMethod;
  final VoidCallback? onSetDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PaymentMethodCard({
    required this.paymentMethod,
    required this.onEdit,
    required this.onDelete,
    this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _PaymentMethodsScreenState._softColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: paymentMethod.isDefault
              ? _PaymentMethodsScreenState._accentColor.withValues(alpha: 0.35)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  paymentMethod.isTransfer
                      ? Icons.swap_horiz
                      : Icons.account_balance_wallet_outlined,
                  color: _PaymentMethodsScreenState._primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          paymentMethod.label,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (paymentMethod.isDefault)
                          const _Badge(
                            label: 'Predeterminado',
                            color: _PaymentMethodsScreenState._accentColor,
                          ),
                        if (!paymentMethod.isActive)
                          const _Badge(label: 'Inactivo', color: Colors.red),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      paymentMethod.displayMethod,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (paymentMethod.isTransfer &&
              (paymentMethod.senderAlias != null ||
                  paymentMethod.senderCbu != null)) ...[
            const SizedBox(height: 12),
            if (paymentMethod.senderAlias != null)
              Text(
                'Alias: ${paymentMethod.senderAlias}',
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (paymentMethod.senderCbu != null) ...[
              const SizedBox(height: 4),
              Text(
                'CBU/CVU: ${paymentMethod.senderCbu}',
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              if (onSetDefault != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSetDefault,
                    icon: const Icon(Icons.star_border),
                    label: const Text('Predeterminado'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _PaymentMethodsScreenState._primaryColor,
                      side: const BorderSide(
                        color: _PaymentMethodsScreenState._primaryColor,
                      ),
                    ),
                  ),
                ),
              if (onSetDefault != null) const SizedBox(width: 10),
              IconButton.filledTonal(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                color: _PaymentMethodsScreenState._primaryColor,
                tooltip: 'Editar metodo',
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
                tooltip: 'Eliminar metodo',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: CircularProgressIndicator(
          color: _PaymentMethodsScreenState._primaryColor,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddPressed;

  const _EmptyState({required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _PaymentMethodsScreenState._softColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.add_card,
            size: 46,
            color: _PaymentMethodsScreenState._primaryColor,
          ),
          const SizedBox(height: 12),
          const Text(
            'Todavia no tenes metodos guardados.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Agrega Mercado Pago o transferencia para usarlos en checkout.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onAddPressed,
            icon: const Icon(Icons.add),
            label: const Text('Agregar metodo'),
            style: FilledButton.styleFrom(
              backgroundColor: _PaymentMethodsScreenState._accentColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
