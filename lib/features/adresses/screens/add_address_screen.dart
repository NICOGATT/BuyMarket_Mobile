import 'package:flutter/material.dart';

import '../../auth/services/auth_services_instance.dart';
import '../services/user_address_service_instance.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  static const Color _primaryColor = Color(0xff2D006B);
  static const Color _accentColor = Color(0xff168BEE);
  static const Color _fieldColor = Color(0xffF2F4F7);

  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _receiverNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _floorController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _referenceController = TextEditingController();

  bool _isDefault = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _labelController.dispose();
    _receiverNameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _floorController.dispose();
    _apartmentController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    FocusScope.of(context).unfocus();

    if (!authServices.isLoggeIn || authServices.token == null) {
      _showMessage('Inicia sesion para guardar una direccion');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final payload = <String, dynamic>{
      'label': _labelController.text.trim(),
      'phone': _phoneController.text.trim(),
      'street': _streetController.text.trim(),
      'number': _numberController.text.trim(),
      'postalCode': _postalCodeController.text.trim(),
      'city': _cityController.text.trim(),
      'province': _provinceController.text.trim(),
      'isDefault': _isDefault,
    };

    _addIfNotEmpty(payload, 'receiverName', _receiverNameController.text);
    _addIfNotEmpty(payload, 'floor', _floorController.text);
    _addIfNotEmpty(payload, 'apartment', _apartmentController.text);
    _addIfNotEmpty(payload, 'reference', _referenceController.text);

    setState(() {
      _isSaving = true;
    });

    try {
      await userAddressService.createAddress(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Direccion guardada')));
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Agregar nueva direccion'),
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
              const Text(
                'Nueva direccion',
                style: TextStyle(
                  color: _primaryColor,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Completa los datos para guardar esta direccion en tu cuenta.',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              _AddressField(
                controller: _labelController,
                label: 'Etiqueta',
                hint: 'Casa, Trabajo, Local',
                icon: Icons.bookmark_border,
                validator: (value) => _requiredValidator(value, 'una etiqueta'),
              ),
              _AddressField(
                controller: _receiverNameController,
                label: 'Nombre de quien recibe',
                hint: 'Opcional',
                icon: Icons.person_outline,
              ),
              _AddressField(
                controller: _phoneController,
                label: 'Telefono de contacto',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) => _requiredValidator(value, 'un telefono'),
              ),
              _AddressField(
                controller: _streetController,
                label: 'Calle',
                icon: Icons.signpost_outlined,
                validator: (value) => _requiredValidator(value, 'la calle'),
              ),
              Row(
                children: [
                  Expanded(
                    child: _AddressField(
                      controller: _numberController,
                      label: 'Numero',
                      icon: Icons.numbers,
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          _requiredValidator(value, 'el numero'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AddressField(
                      controller: _postalCodeController,
                      label: 'Codigo postal',
                      icon: Icons.local_post_office_outlined,
                      validator: (value) =>
                          _requiredValidator(value, 'el codigo postal'),
                    ),
                  ),
                ],
              ),
              _AddressField(
                controller: _cityController,
                label: 'Ciudad',
                icon: Icons.location_city_outlined,
                validator: (value) =>
                    _requiredValidator(value, 'la ciudad o localidad'),
              ),
              _AddressField(
                controller: _provinceController,
                label: 'Provincia',
                icon: Icons.map_outlined,
                validator: (value) => _requiredValidator(value, 'la provincia'),
              ),
              Row(
                children: [
                  Expanded(
                    child: _AddressField(
                      controller: _floorController,
                      label: 'Piso',
                      hint: 'Opcional',
                      icon: Icons.stairs_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AddressField(
                      controller: _apartmentController,
                      label: 'Depto',
                      hint: 'Opcional',
                      icon: Icons.apartment_outlined,
                    ),
                  ),
                ],
              ),
              _AddressField(
                controller: _referenceController,
                label: 'Referencia para el repartidor',
                hint: 'Opcional',
                icon: Icons.notes_outlined,
                maxLines: 3,
              ),
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
                  'Usar como direccion predeterminada',
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
                  onPressed: _isSaving ? null : _saveAddress,
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
                  label: Text(_isSaving ? 'Guardando...' : 'Guardar direccion'),
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

class _AddressField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _AddressField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: _AddAddressScreenState._fieldColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: _AddAddressScreenState._accentColor,
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
