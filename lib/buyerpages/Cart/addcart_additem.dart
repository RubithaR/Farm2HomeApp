import 'package:flutter/material.dart';
import 'package:veg/buyerpages/Cart/CartPage.dart';
import 'package:veg/buyerpages/Cart/CategoryPage.dart';
import 'package:veg/buyerpages/Cart/FruitsPage.dart';
import 'package:veg/buyerpages/Cart/GrainsPage.dart';
import 'package:veg/buyerpages/Cart/VegetablesPage.dart';
import 'package:veg/buyerpages/Cart/bottom_nav_bar.dart';

class CartHomePage extends StatefulWidget {
  const CartHomePage({Key? key}) : super(key: key);

  @override
  State<CartHomePage> createState() => _CartHomePageState();
}

class _CartHomePageState extends State<CartHomePage> {
  int _selectedIndex = 0;

  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: MyBottomNavBar(
        onTabChange: (index) => navigateBottomBar(index),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const CartPage(),
          CategoryPage(
            // Pass onTabChange callback to CategoryPage
            onTabChange: (index) => navigateBottomBar(index),
          ),
          const VegetablesPage(),
          const FruitsPage(),
          const GrainsPage(),
        ],
      ),
    );
  }
}
