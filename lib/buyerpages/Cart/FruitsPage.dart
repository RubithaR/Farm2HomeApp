import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veg/buyerpages/Cart/coffee_tile.dart';
import 'package:veg/buyerpages/Cart/model.dart';
import 'package:veg/buyerpages/Cart/model_cart.dart';

class FruitsPage extends StatefulWidget{
  const FruitsPage({super.key});

  @override
  State<FruitsPage> createState() => _FruitsPageState();
}

class _FruitsPageState extends State<FruitsPage>{
  void addToCart(CartModel cartModel){

    //add to cart
    Provider.of<ModelCartUse>(context, listen: false).addItemToCart(cartModel);

    //notification for successful adding
    final snackBar = SnackBar(
      content: Text('Successfully added to the cart'),
      duration: Duration(seconds: 1),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

  }
  @override
  Widget build(BuildContext context) {
    return Consumer<ModelCartUse>(
      builder: (context, value, child) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              //heading
              const Text(
                "FRUITS CATEGORY",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 25),

              //categories list
              Expanded(
                child: ListView.builder(
                  itemCount: value.fruits.length,
                  itemBuilder: (context, index) {
                    //get
                    CartModel eachCart = value.fruits[index];

                    //return the title of item
                    return CoffeeTile(
                      cartModel: eachCart,
                      icon: Icon(Icons.add),
                      onPressed: () => addToCart(eachCart),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}