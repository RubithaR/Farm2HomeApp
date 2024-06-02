
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Fruits extends StatefulWidget {
  const Fruits({super.key});

  @override
  State<Fruits> createState() => _FruitsState();
}

class _FruitsState extends State<Fruits> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Fruits',
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
                                hintText: "Search Vegetable",
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
                    padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child : Hero(
                            tag: 'fishesHro',

                            child: Container(
                              padding: const EdgeInsets.all(6),
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
                                ],
                              ),
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/seller_image/eggs.jpeg',
                                    width: 150, // Adjust width as needed
                                    height: 150, // Adjust height as needed
                                    fit: BoxFit.contain, // Ensures the image scales properly
                                  ),
                                  const Text(
                                    'Eggs',
                                    style: TextStyle(fontSize: 20, fontWeight : FontWeight.w700,color: Colors.green),
                                  ),
                                  const SizedBox(height: 6),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child : Hero(
                            tag: 'eggHero',

                            child: Container(
                              padding: const EdgeInsets.all(6),
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
                                ],
                              ),
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/seller_image/fishes.jpeg',
                                    width: 150, // Adjust width as needed
                                    height: 150, // Adjust height as needed
                                    fit: BoxFit.contain, // Ensures the image scales properly
                                  ),
                                  const Text(
                                    'Fishes',
                                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700, color: Colors.green),
                                  ),
                                  const SizedBox(height: 6),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child : Hero(
                            tag: 'fishesHro',

                            child: Container(
                              padding: const EdgeInsets.all(6),
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
                                ],
                              ),
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/seller_image/eggs.jpeg',
                                    width: 150, // Adjust width as needed
                                    height: 150, // Adjust height as needed
                                    fit: BoxFit.contain, // Ensures the image scales properly
                                  ),
                                  const Text(
                                    'Eggs',
                                    style: TextStyle(fontSize: 20, fontWeight : FontWeight.w700,color: Colors.green),
                                  ),
                                  const SizedBox(height: 6),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child : Hero(
                            tag: 'eggHero',

                            child: Container(
                              padding: const EdgeInsets.all(6),
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
                                ],
                              ),
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/seller_image/fishes.jpeg',
                                    width: 150, // Adjust width as needed
                                    height: 150, // Adjust height as needed
                                    fit: BoxFit.contain, // Ensures the image scales properly
                                  ),
                                  const Text(
                                    'Fishes',
                                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700, color: Colors.green),
                                  ),
                                  const SizedBox(height: 6),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child : Hero(
                            tag: 'fishesHro',

                            child: Container(
                              padding: const EdgeInsets.all(6),
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
                                ],
                              ),
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/seller_image/eggs.jpeg',
                                    width: 150, // Adjust width as needed
                                    height: 150, // Adjust height as needed
                                    fit: BoxFit.contain, // Ensures the image scales properly
                                  ),
                                  const Text(
                                    'Eggs',
                                    style: TextStyle(fontSize: 20, fontWeight : FontWeight.w700,color: Colors.green),
                                  ),
                                  const SizedBox(height: 6),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child : Hero(
                            tag: 'eggHero',

                            child: Container(
                              padding: const EdgeInsets.all(6),
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
                                ],
                              ),
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/seller_image/fishes.jpeg',
                                    width: 150, // Adjust width as needed
                                    height: 150, // Adjust height as needed
                                    fit: BoxFit.contain, // Ensures the image scales properly
                                  ),
                                  const Text(
                                    'Fishes',
                                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700, color: Colors.green),
                                  ),
                                  const SizedBox(height: 6),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child : Hero(
                            tag: 'fishesHro',

                            child: Container(
                              padding: const EdgeInsets.all(6),
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
                                ],
                              ),
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/seller_image/eggs.jpeg',
                                    width: 150, // Adjust width as needed
                                    height: 150, // Adjust height as needed
                                    fit: BoxFit.contain, // Ensures the image scales properly
                                  ),
                                  const Text(
                                    'Eggs',
                                    style: TextStyle(fontSize: 20, fontWeight : FontWeight.w700,color: Colors.green),
                                  ),
                                  const SizedBox(height: 6),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child : Hero(
                            tag: 'eggHero',

                            child: Container(
                              padding: const EdgeInsets.all(6),
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
                                ],
                              ),
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/seller_image/fishes.jpeg',
                                    width: 150, // Adjust width as needed
                                    height: 150, // Adjust height as needed
                                    fit: BoxFit.contain, // Ensures the image scales properly
                                  ),
                                  const Text(
                                    'Fishes',
                                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700, color: Colors.green),
                                  ),
                                  const SizedBox(height: 6),
                                ],
                              ),
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
                  SizedBox(
                    height: 43.0,
                    width: 170,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
