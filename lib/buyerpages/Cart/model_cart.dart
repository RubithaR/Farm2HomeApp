import 'package:flutter/material.dart';

import 'model.dart';

class ModelCartUse extends ChangeNotifier{
  //categories
  final List<CartModel> _categories = [
    CartModel(name: 'Vegetables', quantity: 'Category', imagePath: 'assets/images/buyer_homepage/vegetables.jpeg'),
    CartModel(name: 'Fruits', quantity: 'Category', imagePath: 'assets/images/seller_image/fruits.jpeg'),
    CartModel(name: 'Grains', quantity: 'Category', imagePath: 'assets/images/seller_image/grains.jpeg'),
  ];

  //vegetables
  final List<CartModel> _vegetables = [
    CartModel(name: 'Carrot', quantity: '1Kg', imagePath: 'assets/images/seller_image/Vegetables/carrot.jpg'),
    CartModel(name: 'Onion', quantity: '1Kg', imagePath: 'assets/images/seller_image/Vegetables/onion.jpg'),
  ];

  //fruits
  final List<CartModel> _fruits = [
    CartModel(name: 'Apple',quantity: '1Kg', imagePath: 'assets/images/seller_image/Fruits/Apple.jpg'),
    CartModel(name: 'Pineapple',quantity: '1Kg', imagePath: 'assets/images/seller_image/Fruits/pinapple.jpg'),
    CartModel(name: 'Pomegranate',quantity: '1Kg', imagePath: 'assets/images/seller_image/Fruits/Pomegranate.jpg'),
    CartModel(name: 'Papaya',quantity: '1Kg', imagePath: 'assets/images/seller_image/Fruits/Papaya.jpeg'),
    CartModel(name: 'Orange',quantity: '1Kg', imagePath: 'assets/images/seller_image/Fruits/Orange.jpg'),
  ];

  final List<CartModel> _grains = [
    CartModel(name: 'Carrot',quantity: '1Kg', imagePath: 'assets/images/seller_image/Vegetables/carrot.jpg'),
    CartModel(name: 'Onion',quantity: '1Kg', imagePath: 'assets/images/seller_image/Vegetables/onion.jpg'),
  ];

  //user cart
  List<CartModel> _userCart = [];




  //get user cart
  List<CartModel> get userCart => _userCart;


  //get categories
  List<CartModel> get categories => _categories;

  //get vegetables
  List<CartModel> get vegetables => _vegetables;

  //get fruits
  List<CartModel> get fruits => _fruits;

  //get grains
  List<CartModel> get grains => _grains;

  //add item to cart
  void addItemToCart(CartModel cartmodel){
    _userCart.add(cartmodel);
    notifyListeners();
  }

  //remove item from cart
  void removeItemFromCart(CartModel cartmodel){
    _userCart.remove(cartmodel);
    notifyListeners();
  }
  
}