import 'package:flutter/material.dart';
import 'package:veg/sellerpages/add_item_page.dart';
import 'package:veg/sellerpages/categories/categories.dart';
import 'package:veg/sellerpages/view_orders_page.dart'; // Import the new View Orders page

class HomePageSeller extends StatefulWidget {
  const HomePageSeller({super.key});

  @override
  State<HomePageSeller> createState() => _HomePageSellerState();
}

class _HomePageSellerState extends State<HomePageSeller> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly, // Add spacing between buttons
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Container(
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddItemsPage(),
                            ),
                          );
                        },
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Colors.green),
                            ),
                          ),
                          overlayColor: MaterialStateColor.resolveWith(
                              (states) => Colors.green.withOpacity(0.2)),
                        ),
                        child: const Column(
                          children: [
                            Image(
                              image: AssetImage(
                                  'assets/images/buyer_homepage/vegetables.jpeg'),
                              height: 140,
                              width: 125,
                            ),
                            Text(
                              'Start',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.green),
                            ),
                            SizedBox(height: 6),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewOrdersPage(),
                            ),
                          );
                        },
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Colors.green),
                            ),
                          ),
                          overlayColor: MaterialStateColor.resolveWith(
                              (states) => Colors.green.withOpacity(0.2)),
                        ),
                        child: const Column(
                          children: [
                            Image(
                              image: AssetImage(
                                  'assets/images/buyer_homepage/vegetables.jpeg'), // Same image for View Orders
                              height: 140,
                              width: 125,
                            ),
                            Text(
                              'View Orders',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.green),
                            ),
                            SizedBox(height: 6),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
