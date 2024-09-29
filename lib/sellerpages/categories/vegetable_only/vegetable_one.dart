import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:veg/login_pages/login.dart';
import 'package:veg/sellerpages/AddItemsPage.dart';

class VegetableOne extends StatefulWidget {
  const VegetableOne({super.key});

  @override
  State<VegetableOne> createState() => _VegetableOneState();
}

class _VegetableOneState extends State<VegetableOne> {
  User? currentFirebaseUser;
  final List<String> vegetables = ['Carrot', 'Beans']; // Add more vegetable names here
  final Map<String, TextEditingController> priceControllers = {};
  final Map<String, TextEditingController> quantityControllers = {};

  @override
  void initState() {
    super.initState();
    currentFirebaseUser = FirebaseAuth.instance.currentUser;

    // Initialize controllers for each vegetable
    for (var vegetable in vegetables) {
      priceControllers[vegetable] = TextEditingController();
      quantityControllers[vegetable] = TextEditingController();
    }
  }

  @override
  void dispose() {
    // Dispose controllers when not needed
    for (var vegetable in vegetables) {
      priceControllers[vegetable]?.dispose();
      quantityControllers[vegetable]?.dispose();
    }
    super.dispose();
  }

  void saveVegetableInfo(String vegetableName, String price, String quantity) {
    if (currentFirebaseUser != null) {
      Map<String, String> sellerDataMap = {
        "price": price,
        "quantity": quantity,
      };
      DatabaseReference sellersRef = FirebaseDatabase.instance.ref().child("sellers").child(currentFirebaseUser!.uid).child("vegetable_details");

      // Create vegetable_details node under the seller node
      sellersRef.child(vegetableName).set(sellerDataMap);


      // Clear the input fields after saving
      priceControllers[vegetableName]?.clear();
      quantityControllers[vegetableName]?.clear();
    } else {
      // Handle user not being logged in
      // You can optionally navigate to the login page or show an error message here
    }
  }

  void handleSave() {
    for (var vegetable in vegetables) {
      if (priceControllers[vegetable]!.text.isNotEmpty && quantityControllers[vegetable]!.text.isNotEmpty) {
        saveVegetableInfo(vegetable, priceControllers[vegetable]!.text, quantityControllers[vegetable]!.text);
      }
    }
    // Navigate to the login page after saving
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Additemspage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Vegetable',
          style: TextStyle(fontSize: 20.0, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.search,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                hintText: "Search Vegetable",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.filter_list,
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Vegetable Cards

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 2),
                    child: Column( // Use Column to stack the rows vertically
                      children: [
                        // First Row of Vegetables
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (var vegetable in vegetables)
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 6), // Add horizontal margin for spacing
                                width: 150, // Increased width for better appearance
                                child: GestureDetector(
                                  child: Hero(
                                    tag: '${vegetable}Hero',
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.8),
                                            spreadRadius: 2,
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          )
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/images/seller_image/Vegetables/${vegetable.toLowerCase()}.jpg',
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.contain,
                                          ),
                                          Text(
                                            vegetable,
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.green),
                                          ),
                                          const SizedBox(height: 6),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: TextFormField(
                                              controller: priceControllers[vegetable],
                                              decoration: const InputDecoration(
                                                labelText: 'Price',
                                                labelStyle: TextStyle(fontSize: 18),
                                                hintText: 'Enter the price',
                                                border: OutlineInputBorder(),
                                              ),
                                              keyboardType: TextInputType.number,
                                              autocorrect: true,
                                            ),
                                          ),
                                          const SizedBox(height: 20.0),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: TextFormField(
                                              controller: quantityControllers[vegetable],
                                              decoration: const InputDecoration(
                                                labelText: 'Quantity',
                                                labelStyle: TextStyle(fontSize: 18),
                                                hintText: 'Enter the quantity',
                                                border: OutlineInputBorder(),
                                              ),
                                              keyboardType: TextInputType.number,
                                              autocorrect: true,
                                            ),
                                          ),
                                          const SizedBox(height: 20.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20), // Add space between the rows
                        // Second Row of Vegetables
                     /*   Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (var vegetable in ['Tomato', 'Cabbage']) // Add your new vegetable names here
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 6), // Add horizontal margin for spacing
                                width: 150, // Increased width for better appearance
                                child: GestureDetector(
                                  child: Hero(
                                    tag: '${vegetable}Hero',
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.8),
                                            spreadRadius: 2,
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          )
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/images/seller_image/Vegetables/${vegetable.toLowerCase()}.jpg', // Ensure your images are named accordingly
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.contain,
                                          ),
                                          Text(
                                            vegetable,
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.green),
                                          ),
                                          const SizedBox(height: 6),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: TextFormField(
                                              controller: priceControllers[vegetable],
                                              decoration: const InputDecoration(
                                                labelText: 'Price',
                                                labelStyle: TextStyle(fontSize: 18),
                                                hintText: 'Enter the price',
                                                border: OutlineInputBorder(),
                                              ),
                                              keyboardType: TextInputType.number,
                                              autocorrect: true,
                                            ),
                                          ),
                                          const SizedBox(height: 20.0),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: TextFormField(
                                              controller: quantityControllers[vegetable],
                                              decoration: const InputDecoration(
                                                labelText: 'Quantity',
                                                labelStyle: TextStyle(fontSize: 18),
                                                hintText: 'Enter the quantity',
                                                border: OutlineInputBorder(),
                                              ),
                                              keyboardType: TextInputType.number,
                                              autocorrect: true,
                                            ),
                                          ),
                                          const SizedBox(height: 20.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),*/
                      ],
                    ),
                  ),



                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Use spaceEvenly for equal spacing
                children: <Widget>[
                  Expanded( // Use Expanded to make buttons responsive
                    child: SizedBox(
                      height: 43.0,
                      child: ElevatedButton(
                        onPressed: () {
                          // Your cancel logic here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20), // Add space between buttons
                  Expanded( // Use Expanded to make buttons responsive
                    child: SizedBox(
                      height: 43.0,
                      child: ElevatedButton(
                        onPressed: handleSave, // Call handleSave on button press
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text(
                          'Save',
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
}
