import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:veg/sellerpages/categories/fruits_two.dart';
import 'package:veg/sellerpages/categories/vegetable_only/vegetable_adding.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text(
            'Categories',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
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
                              hintText: "Search Categories",
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
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
                              Flexible(
                                child: Image.asset(
                                  'assets/images/seller_image/vegetables.jpeg',
                                  width: 110, // Adjust width as needed
                                  height: 110, // Adjust height as needed
                                  fit: BoxFit
                                      .contain, // Ensures the image scales properly
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    hintText: "Vegetable",
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              FloatingActionButton(
                                  heroTag: 'veg',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const VegetableOne(),
                                      ),
                                    );
                                  },
                                  backgroundColor: Colors.green,
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
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
                              Flexible(
                                child: Image.asset(
                                  'assets/images/seller_image/fruits.jpeg',
                                  width: 110, // Adjust width as needed
                                  height: 110, // Adjust height as needed
                                  fit: BoxFit
                                      .contain, // Ensures the image scales properly
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    hintText: "Fruits",
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              FloatingActionButton(
                                  heroTag: 'fruits',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Fruits(),
                                      ),
                                    );
                                  },
                                  backgroundColor: Colors.green,
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
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
                              Flexible(
                                child: Image.asset(
                                  'assets/images/seller_image/grains.jpeg',
                                  width: 110, // Adjust width as needed
                                  height: 110, // Adjust height as needed
                                  fit: BoxFit
                                      .contain, // Ensures the image scales properly
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    hintText: "Grains",
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const FloatingActionButton(
                                  heroTag: null,
                                  onPressed:
                                      (null) /*{
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                        const Categories(),
                                      ),
                                    );
                                  }*/
                                  ,
                                  backgroundColor: Colors.green,
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  )),
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
        ));
  }
}
