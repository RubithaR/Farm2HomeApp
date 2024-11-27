import 'dart:async';
import 'dart:math'; // Add this import for math functions like cos, asin, sqrt, and pi
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class CheckLocationSeller extends StatefulWidget {
  final double latitude; // buyer's latitude
  final double longitude; // buyer's longitude
  final String buyerName;

  const CheckLocationSeller({super.key, required this.latitude, required this.longitude, required this.buyerName});

  @override
  State<CheckLocationSeller> createState() => _CheckLocationSellerState();
}

class _CheckLocationSellerState extends State<CheckLocationSeller> {
  LatLng _currentLocation = const LatLng(0.0, 0.0); // Seller's current location
  bool _locationFetched = false;
  bool _isMoving = false; // Track if the marker is moving
  String? uid;
  GoogleMapController? mapController;
  BitmapDescriptor? buyerIcon; // Buyer icon
  List<LatLng> _routeCoordinates = []; // List to store route coordinates
  late Timer _timer; // Timer for animating the marker

  String mapKey = "AIzaSyA9GskZpUFgljTermxTw-HVE3O6g_GtlIc"; // Replace with your Google Maps API key

  @override
  void initState() {
    super.initState();
    _loadBuyerIcon(); // Load the custom icon
    _getUserLocationFromDatabase().then((_) {
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

  // Fetch the seller's location from Firebase
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

  // Get the seller's current location using Geolocator
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

  // Update the seller's location in Firebase
  Future<void> _updateLocationInFirebase(LatLng newLocation) async {
    if (uid != null) {
      DatabaseReference userRef = FirebaseDatabase.instance.ref().child("Users").child(uid!);
      await userRef.update({
        'location': {
          'latitude': newLocation.latitude,
          'longitude': newLocation.longitude,
        }
      });
      setState(() {
        _currentLocation = newLocation;
      });

      // Re-fetch the polyline points after updating the location
      getPolylinePoints();
    }
  }

  // Animate the marker to the buyer's location
  void _moveMarkerToBuyer() {
    if (_routeCoordinates.isEmpty) return;

    // Start the animation from the first point in the route
    int currentPointIndex = 0;

    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      // If we've reached the last point in the polyline, stop the timer
      if (currentPointIndex >= _routeCoordinates.length) {
        _timer.cancel();
        setState(() {
          _isMoving = false;
        });
        return;
      }

      // Move the marker a little closer to the next polyline point
      LatLng nextPoint = _routeCoordinates[currentPointIndex];
      _currentLocation = _getIntermediatePosition(_currentLocation, nextPoint, 0.1); // Increased step size

      // Check if we are close enough to the next point to increment the index
      if (_distance(_currentLocation, nextPoint) < 0.001) {
        currentPointIndex++;
      }

      // Add the current position to the polyline list to update it
      _routeCoordinates.add(_currentLocation);

      // Update the state to rebuild the map and polyline
      setState(() {});
    });
  }



  // Calculate an intermediate position between two LatLng points
  LatLng _getIntermediatePosition(LatLng start, LatLng end, double ratio) {
    double lat = start.latitude + (end.latitude - start.latitude) * ratio;
    double lng = start.longitude + (end.longitude - start.longitude) * ratio;
    return LatLng(lat, lng);
  }

  // Calculate distance between two LatLng points
  double _distance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // Earth's radius in km
    double dLat = _degreesToRadians(point2.latitude - point1.latitude);
    double dLng = _degreesToRadians(point2.longitude - point1.longitude);
    double a =
        0.5 - (cos(dLat) / 2) +
            cos(_degreesToRadians(point1.latitude)) * cos(_degreesToRadians(point2.latitude)) *
                (1 - cos(dLng)) / 2;
    return earthRadius * 2 * asin(sqrt(a));
  }

  // Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180); // Use 'pi' from dart:math
  }

  Future<void> getPolylinePoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    // buyer's location
    LatLng buyerLocation = LatLng(widget.latitude, widget.longitude);

    // Fetch route between buyer and seller using PolylineRequest
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: mapKey, // Replace with your Google Maps API key
      request: PolylineRequest(
        origin: PointLatLng(_currentLocation.latitude, _currentLocation.longitude), // seller's location
        destination: PointLatLng(buyerLocation.latitude, buyerLocation.longitude), // buyer's location
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
        _moveCameraToBounds(buyerLocation);
      });
    } else {
      print("Error fetching polyline: ${result.errorMessage}");
    }
  }

  // Move the camera to fit the route bounds
  void _moveCameraToBounds(LatLng buyerLocation) {
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        _currentLocation.latitude < buyerLocation.latitude ? _currentLocation.latitude : buyerLocation.latitude,
        _currentLocation.longitude < buyerLocation.longitude ? _currentLocation.longitude : buyerLocation.longitude,
      ),
      northeast: LatLng(
        _currentLocation.latitude > buyerLocation.latitude ? _currentLocation.latitude : buyerLocation.latitude,
        _currentLocation.longitude > buyerLocation.longitude ? _currentLocation.longitude : buyerLocation.longitude,
      ),
    );

    mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  // Display the map with the buyer's and seller's locations
  @override
  Widget build(BuildContext context) {
    LatLng buyerLocation = LatLng(widget.latitude, widget.longitude);

    return GestureDetector(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Live Order Tracking"),
          backgroundColor: Colors.blue,
        ),
        body: Column(
          children: [
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentLocation,
                  zoom: 14.0,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId("buyer"),
                    position: buyerLocation,
                    icon: buyerIcon ?? BitmapDescriptor.defaultMarker,
                    infoWindow: InfoWindow(title: widget.buyerName),
                  ),
                  Marker(
                    markerId: const MarkerId("seller"),
                    position: _currentLocation,
                    infoWindow: InfoWindow(title: "Seller's Location"),
                  ),
                },
                polylines: {
                  Polyline(
                    polylineId: const PolylineId("route"),
                    points: _routeCoordinates,
                    color: Colors.blue,
                    width: 5,
                  ),
                },
                onMapCreated: (controller) {
                  mapController = controller;
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (!_isMoving) {
                  setState(() {
                    _isMoving = true;
                  });
                  _moveMarkerToBuyer(); // Start the animation
                }
              },
              child: Text(_isMoving ? "Moving..." : "Start Moving"),
            ),
          ],
        ),
      ),
    );
  }
}
