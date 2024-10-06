import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:veg/sellerpages/categories/vegetable_only/vegetable_adding.dart';
import 'package:veg/sellerpages/categories/vegetable_only/vegetable_update.dart'; // Assume this navigates to vegetable details

class AddItemsPage extends StatefulWidget {
  const AddItemsPage({super.key});

  @override
  State<AddItemsPage> createState() => _AddItemsPageState();
}

class _AddItemsPageState extends State<AddItemsPage> {
  User? currentFirebaseUser;

  @override
  void initState() {
    super.initState();
    // Retrieve the current logged-in Firebase user
    currentFirebaseUser = FirebaseAuth.instance.currentUser;
    print("Current User: $currentFirebaseUser");
  }

  @override
  Widget build(BuildContext context) {
    if (currentFirebaseUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("No User Logged In"),
        ),
        body: const Center(
          child: Text("Please log in to access your data."),
        ),
      );
    }

    // Reference to the current user's vegetable details in Firebase
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child("sellers")
        .child(currentFirebaseUser!.uid)
        .child("vegetable_details");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Add Items',
          style: TextStyle(fontSize: 20.0, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
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
                  ),
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
          ),

          // Added Items List or No Data message
          Expanded(
            child: FirebaseAnimatedList(
              query: ref,
              defaultChild: const Center(
                child: CircularProgressIndicator(), // Show loader while data is loading
              ),
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                if (snapshot.exists) {
                  Map item = snapshot.value as Map;
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(10),

                      child: ListTile(
                        title: Text(
                          item['name_veg'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, // Bold text for vegetable name
                            fontSize: 18, // Increase font size for vegetable name
                          ),),
                        subtitle: RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: "Price per kg: ",
                                style: TextStyle(color: Colors.black), // Normal text
                              ),
                              TextSpan(
                                text: "${item['price']} Rs", // Bold price amount with Rs
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              ),


                              const TextSpan(
                                text: ", Available Quantity: ", // Normal quantity
                                style:  TextStyle(color: Colors.black),
                              ),
                              TextSpan(
                                text: "${item['quantity']} kg", // Bold price amount with Rs
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              ),

                            ],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.update, color: Colors.green),
                              onPressed: () {
                                // Handle update functionality
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VegetableUpdate(
                                      itemId: snapshot.key!,
                                      name: item['name_veg'],
                                      price: item['price'],
                                      quantity: item['quantity'],
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                ref.child(snapshot.key!).remove();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return const Center(
                    child: Text('No Data Found'),
                  );
                }
              },
            ),
          ),

          // Add more items button
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
                      ),
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
                              hintStyle: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w700),
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
                                  const VegetableOne(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Add',
                              style:
                              TextStyle(fontSize: 20, color: Colors.white),
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
    );
  }
}
