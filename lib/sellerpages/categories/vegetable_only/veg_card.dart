import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

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
    // Retrieve the current logged-in Firebase user
    currentFirebaseUser = FirebaseAuth.instance.currentUser;

    // Log the current user for debugging purposes
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

    // Reference to the sellers and users in Firebase
    DatabaseReference sellersRef = FirebaseDatabase.instance.ref().child("sellers");
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("Users");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Seller and Vegetable Details',
          style: TextStyle(fontSize: 20.0, color: Colors.white),
        ),
      ),
      body: FutureBuilder<DatabaseEvent>(
        future: sellersRef.once(), // Fetch sellers data once
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

          Map<dynamic, dynamic> sellersData = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          List<Widget> sellerWidgets = [];

          // Iterate through each seller and their vegetable details
          return FutureBuilder<List<Widget>>(
            future: Future.wait(sellersData.keys.map((sellerId) async {
              // Fetch seller's user info
              DataSnapshot userSnapshot = (await usersRef.child(sellerId).once()).snapshot; // Accessing the snapshot
              Map<dynamic, dynamic>? userInfo = userSnapshot.value as Map<dynamic, dynamic>?;

              // Get the seller's first name
              String firstName = userInfo?['firstname'] ?? 'Unknown';
              String secondName = userInfo?['secondname'] ?? '';
              String fullName = firstName + (secondName.isNotEmpty ? ' ' + secondName : '');

              // Create a list for the seller's vegetables
              List<Widget> vegetableWidgets = [];
              if (sellersData[sellerId]['vegetable_details'] != null) {
                Map<dynamic, dynamic> vegetableDetails = sellersData[sellerId]['vegetable_details'];
                vegetableDetails.forEach((vegId, vegInfo) {
                  vegetableWidgets.add(
                    ListTile(
                      title: Text(vegInfo['name_veg'] ?? 'Unnamed Vegetable'), // Use a default if null
                      subtitle: Text("Price: ${vegInfo['price'] ?? 'N/A'}, Quantity: ${vegInfo['quantity'] ?? 'N/A'}"),
                    ),
                  );
                });
              }

              // Add the seller's name and their vegetable details to the list
              return ExpansionTile(
                title: Text(fullName.trim().isEmpty ? 'Unknown Seller' : fullName.trim()), // Default name if empty
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

              // Use sellerWidgets here
              return ListView(
                children: futureSnapshot.data ?? [],
              );
            },
          );
        },
      ),
    );
  }
}
