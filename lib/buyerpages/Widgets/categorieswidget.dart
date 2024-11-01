import 'package:flutter/material.dart';
import 'package:veg/buyerpages/AfterCartConfirm.dart';

class CategoriesWidget extends StatefulWidget{
  const CategoriesWidget({super.key});

  @override
  State<CategoriesWidget> createState() => _CategoriesWidgetState();
}

class _CategoriesWidgetState extends State<CategoriesWidget> {
  @override
  Widget build(BuildContext context){
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
        child: Row(
          children: [
            //Single item of horizontal axis scroll
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: GestureDetector(
                onTap: (){
                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (context) => const Aftercartconfirm(
                              vegName: 'carrot'
                          )));
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 1, left: 6, right: 6, bottom: 1),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.8),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0,3),
                          )
                      ]

                  ),
                  child: Image.asset(
                    "assets/images/seller_image/Vegetables/carrot.jpg",
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: GestureDetector(
                onTap: (){
                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (context) => const Aftercartconfirm(
                              vegName: 'apple'
                          )));
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 1, left: 6, right: 6, bottom: 1),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.8),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0,3),
                        )
                      ]

                  ),
                  child: Image.asset(
                    "assets/images/seller_image/Fruits/Apple.jpg",
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: GestureDetector(
                onTap: (){
                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (context) => const Aftercartconfirm(
                              vegName: 'Banana'
                          )));
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 1, left: 6, right: 6, bottom: 1),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.8),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0,3),
                        )
                      ]

                  ),
                  child: Image.asset(
                    "assets/images/seller_image/Fruits/Banana.jpg",
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: GestureDetector(
                onTap: (){
                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (context) => const Aftercartconfirm(
                              vegName: 'broccoli'
                          )));
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 1, left: 6, right: 6, bottom: 1),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.8),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0,3),
                        )
                      ]

                  ),
                  child: Image.asset(
                    "assets/images/seller_image/Vegetables/broccoli.jpg",
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: GestureDetector(
                onTap: (){
                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (context) => const Aftercartconfirm(
                              vegName: 'Avacado'
                          )));
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 1, left: 6, right: 6, bottom: 1),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.8),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0,3),
                        )
                      ]

                  ),
                  child: Image.asset(
                    "assets/images/seller_image/Fruits/Avacado.jpg",
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: GestureDetector(
                onTap: (){
                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (context) => const Aftercartconfirm(
                              vegName: 'beetroot'
                          )));
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 1, left: 6, right: 6, bottom: 1),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.8),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0,3),
                        )
                      ]

                  ),
                  child: Image.asset(
                    "assets/images/seller_image/Vegetables/beetroot.jpg",
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: GestureDetector(
                onTap: (){
                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (context) => const Aftercartconfirm(
                              vegName: 'Cocunut'
                          )));
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 1, left: 6, right: 6, bottom: 1),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.8),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0,3),
                        )
                      ]

                  ),
                  child: Image.asset(
                    "assets/images/seller_image/Vegetables/Cocunut.jpg",
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}