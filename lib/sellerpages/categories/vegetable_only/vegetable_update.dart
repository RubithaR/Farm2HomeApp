import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class VegetableUpdate extends StatefulWidget {
  final String itemId;
  final String name;
  final String price;
  final String quantity;

  const VegetableUpdate({
    Key? key,
    required this.itemId,
    required this.name,
    required this.price,
    required this.quantity,
  }) : super(key: key);

  @override
  _VegetableUpdateState createState() => _VegetableUpdateState();
}

class _VegetableUpdateState extends State<VegetableUpdate> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set initial values for the text fields
    _nameController.text = widget.name;
    _priceController.text = widget.price;
    _quantityController.text = widget.quantity;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  // Function to update vegetable details
  void updateVegetable() {
    if (_formKey.currentState!.validate()) {
      DatabaseReference sellersRef = FirebaseDatabase.instance
          .ref()
          .child("sellers")
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child("vegetable_details")
          .child(widget.itemId);

      sellersRef.update({
        "name_veg": _nameController.text,
        "price": _priceController.text,
        "quantity": _quantityController.text,
      }).then((_) {
        Navigator.pop(context); // Go back to the previous page
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update data: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false, // Add this line to remove the back arrow
        title: const Text(
          'Update Vegetable',
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
                  // Form widget with form fields
                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 25, horizontal: 2),
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            label: 'Name',
                            hintText: 'Enter the name of the vegetable',
                          ),
                          const SizedBox(height: 20.0),
                          _buildTextField(
                            controller: _priceController,
                            label: 'Price for 1kg',
                            hintText: 'Enter the price in LkR',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20.0),
                          _buildTextField(
                            controller: _quantityController,
                            label: 'Quantity (in kg)',
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
                        onPressed: updateVegetable,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text(
                          'Update',
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
