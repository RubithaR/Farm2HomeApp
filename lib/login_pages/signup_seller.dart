
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:veg/login_pages/login.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:veg/authentication/auth.dart';
import 'package:firebase_storage/firebase_storage.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SignUpScreenSeller());
}

class SignUpScreenSeller extends StatefulWidget {
  const SignUpScreenSeller({super.key});

  @override
  State<SignUpScreenSeller> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreenSeller> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController _firstnamecontroller = TextEditingController();
  final TextEditingController _districtcontroller = TextEditingController();
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  final TextEditingController _phonecontroller = TextEditingController();
  Uint8List? _image;
  bool isSecurePassword = true ;

  // District list for dropdown
  final List<String> districts = [
    "Ampara", "Anuradhapura", "Badulla", "Batticaloa", "Colombo", "Galle",
    "Gampaha", "Hambantota", "Jaffna", "Kalutara", "Kandy", "Kegalle",
    "Kilinochchi", "Kurunegala", "Mannar", "Matale", "Matara", "Monaragala",
    "Mullaitivu", "Nuwara Eliya", "Polonnaruwa", "Puttalam", "Ratnapura",
    "Trincomalee", "Vavuniya"
  ]..sort();

  final Map<String, List<String>> placesMap = {
    "Ampara": ["Akkaraipattu", "Ampara Town", "Kalmunai", "Pothuvil", "Samanthurai"],
    "Anuradhapura": ["Anuradhapura Town", "Habarana", "Mihintale", "Rathkinda", "Tissawewa"],
    "Badulla": ["Badulla Town", "Buddhagama", "Ella", "Haputale", "Passara"],
    "Batticaloa": ["Batticaloa Town", "Eravur", "Kaluwanchikudy", "Kattankudy", "Valaichenai"],
    "Colombo": ["Bambalapitiya", "Dehiwala", "GalleFace", "Kollupitiya", "Mount Lavinia", "Pettah", "Wellawatte"],
    "Galle": ["Ambalangoda", "Gintota", "Hikkaduwa", "Koggala", "Unawatuna"],
    "Gampaha": ["Gampaha Town", "Ja-Ela", "Kelaniya", "Negombo", "Veyangoda"],
    "Hambantota": ["Ambalantota", "Hambantota Town", "Katuwana", "Ranna", "Tangalle"],
    "Jaffna": ["Chavakachcheri", "Jaffna Town", "Nallur", "Point Pedro", "Vannarpannai"],
    "Kalutara": ["Aluthgama", "Beruwala", "Bentota", "Kalutara Town", "Moragalla"],
    "Kandy": ["Gatambe", "Hanthana", "Katugastota", "Peradeniya", "Pilimathalawa"],
    "Kegalle": ["Aranayaka", "Kegalle Town", "Mawanella", "Rambukkana", "Warakapola"],
    "Kilinochchi": ["Elephant Pass", "Kilinochchi Town", "Mulliyawalai", "Palai", "Pooneryn"],
    "Kurunegala": ["Dambulla", "Kurunegala Town", "Maho", "Melsiripura", "Puttalam"],
    "Mannar": ["Adam's Bridge", "Mannar Town", "Nanattan", "Pesalai", "Thalaimannar"],
    "Matale": ["Dambulla", "Kandegama", "Matale Town", "Naula", "Rattota"],
    "Matara": ["Kamburugamuwa", "Matara Town", "Mirissa", "Tangalle", "Weligama"],
    "Monaragala": ["Balangoda", "Buttala", "Kataragama", "Monaragala Town", "Thanamalwila"],
    "Mullaitivu": ["Alampil", "Mullaitivu Town", "Mullaitivu District", "Oddusuddan", "Puthukkudiyiruppu"],
    "Nuwara Eliya": ["Ambewela", "Gregory Lake", "Hakgala", "Nanu Oya", "Nuwara Eliya Town"],
    "Polonnaruwa": ["Dimbulagala", "Girithale", "Habarana", "Medirigiriya", "Polonnaruwa Town"],
    "Puttalam": ["Anamaduwa", "Chilaw", "Mannar", "Nattandiya", "Puttalam Town"],
    "Ratnapura": ["Balangoda", "Egodauyana", "Pelmadulla", "Ratnapura Town", "Rathnapura District"],
    "Trincomalee": ["Kinniya", "Nilaveli", "Trincomalee Town", "Uppuveli", "Verugal"],
    "Vavuniya": ["Andankulam", "Mannar", "Puthukudiyiruppu", "Thandikulam", "Vavuniya Town"]
  };
  List<String> placeList = [];
  String? _selectedPlace;



  String? _selectedDistrict;


