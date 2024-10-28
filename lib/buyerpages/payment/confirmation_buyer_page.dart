// Not use
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class BuyerConfirmationPage extends StatefulWidget {
  const BuyerConfirmationPage({super.key});

  @override
  State<BuyerConfirmationPage> createState() => _BuyerConfirmationPageState();
}

class _BuyerConfirmationPageState extends State<BuyerConfirmationPage> {
  User? currentFirebaseUser;
  final DatabaseReference completionRef = FirebaseDatabase.instance.ref().child("completion");
  late String sellerUid;
  bool showConfirmationDialog = false;

  @override
  void initState() {
    super.initState();
    currentFirebaseUser = FirebaseAuth.instance.currentUser;

    // Listen for completion updates for the current buyer
    if (currentFirebaseUser != null) {
      completionRef.orderByChild('buyer_uid').equalTo(currentFirebaseUser!.uid).onChildAdded.listen((event) {
        var data = event.snapshot.value as Map<dynamic, dynamic>;

        // Check if the completion status is 'completed'
        if (data['status'] == 'completed') {
          sellerUid = data['seller_uid'];
          setState(() {
            showConfirmationDialog = true;
          });

          // Show the confirmation dialog to the buyer
          _showBuyerConfirmationDialog(context, sellerUid);
        }
      });
    }
  }

  // Dialog to confirm if the buyer received the vegetable
  void _showBuyerConfirmationDialog(BuildContext context, String sellerUid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delivery"),
          content: const Text("Did you receive the vegetable from the seller?"),
          actions: [
            TextButton(
              onPressed: () {
                // Update Firebase with 'confirmed' status
                _updateBuyerResponse('confirmed');
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                // Update Firebase with 'declined' status
                _updateBuyerResponse('declined');
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("No"),
            ),
          ],
        );
      },
    );
  }

  // Function to update the buyer's response in Firebase
  void _updateBuyerResponse(String response) {
    DatabaseReference confirmationRef = FirebaseDatabase.instance.ref().child('confirmation');
    confirmationRef.child(currentFirebaseUser!.uid).set({
      'buyer_uid': currentFirebaseUser!.uid,
      'seller_uid': sellerUid,
      'response': response,  // Either 'confirmed' or 'declined'
    }).then((_) {
      print("Buyer response updated: $response");
    }).catchError((error) {
      print("Failed to update buyer response: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Confirmation"),
      ),
      body: Center(
        child: showConfirmationDialog
            ? const Text("Awaiting buyer confirmation...")
            : const Text("No pending deliveries."),
      ),
    );
  }
}
