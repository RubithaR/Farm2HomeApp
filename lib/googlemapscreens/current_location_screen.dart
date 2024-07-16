import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  static const LatLng _pGooglePlex = LatLng(6.825761, 79.870372);
  @override
  Widget build(BuildContext context){
    return const Scaffold(
      body: GoogleMap(initialCameraPosition: CameraPosition(target: _pGooglePlex, zoom: 14,),),
    );
  }
}