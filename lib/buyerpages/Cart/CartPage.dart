import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veg/buyerpages/Cart/coffee_tile.dart';
import 'package:veg/buyerpages/Cart/model.dart';
import 'package:veg/buyerpages/Cart/model_cart.dart';

class CartPage extends StatefulWidget{
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage>{

  //remove cart item
  void removeFromCart(CartModel cartModel){
    Provider.of<ModelCartUse>(context, listen: false).removeItemFromCart(cartModel);

    final snackBar = SnackBar(
      content: Text('Successfully removed from the cart'),
      duration: Duration(seconds: 1),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context){
    return Consumer<ModelCartUse>(
      builder: (context, value, child) =>     SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              children: [Text('Your Cart', style: TextStyle(fontSize: 20),),

                //list of cart items
                Expanded(child: ListView.builder(itemCount: value.userCart.length, itemBuilder: (context, index){
                  //get individual
                  CartModel eachmodel = value.userCart[index];

                  //return the coffee tile
                  return CoffeeTile(cartModel: eachmodel, onPressed: () => removeFromCart(eachmodel), icon: Icon(Icons.delete),);
                }
                ),)
              ],


            ),
          )
      ),
    );

  }
}