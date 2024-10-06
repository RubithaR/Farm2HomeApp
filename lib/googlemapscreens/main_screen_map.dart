
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
class MapLiveLocation extends StatefulWidget {
  const MapLiveLocation({super.key});

  @override
  State<MapLiveLocation> createState() => _MapLiveLocationState();
}

class _MapLiveLocationState extends State<MapLiveLocation> {


  //getting current location
  Future<Position> getCurrentLocation() async{
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled){
      return Future.error('Location service are disabled');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied){
        return Future.error('Location permissions are denied');
      }
    }
    if(permission == LocationPermission.deniedForever){
      return Future.error('Location permanently denied, we can not request permission');
    }
    return await Geolocator.getCurrentPosition();

 }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Location',
          style: TextStyle(fontSize: 20.0, color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget> [
            const Text('current location of user'
                ,textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                getCurrentLocation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),

              child: const Text("Get Current Location"), // Text can be made constant

                ),

            const SizedBox(height: 20),

          ],
        ),

      ),
    );
  }
}
