import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart'; // For location services
import 'dart:math';
import 'package:veg/shortest_path/dijkstra.dart';
import 'package:veg/shortest_path/real_path.dart'; // Import Dijkstra implementation

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
  List<LatLng> _buyerLocations = [];
  Map<MarkerId, Marker> userMarkers = {};
  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = [];
  Map<String, LatLng> locationMap = {};
  final Graph _graph = Graph();

  late DatabaseReference ordersRef;

  @override
  void initState() {
    super.initState();
    _getUserLocationFromDatabase();
  }

  // Fetch the seller's location from Firebase Realtime Database
  Future<void> _getUserLocationFromDatabase() async {
    uid = FirebaseAuth.instance.currentUser?.uid;
    print("Current Seller ID: $uid");

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
            _addCurrentLocationMarker(); // Add seller location marker
          });
          _fetchBuyerLocations();
        } else {
          _getCurrentLocation();
        }
      } else {
        _getCurrentLocation();
      }
    }
  }

  // Fetch the current device location if no location is found in Firebase
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await getCurrentLocation();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _locationFetched = true;
        _addCurrentLocationMarker(); // Add seller location marker after fetching
      });
      _updateLocationInFirebase(_currentLocation);
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  // Get the current location using Geolocator
  Future<Position> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied");
      }
    }
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

  // Add a marker for the seller's current location
  // Add a marker for the seller's current location
  void _addCurrentLocationMarker() {
    Marker sellerMarker = Marker(
      markerId: const MarkerId('currentLocation'),
      position: _currentLocation,
      draggable: true, // Allow marker to be draggable
      onDragEnd: (newPosition) {
        // When the dragging ends, update the position
        _onMarkerDragged(newPosition); // Call a separate method to handle updating location
      },
      infoWindow: const InfoWindow(title: 'Your location'),
    );

    // Update the marker on the map
    setState(() {
      userMarkers[MarkerId('currentLocation')] = sellerMarker;
    });
  }

  void _onMarkerDragged(LatLng newPosition) {
    setState(() {
      _currentLocation = newPosition; // Update the current location state
    });
    _updateLocationInFirebase(newPosition); // Save the updated location in Firebase
  }


  void _onMapTap(LatLng tappedPoint) {
    setState(() {
      _currentLocation = tappedPoint; // Update to the new tapped location
    });
    _addCurrentLocationMarker(); // Add or update the marker at the tapped point
    _updateLocationInFirebase(tappedPoint); // Save the new location to Firebase
  }








  // Save the route for each buyer
  Future<void> _saveOrder(String buyerId, List<LatLng> routeCoordinates) async {
    if (uid != null) {
      DatabaseReference ordersRef = FirebaseDatabase.instance.ref().child("paths").child(uid!).child(buyerId);

      // Prepare route details (only the buyer's location and seller's ID)
      Map<String, dynamic> orderDetails = {
        'route': routeCoordinates.map((latLng) => {
          'latitude': latLng.latitude,
          'longitude': latLng.longitude,
        }).toList(),
        'buyerId': buyerId,
        'timestamp': ServerValue.timestamp,
      };

      // Save or overwrite the order for the buyer
      await ordersRef.set(orderDetails);
      print("Order saved for buyer: $buyerId");
    }
  }

  // Find the shortest route to all buyers
  // Add this function in your MapPageSellerState class
  // Method to calculate the shortest path to all buyers
  void _findShortestRouteToAllBuyers() {
    print("Finding the shortest path to all buyers...");

    if (uid != null && locationMap.isNotEmpty) {
      // Add current location to the list
      List<LatLng> routePoints = [_currentLocation];

      // Set of unvisited buyer locations
      Set<String> unvisitedBuyers = locationMap.keys.toSet();

      LatLng currentLocation = _currentLocation;

      while (unvisitedBuyers.isNotEmpty) {
        // Find the nearest unvisited buyer
        String nearestBuyerId = unvisitedBuyers.first;
        double minDistance = _calculateDistance(currentLocation, locationMap[nearestBuyerId]!);

        for (String buyerId in unvisitedBuyers) {
          double distance = _calculateDistance(currentLocation, locationMap[buyerId]!);
          if (distance < minDistance) {
            minDistance = distance;
            nearestBuyerId = buyerId;
          }
        }

        // Move to the nearest buyer
        LatLng nearestBuyerLocation = locationMap[nearestBuyerId]!;
        routePoints.add(nearestBuyerLocation);

        // Update current location to nearest buyer's location
        currentLocation = nearestBuyerLocation;

        // Mark the nearest buyer as visited
        unvisitedBuyers.remove(nearestBuyerId);

        // Save the order for the current buyer
        _saveOrder(nearestBuyerId, routePoints);
      }

      // Draw the polyline for the shortest path
      _drawPolyline(routePoints);
      print("Shortest path to all buyers calculated successfully.");
    } else {
      print("No buyers found or map not initialized.");
    }
  }

  // Fetch buyer locations from Firebase
  void _fetchBuyerLocations() async {
    if (uid != null) {
      ordersRef = FirebaseDatabase.instance.ref().child("final_order");
      ordersRef.onValue.listen((DatabaseEvent event) async {
        if (event.snapshot.exists) {
          Map<dynamic, dynamic>? ordersData = event.snapshot.value as Map<dynamic, dynamic>?;

          if (ordersData != null) {
            setState(() {
              userMarkers.clear(); // Clear old markers
              _addCurrentLocationMarker(); // Re-add seller location marker
              _buyerLocations.clear();
            });

            List<Future<void>> futures = [];

            for (var buyerId in ordersData.keys) {
              var sellerData = ordersData[buyerId];
              if (sellerData is Map) {
                for (var orderEntry in sellerData.entries) {
                  var orderSellerUid = orderEntry.key;
                  if (uid == orderSellerUid) {
                    futures.add(_getBuyerLocation(buyerId).then((buyerLocation) {
                      if (buyerLocation != null) {
                        setState(() {
                          _buyerLocations.add(buyerLocation);
                          locationMap[buyerId] = buyerLocation;
                          double distance = _calculateDistance(_currentLocation, buyerLocation);
                          _graph.addEdge(buyerId, uid!, distance);
                        });
                      }
                    }));
                  }
                }
              }
            }

            await Future.wait(futures);

            if (_buyerLocations.isNotEmpty) {
              _findShortestRouteToAllBuyers();
            }
          }
        }
      });
    }
  }

  // Fetch the buyer's location from Firebase
  Future<LatLng?> _getBuyerLocation(String buyerId) async {
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("Users").child(buyerId);
    DatabaseEvent event = await usersRef.once();
    if (event.snapshot.exists) {
      Map<dynamic, dynamic>? userData = event.snapshot.value as Map<dynamic, dynamic>?;
      if (userData != null && userData['location'] != null) {
        LatLng buyerLocation = LatLng(
          userData['location']['latitude'] ?? 0.0,
          userData['location']['longitude'] ?? 0.0,
        );

        BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(67, 67)),
          'assets/images/home.png',
        );
        MarkerId markerId = MarkerId(buyerId);
        Marker marker = Marker(
          markerId: markerId,
          position: buyerLocation,
          icon: markerIcon,
          infoWindow: InfoWindow(title: "Buyer: ${userData['firstname']}"),
        );
        setState(() {
          userMarkers[markerId] = marker;
        });
        return buyerLocation;
      }
    }
    return null;
  }

  // Calculate the great circle distance between two LatLng points (Haversine formula)
  double _calculateDistance(LatLng start, LatLng end) {
    const earthRadius = 6371000.0; // in meters
    double lat1 = _degreesToRadians(start.latitude);
    double lon1 = _degreesToRadians(start.longitude);
    double lat2 = _degreesToRadians(end.latitude);
    double lon2 = _degreesToRadians(end.longitude);
    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 *
        atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  // Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  // Draw polyline on the map based on route coordinates
  void _drawPolyline(List<LatLng> routeCoordinates) async {
    setState(() {
      polylineCoordinates.clear();
      polylineCoordinates.addAll(routeCoordinates);
    });
  }

  // Update marker position after dragging


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _locationFetched
            ? GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            mapController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: _currentLocation,
            zoom: 14.0,
          ),
          onTap: (LatLng tappedPoint) {
            _onMapTap(tappedPoint); // Call the _onMapTap function when the map is tapped
          },
          markers: Set<Marker>.of(userMarkers.values),
          polylines: {
            Polyline(
              polylineId: const PolylineId("route"),
              points: polylineCoordinates,
              color: Colors.red,
              width: 4,
            ),
          },
        )



            : const Center(
          child: CircularProgressIndicator(),
        ),
// The Start button on the left side
          Positioned(
            left: 16.0, // Adjust this value for precise positioning
            bottom: 20.0, // Distance from the bottom of the screen
            child: FloatingActionButton(
              onPressed: () {
                // Handle button press
                // You can add any function call here to start route tracking, etc.
              },
              backgroundColor: Colors.green,
              child: const Icon(Icons.play_arrow),
            ),
          ),




       ],
      ),
    );
  }
}
