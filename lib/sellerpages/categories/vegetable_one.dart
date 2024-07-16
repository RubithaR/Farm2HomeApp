import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VegetableOne extends StatefulWidget {
  const VegetableOne({super.key});

  @override
  State<VegetableOne> createState() => _VegetableOneState();
}

class _VegetableOneState extends State<VegetableOne> {
  TextEditingController priceController =TextEditingController();
  TextEditingController quantityController =TextEditingController();

  final CollectionReference  vegetableItems = FirebaseFirestore.instance.collection("Vegetable") ;
  Future<void> vegetableData()  async{
    return showDialog(
      context: context,
      builder: (BuildContext context){
        return myDialogBox( context: context ,
            onPressed:(){
              String price = priceController.text;
              String quantity = quantityController.text;
              vegetableItems.add({
                'price' :price ,
                'quantity' : quantity
              });
              Navigator.pop(context);
            });
      },
    ) ;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Vegetable',
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 25, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: vegetableData,
                          child: Hero(
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
                                    'assets/images/seller_image/Vegetables/carrot.jpg',
                                    width: 150, // Adjust width as needed
                                    height: 150, // Adjust height as needed
                                    fit: BoxFit
                                        .contain, // Ensures the image scales properly
                                  ),
                                  const Text(
                                    'Carrot',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.green),
                                  ),
                                  const SizedBox(height: 6),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Hero(
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
                                    'assets/images/seller_image/Vegetables/onion.jpg',
                                    width: 150, // Adjust width as needed
                                    height: 150, // Adjust height as needed
                                    fit: BoxFit
                                        .contain, // Ensures the image scales properly
                                  ),
                                  const Text(
                                    'Onion',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.green),
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
  Dialog myDialogBox({
    required BuildContext context,
    required VoidCallback onPressed ,
  }){
    return Dialog(
      shape : RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ) ,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child:Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Add the details",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18 ,
                    ),
                  ),
                  IconButton(onPressed: () {
                    Navigator.pop(context);

                  },
                      icon: const Icon(Icons.close))
                ],
              ),
              commonTextField("eg.  00.00 Rs " , "Enter price of one kilo" , priceController),
              commonTextField("eg.  00.00 kg" , "Enter price quantity in kilo" , quantityController),
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green ,
                ),
                child: const Text(
                  'Store' ,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),

                ),
              ),
              const SizedBox(height: 10,) ,


            ],
          ),
        ),
      ) ,
    ) ;
  }
  Padding  commonTextField(hint,label, controller){
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20 ,
        vertical: 8,
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          labelText:label,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: Colors.green,
              width : 2,
            ),
          ),
          enabledBorder:OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: Colors.green,
              width : 2,
            ),
          ),
        ),
      ),
    );
  }

}