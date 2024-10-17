import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:veg/sellerpages/add_item_page.dart';
import 'package:veg/sellerpages/map/seller_location.dart';
import 'package:veg/sellerpages/view_order/view_orders_page.dart';

class HomePageSeller extends StatefulWidget {
  const HomePageSeller({super.key});

  @override
  State<HomePageSeller> createState() => _HomePageSellerState();
}

class _HomePageSellerState extends State<HomePageSeller> {
  String? sellerId;
  String? firstName;

  @override
  void initState() {
    super.initState();
    _fetchSellerDetails(); // Fetch seller details on init
  }

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
          firstName = data['firstname']; // Assuming you're saving the first name under this key
        });
      }
    } else {
      print('No user is logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home',), // Greet the seller by name
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Welcome Message
           Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(firstName != null ? 'Welcome, $firstName' : 'Welcome',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),

            ),
          ),

          // Location Box
          GestureDetector(
            onTap: () {
              // Navigate to another page when tapped
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MapPageSeller(), // Replace with your location page
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green),
              ),
              child: const Row(
                children: [
                  Icon(Icons.location_on, color: Colors.green),
                  SizedBox(width: 10), // Add spacing between the icon and text
                  Text(
                    'Your Location',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Button Container
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(
                  imagePath: 'assets/images/buyer_homepage/vegetables.jpeg',
                  label: 'Start',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddItemsPage(),
                      ),
                    );
                  },
                ),
                _buildButton(
                  imagePath: 'assets/images/buyer_homepage/vegetables.jpeg',
                  label: 'View Orders',
                  onPressed: () {
                    // Pass the sellerId to ViewOrdersPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewOrdersPage(sellerId: sellerId!), // Ensure sellerId is not null
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build button
  Widget _buildButton({
    required String imagePath,
    required String label,
    required VoidCallback onPressed, // Add this parameter
  }) {
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.8),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        child: TextButton(
          onPressed: onPressed, // Use the passed callback here
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.green),
              ),
            ),
            overlayColor: MaterialStateProperty.resolveWith(
                    (states) => Colors.green.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Image(
                image: AssetImage(imagePath),
                height: 120,
                width: 120,
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 20, color: Colors.green),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}
