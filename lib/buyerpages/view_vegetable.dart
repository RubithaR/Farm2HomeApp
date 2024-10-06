import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:veg/buyerpages/Cart_page.dart';

class Sample extends StatefulWidget {
  const Sample({super.key});

  @override
  State<Sample> createState() => _SampleState();
}

class _SampleState extends State<Sample> {
  User? currentFirebaseUser;

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

    DatabaseReference sellersRef =
        FirebaseDatabase.instance.ref().child("sellers");
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("Users");
    DatabaseReference ordersRef =
        FirebaseDatabase.instance.ref().child("orders");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Seller and Vegetable Details',
          style: TextStyle(fontSize: 20.0, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Cart()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<DatabaseEvent>(
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
          List<Widget> sellerWidgets = [];

          return FutureBuilder<List<Widget>>(
            future: Future.wait(sellersData.keys.map((sellerId) async {
              DataSnapshot userSnapshot =
                  (await usersRef.child(sellerId).once()).snapshot;
              Map<dynamic, dynamic>? userInfo =
                  userSnapshot.value as Map<dynamic, dynamic>?;

              String firstName = userInfo?['firstname'] ?? 'Unknown';
              String secondName = userInfo?['secondname'] ?? '';
              String fullName =
                  firstName + (secondName.isNotEmpty ? ' ' + secondName : '');

              List<Widget> vegetableWidgets = [];
              if (sellersData[sellerId]['vegetable_details'] != null) {
                Map<dynamic, dynamic> vegetableDetails =
                    sellersData[sellerId]['vegetable_details'];
                vegetableDetails.forEach((vegId, vegInfo) {
                  vegetableWidgets.add(
                    ListTile(
                      title: GestureDetector(
                        child: Text(vegInfo['name_veg'] ?? 'Unnamed Vegetable'),
                        onTap: () => _showQuantityDialog(
                            vegInfo, sellerId, vegId, ordersRef),
                      ),
                      subtitle: Text(
                          "Price: ${vegInfo['price'] ?? 'N/A'}, Quantity: ${vegInfo['quantity'] ?? 'N/A'}"),
                    ),
                  );
                });
              }

              return ExpansionTile(
                title: Text(fullName.trim().isEmpty
                    ? 'Unknown Seller'
                    : fullName.trim()),
                children: vegetableWidgets,
              );
            })).then((value) => value.toList()),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (futureSnapshot.hasError) {
                return Center(child: Text("Error: ${futureSnapshot.error}"));
              }

              return ListView(
                children: futureSnapshot.data ?? [],
              );
            },
          );
        },
      ),
    );
  }

  void _showQuantityDialog(Map<dynamic, dynamic> vegInfo, String sellerId,
      String vegId, DatabaseReference ordersRef) {
    final TextEditingController quantityController = TextEditingController();
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
                int quantity = int.tryParse(quantityController.text) ?? 0;
                if (quantity > 0) {
                  double price =
                      double.tryParse(vegInfo['price'].toString()) ?? 0;
                  double totalPrice = price * quantity;

                  // Add to cart in Firebase
                  ordersRef
                      .child(currentFirebaseUser!.uid)
                      .child(sellerId)
                      .child(vegId)
                      .set({
                    "name_veg": vegInfo['name_veg'],
                    "quantity": quantity,
                    "total_price": totalPrice,
                    "buyer_id": currentFirebaseUser!.uid,
                  });

                  // Optionally, show a confirmation message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to cart!')),
                  );
                  Navigator.pop(context);
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
