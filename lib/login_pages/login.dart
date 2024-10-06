import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:veg/buyerpages/homepage_buyer.dart';
import 'package:veg/login_pages/forgetpassword.dart';
import 'package:veg/login_pages/signup_buyer.dart';
import 'package:veg/login_pages/signup_seller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:veg/sellerpages/homepage_seller.dart';
import 'package:geolocator/geolocator.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});
  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  Future<Position> getCurrentLocation(BuildContext context) async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, show a dialog
      _showLocationServiceDialog(context);
      return Future.error('Location services are disabled.');
    }

    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permission denied, show an error dialog
        _showPermissionDeniedDialog(context);
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, show an error dialog
      _showPermissionDeniedDialog(context);
      return Future.error('Location permissions are permanently denied.');
    }

    // If everything is okay, return the current position
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

// Function to show the location services dialog
  void _showLocationServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text('Please enable location services in your settings.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

// Function to show the permission denied dialog
  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Location Permission Denied'),
        content: const Text('Please grant location permission in your settings.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    try {
      // Sign in user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Get current location before storing
        Position position;
        try {
          position = await getCurrentLocation(context);
        } catch (e) {
          _showErrorDialog('Error fetching location: $e');
          return; // Stop further execution if there's an error
        }

        // Store user location in the database
        String uid = user.uid;
        DatabaseReference userRef = FirebaseDatabase.instance.ref().child("Users").child(uid);

        await userRef.update({
          'location': {
            'latitude': position.latitude,
            'longitude': position.longitude,
          }
        });

        // Fetch user data
        DatabaseEvent event = await userRef.once();
        if (event.snapshot.exists) {
          Map<dynamic, dynamic>? userData = event.snapshot.value as Map<dynamic, dynamic>?;
          if (userData != null) {
            if (userData['role'] == 'Buyer') {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePageBuyer()));
            } else if (userData['role'] == 'Seller') {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePageSeller()));
            } else {
              _showErrorDialog('Unknown user role');
            }
          } else {
            _showErrorDialog('User data is null');
          }
        } else {
          _showErrorDialog('No data found for this user');
        }
      } else {
        _showErrorDialog('User ID is null');
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An error occurred'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: const Text(
          'LogIn',
          style: TextStyle(fontSize: 20.0, color: Colors.white),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  "assets/images/vegetable.jpg",
                  height: height * 0.35,
                  width: width,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'LOGIN',
                    style: TextStyle(
                      color: Colors.lightGreen,
                      fontSize: 30.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _emailController,
                        validator: (email) {
                          if (email!.isEmpty) {
                            return "Please Enter Email";
                          } else if (!RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(email)) {
                            return "It's Not a valid Email";
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.people),
                          labelText: 'Username',
                          labelStyle: TextStyle(fontSize: 20),
                          hintText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: true,
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _passwordController,
                        validator: (password) {
                          if (password!.isEmpty) {
                            return "Please Enter password";
                          } else if (password.length < 8) {
                            return "Password length is lower than 8 characters";
                          } else if (password.length > 15) {
                            return "Password length is higher than 15 characters";
                          }
                          return null;
                        },
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_open),
                          labelText: 'Password',
                          labelStyle: const TextStyle(fontSize: 20),
                          hintText: 'Password',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.remove_red_eye_sharp),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Forgotpassword()),
                            );
                          },
                          child: const Text('Forget Password?'),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      SizedBox(
                        height: 43.0,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text(
                            'Log In',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            "Don't have an Account?",
                            style: TextStyle(fontSize: 15),
                          ),
                          TextButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Container(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(height: 20.0),
                                        const ListTile(
                                          title: Text(
                                            "Create Account:",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          leading: const Icon(
                                            Icons.people_alt_outlined,
                                            color: Colors.green,
                                          ),
                                          title: const Text("Seller"),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                  const SignUpScreenSeller()),
                                            );
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(
                                            Icons.people_alt_outlined,
                                            color: Colors.green,
                                          ),
                                          title: const Text("Buyer"),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                  const SignUpScreenBuyer()),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: const Text('Create Account'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
