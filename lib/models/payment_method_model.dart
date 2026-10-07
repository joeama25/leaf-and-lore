class PaymentMethodModel {
  final int? id;
  final int userId;
  final String cardHolder;
  final String cardNumber;   // store last 4 digits only
  final String expiry;       // MM/YY
  final String? brand;       // Visa / Mastercard

  PaymentMethodModel({
    this.id,
    required this.userId,
    required this.cardHolder,
    required this.cardNumber,
    required this.expiry,
    this.brand,
  });

  String get last4 =>
      cardNumber.length >= 4 ? cardNumber.substring(cardNumber.length - 4) : cardNumber;

  String get masked => '${brand ?? "Card"} ending in $last4';

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'card_holder': cardHolder,
    'card_number': cardNumber,
    'expiry': expiry,
    'brand': brand,
  };

  factory PaymentMethodModel.fromMap(Map<String, dynamic> map) => PaymentMethodModel(
    id: map['id'] as int?,
    userId: map['user_id'] as int,
    cardHolder: map['card_holder'] as String,
    cardNumber: map['card_number'] as String,
    expiry: map['expiry'] as String,
    brand: map['brand'] as String?,
  );
}