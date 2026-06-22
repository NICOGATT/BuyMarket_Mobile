import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../auth/services/auth_services_instance.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color _primaryColor = Color(0xff2D006B);
  static const Color _accentColor = Color(0xff168BEE);
  static const Color _quickActionColor = Color(0xffDFF4FF);
  static const Color _menuItemColor = Color(0xffF2F4F7);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authServices,
      builder: (context, child) {
        if (!authServices.isLoggeIn) {
          return const _GuestProfile();
        }

        final user = authServices.user;
        final displayName = _buildDisplayName(
          firstName: user?.firstName,
          lastName: user?.lastName,
        );

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProfileHeader(name: displayName),
                  const SizedBox(height: 24),
                  _QuickActions(
                    actions: [
                      _QuickActionData(
                        icon: Icons.person,
                        title: 'Informacion personal',
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.profileSettings,
                          );
                        },
                      ),
                      _QuickActionData(
                        icon: Icons.confirmation_number,
                        title: 'Cupones',
                        onTap: () {
                          // TODO: conectar con la ruta de cupones cuando exista.
                        },
                      ),
                      _QuickActionData(
                        icon: Icons.workspace_premium,
                        title: 'Mi plan',
                        onTap: () {
                          // TODO: conectar con la ruta de planes cuando exista.
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const _ProfileSectionTitle(title: 'Billetera'),
                  _ProfileMenuItem(
                    icon: Icons.account_balance_wallet,
                    title: 'Billetera',
                    isHighlighted: true,
                    onTap: () {
                      // TODO: conectar con la ruta de billetera cuando exista.
                    },
                  ),
                  const SizedBox(height: 18),
                  const _ProfileSectionTitle(title: 'Compras'),
                  _ProfileMenuItem(
                    icon: Icons.location_on,
                    title: 'Direcciones',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.addresses);
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.shopping_bag,
                    title: 'Mis compras',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.myOrders);
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.local_shipping,
                    title: 'Seguimiento de pedidos',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.myOrders);
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.assignment_return,
                    title: 'Devoluciones',
                    onTap: () {
                      // TODO: conectar con la ruta de devoluciones cuando exista.
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.support_agent,
                    title: 'Soporte',
                    onTap: () {
                      // TODO: conectar con la ruta de soporte cuando exista.
                    },
                  ),
                  const SizedBox(height: 18),
                  const _ProfileSectionTitle(title: 'Central de vendedores'),
                  _ProfileMenuItem(
                    icon: Icons.store,
                    title: 'Vender',
                    isHighlighted: true,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.addProduct);
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.inventory_2,
                    title: 'Mis publicaciones',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.myProducts);
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.point_of_sale,
                    title: 'Ventas realizadas',
                    onTap: () {
                      // TODO: conectar con la ruta de ventas realizadas cuando exista.
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.sell,
                    title: 'Crear cupon',
                    onTap: () {
                      // TODO: conectar con la ruta para crear cupones cuando exista.
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.campaign,
                    title: 'Promocionar',
                    onTap: () {
                      // TODO: conectar con la ruta de promociones cuando exista.
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.receipt_long,
                    title: 'Facturacion',
                    onTap: () {
                      // TODO: conectar con la ruta de facturacion cuando exista.
                    },
                  ),
                  const SizedBox(height: 18),
                  _ProfileMenuItem(
                    icon: Icons.credit_card,
                    title: 'Metodos de pago',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.paymentMethods);
                    },
                  ),
                  const SizedBox(height: 18),
                  _ProfileMenuItem(
                    icon: Icons.logout,
                    title: 'Cerrar sesion',
                    foregroundColor: Colors.red,
                    onTap: () async {
                      await authServices.logout();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static String _buildDisplayName({
    required String? firstName,
    required String? lastName,
  }) {
    final fullName = [
      firstName,
      lastName,
    ].where((value) => value != null && value.trim().isNotEmpty).join(' ');

    if (fullName.isNotEmpty) {
      return fullName;
    }

    return 'Usuario BuyMarket';
  }
}

class _GuestProfile extends StatelessWidget {
  const _GuestProfile();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 48,
                  backgroundColor: ProfileScreen._quickActionColor,
                  child: Icon(
                    Icons.person,
                    size: 54,
                    color: ProfileScreen._primaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'No has iniciado sesion',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ProfileScreen._primaryColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Ingresa para ver tus compras, ventas y configuracion.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.authWelcome);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ProfileScreen._accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Iniciar sesion',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;

  const _ProfileHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 46,
          backgroundColor: ProfileScreen._quickActionColor,
          child: Icon(
            Icons.person,
            color: ProfileScreen._primaryColor,
            size: 56,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: ProfileScreen._primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  final List<_QuickActionData> actions;

  const _QuickActions({
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < actions.length; index++) ...[
          Expanded(
            child: _QuickActionCard(action: actions[index]),
          ),
          if (index != actions.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final _QuickActionData action;

  const _QuickActionCard({
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ProfileScreen._quickActionColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                action.icon,
                color: ProfileScreen._primaryColor,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                action.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ProfileScreen._primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileSectionTitle extends StatelessWidget {
  final String title;

  const _ProfileSectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: ProfileScreen._primaryColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isHighlighted;
  final Color? foregroundColor;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isHighlighted = false,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = foregroundColor ??
        (isHighlighted ? ProfileScreen._accentColor : ProfileScreen._primaryColor);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isHighlighted
            ? ProfileScreen._accentColor.withValues(alpha: 0.10)
            : ProfileScreen._menuItemColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: ListTile(
            minTileHeight: 58,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: Icon(
              icon,
              color: effectiveColor,
            ),
            title: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foregroundColor ?? Colors.black87,
                fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w700,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: foregroundColor ?? Colors.black38,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionData {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionData({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}
