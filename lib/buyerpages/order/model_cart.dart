class CartItem {
  final String vegetableId;
  final String vegetableName;
  final double quantity;
  final double totalPrice;

  CartItem({
    required this.vegetableId,
    required this.vegetableName,
    required this.quantity,
    required this.totalPrice,
  });

  factory CartItem.fromMap(Map<dynamic, dynamic> map) {
    return CartItem(
      vegetableId: map['vegetableId'] ?? '',
      vegetableName: map['name_veg'] ?? '',
      quantity: (map['quantity'] is int)
          ? (map['quantity'] as int).toDouble() // Convert int to double
          : (map['quantity'] as double? ?? 0.0), // Use double if available, default to 0.0
      totalPrice: (map['total_price'] is int)
          ? (map['total_price'] as int).toDouble() // Convert int to double
          : (map['total_price'] as double? ?? 0.0), // Use double if available, default to 0.0
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vegetableId': vegetableId,
      'name_veg': vegetableName,
      'quantity': quantity,
      'total_price': totalPrice,
    };
  }
}
