import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class CheckLocationSeller extends StatefulWidget {
  final double latitude; // Seller's latitude
  final double longitude; // Seller's longitude
  final String buyerName;

  const CheckLocationSeller({super.key, required this.latitude, required this.longitude, required this.buyerName});

  @override
  State<CheckLocationSeller> createState() => _CheckLocationSellerState();
}
class _CheckLocationSellerState extends State<CheckLocationSeller> {
  LatLng _currentLocation = const LatLng(0.0, 0.0); // Buyer's current location
  bool _locationFetched = false;
  String? uid;
  GoogleMapController? mapController;
  BitmapDescriptor? buyerIcon; // Buyer icon
  List<LatLng> _routeCoordinates = []; // List to store route coordinates

  String mapKey = "AIzaSyA9GskZpUFgljTermxTw-HVE3O6g_GtlIc"; // Replace with your Google Maps API key

  @override
  void initState() {
    super.initState();
    _loadBuyerIcon(); // Load the custom icon
    _getUserLocationFromDatabase().then((_) {
      // Fetch the route once buyer's location is fetched
      if (_locationFetched) {
        getPolylinePoints();
      }
    });
  }

  // Load the buyer icon
  Future<void> _loadBuyerIcon() async {
    buyerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)), // Adjust the size as needed
      'assets/images/home.png',
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
          getPolylinePoints();
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
      // Fetch the new polyline points based on the updated location
      setState(() {
        _currentLocation = newLocation;
      });

      // Re-fetch the polyline points after updating the location
      getPolylinePoints();
    }
  }

  Future<void> getPolylinePoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    // Seller's location
    LatLng sellerLocation = LatLng(widget.latitude, widget.longitude);

    // Fetch route between buyer and seller using PolylineRequest
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: "AIzaSyA9GskZpUFgljTermxTw-HVE3O6g_GtlIc", // Replace with your Google Maps API key
      request: PolylineRequest(
        origin: PointLatLng(_currentLocation.latitude, _currentLocation.longitude), // Buyer's location
        destination: PointLatLng(sellerLocation.latitude, sellerLocation.longitude), // Seller's location
        mode: TravelMode.driving, // Specify travel mode
      ),
    );


    if (result.points.isNotEmpty) {
      _routeCoordinates.clear(); // Clear previous coordinates
      for (var point in result.points) {
        _routeCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      setState(() {

        // Automatically adjust the camera to fit the route
        _moveCameraToBounds(sellerLocation);
      }); // Update the map with the new route
    } else {
      print("Error fetching polyline: ${result.errorMessage}");
    }
  }

  // Move the camera to fit the route bounds
  void _moveCameraToBounds(LatLng sellerLocation) {
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        _currentLocation.latitude < sellerLocation.latitude ? _currentLocation.latitude : sellerLocation.latitude,
        _currentLocation.longitude < sellerLocation.longitude ? _currentLocation.longitude : sellerLocation.longitude,
      ),
      northeast: LatLng(
        _currentLocation.latitude > sellerLocation.latitude ? _currentLocation.latitude : sellerLocation.latitude,
        _currentLocation.longitude > sellerLocation.longitude ? _currentLocation.longitude : sellerLocation.longitude,
      ),
    );

    mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  // Display the map with the buyer's and seller's locations
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
              _updateLocationInFirebase(newPosition); // Update the new location in Firebase
            },
            infoWindow: const InfoWindow(title: 'Your location'),
          ),
          // Seller's location marker with custom image
          Marker(
            markerId: const MarkerId('sellerLocation'),
            position: sellerLocation,
            icon: buyerIcon ?? BitmapDescriptor.defaultMarker, // Use your custom image or a default if not loaded
            infoWindow: InfoWindow(title: widget.buyerName),
          ),
        },
        polylines: {
          Polyline(
            polylineId: const PolylineId('route'),
            points: _routeCoordinates,
            color: Colors.blue,
            width: 5,
          ),
        },

        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        onTap: (LatLng tappedLocation) {
          _updateLocationInFirebase(tappedLocation); // Update location when map is tapped
        },
      )
          : const Center(child: CircularProgressIndicator()), // Show a spinner while fetching location
    );
  }
}

