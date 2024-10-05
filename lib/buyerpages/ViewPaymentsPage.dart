import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ViewPaymentsPage extends StatefulWidget {
  const ViewPaymentsPage({Key? key}) : super(key: key);

  @override
  State<ViewPaymentsPage> createState() => _ViewPaymentsPageState();
}

class _ViewPaymentsPageState extends State<ViewPaymentsPage> {
  User? currentFirebaseUser;
  final DatabaseReference paymentsRef =
      FirebaseDatabase.instance.ref().child("payments");

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
        future: paymentsRef.child(currentFirebaseUser!.uid).once(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("No payment history found."));
          }

          Map<dynamic, dynamic> paymentData =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          List<Widget> paymentWidgets = [];

          paymentData.forEach((sellerId, details) {
            paymentWidgets.add(ListTile(
              title: Text("Seller ID: $sellerId"),
              subtitle: Text(
                  "Total Amount: LKR ${details['totalAmount']}\nPayment Type: ${details['paymentType']}"),
            ));
          });

          return ListView(children: paymentWidgets);
        },
      ),
    );
  }
}
