import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'payment_page.dart'; // Import payment page
import 'model_cart.dart'; // Import the CartItem model

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  User? currentFirebaseUser;
  final DatabaseReference ordersRef =
      FirebaseDatabase.instance.ref().child("orders");

  @override
  void initState() {
    super.initState();
    currentFirebaseUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    if (currentFirebaseUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("No User Logged In"),
        ),
        body: const Center(
          child: Text("Please log in to view your cart."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<DatabaseEvent>(
        future: ordersRef.child(currentFirebaseUser!.uid).once(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print("Error fetching cart: ${snapshot.error}");
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("Your cart is empty."));
          }

          Map<dynamic, dynamic> ordersData =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          print("Orders Data: $ordersData"); // Debug print
          List<Widget> orderWidgets = [];

          ordersData.forEach((sellerId, vegetables) {
            print("Processing Seller ID: $sellerId"); // Debug print
            double totalSellerPrice = 0;

            vegetables.forEach((vegId, vegInfo) {
              print("Processing Vegetable ID: $vegId"); // Debug print
              CartItem cartItem = CartItem.fromMap({
                'vegetableId': vegId,
                'name_veg': vegInfo['name_veg'],
                'quantity': vegInfo['quantity'],
                'total_price': vegInfo['total_price'],
              });
              totalSellerPrice += cartItem.totalPrice;

              orderWidgets.add(ListTile(
                title: Text(
                    "${cartItem.vegetableName} (Quantity: ${cartItem.quantity})"),
                subtitle: Text("Total Price: LKR ${cartItem.totalPrice}"),
              ));
            });

            // Add the pay button after the total price for the seller
            orderWidgets.add(ListTile(
              title: Text(
                  "Total Price for Seller $sellerId: LKR $totalSellerPrice"),
              subtitle: const Text(""),
              tileColor: Colors.grey.shade200,
              trailing: ElevatedButton(
                onPressed: () {
                  // Navigate to payment page with seller ID and total price
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentPage(
                        sellerId: sellerId,
                        totalAmount: totalSellerPrice,
                      ),
                    ),
                  );
                },
                child: const Text("Pay"),
              ),
            ));
          });

          return ListView(children: orderWidgets);
        },
      ),
    );
  }
}
