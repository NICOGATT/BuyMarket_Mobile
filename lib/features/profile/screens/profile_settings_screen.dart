import 'package:flutter/material.dart';

import '../../auth/models/auth_user.dart';
import '../../auth/services/auth_services_instance.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  static const Color _primaryColor = Color(0xff2D006B);
  static const Color _surfaceColor = Color(0xffF2F4F7);

  AuthUser? _freshUser;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshUser();
    });
  }

  Future<void> _refreshUser() async {
    if (!authServices.isLoggeIn || authServices.token == null) {
      setState(() {
        _error = 'Inicia sesion para ver tu informacion personal';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final refreshedUser = await authServices.refreshCurrentUser();
      if (!mounted) return;
      setState(() {
        _freshUser = refreshedUser;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Informacion personal'),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: _primaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: authServices,
          builder: (context, child) {
            final user = _freshUser ?? authServices.user;

            if (_isLoading && user == null) {
              return const Center(
                child: CircularProgressIndicator(color: _primaryColor),
              );
            }

            return RefreshIndicator(
              onRefresh: _refreshUser,
              color: _primaryColor,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                children: [
                  if (_error != null) ...[
                    _ErrorBanner(message: _error!),
                    const SizedBox(height: 14),
                  ],
                  if (user == null)
                    const _EmptyUserState()
                  else ...[
                    _ProfileHeader(user: user, isRefreshing: _isLoading),
                    const SizedBox(height: 18),
                    _PersonalDataCard(user: user),
                    const SizedBox(height: 14),
                    _SecurityCard(user: user),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final AuthUser user;
  final bool isRefreshing;

  const _ProfileHeader({required this.user, required this.isRefreshing});

  @override
  Widget build(BuildContext context) {
    final displayName = _displayName(user);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _ProfileSettingsScreenState._primaryColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 34,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              color: _ProfileSettingsScreenState._primaryColor,
              size: 40,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
              ],
            ),
          ),
          if (isRefreshing)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

class _PersonalDataCard extends StatelessWidget {
  final AuthUser user;

  const _PersonalDataCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.badge_outlined,
      title: 'Datos del usuario',
      children: [
        _InfoRow(label: 'Nombre', value: _fallback(user.firstName)),
        _InfoRow(
          label: 'Apellido',
          value: _fallback(
            user.lastName,
            emptyText: 'No recibido desde el servidor',
          ),
        ),
        _InfoRow(label: 'Email', value: _fallback(user.email)),
      ],
    );
  }
}

class _SecurityCard extends StatelessWidget {
  final AuthUser user;

  const _SecurityCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final isVerified = user.isEmailVerified;

    return _InfoCard(
      icon: Icons.shield_outlined,
      title: 'Seguridad',
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estado del email',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    user.email.isEmpty ? 'Sin email informado' : user.email,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _VerificationBadge(isVerified: isVerified),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          isVerified
              ? 'Tu email esta verificado y la cuenta tiene una capa extra de seguridad.'
              : 'Tu email todavia figura como pendiente de verificacion.',
          style: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _ProfileSettingsScreenState._surfaceColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: _ProfileSettingsScreenState._primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationBadge extends StatelessWidget {
  final bool isVerified;

  const _VerificationBadge({required this.isVerified});

  @override
  Widget build(BuildContext context) {
    final color = isVerified ? Colors.green : Colors.orange;
    final label = isVerified ? 'Verificado' : 'Pendiente';
    final icon = isVerified ? Icons.check_circle : Icons.schedule;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
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

class _EmptyUserState extends StatelessWidget {
  const _EmptyUserState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _ProfileSettingsScreenState._surfaceColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 46,
            color: _ProfileSettingsScreenState._primaryColor,
          ),
          SizedBox(height: 12),
          Text(
            'No hay datos de usuario disponibles.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Volver a iniciar sesion puede actualizar la informacion.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

String _displayName(AuthUser user) {
  final fullName = [
    user.firstName,
    user.lastName,
  ].where((value) => value.trim().isNotEmpty).join(' ');

  return fullName.isNotEmpty ? fullName : 'Usuario BuyMarket';
}

String _fallback(String value, {String emptyText = 'No informado'}) {
  return value.trim().isEmpty ? emptyText : value.trim();
}
