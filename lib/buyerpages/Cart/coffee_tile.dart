import 'package:flutter/material.dart';
import 'package:veg/buyerpages/Cart/model.dart';

class CoffeeTile extends StatelessWidget{
  final CartModel cartModel;
  void Function()? onPressed;
  final Widget icon;
  CoffeeTile({super.key, required this.cartModel, required this.onPressed, required this.icon});

  @override
  Widget build(BuildContext context){
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.8),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                )
          ],),
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(vertical: 25, horizontal: 10),
      child: ListTile(
        title: Text(
            cartModel.name.toString(),
            style: TextStyle(
              color: Colors.green,
              fontSize: 18,
              fontWeight: FontWeight.bold
            ),),
        subtitle: Text(
          cartModel.quantity.toString(),
          style: TextStyle(
            color: Colors.black,
            fontSize: 12.0,
            fontWeight: FontWeight.normal,
          ),
        ),
        leading: Image.asset(
          cartModel.imagePath,
          width: 70,
          height: 180,
          fit: BoxFit.cover,
        ),
        trailing: IconButton(
          icon: icon,
          onPressed: onPressed,
        ),
      ),
    );
  }
}