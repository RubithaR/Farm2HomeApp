import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:veg/shortest_path/dijkstra.dart';
import 'package:veg/shortest_path/real_path.dart';

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

  Future<void> getPolylinePoints(LatLng current) async {
    PolylinePoints polylinePoints = PolylinePoints();

    LatLng sellerLocation = LatLng(current.latitude, current.longitude);

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: "AIzaSyA9GskZpUFgljTermxTw-HVE3O6g_GtlIc",
      request: PolylineRequest(
        origin: PointLatLng(_currentLocation.latitude, _currentLocation.longitude),
        destination: PointLatLng(sellerLocation.latitude, sellerLocation.longitude),
        mode: TravelMode.driving,
      ),
    );
  }

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
            _addCurrentLocationMarker();
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

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await getCurrentLocation();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _locationFetched = true;
        _addCurrentLocationMarker();
      });
      _updateLocationInFirebase(_currentLocation);
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

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

      _fetchBuyerLocations();
    }
  }

  void _addCurrentLocationMarker() {
    Marker sellerMarker = Marker(
      markerId: const MarkerId('currentLocation'),
      position: _currentLocation,
      draggable: true,
      onDragEnd: (newPosition) {
        _onMarkerDragged(newPosition);
      },
      infoWindow: const InfoWindow(title: 'Your location'),
    );

    setState(() {
      userMarkers[MarkerId('currentLocation')] = sellerMarker;
    });
  }

  void _onMarkerDragged(LatLng newPosition) {
    setState(() {
      _currentLocation = newPosition;
    });
    _updateLocationInFirebase(newPosition);
  }
  //Hi
  void _onMapTap(LatLng tappedPoint) {
    setState(() {
      _currentLocation = tappedPoint;
    });
    _addCurrentLocationMarker();
    _updateLocationInFirebase(tappedPoint);
  }

  Future<void> _saveOrder(String buyerId, List<LatLng> routeCoordinates) async {
    if (uid != null) {
      DatabaseReference ordersRef = FirebaseDatabase.instance.ref().child("paths").child(uid!).child(buyerId);

      Map<String, dynamic> orderDetails = {
        'route': routeCoordinates.map((latLng) => {
          'latitude': latLng.latitude,
          'longitude': latLng.longitude,
        }).toList(),
        'buyerId': buyerId,
        'timestamp': ServerValue.timestamp,
      };

      await ordersRef.set(orderDetails);
      print("Order saved for buyer: $buyerId");
    }
  }

  void _findShortestRouteToAllBuyers() {
    if (uid != null && locationMap.isNotEmpty) {
      List<LatLng> routePoints = [_currentLocation];

      Set<String> unvisitedBuyers = locationMap.keys.toSet();
      LatLng currentLocation = _currentLocation;

      while (unvisitedBuyers.isNotEmpty) {
        String nearestBuyerId = unvisitedBuyers.first;
        double minDistance = _calculateDistance(currentLocation, locationMap[nearestBuyerId]!);

        for (String buyerId in unvisitedBuyers) {
          double distance = _calculateDistance(currentLocation, locationMap[buyerId]!);
          if (distance < minDistance) {
            minDistance = distance;
            nearestBuyerId = buyerId;
          }
        }

        LatLng nearestBuyerLocation = locationMap[nearestBuyerId]!;
        routePoints.add(nearestBuyerLocation);
        currentLocation = nearestBuyerLocation;
        unvisitedBuyers.remove(nearestBuyerId);
        _saveOrder(nearestBuyerId, routePoints);
      }

      _drawPolyline(routePoints);
    }
  }

  void _fetchBuyerLocations() async {
    if (uid != null) {
      ordersRef = FirebaseDatabase.instance.ref().child("final_order");
      ordersRef.onValue.listen((DatabaseEvent event) async {
        if (event.snapshot.exists) {
          Map<dynamic, dynamic>? ordersData = event.snapshot.value as Map<dynamic, dynamic>?;

          if (ordersData != null) {
            setState(() {
              userMarkers.clear();
              _addCurrentLocationMarker();
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
          infoWindow: const InfoWindow(title: 'Buyer'),
        );

        setState(() {
          userMarkers[markerId] = marker;
        });

        return buyerLocation;
      }
    }
    return null;
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const earthRadius = 6371000.0;
    double dLat = _degreesToRadians(end.latitude - start.latitude);
    double dLon = _degreesToRadians(end.longitude - start.longitude);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(start.latitude)) *
            cos(_degreesToRadians(end.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return earthRadius * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _degreesToRadians(double degrees) => degrees * pi / 180;

  void _drawPolyline(List<LatLng> routeCoordinates) {
    setState(() {
      polylineCoordinates.clear();
      polylineCoordinates.addAll(routeCoordinates);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _locationFetched
              ? GoogleMap(
            onTap: _onMapTap,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 14.0,
            ),
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
              : const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
