import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  LatLng _currentLocation = const LatLng(0.0, 0.0);
  bool _locationFetched = false;
  String? uid;
  Map<MarkerId, Marker> sellerMarkers = {}; // Store sellers' markers

  @override
  void initState() {
    super.initState();
    _getUserLocationFromDatabase(); // Retrieve user location from Firebase
  }

  Future<void> _getNearbySellers() async {
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("Users");
    DatabaseEvent event = await usersRef.once();
    Map<dynamic, dynamic>? allUsers = event.snapshot.value as Map<dynamic, dynamic>?;

    if (allUsers != null) {
      for (var key in allUsers.keys) {
        var value = allUsers[key];
        if (value['role'] == 'Seller' && value['location'] != null) {
          LatLng sellerLocation = LatLng(
            value['location']['latitude'] ?? 0.0,
            value['location']['longitude'] ?? 0.0,
          );

          double distance = _calculateDistance(_currentLocation, sellerLocation);
          if (distance <= 100.0) { // Filter sellers within 5 km
            // Use the new method with ImageConfiguration
            BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(
              const ImageConfiguration(size: Size(48, 48)), // You can adjust the size as needed
              'assets/images/van_image.png',
            );
            MarkerId markerId = MarkerId(key);
            Marker marker = Marker(
              markerId: markerId,
              position: sellerLocation,
              icon: markerIcon, // Use the custom icon here
              infoWindow: InfoWindow(title: "${value['firstname']} "),
            );

            setState(() {
              sellerMarkers[markerId] = marker;
            });
          }
        }
      }
    }
  }

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
          _getNearbySellers(); // Fetch sellers after getting current location
        } else {
          _getCurrentLocation(); // If no saved location, get current location
        }
      } else {
        _getCurrentLocation(); // If no user data found, get current location
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await getCurrentLocation();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _locationFetched = true;
      });
      _updateLocationInFirebase(_currentLocation); // Store new location in Firebase
      _getNearbySellers(); // Fetch sellers after getting current location
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

  double _calculateDistance(LatLng start, LatLng end) {
    const earthRadius = 6371; // Radius of the Earth in km
    double dLat = _degreesToRadians(end.latitude - start.latitude);
    double dLng = _degreesToRadians(end.longitude - start.longitude);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(start.latitude)) *
            cos(_degreesToRadians(end.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  void _onMapTap(LatLng tappedLocation) {
    setState(() {
      _currentLocation = tappedLocation;
    });
    _updateLocationInFirebase(tappedLocation); // Update new location in Firebase
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map"),
        backgroundColor: Colors.green,
      ),
      body: _locationFetched
          ? GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentLocation,
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
          ...sellerMarkers.values, // Add seller markers
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
