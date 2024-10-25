import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class OldOrdersSeller extends StatefulWidget {
  final String sellerId; // Seller's UID

  const OldOrdersSeller({super.key, required this.sellerId});

  @override
  State<OldOrdersSeller> createState() => _OldOrdersSellerState();
}

class _OldOrdersSellerState extends State<OldOrdersSeller> {
  final DatabaseReference historyRef = FirebaseDatabase.instance.ref().child("history_off_order");
  final DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("Users");

  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, Map<String, dynamic>>> fetchUserDetails(List<String> buyerIds) async {
    Map<String, Map<String, dynamic>> usersDetails = {};

    for (String buyerId in buyerIds) {
      final userSnapshot = await usersRef.child(buyerId).once();
      if (userSnapshot.snapshot.value != null) {
        // Safely convert the data
        usersDetails[buyerId] = Map<String, dynamic>.from(userSnapshot.snapshot.value as Map<Object?, Object?>);
      }
    }

    return usersDetails;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Unfocus all text fields
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("History of Orders"),
          backgroundColor: Colors.green,
        ),
        body: StreamBuilder<DatabaseEvent>(
          stream: historyRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)),
              );
            }
            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              return const Center(child: Text("No orders available."));
            }

            Map<dynamic, dynamic>? allOrders = snapshot.data!.snapshot.value as Map<dynamic, dynamic>?;

            // Map to group orders by buyer ID
            Map<String, List<Map<String, dynamic>>> groupedOrders = {};

            if (allOrders == null || allOrders.isEmpty) {
              return const Center(child: Text("No orders found here."));
            }

            // Group orders by buyer ID
            allOrders.forEach((buyerId, buyerOrders) {
              buyerOrders.forEach((sellerId, sellerOrders) {
                if (sellerId == widget.sellerId) {
                  sellerOrders.forEach((vegId, vegetableOrder) {
                    vegetableOrder.forEach((orderId, orderDetails) {
                      // Create an order map to hold details
                      var orderDetail = {
                        'name_veg': orderDetails['name_veg'] ?? 'Unknown',
                        'quantity': orderDetails['quantity'] ?? 0,
                        'total_price': orderDetails['total_price'] ?? 0,
                        'buyer_id': orderDetails['buyer_id'] ?? 'Unknown',
                        'payment': orderDetails['payment'] ?? {}, // Safely include payment details
                      };

                      // Add the order to the appropriate buyer
                      if (!groupedOrders.containsKey(buyerId)) {
                        groupedOrders[buyerId] = [];
                      }
                      groupedOrders[buyerId]!.add(orderDetail);
                    });
                  });
                }
              });
            });

            // Fetch user details for all buyers in a separate future
            return FutureBuilder<Map<String, Map<String, dynamic>>>( // Future to fetch user details
              future: fetchUserDetails(groupedOrders.keys.toList()),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (userSnapshot.hasError) {
                  return Center(
                    child: Text("Error fetching user details: ${userSnapshot.error}"),
                  );
                }

                // Create a list of widgets to display orders grouped by buyer
                List<Widget> orderWidgets = groupedOrders.entries.map((entry) {
                  String buyerId = entry.key;
                  List<Map<String, dynamic>> orders = entry.value;

                  // Calculate total price for this buyer
                  double buyerTotal = 0.0;
                  String paymentType = 'Unknown'; // Initialize paymentType

                  for (var order in orders) {
                    buyerTotal += (order['total_price'] as num).toDouble();
                    // Extracting payment type from order details
                    if (order['payment'] != null) {
                      var paymentDetails = order['payment'] as Map<dynamic, dynamic>;
                      if (paymentDetails.isNotEmpty) {
                        paymentType = paymentDetails.values.first['paymentType'] ?? 'Unknown'; // Get the paymentType if exists
                      }
                    }
                  }

                  // Retrieve user details for this buyer
                  Map<String, dynamic>? userDetails = userSnapshot.data![buyerId];
                  String buyerName = userDetails?['firstname'] ?? 'Unknown';
                  String buyerPhone = userDetails?['phone'] ?? 'Unknown';
                  String district = userDetails?['district'] ?? 'Unknown';

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green), // Green border
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("BuyerID: $buyerId", style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text("Name: $buyerName", style: const TextStyle(fontSize: 16)),
                            Text("Phone: $buyerPhone", style: const TextStyle(fontSize: 16)),
                            Text("District: $district", style: const TextStyle(fontSize: 16.0)),
                            const Divider(thickness: 1, color: Colors.green),

                            const SizedBox(height: 10), // Space between buyer details and orders
                            ...orders.map((order) {
                              return ListTile(
                                title: Text("${order['name_veg']}"),
                                subtitle: Text("Quantity: ${order['quantity']}"),
                                trailing: Text("Total: LKR ${order['total_price'].toStringAsFixed(2)}",
                                  style: const TextStyle(fontWeight: FontWeight.bold),),
                              );
                            }),
                            const Divider(thickness: 1, color: Colors.green),

                            const SizedBox(height: 10), // Space between orders and total

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
                                    "Total Price: LKR ${buyerTotal.toStringAsFixed(2)}",
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
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList();

                if (orderWidgets.isEmpty) {
                  return const Center(child: Text("No orders found for this seller."));
                }

                return SingleChildScrollView(
                  child: Column(
                    children: orderWidgets,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
