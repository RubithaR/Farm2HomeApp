import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckLocation extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String sellerName;

  const CheckLocation({super.key, required this.latitude, required this.longitude, required this.sellerName});

  @override
  State<CheckLocation> createState() => _CheckLocationState();
}

class _CheckLocationState extends State<CheckLocation> {
  LatLng _currentLocation = const LatLng(0.0, 0.0);
  bool _locationFetched = false;
  String? uid;
  GoogleMapController? mapController;
  BitmapDescriptor? sellerIcon;
  List<LatLng> _routeCoordinates = [];

  String mapKey = "AIzaSyA9GskZpUFgljTermxTw-HVE3O6g_GtlIc"; // Replace with your Google Maps API key

  @override
  void initState() {
    super.initState();
    _loadSellerIcon();
    _getUserLocationFromDatabase().then((_) {
      if (_locationFetched) {
        getPolylinePoints();
      }
    });
  }

  Future<void> _loadSellerIcon() async {
    sellerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/van_image.png',
    );
    setState(() {});
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
          getPolylinePoints();

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
      });
      _updateLocationInFirebase(_currentLocation);
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

      setState(() {
        _currentLocation = newLocation;
      });
      getPolylinePoints();
    }
  }

  Future<void> getPolylinePoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    LatLng sellerLocation = LatLng(widget.latitude, widget.longitude);

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: "AIzaSyA9GskZpUFgljTermxTw-HVE3O6g_GtlIc", // Replace with your Google Maps API key
      request: PolylineRequest(
        origin: PointLatLng(_currentLocation.latitude, _currentLocation.longitude), // seller's location
        destination: PointLatLng(sellerLocation.latitude, sellerLocation.longitude), // buyer's location
        mode: TravelMode.driving, // Specify travel mode
      ),
    );
    if (result.points.isNotEmpty) {
      _routeCoordinates.clear();
      for (var point in result.points) {
        _routeCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      setState(() {});
      _moveCameraToBounds(sellerLocation);
    } else {
      print("Error fetching polyline: ${result.errorMessage}");
    }
  }

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

  @override
  Widget build(BuildContext context) {
    LatLng sellerLocation = LatLng(widget.latitude, widget.longitude);

    return GestureDetector(
      child: Scaffold(
        body: _locationFetched
            ? GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentLocation,
            zoom: 14,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('buyerLocation'),
              position: _currentLocation,
              draggable: true,
              onDragEnd: (newPosition) {
                _updateLocationInFirebase(newPosition);
              },
              infoWindow: const InfoWindow(title: 'Your location'),
            ),
            Marker(
              markerId: const MarkerId('sellerLocation'),
              position: sellerLocation,
              icon: sellerIcon ?? BitmapDescriptor.defaultMarker,
              infoWindow: InfoWindow(title: widget.sellerName),
            ),
          },
          polylines: {
            Polyline(
              polylineId: const PolylineId("route"),
              color: Colors.blue,
              width: 5,
              points: _routeCoordinates,
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
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
