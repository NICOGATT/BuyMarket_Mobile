import 'package:flutter/material.dart';

import '../models/sub_category_attribute.dart';

class DynamicAttributeFields extends StatelessWidget {
  final List<SubCategoryAttribute> attributes;
  final Map<String, dynamic> values;
  final void Function(SubCategoryAttribute attribute, dynamic value) onChanged;

  const DynamicAttributeFields({
    super.key,
    required this.attributes,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (attributes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: attributes.map(_buildField).toList(),
    );
  }

  Widget _buildField(SubCategoryAttribute attribute) {
    switch (attribute.type) {
      case 'number':
        return _NumberAttributeField(
          key: ValueKey(attribute.id),
          attribute: attribute,
          value: values[attribute.id],
          onChanged: (value) => onChanged(attribute, value),
        );
      case 'select':
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: DropdownButtonFormField<String>(
            value: values[attribute.id]?.toString().isNotEmpty == true
                ? values[attribute.id].toString()
                : null,
            decoration: _decoration(attribute.name),
            items: attribute.options
                .map(
                  (option) => DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  ),
                )
                .toList(),
            validator: (value) =>
                attribute.isRequired && (value == null || value.isEmpty)
                    ? 'Campo requerido'
                    : null,
            onChanged: (value) => onChanged(attribute, value),
          ),
        );
      case 'boolean':
        return Card(
          elevation: 0,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SwitchListTile(
            title: Text(attribute.name),
            value: values[attribute.id] == true,
            onChanged: (value) => onChanged(attribute, value),
          ),
        );
      case 'text':
      default:
        return _TextAttributeField(
          key: ValueKey(attribute.id),
          attribute: attribute,
          value: values[attribute.id]?.toString() ?? '',
          onChanged: (value) => onChanged(attribute, value),
        );
    }
  }

  static InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class _TextAttributeField extends StatefulWidget {
  final SubCategoryAttribute attribute;
  final String value;
  final ValueChanged<String> onChanged;

  const _TextAttributeField({
    super.key,
    required this.attribute,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_TextAttributeField> createState() => _TextAttributeFieldState();
}

class _TextAttributeFieldState extends State<_TextAttributeField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: _controller,
        decoration: DynamicAttributeFields._decoration(widget.attribute.name),
        validator: (value) =>
            widget.attribute.isRequired &&
                    (value == null || value.trim().isEmpty)
                ? 'Campo requerido'
                : null,
        onChanged: widget.onChanged,
      ),
    );
  }
}

class _NumberAttributeField extends StatefulWidget {
  final SubCategoryAttribute attribute;
  final dynamic value;
  final ValueChanged<num?> onChanged;

  const _NumberAttributeField({
    super.key,
    required this.attribute,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_NumberAttributeField> createState() => _NumberAttributeFieldState();
}

class _NumberAttributeFieldState extends State<_NumberAttributeField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value?.toString() ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: DynamicAttributeFields._decoration(widget.attribute.name),
        validator: (value) {
          if (widget.attribute.isRequired &&
              (value == null || value.isEmpty)) {
            return 'Campo requerido';
          }
          if (value != null && value.isNotEmpty && num.tryParse(value) == null) {
            return 'Ingresa un numero valido';
          }
          return null;
        },
        onChanged: (value) => widget.onChanged(num.tryParse(value)),
      ),
    );
  }
}
