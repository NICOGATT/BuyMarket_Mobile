import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../models/user_address.dart';
import '../services/user_address_service_instance.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  static const Color _primaryColor = Color(0xff2D006B);
  static const Color _accentColor = Color(0xff168BEE);
  static const Color _softColor = Color(0xffF2F4F7);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userAddressService.loadAddresses();
    });
  }

  Future<void> _openAddAddress() async {
    final created = await Navigator.pushNamed(context, AppRoutes.addAddress);

    if (created == true) {
      await userAddressService.loadAddresses();
    }
  }

  Future<void> _setDefaultAddress(UserAddress address) async {
    try {
      await userAddressService.setDefaultAddress(address.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Direccion predeterminada actualizada')),
      );
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _deleteAddress(UserAddress address) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar direccion'),
          content: Text('Queres eliminar "${address.label}"?'),
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
      await userAddressService.deleteAddress(address.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Direccion eliminada')));
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
        title: const Text('Mis direcciones'),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: _primaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: userAddressService,
          builder: (context, child) {
            final addresses = userAddressService.addresses;

            return RefreshIndicator(
              onRefresh: userAddressService.loadAddresses,
              color: _primaryColor,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                children: [
                  _Header(onAddPressed: _openAddAddress),
                  const SizedBox(height: 18),
                  if (userAddressService.error != null)
                    _ErrorBanner(message: userAddressService.error!),
                  if (userAddressService.error != null)
                    const SizedBox(height: 14),
                  if (userAddressService.isLoading)
                    const _LoadingState()
                  else if (addresses.isEmpty)
                    _EmptyState(onAddPressed: _openAddAddress)
                  else
                    ...addresses.map(
                      (address) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AddressCard(
                          address: address,
                          onSetDefault: address.isDefault
                              ? null
                              : () => _setDefaultAddress(address),
                          onDelete: () => _deleteAddress(address),
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
        color: _AddressesScreenState._primaryColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on, color: Colors.white, size: 34),
          const SizedBox(height: 14),
          const Text(
            'Mis direcciones',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Guarda tus direcciones para comprar y vender mas rapido.',
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
              icon: const Icon(Icons.add_location_alt),
              label: const Text('Agregar nueva direccion'),
              style: FilledButton.styleFrom(
                backgroundColor: _AddressesScreenState._accentColor,
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

class _AddressCard extends StatelessWidget {
  final UserAddress address;
  final VoidCallback? onSetDefault;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.onDelete,
    this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _AddressesScreenState._softColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: address.isDefault
              ? _AddressesScreenState._accentColor.withValues(alpha: 0.35)
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
                child: const Icon(
                  Icons.home_work,
                  color: _AddressesScreenState._primaryColor,
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
                          address.label,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (address.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _AddressesScreenState._accentColor
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Predeterminada',
                              style: TextStyle(
                                color: _AddressesScreenState._accentColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      address.formattedAddress,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (address.receiverName != null || address.phone.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Recibe: ${address.receiverName ?? '-'}'
              '${address.phone.isNotEmpty ? ' - ${address.phone}' : ''}',
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (address.reference != null) ...[
            const SizedBox(height: 8),
            Text(
              address.reference!,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              if (onSetDefault != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSetDefault,
                    icon: const Icon(Icons.star_border),
                    label: const Text('Predeterminada'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _AddressesScreenState._primaryColor,
                      side: const BorderSide(
                        color: _AddressesScreenState._primaryColor,
                      ),
                    ),
                  ),
                ),
              if (onSetDefault != null) const SizedBox(width: 10),
              IconButton.filledTonal(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
                tooltip: 'Eliminar direccion',
              ),
            ],
          ),
        ],
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
          color: _AddressesScreenState._primaryColor,
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
        color: _AddressesScreenState._softColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.add_location_alt_outlined,
            size: 46,
            color: _AddressesScreenState._primaryColor,
          ),
          const SizedBox(height: 12),
          const Text(
            'Todavia no tenes direcciones guardadas.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Agrega una para usarla en compras y publicaciones.',
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
            label: const Text('Agregar nueva direccion'),
            style: FilledButton.styleFrom(
              backgroundColor: _AddressesScreenState._accentColor,
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