  @override
  void dispose() {
    _firstnamecontroller.dispose();
    _districtcontroller.dispose();
    _emailcontroller.dispose();
    _passwordcontroller.dispose();
    _phonecontroller.dispose();
    super.dispose();
  }
  Future<void> registerNewUser() async {
    try {
      User? userFirebase = (await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailcontroller.text.trim(),
        password: _passwordcontroller.text.trim(),
      )).user;

      if (!context.mounted) return;
      Navigator.pop(context);

      // Save user data to Firebase Realtime Database
      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("Users").child(userFirebase!.uid);
      Map userDataMap = {
        "firstname": _firstnamecontroller.text.trim(),
        "district": _selectedDistrict ?? "",  // Save the selected district here
        "place": _selectedPlace ?? "",  // Save the selected place here
        "email": _emailcontroller.text.trim(),
        "password": _passwordcontroller.text.trim(),
        "phone": _phonecontroller.text.trim(),
        "role": "Seller",
      };
      usersRef.set(userDataMap);

      // After saving data, navigate to login screen
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LogInScreen()));

    } catch (error) {
      // Handle registration error
      print('Registration error: $error');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration failed. Please try again later.')));
    }
  }


  Future<String> uploadImageToStorage(String childName, Uint8List file) async {
    Reference ref = FirebaseStorage.instance.ref().child(childName);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> saveData({
    required String firstName,
    required String secondName,
    required String imageUrl,
    required String uid,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('userProfile').doc(uid).set({
        'firstName': firstName,
        'secondName': secondName,
        'imageLink': imageUrl,
        'uid': uid,
      });
    } catch (err) {
      print(err);
    }
  }

  Future<void> selectImage() async {
    final ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      _image = await file.readAsBytes();
      setState(() {});
    } else {
      print('No Images Selected');
    }
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
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Center(
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.lightGreen,
                      fontSize: 30.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Stack(
                  children: [
                    _image != null
                        ? CircleAvatar(radius: 64, backgroundImage: MemoryImage(_image!))
                        : const CircleAvatar(
                      radius: 64,
                      backgroundImage: NetworkImage('https://png.pngitem.com/pimgs/s/421-4212266_transparent-default-avatar-png-default-avatar-images-png.png'),
                    ),
                    Positioned(
                      bottom: -10,
                      left: 80,
                      child: IconButton(
                        onPressed: selectImage,
                        icon: const Icon(Icons.add_a_photo),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        validator: (firstName) {
                          if (firstName!.isEmpty) {
                            return "Please Enter first name";
                          }
                          return null;
                        },
                        controller: _firstnamecontroller,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.people_alt_outlined),
                          labelText: 'First Name',
                          labelStyle: TextStyle(fontSize: 20),
                          hintText: 'First Name',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.text,
                        autocorrect: true,
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.location_city),
                          labelText: 'District',
                          labelStyle: TextStyle(fontSize: 20),
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedDistrict,
                        items: districts.map((String district) {
                          return DropdownMenuItem<String>(
                            value: district,
                            child: Text(district),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedDistrict = newValue;
                            placeList = placesMap[_selectedDistrict] ?? [];  // Update placeList based on selected district
                            _selectedPlace = null;  // Reset selected place
                          });
                        },
                        validator: (value) => value == null ? 'Please select a district' : null,
                        isExpanded: true,
                        // To show scrollable list if there are more than 5 items
                        menuMaxHeight: 250,
                      ),

                      const SizedBox(
                        height: 20.0,
                      ),

                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.location_pin),
                          labelText: 'Place',
                          labelStyle: TextStyle(fontSize: 20),
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedPlace,
                        items: placeList.isNotEmpty
                            ? List.generate(
                          placeList.length > 5 ? 5 : placeList.length, (index) {
                          return DropdownMenuItem<String>(
                            value: placeList[index],
                            child: Text(placeList[index]),
                          );
                        },
                        )
                            : [],
                        onChanged: (String? newPlace) {
                          setState(() {
                            _selectedPlace = newPlace;
                          });
                        },
                        validator: (value) => value == null ? 'Please select a place' : null,
                        isExpanded: true,
                        // To show scrollable list if there are more than 5 items
                        menuMaxHeight: 300,  // Adjust this value as necessary
                      ),


                      const SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                        controller: _phonecontroller,
                        validator: (pNumber) {
                          if (pNumber!.isEmpty) {
                            return "Please Enter phone number";
                          } else if (pNumber.length != 10) {
                            return "Please Enter correct phone number";
                          }
                          return null;
                        },
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
                          border: OutlineInputBorder(),
                        ),
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
                        obscureText: isSecurePassword,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_open),
                          labelText: 'Password',
                          labelStyle: const TextStyle(fontSize: 20),
                          hintText: 'Password',
                          border: const OutlineInputBorder(),
                          suffixIcon: togglePassword(),
                        ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      SizedBox(
                        height: 43.0,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              // checkIfNetworkIsAvailable();
                              registerNewUser();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
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
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                          )
                        ],
                      )
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
  Widget togglePassword(){
    return IconButton(onPressed: (){
      setState(() {
        isSecurePassword = !isSecurePassword;
      });

    }, icon: isSecurePassword ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
      color: Colors.black,);
  }

}
