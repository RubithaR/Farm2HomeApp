import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckLocation extends StatefulWidget {
  final double latitude; // Seller's latitude
  final double longitude; // Seller's longitude
  final String sellerUID; // Seller's unique ID
  final String sellerName;

  const CheckLocation({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.sellerUID,
    required this.sellerName,
  });

  @override
  State<CheckLocation> createState() => _CheckLocationState();
}

class _CheckLocationState extends State<CheckLocation> {
  LatLng _currentLocation = const LatLng(0.0, 0.0); // Buyer's current location
  LatLng _sellerLocation = const LatLng(0.0, 0.0); // Seller's updated location
  bool _locationFetched = false;
  String? uid;
  GoogleMapController? mapController;
  BitmapDescriptor? sellerIcon;
  DatabaseReference? sellerRef;

  @override
  void initState() {
    super.initState();
    _loadSellerIcon(); // Load the custom seller icon
    _getUserLocationFromDatabase(); // Fetch buyer's location
    _trackSellerLocation(); // Start tracking seller's location in real-time
  }

  // Load the custom seller icon
  Future<void> _loadSellerIcon() async {
    sellerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/van_image.png',
    );
    setState(() {}); // Rebuild the widget once the icon is loaded
  }

  // Fetch the buyer's location from Firebase
  Future<void> _getUserLocationFromDatabase() async {
    uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      DatabaseReference userRef = FirebaseDatabase.instance.ref().child("Users").child(uid!);
      DatabaseEvent event = await userRef.once();

      if (event.snapshot.exists) {
        Map<dynamic, dynamic>? userData = event.snapshot.value as Map<dynamic, dynamic>?;

        if (userData != null && userData['location'] != null) {
          setState(() {
            _currentLocation = LatLng(
              userData['location']['latitude'] ?? 0.0,
              userData['location']['longitude'] ?? 0.0,
            );
            _locationFetched = true;
          });
        } else {
          _getCurrentLocation(); // If no location is saved, get the current location
        }
      } else {
        _getCurrentLocation(); // If no user data, get current location
      }
    }
  }

  // Get the buyer's current location using Geolocator
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await getCurrentLocation();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _locationFetched = true;
      });
      _updateLocationInFirebase(_currentLocation); // Store the new location in Firebase
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  // Function to get the current position of the buyer
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  // Update the buyer's location in Firebase
  Future<void> _updateLocationInFirebase(LatLng newLocation) async {
    if (uid != null) {
      DatabaseReference userRef = FirebaseDatabase.instance.ref().child("Users").child(uid!);
      await userRef.update({
        'location': {
          'latitude': newLocation.latitude,
          'longitude': newLocation.longitude,
        }
      });
    }
  }

  // Track the seller's location from Firebase in real-time
  Future<void> _trackSellerLocation() async {
    sellerRef = FirebaseDatabase.instance.ref().child('sellers').child(widget.sellerUID);

    sellerRef!.child('location').onValue.listen((DatabaseEvent event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> sellerLocationData = event.snapshot.value as Map<dynamic, dynamic>;
        if (sellerLocationData['latitude'] != null && sellerLocationData['longitude'] != null) {
          setState(() {
            _sellerLocation = LatLng(
              sellerLocationData['latitude'],
              sellerLocationData['longitude'],
            );
            print("Seller location updated to: $_sellerLocation"); // Debugging
          });
        } else {
          print("Seller location data is incomplete: $sellerLocationData"); // Debugging
        }
      } else {
        print("Seller location snapshot does not exist."); // Debugging
      }
    });
  }

  // Build the Google Map with buyer and seller markers
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _locationFetched
          ? GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentLocation,
          zoom: 14,
        ),
        markers: {
          // Buyer's location marker
          Marker(
            markerId: const MarkerId('buyerLocation'),
            position: _currentLocation,
            draggable: true,
            onDragEnd: (newPosition) {
              setState(() {
                _currentLocation = newPosition;
              });
              _updateLocationInFirebase(newPosition);
            },
            infoWindow: const InfoWindow(title: 'Your location'),
          ),
          // Seller's location marker
          Marker(
            markerId: const MarkerId('sellerLocation'),
            position: _sellerLocation, // Updated in real-time
            icon: sellerIcon ?? BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(title: widget.sellerName),
          ),
        },
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        onTap: (LatLng tappedLocation) {
          setState(() {
            _currentLocation = tappedLocation;
          });
          _updateLocationInFirebase(tappedLocation);
        },
      )
          : const Center(child: CircularProgressIndicator()), // Show a loading spinner until the location is fetched
    );
  }
}
