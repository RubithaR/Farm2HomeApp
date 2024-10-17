import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ViewPaymentsPage.dart'; // Import the ViewPaymentsPage

class PaymentPage extends StatefulWidget {
  final String sellerId;
  final double totalAmount;

  const PaymentPage({required this.sellerId, required this.totalAmount, super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedPaymentMethod = "cash"; // Default to cash
  String? _selectedCardType; // Variable for card type
  final User? currentFirebaseUser = FirebaseAuth.instance.currentUser;

  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardHolderNameController = TextEditingController();
  final TextEditingController secretCodeController = TextEditingController();


  void _submitPayment() async {
    // Validate payment details
    if (_selectedPaymentMethod == "card") {
      if (cardNumberController.text.isEmpty ||
          cardHolderNameController.text.isEmpty ||
          secretCodeController.text.isEmpty ||
          _selectedCardType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter all card details.')),
        );
        return;
      }
    }

    // Call function to save payment and update database
    await _savePaymentDetails(
      paymentType: _selectedPaymentMethod == "cash" ? "Cash" : "Card",
      cardType: _selectedPaymentMethod == "card" ? _selectedCardType : null,
      cardHolderName: _selectedPaymentMethod == "card"
          ? cardHolderNameController.text
          : null,
    );
  }

  Future<void> _savePaymentDetails({
    required String paymentType,
    String? cardType,
    String? cardHolderName,
  }) async {
    final DatabaseReference ordersRef = FirebaseDatabase.instance.ref().child('orders');
    final DatabaseReference finalOrdersRef = FirebaseDatabase.instance.ref().child('final_order');

    try {
      // Retrieve current buyer's orders from Firebase
      final DataSnapshot ordersSnapshot = await ordersRef
          .child(currentFirebaseUser!.uid)
          .child(widget.sellerId)
          .get();

      if (ordersSnapshot.exists) {
        final Map<dynamic, dynamic> ordersData = ordersSnapshot.value as Map<dynamic, dynamic>;

        // Iterate through the buyer's orders and save them under final_order
        for (var vegId in ordersData.keys) {
          var vegInfo = ordersData[vegId];
          final String orderUniqueId = vegInfo.keys.first; // Get the unique order ID

          // Save the order details under 'final_order'
          await finalOrdersRef
              .child(currentFirebaseUser!.uid)
              .child(widget.sellerId)
              .child(vegId)
              .child(orderUniqueId)
              .set(vegInfo[orderUniqueId]);

          // Save the payment details under 'final_order'
          await finalOrdersRef
              .child(currentFirebaseUser!.uid)
              .child(widget.sellerId)
              .child(vegId)
              .child(orderUniqueId)
              .child("payment")
              .push()
              .set({
            'totalAmount': widget.totalAmount,
            'paymentType': paymentType,
            'cardType': cardType,
            'cardHolderName': cardHolderName,
          });
        }

        // Remove the original order from 'orders'
        await ordersRef
            .child(currentFirebaseUser!.uid)
            .child(widget.sellerId)
            .remove();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful!')),
        );

        // Navigate to the ViewPaymentsPage after payment is successful
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ViewPaymentsPage()),
        );
      } else {
        // No orders found for this buyer
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No orders found to process.')),
        );
      }
    } catch (error) {
      // Handle any errors that occur during the process
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Total Amount: LKR ${widget.totalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16.0),
              const Text("Select Payment Method", style: TextStyle(fontSize: 16)),
              RadioListTile<String>(
                title: const Text("Cash on Delivery"),
                value: "cash",
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text("Card Payment"),
                value: "card",
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
              const SizedBox(height: 10),
              if (_selectedPaymentMethod == "card") ...[
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Card Type",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Visa", child: Text("Visa")),
                    DropdownMenuItem(value: "MasterCard", child: Text("MasterCard")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCardType = value;
                    });
                  },
                  value: _selectedCardType,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: cardNumberController,
                  decoration: const InputDecoration(
                    labelText: "Card Number",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: cardHolderNameController,
                  decoration: const InputDecoration(
                    labelText: "Card Holder Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: secretCodeController,
                  decoration: const InputDecoration(
                    labelText: "Secret Code (CVV)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _submitPayment,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text(
                      "Submit Payment",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
