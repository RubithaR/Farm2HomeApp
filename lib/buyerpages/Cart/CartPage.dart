import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veg/buyerpages/AfterCartConfirm.dart';
import 'package:veg/buyerpages/Cart/coffee_tile.dart';
import 'package:veg/buyerpages/Cart/model.dart';
import 'package:veg/buyerpages/Cart/model_cart.dart';
import 'package:veg/buyerpages/homepage_buyer.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Remove cart item
  void removeFromCart(CartModel cartModel) {
    Provider.of<ModelCartUse>(context, listen: false)
        .removeItemFromCart(cartModel);

    final snackBar = const SnackBar(
      content: Text('Successfully removed from the cart'),
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
              const Text(
                'Your Cart',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              // List of cart items
              Expanded(
                child: ListView.builder(
                  itemCount: value.userCart.length,
                  itemBuilder: (context, index) {
                    // Get individual cart item
                    CartModel eachModel = value.userCart[index];

                    // Return the coffee tile
                    return CoffeeTile(
                      cartModel: eachModel,
                      onPressed: () => removeFromCart(eachModel),
                      icon: const Icon(Icons.delete),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Buttons to navigate to other pages
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePageBuyer(),
                        ),
                      );
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(

                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Aftercartconfirm(),
                        ),
                      );
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
