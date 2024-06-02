import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:veg/buyerpages/homepage_buyer.dart';
import 'package:veg/firebase_options.dart';
import 'package:veg/login_pages/login.dart';
import 'package:veg/sellerpages/homepage_seller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePageSeller(),
    );
  }
}
