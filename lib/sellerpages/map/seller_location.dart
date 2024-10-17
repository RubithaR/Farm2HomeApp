import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

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
  List<LatLng> _buyerLocations = []; // Store all buyer locations
  Map<MarkerId, Marker> userMarkers = {}; // Store markers for buyers and sellers

  @override
  void initState() {
    super.initState();
    _getUserLocationFromDatabase(); // Retrieve seller's location from Firebase
  }

  // Fetch the seller's location from Firebase Realtime Database on login
  Future<void> _getUserLocationFromDatabase() async {
    uid = FirebaseAuth.instance.currentUser?.uid; // Get seller's UID
    print("Current Seller ID: $uid"); // Print current seller ID

    if (uid != null) {
      DatabaseReference userRef = FirebaseDatabase.instance.ref().child("Users").child(uid!);

      // Fetch the current location saved in Firebase
      DatabaseEvent event = await userRef.once();

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
          _fetchBuyerLocations(); // Fetch buyer locations
        } else {
          _getCurrentLocation(); // Fetch the device's current location if not found in Firebase
        }
      } else {
        _getCurrentLocation(); // Fetch the device's current location if no user data exists in Firebase
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
      _updateLocationInFirebase(_currentLocation); // Save the newly fetched location in Firebase
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  // Get the current location using Geolocator
  Future<Position> getCurrentLocation() async {
    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // If permission is denied, request permission
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied");
      }
    }

    // Get the current position
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  // Update the seller's location in Firebase Realtime Database
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

  // Fetch the buyer's location from Firebase Realtime Database
  Future<void> _fetchBuyerLocations() async {
    if (uid != null) {
      DatabaseReference ordersRef = FirebaseDatabase.instance.ref().child("final_order");

      // Fetch all orders
      DatabaseEvent event = await ordersRef.once();

      if (event.snapshot.exists) {
        Map<dynamic, dynamic>? ordersData = event.snapshot.value as Map<dynamic, dynamic>?;

        if (ordersData != null) {
          // Loop through each buyer (buyer_uid)
          for (var buyerId in ordersData.keys) {
            var sellerData = ordersData[buyerId];

            if (sellerData is Map) {
              // Check if there are orders under this buyer
              for (var orderEntry in sellerData.entries) {
                var orderSellerUid = orderEntry.key; // This is the seller UID

                // Compare the current seller's UID with the seller UID from the order
                if (uid == orderSellerUid) {
                  // Get the buyer's location and add to the list
                  LatLng? buyerLocation = await _getBuyerLocation(buyerId);
                  if (buyerLocation != null) {
                    setState(() {
                      _buyerLocations.add(buyerLocation); // Add buyer's location to the list
                    });
                  }
                }
              }
            }
          }
        } else {
          print("No orders found.");
        }
      }
    } else {
      print("Current seller UID is null.");
    }
  }

  // Fetch a specific buyer's location using their ID
  Future<LatLng?> _getBuyerLocation(String buyerId) async {
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("Users").child(buyerId);
    DatabaseEvent event = await usersRef.once();

    if (event.snapshot.exists) {
      Map<dynamic, dynamic>? userData = event.snapshot.value as Map<dynamic, dynamic>?;

      if (userData != null && userData['location'] != null) {
        String buyerName = userData['firstname'] ?? "Unknown"; // Assuming you have 'firstname' in your user data

        LatLng buyerLocation = LatLng(
          userData['location']['latitude'] ?? 0.0,
          userData['location']['longitude'] ?? 0.0,
        );

        double distance = _calculateDistance(_currentLocation, buyerLocation);
        if (distance <= 10.0) { // Filter buyers within 5 km
          BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(67, 67)), // Adjust the size as needed
            'assets/images/home.png', // Use the custom icon
          );

          MarkerId markerId = MarkerId(buyerId);
          Marker marker = Marker(
            markerId: markerId,
            position: buyerLocation,
            icon: markerIcon,
            infoWindow: InfoWindow(title: "Buyer: $buyerName"),
          );

          setState(() {
            userMarkers[markerId] = marker; // Add buyer marker to map
          });

          return buyerLocation;
        }
      }
    }
    return null;
  }

  // Calculate the distance between the seller and buyer locations
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
          ...userMarkers.values.toSet(), // Add dynamically fetched buyer markers
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
