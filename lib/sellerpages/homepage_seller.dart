import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Home',
          style: TextStyle(fontSize: 20.0, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              child: Column(
                children: [
                  Container(
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
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.search,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                hintText: "Search Item",
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              )
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      hintText: "ADD ITEM",
                                      hintStyle: TextStyle( fontSize : 17 , fontWeight: FontWeight.w700),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: TextButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                          const Categories(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Add',
                                      style: TextStyle( fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(
                    height: 43.0,
                    width: 170,
                    child: Hero(
                      tag: 'cancel',

                    child: ElevatedButton(

                      onPressed: () {
                        // Your cancel logic here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ),
                  ),
                  SizedBox(
                    height: 43.0,
                    width: 170,
                    child : Hero(
                      tag: 'update',

                    child: ElevatedButton(
                      onPressed: () {
                        // Your update logic here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text(
                        'Update',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
