import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttershuttle/providers/database.dart';
import 'package:fluttershuttle/screens/MapScreens/driverMapScreen.dart';
import 'package:fluttershuttle/widgets/main_drawer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PreviewScreen extends StatefulWidget {
  String driverName;
  GeoPoint driverLocation;
  GeoPoint requestLocation;
  String place;
  String uid;
  PreviewScreen(
      {@required this.place,
      @required this.driverLocation,
      @required this.requestLocation,
      @required this.uid,
      @required this.driverName});
  @override
  _PreviewScreenState createState() => _PreviewScreenState(
        driverLocation,
        requestLocation,
        place,
        uid,
        driverName,
      );
}

class _PreviewScreenState extends State<PreviewScreen> {
  GeoPoint driverLocation;
  GeoPoint requestLocation;
  String place;
  String uid;
  bool accepted;
  String _driverName;
  static const api_key = 'AIzaSyCTIRKgbnHsa_nWRcC_-4kPsFqYlSEuzlA';

  _PreviewScreenState(this.driverLocation, this.requestLocation, this.place,
      this.uid, this._driverName);

  GoogleMapController mapController;
  Completer<GoogleMapController> _controller = Completer();
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Set<Marker> _markers = {};
  PolylinePoints polylinePoints;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  DatabaseMethods _databaseMethods = DatabaseMethods();
  LinkedHashMap<String, dynamic> pickUpStatus =
      LinkedHashMap<String, dynamic>();
  Position _currentPosition;

  _getCurrentLocation() async {
    await geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;

        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
    }).catchError((e) {
      print(e);
    });
  }

  _deleteRequest() async {
    _databaseMethods.deleteDocument(
      'pickUpRequest',
      uid,
    );
  }

  _startTime() async {
    var duration = Duration(minutes: 1);
    return Timer(
      duration,
      _deleteRequest,
    );
  }

  _onAcceptRequest(userId) async {
    setState(() {
      GeoPoint _userCurrentLocation = GeoPoint(
        _currentPosition.latitude,
        _currentPosition.longitude,
      );
      accepted = true;
      pickUpStatus.putIfAbsent('Status', () => accepted);
      pickUpStatus.putIfAbsent('DriversLocation', () => _userCurrentLocation);
      _databaseMethods.addPickUpStatusInfo(pickUpStatus, userId);
      _startTime();
    });
  }

  _addMarkers() {
    _markers.add(Marker(
      markerId: MarkerId('Driver'),
      position: LatLng(
        driverLocation.latitude,
        driverLocation.longitude,
      ),
      infoWindow: InfoWindow(
        title: 'CurrentPlace',
      ),
      icon: BitmapDescriptor.defaultMarker,
    ));
    _markers.add(Marker(
      markerId: MarkerId('PickUp'),
      position: LatLng(
        requestLocation.latitude,
        requestLocation.longitude,
      ),
      infoWindow: InfoWindow(
        title: 'Destination',
        snippet: place,
      ),
      icon: BitmapDescriptor.defaultMarker,
    ));
  }

  _createPolylines(GeoPoint start, GeoPoint destination) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      api_key, // Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.transit,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    PolylineId id = PolylineId('Route');

    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 5,
    );

    polylines[id] = polyline;
  }

  void check(CameraUpdate u, GoogleMapController c) async {
    c.animateCamera(u);
    mapController.animateCamera(u);
    LatLngBounds l1 = await c.getVisibleRegion();
    LatLngBounds l2 = await c.getVisibleRegion();
    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90)
      check(u, c);
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _controller.complete(controller);

    LatLngBounds bound = LatLngBounds(
      southwest: LatLng(
        driverLocation.latitude,
        driverLocation.longitude,
      ),
      northeast: LatLng(
        requestLocation.latitude,
        requestLocation.longitude,
      ),
    );

    CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 50);
    this.mapController.animateCamera(u2).then((void v) {
      check(u2, this.mapController);
    });
  }

  void _onCameraMove(CameraPosition position) {
    driverLocation = GeoPoint(
      position.target.latitude,
      position.target.longitude,
    );
  }

  @override
  void initState() {
    accepted = false;
    _createPolylines(driverLocation, requestLocation);
    _addMarkers();
    _getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Preview Tab'),
        backgroundColor: Colors.green,
      ),
      drawer: MainDrawer(
        userName: _driverName,
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                driverLocation.latitude,
                driverLocation.longitude,
              ),
              zoom: 18,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            onMapCreated: _onMapCreated,
            onCameraMove: _onCameraMove,
            polylines: Set<Polyline>.of(polylines.values),
            markers: _markers,
          ),
          if (!accepted)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Container(
                  height: MediaQuery.of(context).size.width * 0.08,
                  width: MediaQuery.of(context).size.width * 0.38,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.black,
                          style: BorderStyle.solid,
                          width: 1.0),
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20.0)),
                  child: FlatButton(
                    onPressed: () {
                      _onAcceptRequest(uid);
                    },
                    child: Text('Accept Request'),
                  ),
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DriverMapScreen(),
                    ),
                  );
                },
                child: Text(
                  'Go Back',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
