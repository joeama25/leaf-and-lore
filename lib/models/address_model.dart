class AddressModel {
  final int? id;
  final int userId;
  final String? label;
  final String street;
  final String city;
  final String state;
  final String? zip;
  final String country;

  AddressModel({
    this.id,
    required this.userId,
    this.label,
    required this.street,
    required this.city,
    required this.state,
    this.zip,
    required this.country,
  });

  String get oneLine =>
      '$street, $city, $state${zip != null ? ", $zip" : ""}';

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'label': label,
    'street': street,
    'city': city,
    'state': state,
    'zip': zip,
    'country': country,
  };

  factory AddressModel.fromMap(Map<String, dynamic> map) => AddressModel(
    id: map['id'] as int?,
    userId: map['user_id'] as int,
    label: map['label'] as String?,
    street: map['street'] as String,
    city: map['city'] as String,
    state: map['state'] as String,
    zip: map['zip'] as String?,
    country: map['country'] as String,
  );
}