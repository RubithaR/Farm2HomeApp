import 'package:flutter/material.dart';

class MyBottomNavBar extends StatefulWidget {
  final void Function(int)? onTabChange; // Callback to handle tab changes

  const MyBottomNavBar({Key? key, this.onTabChange}) : super(key: key);

  @override
  _MyBottomNavBarState createState() => _MyBottomNavBarState();
}

class _MyBottomNavBarState extends State<MyBottomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Call the onTabChange callback if provided
    widget.onTabChange?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category_outlined),
          label: 'Categories',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.looks_one),
          label: 'Vegetables',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.looks_two),
          label: 'Fruits',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.looks_3),
          label: 'Grains',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.green,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
    );
  }
}
