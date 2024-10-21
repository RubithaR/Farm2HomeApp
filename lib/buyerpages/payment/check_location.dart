import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckLocation extends StatefulWidget {
  final double latitude; // Seller's latitude
  final double longitude; // Seller's longitude
  final String sellerName ;

  const CheckLocation({super.key, required this.latitude, required this.longitude, required this.sellerName});

  @override
  State<CheckLocation> createState() => _CheckLocationState();
}

class _CheckLocationState extends State<CheckLocation> {
  LatLng _currentLocation = const LatLng(0.0, 0.0); // Buyer's current location
  bool _locationFetched = false;
  String? uid;
  GoogleMapController? mapController;
  BitmapDescriptor? sellerIcon; // Declare sellerIcon here

  @override
  void initState() {
    super.initState();
    _loadSellerIcon(); // Load the custom icon
    _getUserLocationFromDatabase(); // Fetch buyer's location from the database
  }

  // Load the seller icon
  Future<void> _loadSellerIcon() async {
    sellerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)), // Adjust the size as needed
      'assets/images/van_image.png',
    );
    setState(() {}); // Call setState to rebuild the widget once the icon is loaded
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
          _getCurrentLocation(); // If no location is saved, get current location
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

  // Display the map with only the buyer's and seller's locations
  @override
  Widget build(BuildContext context) {
    // Seller's location from navigation arguments
    LatLng sellerLocation = LatLng(widget.latitude, widget.longitude);

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
            draggable: true, // Allow dragging to update location
            onDragEnd: (newPosition) {
              setState(() {
                _currentLocation = newPosition;
              });
              _updateLocationInFirebase(newPosition); // Update the new location in Firebase
            },
            infoWindow: const InfoWindow(title: 'Your location'),
          ),
          // Seller's location marker with custom image
          Marker(
            markerId: const MarkerId('sellerLocation'),
            position: sellerLocation,
            icon: sellerIcon ?? BitmapDescriptor.defaultMarker, // Use your custom image or a default if not loaded
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
          _updateLocationInFirebase(tappedLocation); // Update location when map is tapped
        },
      )
          : const Center(child: CircularProgressIndicator()), // Show a spinner while fetching location
    );
  }
}