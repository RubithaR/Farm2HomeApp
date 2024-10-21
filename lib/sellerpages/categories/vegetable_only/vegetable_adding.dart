import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:veg/sellerpages/add_item_page.dart';

class VegetableOne extends StatefulWidget {
  const VegetableOne({super.key});

  @override
  State<VegetableOne> createState() => _VegetableOneState();
}

class _VegetableOneState extends State<VegetableOne> {
  User? currentFirebaseUser;

  // Define a GlobalKey for the form
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _nameVegController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentFirebaseUser = FirebaseAuth.instance.currentUser;
  }

  @override
  void dispose() {
    // Dispose controllers when not needed
    _priceController.dispose();
    _quantityController.dispose();
    _nameVegController.dispose();
    super.dispose();
  }

  // Save vegetable information to Firebase
  void saveVegetableInfo() {
    if (_formKey.currentState!.validate()) {
      if (currentFirebaseUser != null) {
        // Reference to seller's node in Realtime Database
        DatabaseReference sellersRef = FirebaseDatabase.instance
            .ref()
            .child("sellers")
            .child(currentFirebaseUser!.uid)
            .child("vegetable_details");

        // Generate a new key for the entry
        String key = sellersRef.push().key!;

        // Create a map to hold the vegetable data
        Map<String, String> sellerDataMap = {
          "price": _priceController.text.trim(),
          "quantity": _quantityController.text.trim(),
          "name_veg": _nameVegController.text.trim(),
        };

        // Save data to Firebase
        sellersRef.child(key).set(sellerDataMap).then((_) {
          // Clear the form fields after saving
          _priceController.clear();
          _quantityController.clear();
          _nameVegController.clear();

          // Navigate to AddItemsPage
          Navigator.pop(context);
        }).catchError((error) {
          // Handle errors (e.g., network issues)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save data: $error')),
          );
        });
      }
    } else {
      // If form is not valid, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out the form correctly')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false, // Add this line to remove the back arrow
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

                  // Form widget with form fields
                  Form(
                    key: _formKey, // Assign the form key
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 25, horizontal: 2),
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _nameVegController,
                            label: 'Name',
                            hintText: 'Enter the name of the vegetable',
                          ),
                          const SizedBox(height: 20.0),
                          _buildTextField(
                            controller: _priceController,
                            label: 'Price for 1kg ',
                            hintText: 'Enter the price in LkR',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20.0),
                          _buildTextField(
                            controller: _quantityController,
                            label: 'Quantity (in kg) ',
                            hintText: 'Enter the quantity you have now',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20.0),
                        ],
                      ),
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: SizedBox(
                      height: 43.0,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
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
                  const SizedBox(width: 20),
                  Expanded(
                    child: SizedBox(
                      height: 43.0,
                      child: ElevatedButton(
                        onPressed: saveVegetableInfo, // Call saveVegetableInfo
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

  // Helper function to build text fields with validation
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter $label";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 18),
          hintText: hintText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
