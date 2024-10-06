import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ViewPaymentsPage.dart'; // Import the ViewPaymentsPage

class PaymentPage extends StatefulWidget {
  final String sellerId;
  final double totalAmount;

  const PaymentPage(
      {required this.sellerId, required this.totalAmount, Key? key})
      : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedPaymentMethod = "cash"; // Default to cash
  String? _selectedCardType; // New variable for card type

  final TextEditingController addressController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardHolderNameController =
      TextEditingController();
  final TextEditingController secretCodeController = TextEditingController();

  final DatabaseReference paymentsRef =
      FirebaseDatabase.instance.ref().child("payments");
  final DatabaseReference ordersRef =
      FirebaseDatabase.instance.ref().child("orders"); // Reference for orders
  final User? currentFirebaseUser = FirebaseAuth.instance.currentUser;

  void _submitPayment() {
    if (_selectedPaymentMethod == "cash") {
      if (addressController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your address.')),
        );
        return;
      }
      _savePaymentDetails("Cash", address: addressController.text);
    } else {
      if (cardNumberController.text.isEmpty ||
          cardHolderNameController.text.isEmpty ||
          secretCodeController.text.isEmpty ||
          _selectedCardType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter all card details.')),
        );
        return;
      }
      _savePaymentDetails(
        "Card",
        cardType: _selectedCardType,
        cardHolderName: cardHolderNameController.text,
      );
    }
  }

  void _savePaymentDetails(String paymentType,
      {String? address, String? cardType, String? cardHolderName}) {
    paymentsRef.child(currentFirebaseUser!.uid).child(widget.sellerId).set({
      'totalAmount': widget.totalAmount,
      'paymentType': paymentType,
      'address': address,
      'cardType': cardType,
      'cardHolderName': cardHolderName,
    }).then((_) {
      // Remove items from orders after payment
      ordersRef
          .child(currentFirebaseUser!.uid)
          .child(widget.sellerId)
          .remove()
          .then((_) {
        // Navigate to ViewPaymentsPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ViewPaymentsPage()),
        );
      });
    });
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total Amount: LKR ${widget.totalAmount.toStringAsFixed(2)}",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
            const SizedBox(height: 16.0),
            if (_selectedPaymentMethod == "cash")
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: "Enter your address",
                  border: OutlineInputBorder(),
                ),
              ),
            if (_selectedPaymentMethod == "card") ...[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Card Type",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(child: Text("Visa"), value: "Visa"),
                  DropdownMenuItem(
                      child: Text("MasterCard"), value: "MasterCard"),
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
            ElevatedButton(
              onPressed: _submitPayment,
              child: const Text("Submit Payment"),
            ),
          ],
        ),
      ),
    );
  }
}
