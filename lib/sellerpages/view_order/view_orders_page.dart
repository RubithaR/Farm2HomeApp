import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:veg/sellerpages/view_order/check_location_page.dart';
import 'package:quickalert/quickalert.dart';

class ViewOrdersPage extends StatefulWidget {
  final String sellerId; // Seller's UID

  const ViewOrdersPage({super.key, required this.sellerId});

  @override
  State<ViewOrdersPage> createState() => _ViewOrdersPageState();
}

class _ViewOrdersPageState extends State<ViewOrdersPage> {
  final DatabaseReference ordersRef = FirebaseDatabase.instance.ref().child("final_order");
  final DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("Users");

  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, Map<String, dynamic>>> fetchUserDetails(
      List<String> buyerIds) async {
    Map<String, Map<String, dynamic>> usersDetails = {};

    for (String buyerId in buyerIds) {
      final userSnapshot = await usersRef.child(buyerId).once();
      if (userSnapshot.snapshot.value != null) {
        // Safely convert the data
        usersDetails[buyerId] = Map<String, dynamic>.from(
            userSnapshot.snapshot.value as Map<Object?, Object?>);
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
          title: const Text("Your Orders"),
          backgroundColor: Colors.green,
        ),
        body: StreamBuilder<DatabaseEvent>(
          stream: ordersRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text("Error: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red)),
              );
            }
            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              return const Center(child: Text("No orders available."));
            }

            Map<dynamic, dynamic>? allOrders =
            snapshot.data!.snapshot.value as Map<dynamic, dynamic>?;

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
                        'payment': orderDetails['payment'] ??
                            {}, // Safely include payment details
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
            return FutureBuilder<Map<String, Map<String, dynamic>>>(
              // Future to fetch user details
              future: fetchUserDetails(groupedOrders.keys.toList()),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (userSnapshot.hasError) {
                  return Center(
                    child: Text(
                        "Error fetching user details: ${userSnapshot.error}"),
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
                      var paymentDetails =
                      order['payment'] as Map<dynamic, dynamic>;
                      if (paymentDetails.isNotEmpty) {
                        paymentType =
                            paymentDetails.values.first['paymentType'] ??
                                'Unknown'; // Get the paymentType if exists
                      }
                    }
                  }

                  // Retrieve user details for this buyer
                  Map<String, dynamic>? userDetails =
                  userSnapshot.data![buyerId];
                  String buyerName = userDetails?['firstname'] ?? 'Unknown';
                  String buyerPhone = userDetails?['phone'] ?? 'Unknown';
                  String district = userDetails?['district'] ?? 'Unknown';

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green), // Green border
                    ),
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("BuyerID: $buyerId",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text("Name: $buyerName",
                                style: const TextStyle(fontSize: 16)),
                            Text("Phone: $buyerPhone",
                                style: const TextStyle(fontSize: 16)),
                            Text("District: $district",
                                style: const TextStyle(fontSize: 16.0)),
                            const Divider(thickness: 1, color: Colors.green),

                            const SizedBox(
                                height:
                                10), // Space between buyer details and orders
                            ...orders.map((order) {
                              return ListTile(
                                title: Text("${order['name_veg']}"),
                                subtitle:
                                Text("Quantity: ${order['quantity'].toStringAsFixed(2)}"),
                                trailing: Text(
                                  "Total: LKR ${order['total_price'].toStringAsFixed(2)}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              );
                            }),
                            const Divider(thickness: 1, color: Colors.green),

                            const SizedBox(
                                height: 10), // Space between orders and total

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
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10.0),

                                  // Display payment type below the total price
                                  Text(
                                    "Payment Type: $paymentType", // Use the local paymentType variable
                                    style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),

                            ElevatedButton(
                              onPressed: () {
                                // Retrieve the location from user details
                                double? buyerLatitude =
                                userDetails?['location']?['latitude'];
                                double? buyerLongitude =
                                userDetails?['location']?['longitude'];

                                // Ensure the buyer has a location before navigating
                                if (buyerLatitude != null &&
                                    buyerLongitude != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CheckLocationSeller(
                                        latitude: buyerLatitude,
                                        longitude: buyerLongitude,
                                        buyerName: buyerName,
                                      ),
                                    ),
                                  );
                                } else {
                                  // Show a message if the location is not available
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Location not available for this buyer.")),
                                  );
                                }
                              },
                              child: const Text("View on Map"),
                            ),

                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .end, // Align the button to the right
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.success,
                                      text: "Delivery completed Successfully",
                                      onConfirmBtnTap: () async {
                                        try {
                                          // Create a reference to the specific buyer's orders in 'final_order'
                                          final DatabaseReference finalOrderRef = FirebaseDatabase.instance.ref()
                                              .child('final_order')
                                              .child(buyerId)
                                              .child(widget.sellerId);

                                          // Fetch the orders for this specific seller and buyer
                                          final DataSnapshot orderSnapshot = await finalOrderRef.get();

                                          if (orderSnapshot.exists) {
                                            Map<dynamic, dynamic> orders =
                                            orderSnapshot.value as Map<dynamic, dynamic>;

                                            // Create a reference to save the order in 'history_off_order'
                                            final DatabaseReference historyRef = FirebaseDatabase.instance.ref()
                                                .child('history_off_order')
                                                .child(buyerId)
                                                .child(widget.sellerId);

                                            // Create a reference to save the order in 'history_off_order'
                                            final DatabaseReference historyAlgoRef = FirebaseDatabase.instance.ref()
                                                .child('history_for_algo');

                                            // Fetch buyer details for district information
                                            final DatabaseReference buyerRef = FirebaseDatabase.instance.ref()
                                                .child('Users')
                                                .child(buyerId);

                                            final DataSnapshot buyerSnapshot = await buyerRef.get();
                                            final String buyerDistrict = buyerSnapshot.child('district').value as String;


                                            // Save orders to 'history_off_order' and aggregate data for 'history_for_algo'
                                            for (String vegId in orders.keys) {
                                              Map<dynamic, dynamic> vegOrders = orders[vegId];
                                              double totalQuantity = 0.0;

                                              for (String orderId in vegOrders.keys) {
                                                // Save individual orders to history
                                                await historyRef.child(vegId).child(orderId).set(vegOrders[orderId]);

                                                // Aggregate quantity for each vegetable, casting to double to avoid type issues
                                                double quantity = (vegOrders[orderId]['quantity'] as num).toDouble();
                                                totalQuantity += quantity;
                                              }

                                              // Save aggregated data by vegetable ID, name, and district in 'history_for_algo'
                                              String vegetableName = vegOrders.values.first['name_veg'] as String;
                                              await historyAlgoRef
                                                  .child(vegetableName)
                                                  .child(buyerDistrict)
                                                  .set({
                                                'total_quantity': ServerValue.increment(totalQuantity),
                                              });
                                            }

                                            // Now remove the orders from 'final_order'
                                            await finalOrderRef.remove();

                                            // Display success message and close the dialog
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Order moved to history successfully!')),
                                            );
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          } else {
                                            // No orders found for this buyer
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'No orders found to move.')),
                                            );
                                          }
                                        } catch (error) {
                                          // Handle any errors that occur during the process
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text('Error: $error')),
                                          );
                                        }
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green),
                                  child: const Text(
                                    "Done",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList();

                if (orderWidgets.isEmpty) {
                  return const Center(
                      child: Text("No orders found for this seller."));
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