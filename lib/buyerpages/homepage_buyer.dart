import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:veg/googlemapscreens/current_location_screen.dart';
import '../buyerpages/Widgets/appbarwidget.dart';
import '../buyerpages/Widgets/categorieswidget.dart';

class HomePageBuyer extends StatefulWidget{
  const HomePageBuyer({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePageBuyer> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: ListView(
        children: [
          //Custom App Bar Widget
          const AppBarWidget(),

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
                      offset: const Offset(0,3),
                    )
                  ]),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: Row(children: [
                  const Icon(CupertinoIcons.search, color: Colors.green,
                  ),
                  const SizedBox(
                    height: 20,) ,
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        hintText: "What would you like to buy?",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  const Icon(Icons.filter_list, color: Colors.green,),
                ],),
              ),
            ),
          ),

          //Category
          const Padding(padding: EdgeInsets.only(top: 20, left: 10),
            child: Text(
              "Categories",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.green,
              ),
            ) ,
          ),

          //Category scroll axis
          const CategoriesWidget(),

          const Padding(padding: EdgeInsets.symmetric(vertical: 10)),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            child: Row(
              children: [
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CurrentLocationScreen()));
                  },
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
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        splashColor: Colors.green,
                        child: Column(
                          children: [
                            Ink.image(
                              image: const AssetImage('assets/images/buyer_homepage/vegetables.jpeg'),
                              height: 150,
                              width: 150,
                            ),
                            const Text('Find Nearby \n     Sellers',
                              style: TextStyle(fontSize: 20, color: Colors.green),),
                            const SizedBox(height: 6),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(right: 46),),
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
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        splashColor: Colors.green,
                        child: Column(
                          children: [
                            Ink.image(
                              image: const AssetImage('assets/images/buyer_homepage/vegetables.jpeg'),
                              height: 150,
                              width: 150,
                            ),
                            const Text('My Location',
                              style: TextStyle(fontSize: 20, color: Colors.green),),
                            const SizedBox(height: 6),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

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
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        splashColor: Colors.green,
                        child: Column(
                          children: [
                            Ink.image(
                              image: const AssetImage('assets/images/buyer_homepage/vegetables.jpeg'),
                              height: 150,
                              width: 150,
                            ),
                            const Text('My Location',
                              style: TextStyle(fontSize: 20, color: Colors.green),),
                            const SizedBox(height: 6),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(right: 46),),
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
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        splashColor: Colors.green,
                        child: Column(
                          children: [
                            Ink.image(
                              image: const AssetImage('assets/images/buyer_homepage/vegetables.jpeg'),
                              height: 150,
                              width: 150,
                            ),
                            const Text('View Orders', style: TextStyle(fontSize: 20, color: Colors.green),),
                            const SizedBox(height: 6),

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