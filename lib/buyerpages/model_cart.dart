class CartItem {
  final String vegetableId;
  final String vegetableName;
  final int quantity;
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
      quantity: map['quantity'] ?? 0,
      totalPrice: (map['total_price'] is int)
          ? (map['total_price'] as int).toDouble() // Cast int to double
          : (map['total_price'] ?? 0.0), // Ensure it's a double
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
