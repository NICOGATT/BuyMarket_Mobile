import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/routes/app_routes.dart';
import '../../auth/services/auth_services_instance.dart';
import '../services/profile_avatar_service.dart';
import 'profile_photo_crop_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const Color _primaryColor = Color(0xff2D006B);
  static const Color _accentColor = Color(0xff5E2CA5);
  static const Color _quickActionColor = Color(0xffEEE6FF);
  static const Color _menuItemColor = Color(0xffF2F4F7);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _selectedPlanKey = 'selected_membership_plan';

  String _currentPlan = 'free';

  @override
  void initState() {
    super.initState();
    _loadSelectedPlan();
  }

  Future<void> _loadSelectedPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPlan = prefs.getString(_selectedPlanKey);
    final selectedPlan = switch (savedPlan) {
      'plus' => 'plus',
      'premium' => 'premium',
      _ => 'free',
    };
    if (!mounted || selectedPlan == _currentPlan) return;
    setState(() => _currentPlan = selectedPlan);
  }

  String? get _currentPlanAssetPath => switch (_currentPlan) {
    'plus' => 'assets/images/plans/plan_plus.png',
    'premium' => 'assets/images/plans/plan_premium.png',
    _ => null,
  };

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
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProfileHeader(
                    name: displayName,
                    userId: user?.id ?? user?.email ?? 'current-user',
                  ),
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
                          Navigator.pushNamed(context, AppRoutes.coupons);
                        },
                      ),
                      _QuickActionData(
                        icon: Icons.auto_awesome,
                        assetPath: _currentPlanAssetPath,
                        title: 'Mi plan',
                        onTap: () async {
                          await Navigator.pushNamed(context, AppRoutes.plans);
                          await _loadSelectedPlan();
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
                      Navigator.pushNamed(context, AppRoutes.wallet);
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
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 48,
                  child: Icon(Icons.person, size: 54),
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
                      Navigator.pushNamed(context, AppRoutes.login);
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
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.register);
                  },
                  child: const Text(
                    '¿No tienes cuenta?',
                    style: TextStyle(
                      color: ProfileScreen._primaryColor,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
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

class _ProfileHeader extends StatefulWidget {
  final String name;
  final String userId;

  const _ProfileHeader({required this.name, required this.userId});

  @override
  State<_ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<_ProfileHeader> {
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _photoBytes;
  bool _isPickingPhoto = false;

  @override
  void initState() {
    super.initState();
    profileAvatarService.addListener(_syncPhoto);
    _loadPhoto();
  }

  @override
  void dispose() {
    profileAvatarService.removeListener(_syncPhoto);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ProfileHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) _loadPhoto();
  }

  Future<void> _loadPhoto() async {
    await profileAvatarService.load(widget.userId);
    _syncPhoto();
  }

  void _syncPhoto() {
    if (!mounted || !profileAvatarService.isLoadedFor(widget.userId)) return;
    setState(() => _photoBytes = profileAvatarService.photoBytes);
  }

  Future<void> _showPhotoOptions() async {
    if (_isPickingPhoto) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Foto de perfil',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tomar una foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            if (_photoBytes != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Eliminar foto',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _removePhoto();
                },
              ),
          ],
        ),
      ),
    );
    if (source != null) await _pickPhoto(source);
  }

  Future<void> _pickPhoto(ImageSource source) async {
    setState(() => _isPickingPhoto = true);
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 82,
      );
      if (image == null) return;

      final originalBytes = await image.readAsBytes();
      if (!mounted) return;
      final bytes = await Navigator.push<Uint8List>(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => ProfilePhotoCropScreen(imageBytes: originalBytes),
        ),
      );
      if (bytes == null) return;

      await profileAvatarService.save(widget.userId, bytes);
    } catch (error, stackTrace) {
      debugPrint('PROFILE PHOTO ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo abrir el editor. Cerrá y volvé a iniciar la app.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isPickingPhoto = false);
    }
  }

  Future<void> _removePhoto() async {
    await profileAvatarService.remove(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 46,
              backgroundImage: _photoBytes == null
                  ? null
                  : MemoryImage(_photoBytes!),
              child: _photoBytes == null
                  ? const Icon(Icons.person, size: 56)
                  : null,
            ),
            Positioned(
              right: -3,
              bottom: -3,
              child: Material(
                color: ProfileScreen._accentColor,
                shape: const CircleBorder(),
                elevation: 3,
                child: InkWell(
                  key: const Key('profile-photo-edit-button'),
                  onTap: _isPickingPhoto ? null : _showPhotoOptions,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: _isPickingPhoto
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.edit, size: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          widget.name,
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

  const _QuickActions({required this.actions});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < actions.length; index++) ...[
          Expanded(child: _QuickActionCard(action: actions[index])),
          if (index != actions.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final _QuickActionData action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Material(
        color: ProfileScreen._quickActionColor,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: action.onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (action.assetPath != null)
                  Image.asset(
                    action.assetPath!,
                    width: 46,
                    height: 46,
                    fit: BoxFit.contain,
                  )
                else
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
      ),
    );
  }
}

class _ProfileSectionTitle extends StatelessWidget {
  final String title;

  const _ProfileSectionTitle({required this.title});

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
    final effectiveColor =
        foregroundColor ??
        (isHighlighted
            ? ProfileScreen._accentColor
            : ProfileScreen._primaryColor);

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
            leading: Icon(icon, color: effectiveColor),
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
  final String? assetPath;
  final String title;
  final VoidCallback onTap;

  const _QuickActionData({
    required this.icon,
    required this.title,
    required this.onTap,
    this.assetPath,
  });
}
