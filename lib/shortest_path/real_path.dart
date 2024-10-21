/*
not use now ****************************************


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; // Added for getting seller's current location
import 'dart:async';

class RealPath extends StatefulWidget {
  const RealPath({super.key});

  @override
  State<RealPath> createState() => _RealPathState();
}

class _RealPathState extends State<RealPath> {
  late GoogleMapController mapController;
  List<LatLng> routeCoordinates = [];
  Map<MarkerId, Marker> buyerMarkers = {};
  String? sellerUid;
  LatLng? sellerLocation;
  bool isLocationLoaded = false;

  @override
  void initState() {
    super.initState();
    sellerUid = FirebaseAuth.instance.currentUser?.uid;
    _getSellerLocation(); // Fetch seller's current location
  }

  // Fetch seller's current location using Geolocator
  Future<void> _getSellerLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Handle the case when permissions are permanently denied
        return;
      }

      Position sellerCurrentLocation = await Geolocator.getCurrentPosition();
      sellerLocation = LatLng(
        sellerCurrentLocation.latitude,
        sellerCurrentLocation.longitude,
      );
      setState(() {
        isLocationLoaded = true;
      });
      _fetchOrderData(); // Fetch order data once the location is loaded
    } catch (e) {
      print("Error getting seller location: $e");
    }
  }

  // Fetch order data from Firebase Realtime Database
  Future<void> _fetchOrderData() async {
    if (sellerUid != null && isLocationLoaded) {
      // Accessing the paths for the current seller
      DatabaseReference ordersRef = FirebaseDatabase.instance
          .ref()
          .child("paths")
          .child(sellerUid!);

      ordersRef.onValue.listen((DatabaseEvent event) async {
        if (event.snapshot.exists) {
          Map<dynamic, dynamic>? buyersData =
          event.snapshot.value as Map<dynamic, dynamic>?;

          if (buyersData != null) {
            setState(() {
              buyerMarkers.clear();
              routeCoordinates.clear();
            });

            for (var buyerId in buyersData.keys) {
              var buyerOrders = buyersData[buyerId];
              if (buyerOrders is Map) {
                for (var orderId in buyerOrders.keys) {
                  var orderDetails = buyerOrders[orderId];
                  if (orderDetails is Map) {
                    String? orderBuyerId = orderDetails['buyerId'];
                    if (orderBuyerId == null) continue;

                    List<dynamic>? route = orderDetails['route'];
                    if (route != null) {
                      for (var point in route) {
                        if (point is Map && point['latitude'] != null && point['longitude'] != null) {
                          routeCoordinates.add(LatLng(
                            point['latitude'],
                            point['longitude'],
                          ));
                        }
                      }
                      await _addBuyerMarker(orderBuyerId, routeCoordinates.last);
                    }
                  }
                }
              }
            }
          }
        }
      });
    }
  }

  // Add a marker for the buyer's last location in the route
  Future<void> _addBuyerMarker(String buyerId, LatLng position) async {
    BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(67, 67)),
      'assets/images/home.png',
    );

    MarkerId markerId = MarkerId(buyerId);
    Marker marker = Marker(
      markerId: markerId,
      position: position,
      icon: markerIcon,
      infoWindow: InfoWindow(title: "Buyer: $buyerId"),
    );

    setState(() {
      buyerMarkers[markerId] = marker;
    });
  }

  // Create a polyline based on real routes between seller and buyers
  Polyline _createPolyline() {
    return Polyline(
      polylineId: const PolylineId("route"),
      points: [sellerLocation!, ...routeCoordinates],
      color: Colors.blue,
      width: 4,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buyer Route'),
      ),
      body: isLocationLoaded && routeCoordinates.isNotEmpty
          ? GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: sellerLocation!, // Start at the seller's current location
          zoom: 14.0,
        ),
        markers: Set<Marker>.of(buyerMarkers.values),
        polylines: {_createPolyline()},
      )
          : const Center(child: CircularProgressIndicator()), // Show loading until data is fetched
    );
  }
}
*/