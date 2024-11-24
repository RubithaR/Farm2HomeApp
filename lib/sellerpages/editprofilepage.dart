import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class Editprofilepage extends StatefulWidget {
  final String sellerId; // Seller's UID

  const Editprofilepage({super.key, required this.sellerId});

  @override
  State<Editprofilepage> createState() => _Editprofile();
}

class _Editprofile extends State<Editprofilepage> {
  String? sellerId;
  void initState() {
    super.initState();
    _fetchSellerDetails();
  }



  // Controllers for input fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();

  String? _email; // For displaying email
  String? _role; // For displaying role

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  Future<void> _fetchSellerDetails() async {
    final User? user = FirebaseAuth.instance.currentUser;
    sellerId = user?.uid; // Set sellerId from the current user's UID

    if (sellerId != null) {
      // Reference to the seller's data in the database
      DatabaseReference sellerRef = FirebaseDatabase.instance.ref('Users/$sellerId');

      // Get seller data
      DatabaseEvent event = await sellerRef.once();
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _firstNameController.text = data['firstname'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _passwordController.text = data['password'] ?? '';
          _districtController.text = data['district'] ?? '';
          _placeController.text = data['place'] ?? '';
          _email = data['email']; // Display email
          _role = data['role'];  // Assuming you're saving the first name under this key
        });
      }
    } else {
      print('No user is logged in');
    }
  }


  Future<void> _updateUserData(String userId) async {
    try {
      await _database.child('Users').child('$sellerId').update({
        'firstname': _firstNameController.text,
        'phone': _phoneController.text,
        'password': _passwordController.text,
        'district': _districtController.text,
        'place': _placeController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  InputDecoration _buildInputDecoration(String labelText, IconData icon) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      filled: true,
      fillColor: Colors.grey[200],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              TextField(
                controller: _firstNameController,
                decoration: _buildInputDecoration("First Name", Icons.person),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _phoneController,
                decoration: _buildInputDecoration(
                    "Phone Number", Icons.phone_android),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: _buildInputDecoration("Password", Icons.lock),
                obscureText: true,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _districtController,
                decoration: _buildInputDecoration("District", Icons.map),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _placeController,
                decoration: _buildInputDecoration("Place", Icons.place),
              ),
              SizedBox(height: 30),
              Text(
                "Email: ${_email ?? 'Loading...'}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Role  : ${_role ?? 'Loading...'}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _updateUserData(widget.sellerId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Center(
                  child: Text(
                    "Update Profile",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
