import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:veg/buyerpages/homepage_buyer.dart';
import 'package:veg/login_pages/forgetpassword.dart';
import 'package:veg/login_pages/signup_buyer.dart';
import 'package:veg/login_pages/signup_seller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:veg/sellerpages/homepage_seller.dart';


class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});
  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref("Users");
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();


  void _signIn() async {
    try {
      UserCredential newUser = await _auth.signInWithEmailAndPassword(
        email: _emailcontroller.text,
        password: _passwordcontroller.text,
      );
      if (newUser != null) {
        User? user = _auth.currentUser;
        String? userId = user?.uid;
        print('User ID: $userId');
        if (userId != null) {
          print('Hi1');


          DatabaseReference userRef = FirebaseDatabase.instance.ref().child("Users").child(userId);
          DatabaseEvent event;
          try {
            event = await userRef.once();
          } catch (e) {
            print('Error fetching data: $e');
            return;
          }
          print('Snapshot: ${event.snapshot.value}');
          if (event.snapshot.exists) {
            print('Hi2');
            Map<dynamic, dynamic>? userData = event.snapshot.value as Map<dynamic, dynamic>?;
            if (userData != null) {
              print('User Data: $userData');
              setState(() {
                if (userData['role'] == 'Buyer') {
                  print('Hi3');
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomePageBuyer()));
                } else if (userData['role'] == 'Seller') {
                  print('Hi4');
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomePageSeller()));
                }
              });
            } else {
              print('User data is null');
            }
          } else {
            print('No data found for this user');
          }
        } else {
          print('User ID is null');
        }
      } else {
        print('UserCredential is null');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  @override
  void dispose() {
    _emailcontroller.dispose();
    _passwordcontroller.dispose();
    super.dispose();
  }
  //local variable can't access out site the class

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
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            controller: _emailcontroller,
                            /*  onSaved: (value){
                              _email = value!;

                            }, */
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
                                border: OutlineInputBorder()),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: true,
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            controller: _passwordcontroller,

                            /*onSaved: (value){
                              _password = value!;

                            },*/
                            validator: (password) {
                              if (password!.isEmpty) {
                                return "Please Enter password";
                              } else if (password.length < 8) {
                                return "Password length is lower than 8 character";
                              } else if (password.length > 15) {
                                return "Password length is higher than 15 character";
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
                                    icon: const Icon(
                                        Icons.remove_red_eye_sharp))),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Forgotpassword()),
                                  );
                                },
                                child: const Text('Forget Password?')),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          SizedBox(
                            height: 43.0,
                            width: double.infinity,
                            child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    _signIn();
                                  }
                                },
                                style:  ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,

                                ),
                                child: const Text(
                                  'Log In',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white),
                                )),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text(
                                "Don't have an Account?",
                                style: TextStyle(fontSize: 15),
                              ),
                              TextButton(
                                onPressed: () {
                                    showModalBottomSheet(context: context, builder: (context){
                                      return Container(
                                        padding: const EdgeInsets.only(bottom: 20),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const SizedBox(
                                              height: 20.0,
                                            ),
                                            const ListTile(
                                              title: Text("Create Account : ", style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green
                                              )),
                                            ),
                                            ListTile(
                                              leading: const Icon(Icons.people_alt_outlined, color: Colors.green,),
                                              title: const Text("Seller"),
                                              onTap: (){
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreenSeller()));
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(Icons.people_alt_outlined, color: Colors.green,),
                                              title: const Text("Buyer"),
                                              onTap: (){
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreenBuyer()));
                                              },
                                            ),
                                            const SizedBox(
                                              height: 20.0,
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                                },
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                              )
                            ],
                          )
                        ],
                      )),
                ],
              ),
            ),
          ),
        ));
  }

}
