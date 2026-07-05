import 'package:flutter/material.dart';

import '../../auth/services/auth_services_instance.dart';
import '../models/user_payment_method.dart';
import '../service/user_payment_method_service_instance.dart';

class PaymentMethodFormScreen extends StatefulWidget {
  const PaymentMethodFormScreen({super.key});

  @override
  State<PaymentMethodFormScreen> createState() =>
      _PaymentMethodFormScreenState();
}

class _PaymentMethodFormScreenState extends State<PaymentMethodFormScreen> {
  static const Color _primaryColor = Color(0xff2D006B);
  static const Color _accentColor = Color(0xff168BEE);
  static const Color _fieldColor = Color(0xffF2F4F7);

  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _senderAliasController = TextEditingController();
  final _senderCbuController = TextEditingController();

  String _method = 'mercado_pago';
  bool _isDefault = false;
  bool _isSaving = false;
  bool _didReadArgs = false;
  UserPaymentMethod? _editingPaymentMethod;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didReadArgs) return;
    _didReadArgs = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is UserPaymentMethod) {
      _editingPaymentMethod = args;
      _method = args.method == 'transfer' ? 'transfer' : 'mercado_pago';
      _labelController.text = args.label;
      _senderAliasController.text = args.senderAlias ?? '';
      _senderCbuController.text = args.senderCbu ?? '';
      _isDefault = args.isDefault;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _senderAliasController.dispose();
    _senderCbuController.dispose();
    super.dispose();
  }

  Future<void> _savePaymentMethod() async {
    FocusScope.of(context).unfocus();

    if (!authServices.isLoggeIn || authServices.token == null) {
      _showMessage('Inicia sesion para guardar un metodo de pago');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final payload = <String, dynamic>{
      'method': _method,
      'label': _labelController.text.trim(),
      'isDefault': _isDefault,
    };

    if (_method == 'transfer') {
      _addIfNotEmpty(payload, 'senderAlias', _senderAliasController.text);
      _addIfNotEmpty(payload, 'senderCbu', _senderCbuController.text);
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (_editingPaymentMethod == null) {
        await userPaymentMethodService.createPaymentMethod(payload);
      } else {
        await userPaymentMethodService.updatePaymentMethod(
          id: _editingPaymentMethod!.id,
          payload: payload,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editingPaymentMethod == null
                ? 'Metodo de pago guardado'
                : 'Metodo de pago actualizado',
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (error) {
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _addIfNotEmpty(Map<String, dynamic> payload, String key, String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) {
      payload[key] = trimmed;
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa $fieldName';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingPaymentMethod != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEditing ? 'Editar metodo' : 'Agregar metodo'),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: _primaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
            children: [
              Text(
                isEditing ? 'Editar metodo de pago' : 'Nuevo metodo de pago',
                style: const TextStyle(
                  color: _primaryColor,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Guarda opciones para elegirlas al confirmar una compra.',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              _MethodSelector(
                value: _method,
                onChanged: (value) {
                  setState(() {
                    _method = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _PaymentField(
                controller: _labelController,
                label: 'Etiqueta',
                hint: _method == 'transfer'
                    ? 'Transferencia Banco Nacion'
                    : 'Mercado Pago',
                icon: Icons.bookmark_border,
                validator: (value) => _requiredValidator(value, 'una etiqueta'),
              ),
              if (_method == 'transfer') ...[
                _PaymentField(
                  controller: _senderAliasController,
                  label: 'Alias de origen',
                  hint: 'Opcional',
                  icon: Icons.alternate_email,
                ),
                _PaymentField(
                  controller: _senderCbuController,
                  label: 'CBU/CVU de origen',
                  hint: 'Opcional',
                  icon: Icons.account_balance,
                  keyboardType: TextInputType.number,
                ),
              ],
              if (_method == 'mercado_pago')
                const _SecurityNote(),
              const SizedBox(height: 4),
              SwitchListTile(
                value: _isDefault,
                onChanged: (value) {
                  setState(() {
                    _isDefault = value;
                  });
                },
                activeThumbColor: _accentColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                title: const Text(
                  'Usar como metodo predeterminado',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _savePaymentMethod,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_isSaving ? 'Guardando...' : 'Guardar metodo'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _accentColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _accentColor.withValues(
                      alpha: 0.55,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _MethodSelector({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: 'mercado_pago',
          icon: Icon(Icons.account_balance_wallet_outlined),
          label: Text('Mercado Pago'),
        ),
        ButtonSegment(
          value: 'transfer',
          icon: Icon(Icons.swap_horiz),
          label: Text('Transferencia'),
        ),
      ],
      selected: {value},
      onSelectionChanged: (selection) {
        onChanged(selection.first);
      },
    );
  }
}

class _SecurityNote extends StatelessWidget {
  const _SecurityNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffF2F4F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline,
            color: _PaymentMethodFormScreenState._primaryColor,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'No guardamos numeros completos de tarjeta ni codigos de seguridad.',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _PaymentField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: _PaymentMethodFormScreenState._fieldColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: _PaymentMethodFormScreenState._accentColor,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
      ),
    );
  }
}
