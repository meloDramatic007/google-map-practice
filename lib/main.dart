import 'package:flutter/material.dart';
import 'dart:async';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',

      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(23.6850, 90.3563),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(23.6850, 90.3563),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  late CameraPosition myPos;
  bool _isCurPosLoading=false;

  Future<void> _fetchUserLoc()async{

    try{

      setState(() {
        _isCurPosLoading=true;
      });

      Location location = new Location();

      bool _serviceEnabled;
      PermissionStatus _permissionGranted;
      LocationData _locationData;

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      _locationData = await location.getLocation();


      myPos=CameraPosition(
          bearing: 192.8334901395799,
          target: LatLng(_locationData.latitude!, _locationData.longitude!),
          tilt: 59.440717697143555,
          zoom: 19.151926040649414,
      );

      setState(() {
        _isCurPosLoading=false;
      });

      debugPrint('location data :${_locationData.toString()}');
    }catch(e){
      debugPrint('Location error : $e');
    }

  }

  @override
  void initState() {
    _fetchUserLoc();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToMyPos,
        label: _isCurPosLoading ? const Text('Loading...') :const Text('To my position!'),
        icon: const Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> _goToMyPos() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(myPos));
  }
}

