import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPage extends StatefulWidget {
  LatLng latLong;
  LocationPage({this.latLong});
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  GoogleMapController _controller;
  LatLng _latLong = LatLng(55.3781, 3.4360);
  CameraPosition _kGooglePlex;
  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(55.3781, 3.4360),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);
  Marker singleMarker;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _kGooglePlex = CameraPosition(
      target: widget.latLong,
      zoom: 10,
    );
    singleMarker = Marker(
      markerId: MarkerId("You"),
      position: widget.latLong,
      infoWindow: InfoWindow(title: "You", snippet: "Snippet"),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final GoogleMap googleMap = GoogleMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: _kGooglePlex,
      markers: {singleMarker},
      mapType: MapType.normal,
      onTap: (LatLng pos) {
        setState(() {
          print(pos.toString());
        });
      },
      onLongPress: (LatLng pos) {
        setState(() {
          print(pos);
        });
      },
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("Location"),
      ),
      body: googleMap,
    );
  }

  void onMapCreated(GoogleMapController controller) async {
    setState(() {
      _controller = controller;
    });
  }
}
