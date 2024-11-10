import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:veg/buyerpages/payment/check_location.dart';

class ViewPaymentsPage extends StatefulWidget {
  const ViewPaymentsPage({super.key});

  @override
  State<ViewPaymentsPage> createState() => _ViewPaymentsPageState();
}

class _ViewPaymentsPageState extends State<ViewPaymentsPage> {
  User? currentFirebaseUser;
  final DatabaseReference orderRef = FirebaseDatabase.instance.ref().child("final_order");
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
          child: Text("Please log in to view your payments."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Payments"),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<DatabaseEvent>(
        future: orderRef.child(currentFirebaseUser!.uid).once(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("No order history found."));
          }

          ordersData = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          List<Widget> orderWidgets = [];

          ordersData.forEach((sellerId, vegetableData) {
            double totalSellerPrice = 0;
            String paymentType = 'Unknown'; // Initialize payment type

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
                        style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
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
                            // Display seller location
                            if (sellerDetails[sellerId]['location'] != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Location: Lat ${sellerDetails[sellerId]['location']['latitude']}, Lng ${sellerDetails[sellerId]['location']['longitude']}",
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                ],
                              ),
                          ],
                        )
                      else
                        const Text("Loading seller details..."),
                      const Divider(thickness: 1, color: Colors.green),

                      // Vegetable details
                      ...vegetableData.entries.map((entry) {
                        String vegId = entry.key;
                        var vegOrders = entry.value as Map<dynamic, dynamic>;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: vegOrders.entries.map((orderEntry) {
                            // Initialize orderDetails here for each order entry
                            var orderDetails = orderEntry.value as Map<dynamic, dynamic>;


                            // Extracting payment type from order details
                            if (orderDetails['payment'] != null) {
                              var paymentDetails = orderDetails['payment'] as Map<dynamic, dynamic>;

                              if (paymentDetails.isNotEmpty) {
                                paymentType = paymentDetails.values.first['paymentType'] ?? 'Unknown'; // Get the paymentType if exists
                              }
                            }


                            // Create a CartItem that includes the payment type
                            CartItem cartItem = CartItem.fromMap({
                              'name_veg': orderDetails['name_veg'],
                              'quantity': (orderDetails['quantity'] as num).toDouble(),
                              'total_price': (orderDetails['total_price'] as num).toDouble(),
                            });

                            totalSellerPrice += cartItem.totalPrice;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
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
                                  ],
                                ),
                                const SizedBox(height: 15.0),
                              ],
                            );
                          }).toList(),
                        );
                      }).toList(),

                      const SizedBox(height: 10.0), // Add space before total price

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
                              "Total Price: LKR ${totalSellerPrice.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10.0),

                            // Display payment type below the total price
                            Text(
                              "Payment Type: $paymentType", // Use the local paymentType variable
                              style: const TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),


                      ElevatedButton(
                        onPressed: () {
                          if (sellerDetails[sellerId]['location'] != null ) {
                            double latitude = sellerDetails[sellerId]['location']['latitude'];
                            double longitude = sellerDetails[sellerId]['location']['longitude'];
                            String sellerName = sellerDetails[sellerId]['firstname'] ?? 'Unknown Seller';

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CheckLocation(
                                  latitude: latitude,
                                  longitude: longitude,
                                  sellerName: sellerName
                                ),
                              ),
                            );
                          } else {
                            // Show a message if the location is not available
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Location not available for this seller.")),
                            );
                          }
                        },
                        child: const Text("View on Map"),
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

// Your CartItem class
class CartItem {
  final String vegetableName;
  final double quantity;
  final double totalPrice;

  CartItem({
    required this.vegetableName,
    required this.quantity,
    required this.totalPrice,
  });

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      vegetableName: map['name_veg'] as String,
      quantity: map['quantity'] as double,
      totalPrice: (map['total_price'] as num).toDouble(),
    );
  }
}