import 'dart:async';
import 'dart:collection';
import 'dart:math' show cos, asin, sqrt;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttershuttle/providers/authenticate.dart';
import 'package:fluttershuttle/providers/database.dart';
import 'package:fluttershuttle/screens/MapScreens/previewScreen.dart';
import 'package:fluttershuttle/widgets/main_drawer.dart';

import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';

import '../AuthScreens/login.dart';

class DriverMapScreen extends StatefulWidget {
  String driverName;

  DriverMapScreen({this.driverName});
  static const routeName = '/mapscreen';

  @override
  _DriverMapScreenState createState() => _DriverMapScreenState(driverName);
}

class _DriverMapScreenState extends State<DriverMapScreen> {
  String _driverName;

  _DriverMapScreenState(this._driverName);

  Set<Marker> _markers = HashSet<Marker>();
  Set<Circle> _circle = HashSet<Circle>();
  Set<Polygon> _polygons = HashSet<Polygon>();

  MapType _currentMapType = MapType.normal;

  DatabaseMethods databaseMethods = DatabaseMethods();

  LatLng _initialPosition = LatLng(6.671206, 3.158301);
  LatLng currentPosition;
  bool isSwitched = false;
  String shuttleType;
  GoogleMapController _mapController;
  bool isViewed = false;

  void _setPolygons() {
    List<LatLng> polygonLatLongs = List<LatLng>();
    polygonLatLongs.add(LatLng(6.672595, 3.151276));
    polygonLatLongs.add(LatLng(6.667549, 3.153160));
    polygonLatLongs.add(LatLng(6.667208, 3.155820));
    polygonLatLongs.add(LatLng(6.665162, 3.155605));
    polygonLatLongs.add(LatLng(6.663712, 3.161869));
    polygonLatLongs.add(LatLng(6.664480, 3.166031));
    polygonLatLongs.add(LatLng(6.665247, 3.166014));
    polygonLatLongs.add(LatLng(6.666099, 3.164973));
    polygonLatLongs.add(LatLng(6.667346, 3.163118));
    polygonLatLongs.add(LatLng(6.670984, 3.163353));
    polygonLatLongs.add(LatLng(6.678610, 3.162515));
    polygonLatLongs.add(LatLng(6.678418, 3.160263));
    polygonLatLongs.add(LatLng(6.675093, 3.160177));
    polygonLatLongs.add(
      LatLng(
        6.674624,
        3.157898,
      ),
    );

    _polygons.add(
      Polygon(
        polygonId: PolygonId("Covenant Map"),
        points: polygonLatLongs,
        fillColor: Colors.transparent,
        strokeColor: Colors.purple,
        strokeWidth: 1,
        visible: false,
      ),
    );
  }

  DatabaseMethods _databaseMethods = DatabaseMethods();
  String userId;

  _getDriverCategory() async {
    final FirebaseUser user = await _auth.currentUser();

    final uid = user.uid;

    userId = uid;
    _databaseMethods.getDriversById(uid).then((result) async {
      shuttleType = await result['ShuttleType'];
    });
  }

  void _onCameraMove(CameraPosition position) {
    currentPosition = position.target;
  }

  void _onMapTypeButtonPressed() {
    setState(
      () {
        _currentMapType = _currentMapType == MapType.normal
            ? MapType.satellite
            : MapType.normal;
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
    });
  }

