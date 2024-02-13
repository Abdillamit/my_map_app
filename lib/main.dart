import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Basic Map'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late GoogleMapController _controller;
  var mapCenter;
  var _latitude = '';
  var _longitude = '';
  var _altitude = '';
  var _address = '';
  final CameraPosition _icp = const CameraPosition(
    target: LatLng(42.8857327, 74605765),
    zoom: 3,
  );

  Future<void> _updatePosition() async {
    Position pos = await _determinePosition();
    List pm = await placemarkFromCoordinates(pos.latitude, pos.longitude);

    // mapCenter = LatLng(pos.latitude, pos.longitude);
    // var cameraPosition = CameraPosition(
    //   target: mapCenter,
    //   zoom: 15,
    // );
    // _controller.moveCamera(CameraUpdate.newCameraPosition(cameraPosition));
    setState(() {
      _latitude = pos.latitude.toString();
      _longitude = pos.longitude.toString();
      _altitude = pos.altitude.toString();
      _address = pos.speed.toString();

      _address = pm[0].toString();
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disable.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permission are disable.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permission are disable.');
    }
    return await Geolocator.getCurrentPosition();
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Your last know localation is :'),
            Text(
              'Latitude:$_latitude',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'Longitude:$_longitude',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'Altitude:$_altitude',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            //  Text('Speed:' + _speed, style: Theme.of(context).textTheme.headlineSmall,),
            const Text('Addres:'),
            Text(_address)
          ],
        ),
      ),
      // body: Stack(
      //   children: [
      //     GoogleMap(
      //       myLocationButtonEnabled: false,
      //       initialCameraPosition: _icp,
      //       onMapCreated: _onMapCreated,
      //     ),
      //   ],
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: _updatePosition,
        tooltip: "Get GPS position",
        child: const Icon(Icons.change_circle_outlined),
      ),
    );
  }
}
