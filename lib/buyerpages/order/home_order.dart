/*import 'package:flutter/material.dart';
import 'package:veg/buyerpages/Cart/CartPage.dart';
import 'package:veg/buyerpages/order/order_details.dart';
import 'package:veg/buyerpages/order/view_veg_seller.dart';
import 'package:veg/buyerpages/payment/ViewPaymentsPage.dart';
import 'package:veg/buyerpages/payment/payment_page.dart';

class HomeOrderPage extends StatefulWidget {
  const HomeOrderPage({Key? key}) : super(key: key);

  @override
  State<HomeOrderPage> createState() => _HomeOrderPageState();
}

class _HomeOrderPageState extends State<HomeOrderPage> {
  int _selectedIndex = 0;

  // Replace with actual seller ID and total amount as needed.
  String sellerId = 'example_seller_id';
  double totalAmount = 100.0; // Example total amount

  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Order Page'),
        backgroundColor: Colors.green,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const CartPage(), // Home page
          const Sample(), // View vegetable and seller
          const Cart(), // Order and seller details
          PaymentPage(sellerId: 'example_seller_id', totalAmount: 100.0), // Payment details
          const ViewPaymentsPage(), // View Payments page
        ],
      ),
      bottomNavigationBar: MyBottomNavBar(
        currentIndex: _selectedIndex,
        onTabChange: navigateBottomBar,
      ),
    );
  }
}

class MyBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTabChange;

  const MyBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTabChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category_outlined),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.looks_one),
          label: 'Payment',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_florist),
          label: 'Fruits',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.grain),
          label: 'Grains',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      onTap: onTabChange,
      type: BottomNavigationBarType.fixed,
    );
  }
}*/
