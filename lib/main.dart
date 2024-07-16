import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veg/buyerpages/Cart/model_cart.dart';
import 'package:veg/buyerpages/homepage_buyer.dart';
import 'package:veg/login_pages/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isIOS
      ? await Firebase.initializeApp(
      options: const FirebaseOptions(
      apiKey: "AIzaSyAyQ4rvmeNa17xKFD-g7SA7K4ktwf6qmlI",
      appId: '1:881238033694:ios:e150f75f8b8852acc4350f',
      messagingSenderId: '881238033694',
      projectId: 'farm2home-bfb60',
      ))
      : await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyA9GskZpUFgljTermxTw-HVE3O6g_GtlIc",
        appId: '1:881238033694:android:bd37d29e4ecee0d5c4350f',
        messagingSenderId: '881238033694',
        projectId: 'farm2home-bfb60',));


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
      return ChangeNotifierProvider(
          create: (context) => ModelCartUse(),
          builder: (context, child) => const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: HomePageBuyer(),
          ),
      );
  }
}
