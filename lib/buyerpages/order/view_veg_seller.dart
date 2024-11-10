import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:veg/buyerpages/order/order_details.dart';
import 'package:veg/buyerpages/payment/ViewPaymentsPage.dart';

class Sample extends StatefulWidget {
  const Sample({super.key});

  @override
  State<Sample> createState() => _SampleState();
}

class _SampleState extends State<Sample> {
  User? currentFirebaseUser;
  Map<String, double> remainingQuantities = {}; // Track remaining quantities locally

  @override
  void initState() {
    super.initState();
    currentFirebaseUser = FirebaseAuth.instance.currentUser;
    print("Current User: $currentFirebaseUser");
  }

  @override
  Widget build(BuildContext context) {
    if (currentFirebaseUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("No User Logged In"),
        ),
        body: const Center(
          child: Text("Please log in to access your data."),
        ),
      );
    }

    DatabaseReference sellersRef = FirebaseDatabase.instance.ref().child("sellers");
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("Users");
    DatabaseReference ordersRef = FirebaseDatabase.instance.ref().child("orders");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Place your orders',
          style: TextStyle(fontSize: 20.0, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<DatabaseEvent>(
              future: sellersRef.once(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return const Center(child: Text("No Sellers Found"));
                }

                Map<dynamic, dynamic> sellersData =
                snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

                return FutureBuilder<List<Widget>>(
                  future: Future.wait(sellersData.keys.map((sellerId) async {
                    DataSnapshot userSnapshot =
                        (await usersRef.child(sellerId).once()).snapshot;
                    Map<dynamic, dynamic>? userInfo =
                    userSnapshot.value as Map<dynamic, dynamic>?;

                    String firstName = userInfo?['firstname'] ?? 'Unknown';
                    String fullName = firstName;

                    List<Widget> vegetableWidgets = [];
                    if (sellersData[sellerId]['vegetable_details'] != null) {
                      Map<dynamic, dynamic> vegetableDetails =
                      sellersData[sellerId]['vegetable_details'];
                      vegetableDetails.forEach((vegId, vegInfo) {
                        // Initialize local remaining quantity if it hasn't been set yet
                        double initialQuantity = double.tryParse(vegInfo['quantity'].toString()) ?? 0;
                        remainingQuantities["$sellerId-$vegId"] ??= initialQuantity;

                        vegetableWidgets.add(
                          Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Colors.green),
                            ),
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vegInfo['name_veg'] ?? 'Unnamed Vegetable',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Price  : ${vegInfo['price'].toStringAsFixed(2) ?? 'N/A'} Rs",
                                  ),
                                  Text(
                                    "Quantity: ${remainingQuantities["$sellerId-$vegId"]!.toStringAsFixed(2)} kg ",
                                  ),
                                ],
                              ),
                              trailing: ElevatedButton(
                                onPressed: () => _showQuantityDialog(
                                    vegInfo, sellerId, vegId, ordersRef),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text("Add"),
                              ),
                            ),
                          ),
                        );
                      });
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 2.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ExpansionTile(
                        title: Text(
                          fullName.trim().isEmpty ? 'Unknown Seller' : fullName.trim(),
                          style: const TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        children: vegetableWidgets,
                      ),
                    );
                  }).toList()),
                  builder: (context, futureSnapshot) {
                    if (futureSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (futureSnapshot.hasError) {
                      return Center(child: Text("Error: ${futureSnapshot.error}"));
                    }

                    return ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: futureSnapshot.data ?? [],
                    );
                  },
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 43.0,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Cart()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuantityDialog(Map<dynamic, dynamic> vegInfo, String sellerId,
      String vegId, DatabaseReference ordersRef) {
    final TextEditingController quantityController = TextEditingController();
    double availableQuantity = remainingQuantities["$sellerId-$vegId"] ?? 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Quantity'),
          content: TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Enter quantity'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                double quantity = double.tryParse(quantityController.text) ?? 0;

                if (quantity > 0 && quantity <= availableQuantity) {
                  double price = double.tryParse(vegInfo['price'].toString()) ?? 0;
                  double totalPrice = price * quantity;
                  setState(() {
                    remainingQuantities["$sellerId-$vegId"] = availableQuantity - quantity;
                  });

                  // Add to cart in Firebase
                  ordersRef
                      .child(currentFirebaseUser!.uid)
                      .child(sellerId)
                      .child(vegId)
                      .push() // Generate unique order ID
                      .set({
                    "name_veg": vegInfo['name_veg'],
                    "quantity": quantity,
                    "total_price": totalPrice,
                    "buyer_id": currentFirebaseUser!.uid,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to cart!')),
                  );
                  Navigator.pop(context);
                } else if (quantity > availableQuantity) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cannot add more than available quantity ($availableQuantity)')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid quantity.')),
                  );
                }
              },
              child: const Text('Add to Cart'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
