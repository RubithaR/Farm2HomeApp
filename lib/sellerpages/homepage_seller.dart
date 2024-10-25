import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:veg/sellerpages/add_item_page.dart';
import 'package:veg/sellerpages/history_seller/old_orders_seller.dart';
import 'package:veg/sellerpages/map/seller_location.dart';
import 'package:veg/sellerpages/view_order/view_orders_page.dart';
import 'package:veg/sellerpages/bottom_nav_bar/bottom_nav_bar.dart';



class HomePageSeller extends StatefulWidget {
  const HomePageSeller({super.key});

  @override
  State<HomePageSeller> createState() => _HomePageSellerState();
}

class _HomePageSellerState extends State<HomePageSeller> {
  String? sellerId;
  String? firstName;
  int _selectedIndex = 0;

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


  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.green,

        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // Add your navigation logic here
            },
          ),
        ],
      )
          : null,

      bottomNavigationBar: MyBottomNavBar(
        onTabChange: _onTabChange,
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomePageContent(),
          const MapPageSeller(),
          const AddItemsPage(),
          ViewOrdersPage(sellerId: sellerId ?? ''),
        ],
      ),
    );
  }

  Widget _buildHomePageContent() {
    return ListView(
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
            setState(() {
              _selectedIndex = 1; // Switch to AddItemsPage
            });
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
                label: 'Add item',
                onPressed: () {
                  setState(() {
                    _selectedIndex = 2; // Switch to AddItemsPage
                  });
                },
              ),
              const SizedBox(width: 15,),
              _buildButton(
                imagePath: 'assets/images/buyer_homepage/vegetables.jpeg',
                label: 'View Orders',
                onPressed: () {
                  // Pass the sellerId to ViewOrdersPage
                  setState(() {
                    _selectedIndex = 3; // Switch to AddItemsPage
                  });
                },
              ),
            ],
          ),
        ),

        // Button Container
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton(
                imagePath: 'assets/images/buyer_homepage/vegetables.jpeg',
                label: 'Route',
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1; // Switch to AddItemsPage
                  });
                },
              ),
              const SizedBox(width: 15,),
              _buildButton(
                imagePath: 'assets/images/buyer_homepage/vegetables.jpeg',
                label: 'History',
                onPressed: () {
                  // Pass the sellerId to ViewOrdersPage
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => OldOrdersSeller(sellerId: sellerId ?? '')
                   ),
                  ) ;
                },
              ),
            ],
          ),
        ),
      ],
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
