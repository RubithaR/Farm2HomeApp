
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:veg/buyerpages/Cart/addcart_additem.dart';
import 'package:veg/buyerpages/history_buyer/old_orders_buyer.dart';
import 'package:veg/buyerpages/payment/ViewPaymentsPage.dart';
import 'package:veg/googlemapscreens/current_location_screen.dart';
import 'package:veg/buyerpages/order/view_veg_seller.dart';
import 'package:veg/login_pages/login.dart';
import 'package:veg/sellerpages/editprofilepage.dart';
import '../buyerpages/Widgets/appbarwidget.dart';
import '../buyerpages/Widgets/categorieswidget.dart';

class HomePageBuyer extends StatefulWidget {
  const HomePageBuyer({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePageBuyer> {

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
      body: ListView(
        children: [
          //Custom App Bar Widget
      Padding(padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 15,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              // The PopupMenuButton will handle the menu display.
            },
            child: Container(padding: const EdgeInsets.all(8),
              decoration:  BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0,3),
                  )
                ],
              ),
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  // Handle menu item selection.
                  if (value == 'Edit Profile') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Editprofilepage(sellerId: sellerId ?? ''),
                      ),
                    );
                  } else if (value == 'History') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OldOrdersBuyer(), // Your History screen
                      ),
                    );
                  } else if (value == 'Logout') {
                    // Log out the user
                    FirebaseAuth.instance.signOut().then((_) {
                      setState(() {
                        sellerId = null; // Clear the sellerId
                      });
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LogInScreen()),
                            (Route<dynamic> route) => false, // Remove all previous routes
                      );
                    }).catchError((error) {
                      // Handle any logout error
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Logout failed: $error')),
                      );
                    });
                  }

                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'Edit Profile',
                    child: Text('Edit Profile'),
                  ),
                  PopupMenuItem<String>(
                    value: 'History',
                    child: Text('History'),
                  ),
                  PopupMenuItem<String>(
                    value: 'Logout',
                    child: Text('Logout'),
                  ),

                ],
                child: const Icon(CupertinoIcons.bars),
              ),
            ),
          ),


          InkWell(
            onTap: (){} ,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration:  BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0,3),
                  )
                ],
              ),
              child: const Icon(Icons.notifications),
            ),
          )
        ],
      ),
    ),

          //Search
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 15,
            ),
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ]),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.search,
                      color: Colors.green,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          hintText: "What would you like to buy?",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.filter_list,
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          ),

          //Category
          const Padding(
            padding: EdgeInsets.only(top: 20, left: 10),
            child: Text(
              "Categories",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.green,
              ),
            ),
          ),

          //Category scroll axis
          const CategoriesWidget(),

          const Padding(padding: EdgeInsets.symmetric(vertical: 10)),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.only(
                          top: 1, left: 5, right: 5, bottom: 1),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.8),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            )
                          ]),
                      child: Material(
                        color: Colors.white,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MapPage(),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            shape:
                            WidgetStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                    color: Colors.green), // Optional border side
                              ),
                            ),
                            overlayColor: WidgetStateColor.resolveWith((states) =>
                                Colors.green.withOpacity(0.2)), // Splash color
                          ),
                          child: const Column(
                            children: [
                              Image(
                                image: AssetImage(
                                    'assets/images/buyer_homepage/location.jpg'),
                                height: 140,
                                width: 125,
                              ),
                              Text(
                                'Random Buy',
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
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 30),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.only(
                          top: 1, left: 5, right: 5, bottom: 1),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.8),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            )
                          ]),
                      child: Material(
                        color: Colors.white,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CartHomePage(),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            shape:
                            WidgetStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                    color: Colors.green), // Optional border side
                              ),
                            ),
                            overlayColor: WidgetStateColor.resolveWith((states) =>
                                Colors.green.withOpacity(0.2)), // Splash color
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
                                'My Cart',
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
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.only(
                          top: 1, left: 5, right: 5, bottom: 1),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.8),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            )
                          ]),
                      child: Material(
                        color: Colors.white,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ViewPaymentsPage(),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            shape:
                            WidgetStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                    color: Colors.green), // Optional border side
                              ),
                            ),
                            overlayColor: WidgetStateColor.resolveWith((states) =>
                                Colors.green.withOpacity(0.2)), // Splash color
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
                                'Your orders',
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
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 30),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.only(
                          top: 1, left: 5, right: 5, bottom: 1),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.8),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            )
                          ]),
                      child: Material(
                        color: Colors.white,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Sample(),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            shape:
                            WidgetStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                    color: Colors.green), // Optional border side
                              ),
                            ),
                            overlayColor: WidgetStateColor.resolveWith((states) =>
                                Colors.green.withOpacity(0.2)), // Splash color
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
                                'View orders',
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