  StreamSubscription _listener;

  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load('assets/images/car_icon.png');
    return byteData.buffer.asUint8List();
  }

  int count;
  var someData;
  QuerySnapshot querySnapshot;

  _notificationBadge() async {
    if (_listener != null) {
      _listener.cancel();
    }
    _listener = Firestore.instance
        .collection('pickUpRequest')
        .snapshots()
        .listen((event) {
      querySnapshot = event;
      count = event.documents.length;
      print(count);
    });
  }

  Set<Polyline> polylines = Set<Polyline>();

  String googleAPIKey = 'AIzaSyCTIRKgbnHsa_nWRcC_-4kPsFqYlSEuzlA';

  _createPolylines(LocationData start, GeoPoint destination, String iD) async {
    PolylinePoints polylinePoints = PolylinePoints();

    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints?.getRouteBetweenCoordinates(
        googleAPIKey,
        PointLatLng(start.latitude, start.longitude),
        PointLatLng(destination.latitude, destination.longitude),
        travelMode: TravelMode.driving);

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(
          point.latitude,
          point.longitude,
        ));
      });
    }

    PolylineId id = PolylineId(iD);

    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.purple,
      points: polylineCoordinates,
      width: 5,
      visible: true,
    );

    polylines.add(polyline);
  }

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Map<String, int> timeData = {};
  _calculateDistance(
    LocationData locationData,
    GeoPoint geoPoint,
    String place,
  ) async {
    double totalDistance = 0.0;
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;

    totalDistance += _coordinateDistance(
      locationData.latitude,
      locationData.longitude,
      geoPoint.latitude,
      geoPoint.longitude,
    );
    int timeToShow;
    double speed = (locationData.speed * 3.6);
    double time = ((totalDistance / speed) * 60);
    time.isInfinite ? timeToShow = 0 : timeToShow = time.round();
    timeData.update(
      '$place',
      (value) => timeToShow,
      ifAbsent: () => timeToShow,
    );
    await databaseMethods.updateEstimatedTime(timeData, uid);
  }

  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  LocationData newLocationData;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _getCurrentLocation() async {
    try {
      currentPosition = _initialPosition;

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }
      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocalData) async {
        if (_mapController != null) {
          currentPosition =
              LatLng(newLocalData.latitude, newLocalData.longitude);
          _mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              new CameraPosition(
                  bearing: 192.8334901395799,
                  target: currentPosition,
                  tilt: 0,
                  zoom: 18.00),
            ),
          );
          final FirebaseUser user = await _auth.currentUser();
          final uid = user.uid;
          Firestore.instance.collection('busStops').snapshots().listen((value) {
            if (value.documents.isNotEmpty) {
              for (int i = 0; i < value.documents.length; ++i) {
                _createPolylines(
                  newLocalData,
                  value.documents[i].data['coordinates'],
                  value.documents[i].data['busStop'],
                );
                _calculateDistance(
                  newLocalData,
                  value.documents[i].data['coordinates'],
                  value.documents[i].data['busStop'],
                );
              }
            }
          });

          setState(() {
            _markers.add(
              Marker(
                markerId: MarkerId('My Location'),
                position: LatLng(
                  newLocalData.latitude,
                  newLocalData.longitude,
                ),
                icon: BitmapDescriptor.defaultMarker,
              ),
            );

            Map<String, dynamic> userLocationData = {};
            newLocationData = newLocalData;
            userLocationData.putIfAbsent(
              'latitude',
              () => newLocationData.latitude,
            );
            userLocationData.putIfAbsent(
              'longitude',
              () => newLocationData.longitude,
            );
            userLocationData.putIfAbsent(
              'speed',
              () => newLocationData.speed,
            );
            userLocationData.putIfAbsent(
              'heading',
              () => newLocationData.heading,
            );
            userLocationData.putIfAbsent(
              'time',
              () => newLocationData.time,
            );
            userLocationData.putIfAbsent(
              'speedAccuracy',
              () => newLocationData.speedAccuracy,
            );
            databaseMethods.updateUserLocation(userLocationData, uid);
          });
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    if (_listener != null) {
      _listener.cancel();
    }

    super.dispose();
  }

  @override
  void initState() {
    _getDriverCategory();
    _setPolygons();
    _getCurrentLocation();
    _notificationBadge();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(
        userName: _driverName,
      ),
      appBar: AppBar(
        title: Text('Your Map'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 15.5,
            ),
            markers: _markers,
            circles: _circle,
            polygons: _polygons,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onCameraMove: _onCameraMove,
            mapType: _currentMapType,
            polylines: polylines,
          ),
          Align(
            alignment: Alignment.topRight,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FloatingActionButton(
                    heroTag: null,
                    onPressed: _onMapTypeButtonPressed,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: Colors.green,
                    child: const Icon(
                      Icons.map,
                      size: 35,
                    ),
                  ),
                ),
                const Icon(
                  Icons.add_location,
                  size: 35,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FlatButton(
              onPressed: () {
                databaseMethods.deleteDocument(
                  'timing',
                  userId,
                );
                AuthService().signOut();
                newLocationData = null;
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: Text(
                'Log out',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ),
          if (shuttleType == 'Car')
            Align(
              alignment: Alignment.centerLeft, //bottomCenter,
              child: Stack(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.notifications),
                    onPressed: () {
                      setState(() {
                        isViewed = true;
                      });
                    }, //_showDialog,
                  ),
                  if (count != 0)
                    Positioned(
                      right: 11,
                      top: 11,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  if (isViewed)
                    Align(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Container(
                            child: Card(
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: ListView.builder(
                                    physics: ClampingScrollPhysics(),
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount: querySnapshot.documents.length,
                                    itemBuilder: (context, index) {
                                      return Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.2,
                                          child: Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Text(
                                                  querySnapshot.documents[index]
                                                      .data['Name'],
                                                  style: TextStyle(
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    Text(
                                                      'User Current Location:',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 15,
                                                    ),
                                                    Text(
                                                      querySnapshot
                                                              .documents[index]
                                                              .data[
                                                          'Current Location'],
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    Text(
                                                      'User Request Location:',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 15,
                                                    ),
                                                    Text(
                                                      querySnapshot
                                                          .documents[index]
                                                          .data['Destination'],
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    Text(
                                                      'Phone Number:',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 30,
                                                    ),
                                                    Text(
                                                      querySnapshot
                                                          .documents[index]
                                                          .data['Phone Number'],
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                    child: Center(
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: <Widget>[
                                                          FlatButton(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20)),
                                                            color:
                                                                Colors.purple,
                                                            onPressed: () {
                                                              setState(() {
                                                                isViewed =
                                                                    false;
                                                              });
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          PreviewScreen(
                                                                    place: querySnapshot
                                                                        .documents[
                                                                            index]
                                                                        .data['Destination'],
                                                                    driverLocation:
                                                                        GeoPoint(
                                                                      currentPosition
                                                                          .latitude,
                                                                      currentPosition
                                                                          .longitude,
                                                                    ),
                                                                    requestLocation: querySnapshot
                                                                        .documents[
                                                                            index]
                                                                        .data['Location'],
                                                                    uid: querySnapshot
                                                                        .documents[
                                                                            index]
                                                                        .documentID,
                                                                    driverName:
                                                                        _driverName,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.3,
                                                              child: Text(
                                                                'Preview this Order',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 25,
                                                          ),
                                                          Container(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.08,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.3,
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .black,
                                                                    style: BorderStyle
                                                                        .solid,
                                                                    width: 1.0),
                                                                color: Colors
                                                                    .transparent,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20.0)),
                                                            child: InkWell(
                                                              onTap: () {
                                                                isViewed =
                                                                    false;
                                                              },
                                                              child: Center(
                                                                child: Text(
                                                                  'Go Back',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontFamily:
                                                                          'Montserrat'),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            )
        ],
      ),
    );
  }
}
