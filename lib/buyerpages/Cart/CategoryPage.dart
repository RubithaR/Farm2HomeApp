import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veg/buyerpages/Cart/FruitsPage.dart';
import 'package:veg/buyerpages/Cart/GrainsPage.dart';
import 'package:veg/buyerpages/Cart/VegetablesPage.dart';
import 'package:veg/buyerpages/Cart/coffee_tile.dart';
import 'package:veg/buyerpages/Cart/model.dart';
import 'package:veg/buyerpages/Cart/model_cart.dart';

class CategoryPage extends StatefulWidget {
  final void Function(int)? onTabChange; // Define the callback property

  const CategoryPage({Key? key, required this.onTabChange}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  void addToCart(CartModel cartModel) {
    int indexToNavigate;

    switch (cartModel.name) {
      case 'Vegetables':
        indexToNavigate = 2; // Index of the vegetables page in the bottom navigation bar
        break;
      case 'Fruits':
        indexToNavigate = 3; // Index of the fruits page in the bottom navigation bar
        break;
      case 'Grains':
        indexToNavigate = 4; // Index of the grains page in the bottom navigation bar
        break;
      default:
        indexToNavigate = 0; // Default to first page if no matching category
    }

    // Call the onTabChange callback passed from the parent widget
    widget.onTabChange?.call(indexToNavigate);
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
                "CATEGORIES",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 25),

              //categories list
              Expanded(
                child: ListView.builder(
                  itemCount: value.categories.length,
                  itemBuilder: (context, index) {
                    //get
                    CartModel eachCart = value.categories[index];

                    //return the title of item
                    return CoffeeTile(
                      cartModel: eachCart,
                      icon: Icon(Icons.navigate_next_outlined),
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
