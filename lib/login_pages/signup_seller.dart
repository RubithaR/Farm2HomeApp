import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:veg/authentication/auth.dart';
import 'package:veg/login_pages/login.dart';

class SignUpScreenSeller extends StatefulWidget {
  const SignUpScreenSeller({super.key});

  @override
  State<SignUpScreenSeller> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreenSeller> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController _firstnamecontroller = TextEditingController();
  final TextEditingController _secondnamecontroller = TextEditingController();
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  final TextEditingController _phonecontroller = TextEditingController();

  @override
  void dispose() {
    _firstnamecontroller.dispose();
    _secondnamecontroller.dispose();
    _emailcontroller.dispose();
    _passwordcontroller.dispose();
    _phonecontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightGreen,
          title: const Text(
            'Create Account',
            style: TextStyle(fontSize: 20.0, color: Colors.white),
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Center(
                    child: Text(
                      'Sign Up',
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
                            controller: _firstnamecontroller,
                            decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.people_alt_outlined),
                                labelText: 'First Name',
                                labelStyle: TextStyle(fontSize: 20),
                                hintText: 'First Name',
                                border: OutlineInputBorder()),
                            keyboardType: TextInputType.text,
                            autocorrect: true,
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            controller: _secondnamecontroller,
                            decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.people_alt_outlined),
                                labelText: 'Second Name',
                                labelStyle: TextStyle(fontSize: 20),
                                hintText: 'Second Name',
                                border: OutlineInputBorder()),
                            keyboardType: TextInputType.text,
                            autocorrect: true,
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            controller: _phonecontroller,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.phone_android_outlined),
                              labelText: 'Phone No',
                              labelStyle: TextStyle(fontSize: 20),
                              hintText: 'Phone No',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          TextFormField(
                            controller: _emailcontroller,
                            validator: (email) {
                              if (email!.isEmpty) {
                                return "Please Enter Email";
                              } else if (!RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(email)) {
                                return "It's Not a valid Email";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.email_outlined),
                                labelText: 'Email',
                                labelStyle: TextStyle(fontSize: 20),
                                hintText: 'Email',
                                border: OutlineInputBorder()),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: true,
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            controller: _passwordcontroller,
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
                            height: 30.0,
                          ),
                          SizedBox(
                            height: 43.0,
                            width: double.infinity,
                            child: ElevatedButton(
                                onPressed: _signUp,
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.grey),
                                )),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text(
                                "Already have an Account?",
                                style: TextStyle(fontSize: 15),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LogInScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Log In",
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

  void _signUp() async {
    String firstname = _firstnamecontroller.text;
    String secondname = _secondnamecontroller.text;
    String email = _emailcontroller.text;
    String password = _passwordcontroller.text;
    String phone = _phonecontroller.text;

    User? user = await _auth.signUpWithEmailAndPassword(email, password);
    if (user != null) {
      print("user is success");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LogInScreen(),
        ),
      );
    } else {
      print("some error happen");
    }
  }
}
