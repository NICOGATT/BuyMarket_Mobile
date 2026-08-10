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
  bool _isSendingVerification = false;
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
      if (authServices.user == null) {
        setState(() {
          _error = error.toString().replaceFirst('Exception: ', '');
        });
      }
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Informacion personal'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
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
                    _PersonalDataCard(
                      user: user,
                      onEdit: () => _editProfile(user),
                    ),
                    const SizedBox(height: 14),
                    _SecurityCard(
                      user: user,
                      isSendingEmailCode: _isSendingVerification,
                      onVerifyEmail: user.isEmailVerified
                          ? null
                          : _startEmailVerification,
                      onVerifyPhone: _showPhoneVerificationUnavailable,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _editProfile(AuthUser user) async {
    final updatedUser = await showModalBottomSheet<AuthUser>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(user: user),
    );
    if (!mounted || updatedUser == null) return;

    setState(() {
      _freshUser = updatedUser;
      _error = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Información actualizada.')),
    );
  }

  Future<void> _startEmailVerification() async {
    setState(() => _isSendingVerification = true);
    try {
      final message = await authServices.sendEmailVerificationCode();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      final verified = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const _EmailVerificationDialog(),
      );
      if (!mounted || verified != true) return;
      setState(() => _freshUser = authServices.user);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSendingVerification = false);
    }
  }

  void _showPhoneVerificationUnavailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'La verificación telefónica todavía no está disponible en el servidor.',
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
            child: Icon(
              Icons.person,
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
  final VoidCallback onEdit;

  const _PersonalDataCard({required this.user, required this.onEdit});

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
        _InfoRow(label: 'Teléfono', value: _fallback(user.phone)),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Editar información'),
          ),
        ),
      ],
    );
  }
}

class _SecurityCard extends StatelessWidget {
  final AuthUser user;
  final bool isSendingEmailCode;
  final VoidCallback? onVerifyEmail;
  final VoidCallback onVerifyPhone;

  const _SecurityCard({
    required this.user,
    required this.isSendingEmailCode,
    required this.onVerifyEmail,
    required this.onVerifyPhone,
  });

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
        if (!isVerified) ...[
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: isSendingEmailCode ? null : onVerifyEmail,
            icon: isSendingEmailCode
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.mark_email_read_outlined),
            label: Text(
              isSendingEmailCode ? 'Enviando...' : 'Verificar email',
            ),
          ),
        ],
        const Divider(height: 32),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estado del teléfono',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    user.phone.isEmpty ? 'Sin teléfono informado' : user.phone,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            _VerificationBadge(isVerified: user.isPhoneVerified),
          ],
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: onVerifyPhone,
          icon: const Icon(Icons.phone_android_outlined),
          label: const Text('Verificar teléfono'),
        ),
      ],
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  final AuthUser user;

  const _EditProfileSheet({required this.user});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _emailController = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final user = await authServices.updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
      );
      if (mounted) Navigator.pop(context, user);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Editar información',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  textInputAction: TextInputAction.next,
                  validator: _requiredField,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Apellido'),
                  textInputAction: TextInputAction.next,
                  validator: _requiredField,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    helperText:
                        'El email se verifica desde la sección Seguridad.',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: widget.user.phone,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    helperText: 'Requiere habilitación en el servidor.',
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: Text(_isSaving ? 'Guardando...' : 'Guardar cambios'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _requiredField(String? value) {
    return value?.trim().isEmpty == true ? 'Este campo es obligatorio' : null;
  }
}

class _EmailVerificationDialog extends StatefulWidget {
  const _EmailVerificationDialog();

  @override
  State<_EmailVerificationDialog> createState() =>
      _EmailVerificationDialogState();
}

class _EmailVerificationDialogState
    extends State<_EmailVerificationDialog> {
  final _codeController = TextEditingController();
  bool _isVerifying = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'Ingresá el código de 6 dígitos.');
      return;
    }

    setState(() {
      _isVerifying = true;
      _error = null;
    });
    try {
      await authServices.verifyEmail(code);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Verificar email'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Ingresá el código de 6 dígitos que enviamos a tu email.'),
          const SizedBox(height: 16),
          TextField(
            controller: _codeController,
            autofocus: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (!_isVerifying) _verify();
            },
            decoration: InputDecoration(
              labelText: 'Código',
              errorText: _error,
              counterText: '',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isVerifying
              ? null
              : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isVerifying ? null : _verify,
          child: Text(_isVerifying ? 'Verificando...' : 'Verificar'),
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
