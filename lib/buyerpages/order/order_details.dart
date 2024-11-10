import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../payment/payment_page.dart';
import 'model_cart.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  User? currentFirebaseUser;
  final DatabaseReference ordersRef = FirebaseDatabase.instance.ref().child("orders");
  final DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("Users");

  Map<String, dynamic> sellerDetails = {}; // To store seller details
  Set<String> fetchedSellers = {}; // To track fetched seller IDs
  Map<dynamic, dynamic> ordersData = {}; // To store orders data

  @override
  void initState() {
    super.initState();
    currentFirebaseUser = FirebaseAuth.instance.currentUser;
  }

  // Function to fetch seller details from "Users"
  Future<void> fetchSellerDetails(String sellerId) async {
    if (!fetchedSellers.contains(sellerId)) {
      DataSnapshot snapshot = await usersRef.child(sellerId).get();
      if (snapshot.exists) {
        setState(() {
          sellerDetails[sellerId] = snapshot.value as Map<dynamic, dynamic>;
          fetchedSellers.add(sellerId); // Mark seller as fetched
        });
      }
    }
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
        title: const Text('Your Orders'),
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

          ordersData = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          List<Widget> orderWidgets = [];
          
          ordersData.forEach((sellerId, vegetableData) {
            double totalSellerPrice = 0.0;

            // Fetch seller details from "Users" node only if not already fetched
            fetchSellerDetails(sellerId);

            // Add seller details (ID, name, phone, district), vegetable details, and total price into a single box
            orderWidgets.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Seller details
                      Text(
                        "SellerID: $sellerId",
                        style: const TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      if (sellerDetails.containsKey(sellerId))
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Name: ${sellerDetails[sellerId]['firstname']}",
                              style: const TextStyle(fontSize: 16.0),
                            ),
                            Text(
                              "Phone: ${sellerDetails[sellerId]['phone']}",
                              style: const TextStyle(fontSize: 16.0),
                            ),
                            Text(
                              "District: ${sellerDetails[sellerId]['district']}",
                              style: const TextStyle(fontSize: 16.0),
                            ),
                          ],
                        )
                      else
                        const Text("Loading seller details..."),
                      const Divider(
                        thickness: 1,
                        color: Colors.green,
                      ),

                      // Vegetable details
                      ...vegetableData.entries.map((entry) {
                        String vegId = entry.key;
                        var vegOrders = entry.value as Map<dynamic, dynamic>;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: vegOrders.entries.map((orderEntry) {
                            var orderDetails = orderEntry.value as Map<dynamic, dynamic>;
                            CartItem cartItem = CartItem.fromMap({
                              'name_veg': orderDetails['name_veg'],
                              'quantity': orderDetails['quantity'],
                              'total_price': orderDetails['total_price'],
                            });
                            totalSellerPrice += cartItem.totalPrice;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between items
                                  children: [
                                    Expanded( // Wrap with Expanded to allow for better layout
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            " ${cartItem.vegetableName}",
                                            style: const TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black),
                                          ),
                                          Text(
                                            "Quantity: ${cartItem.quantity.toStringAsFixed(2)} kg",
                                            style: const TextStyle(fontSize: 14.0),
                                          ),
                                          Text(
                                            "Total Price: LKR ${cartItem.totalPrice.toStringAsFixed(2)}",
                                            style: const TextStyle(fontSize: 14.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        // Remove the order from the database
                                        await ordersRef.child(currentFirebaseUser!.uid).child(sellerId).child(vegId).remove();

                                        // Remove the order from the local data
                                        setState(() {
                                          vegetableData.remove(vegId); // Remove the specific vegetable entry
                                          if (vegetableData.isEmpty) {
                                            ordersData.remove(sellerId); // Remove seller if no vegetables left
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15.0),
                              ],
                            );
                          }).toList(),
                        );
                      }).toList(),

                      const Column(
                        children: [
                          SizedBox(height: 10.0), // Add space before total price
                        ],
                      ),

                      // Total price and Pay button in the same box
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total Price : LKR ${totalSellerPrice.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () async {

                                  // Prepare vegetableDetails for PaymentPage
                                  List<Map<String, dynamic>> vegetableDetails = [];

                                  vegetableData.forEach((vegId, vegOrders) {
                                    vegOrders.entries.forEach((orderEntry) {
                                      var orderDetails = orderEntry.value as Map<dynamic, dynamic>;
                                      vegetableDetails.add({
                                        'vegId': vegId,
                                        'name_veg': orderDetails['name_veg'],
                                        'quantity': orderDetails['quantity'],
                                      });


                                    });
                                  });
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PaymentPage(
                                        sellerId: sellerId,
                                        totalAmount: totalSellerPrice,
                                        vegetableDetails: vegetableDetails,
                                      ),
                                    ),
                                  );

                                  setState(() {
                                    // Update state after navigation, if needed
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: const Text("Pay"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });



          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: orderWidgets,
          );
        },
      ),
    );
  }
}
