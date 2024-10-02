import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:veg/sellerpages/AddItemsPage.dart';
import 'package:veg/sellerpages/categories/categories.dart';

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
            children: [
              GestureDetector(
                onTap: (){},
                child : Container(
                  padding: const EdgeInsets.only(top: 1, left: 6, right: 6, bottom: 1),
                  decoration: BoxDecoration(

                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.8),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0,3),
                        )
                      ]
                  ),
                  child: Material(
                    color: Colors.white,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddItemsPage(),
                          ),
                        );
                      },
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Colors.green), // Optional border side
                          ),
                        ),
                        overlayColor: WidgetStateColor.resolveWith((states) => Colors.green.withOpacity(0.2)), // Splash color
                      ),
                      child: const Column(
                        children: [
                          Image(
                            image: AssetImage('assets/images/buyer_homepage/vegetables.jpeg'),
                            height: 140,
                            width: 125,
                          ),
                          Text(
                            'Start',
                            style: TextStyle(fontSize: 20, color: Colors.green),
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
