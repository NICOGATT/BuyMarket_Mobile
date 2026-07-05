class UserAddress {
  final String id;
  final String label;
  final String? receiverName;
  final String phone;
  final String street;
  final String number;
  final String? floor;
  final String? apartment;
  final String city;
  final String province;
  final String postalCode;
  final String? reference;
  final bool isDefault;

  const UserAddress({
    required this.id,
    required this.label,
    required this.phone,
    required this.street,
    required this.number,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.isDefault,
    this.receiverName,
    this.floor,
    this.apartment,
    this.reference,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: _readString(json, 'id'),
      label: _readString(json, 'label'),
      receiverName: _readNullableString(json, 'receiverName'),
      phone: _readString(json, 'phone'),
      street: _readString(json, 'street'),
      number: _readString(json, 'number'),
      floor: _readNullableString(json, 'floor'),
      apartment: _readNullableString(json, 'apartment'),
      city: _readString(json, 'city'),
      province: _readString(json, 'province'),
      postalCode: _readString(json, 'postalCode'),
      reference: _readNullableString(json, 'reference'),
      isDefault: json['isDefault'] == true,
    );
  }

  String get formattedAddress {
    final apartmentText = [
      if (floor != null && floor!.trim().isNotEmpty) 'Piso $floor',
      if (apartment != null && apartment!.trim().isNotEmpty) 'Depto $apartment',
    ].join(' ');

    final streetLine = [
      '$street $number'.trim(),
      if (apartmentText.isNotEmpty) apartmentText,
    ].join(', ');

    return '$streetLine, $city, $province ($postalCode)';
  }

  static String _readString(Map<String, dynamic> json, String key) {
    return json[key]?.toString() ?? '';
  }

  static String? _readNullableString(Map<String, dynamic> json, String key) {
    final value = json[key]?.toString().trim();
    return value == null || value.isEmpty ? null : value;
  }
}
