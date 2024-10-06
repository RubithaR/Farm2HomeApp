import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ViewOrdersPage extends StatefulWidget {
  const ViewOrdersPage({Key? key}) : super(key: key);

  @override
  State<ViewOrdersPage> createState() => _ViewOrdersPageState();
}

class _ViewOrdersPageState extends State<ViewOrdersPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final DatabaseReference ordersRef =
      FirebaseDatabase.instance.ref().child("orders");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Orders"),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<DatabaseEvent>(
        future: ordersRef.child(currentUser!.uid).once(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("You have no orders yet."));
          }

          Map<dynamic, dynamic> ordersData =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          List<Widget> orderWidgets = [];

          ordersData.forEach((sellerId, orderInfo) {
            List<Widget> itemWidgets = [];
            double totalAmount = 0;

            orderInfo.forEach((orderId, orderDetails) {
              totalAmount += orderDetails['totalAmount'];
              itemWidgets.add(ListTile(
                title: Text("Vegetable: ${orderDetails['vegetableName']}"),
                subtitle: Text("Quantity: ${orderDetails['quantity']}"),
                trailing: Text("Total: LKR ${orderDetails['totalPrice']}"),
              ));
            });

            orderWidgets.add(
              Card(
                elevation: 2,
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: ListTile(
                  title: Text("Order for Seller: $sellerId"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: itemWidgets,
                  ),
                  trailing: Text(
                      "Total Amount: LKR ${totalAmount.toStringAsFixed(2)}"),
                ),
              ),
            );
          });

          return ListView(children: orderWidgets);
        },
      ),
    );
  }
}
