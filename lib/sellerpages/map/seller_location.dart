import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MapPageSeller extends StatefulWidget {
  const MapPageSeller({super.key});

  @override
  State<MapPageSeller> createState() => MapPageSellerState();
}

class MapPageSellerState extends State<MapPageSeller> {
  late GoogleMapController mapController;
  LatLng _currentLocation = const LatLng(0.0, 0.0);
  bool _locationFetched = false;
  String? uid;

  @override
  void initState() {
    super.initState();
    _getUserLocationFromDatabase(); // Retrieve user location from Firebase on login
  }

  // Fetch location from Firebase Realtime Database on login
  Future<void> _getUserLocationFromDatabase() async {
    uid = FirebaseAuth.instance.currentUser?.uid; // Get seller's UID
    if (uid != null) {
      // Reference to the seller's data in Firebase Realtime Database
      DatabaseReference userRef = FirebaseDatabase.instance.ref().child("Users").child(uid!);

      // Fetch the current location saved in Firebase
      DatabaseEvent event = await userRef.once();

      // If the location exists in Firebase, set the _currentLocation variable
      if (event.snapshot.exists) {
        Map<dynamic, dynamic>? userData = event.snapshot.value as Map<dynamic, dynamic>?;
        if (userData != null && userData['location'] != null) {
          setState(() {
            _currentLocation = LatLng(
              userData['location']['latitude'] ?? 0.0,
              userData['location']['longitude'] ?? 0.0,
            );
            _locationFetched = true; // Mark that location has been fetched
          });
        } else {
          // If no location is saved, fetch the device's current location
          _getCurrentLocation();
        }
      } else {
        // If no user data exists in Firebase, fetch the device's current location
        _getCurrentLocation();
      }
    }
  }

  // Fetch the seller's current device location if no location is found in Firebase
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await getCurrentLocation();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _locationFetched = true; // Mark that location has been fetched
      });
      // Save the newly fetched location in Firebase for future logins
      _updateLocationInFirebase(_currentLocation);
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  // Get the device's current location, handle permissions
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

  // Update location in Firebase Realtime Database
  Future<void> _updateLocationInFirebase(LatLng newLocation) async {
    if (uid != null) {
      // Update the seller's location in Firebase under the 'Users/{uid}/location' path
      DatabaseReference userRef = FirebaseDatabase.instance.ref().child("Users").child(uid!);
      await userRef.update({
        'location': {
          'latitude': newLocation.latitude,
          'longitude': newLocation.longitude,
        }
      });
    }
  }

  // When the user taps on the map, update the marker and Firebase with the new location
  void _onMapTap(LatLng tappedLocation) {
    setState(() {
      _currentLocation = tappedLocation; // Set new location on the map
    });
    _updateLocationInFirebase(tappedLocation); // Update the location in Firebase
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _locationFetched
          ? GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentLocation, // Set initial camera position to the fetched location
          zoom: 14,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: _currentLocation,
            draggable: true, // Allow user to drag marker
            onDragEnd: (newPosition) {
              _onMapTap(newPosition); // Update location after dragging
            },
            infoWindow: const InfoWindow(title: 'Your location'),
          ),
        },
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        onTap: _onMapTap, // Update location when map is tapped
      )
          : const Center(child: CircularProgressIndicator()), // Show loading spinner while fetching location
    );
  }
}
