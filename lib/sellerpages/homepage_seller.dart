import 'package:flutter/material.dart';
import 'package:veg/sellerpages/add_item_page.dart';
import 'package:veg/sellerpages/map/seller_location.dart';
import 'package:veg/sellerpages/view_orders_page.dart';

class HomePageSeller extends StatefulWidget {
  const HomePageSeller({super.key});

  @override
  State<HomePageSeller> createState() => _HomePageSellerState();
}

class _HomePageSellerState extends State<HomePageSeller> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Welcome Message
          const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text(
              'Welcome to Your Dashboard!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ViewOrdersPage(),
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
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.green),
              ),
            ),
            overlayColor: WidgetStateProperty.resolveWith(
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
