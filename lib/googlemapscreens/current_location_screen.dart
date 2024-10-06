import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  LatLng _currentLocation = const LatLng(0.0, 0.0);
  bool _locationFetched = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await getCurrentLocation();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _locationFetched = true; // Set to true after fetching location
      });
    } catch (e) {
      // Handle error
      print("Error fetching location: $e");
      // You can show a dialog or message to inform the user about the error
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _locationFetched // Check if location is fetched
          ? GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentLocation,
          zoom: 14,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: _currentLocation,
            infoWindow: const InfoWindow(title: 'You are here'),
          ),
        },
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
      )
          : const Center(child: CircularProgressIndicator()), // Show loading spinner while fetching location
    );
  }
}
